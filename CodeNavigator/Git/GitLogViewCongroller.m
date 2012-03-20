//
//  GitLogViewCongroller.m
//  CodeNavigator
//
//  Created by Guozhen Li on 3/18/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "GitLogViewCongroller.h"
#import "GTReference.h"
#import "GTRepository.h"
#import "GTIndex.h"
#import "GTIndexEntry.h"
#import "GTCommit.h"
#import "GTTree.h"
#import "GTSignature.h"
#import "GTTreeEntry.h"
#import "Utils.h"

#import "git2.h"

#define DETAIL_BUTTON_TAG 101
#define AUTHOR_TAG 102
#define DETAIL_TAG 103
#define SUMMARY_TAG 104
#define DATE_TAG 105

#define kCellHeight 120;

@implementation GitLogViewCongroller

@synthesize repo;
@synthesize commitsArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        selected = -1;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [self setRepo:nil];
    [self setCommitsArray:nil];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void) showModualView
{
    [[Utils getInstance].splitViewController presentModalViewController:self animated:YES];
}

- (IBAction)backButtonClicked:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark GitWrapper
- (void)gitLogForProject:(NSString *)project
{
    if (project == nil || [project length] == 0)
        return;
    NSString* gitFolder = [project stringByAppendingPathComponent:@".git"];
    NSError *error = nil;
    NSURL *url = [NSURL fileURLWithPath:gitFolder];
    repo = [GTRepository repositoryWithURL:url error:&error];
    
    // enumlate remote names
    //NSArray* array = [repo remoteNames];
    
    //create repository
    //    NSURL *newRepoURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/Projects/objgitsample.git"]];
    //    [GTRepository initializeEmptyRepositoryAtURL:newRepoURL error:&error];
    //    GTRepository *newRepo = [GTRepository repositoryWithURL:newRepoURL error:&error];
    //    newRepo = nil;
    //enumerator = nil;
    
//    [repo setupIndexWithError:&error];
//    NSArray* array = [repo.index entries];
//    GTIndexEntry* entry = [array objectAtIndex:9];

    //commit log
    self.commitsArray = [repo selectCommitsBeginningAtSha:nil error:&error block:^BOOL(GTCommit *commit, BOOL *stop) {
		return YES;
	}];
}

#pragma mark libgit2 related

typedef void (^GTTreeDiffStatusBlock)(const git_tree_diff_data *ptr, BOOL *stop);

struct gitDiffData {
    __unsafe_unretained GTTreeDiffStatusBlock block;
};

int gitTreeDiffCallback(const git_tree_diff_data *ptr, void *data);
int gitTreeDiffCallback(const git_tree_diff_data *ptr, void *data)
{
    struct gitDiffData* diff = data;
    BOOL stop = NO;
    diff->block(ptr, &stop);
    return (stop ? GIT_ERROR : GIT_SUCCESS);
}

-(void) gitDiff:(GTTree*)old andNewer:(GTTree*)newer andBlock:(GTTreeDiffStatusBlock)block
{
    struct gitDiffData diff;
    diff.block = block;
    git_tree_diff(old.git_tree, newer.git_tree, gitTreeDiffCallback, &diff);
}

#pragma mark TableView related

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
		
	[tableView beginUpdates];
    int index = indexPath.row;
    if (index > [self.commitsArray count])
    {
        [tableView endUpdates];
        return;
    }
    if (selected != -1 && selected < [self.commitsArray count])
    {
        GTCommit* commit = [self.commitsArray objectAtIndex:selected];
        NSIndexPath* path = [NSIndexPath indexPathForRow:selected inSection:indexPath.section];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:path];
        UITextView* detailView = (UITextView*)[cell viewWithTag:DETAIL_TAG];
        UILabel* summaryView = (UILabel*)[cell viewWithTag:SUMMARY_TAG];
        [summaryView setHidden:NO];
        [detailView setHidden:YES];
        NSString* detail = [NSString stringWithFormat:@"%@", commit.message];
        [summaryView setText:detail];
    }
    
    selected = indexPath.row;
    UITableViewCell *cell2 = [tableView cellForRowAtIndexPath:indexPath];
    UITextView* detailView2 = (UITextView*)[cell2 viewWithTag:DETAIL_TAG];
    UILabel* summaryView2 = (UILabel*)[cell2 viewWithTag:SUMMARY_TAG];
    [summaryView2 setHidden:YES];
    [detailView2 setHidden:NO];
    
    GTCommit* commitCurrent = [self.commitsArray objectAtIndex:selected];
    GTCommit* commitNext = [self.commitsArray objectAtIndex:selected+1];
    
    [self gitDiff:commitNext.tree andNewer:commitCurrent.tree andBlock:^(const git_tree_diff_data *ptr, BOOL *stop){
        NSString* path = [NSString stringWithCString:ptr->path encoding:[NSString defaultCStringEncoding]];
        path = nil;
    }];
    
	[tableView endUpdates];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"commitLogCell";
    UITableViewCell *cell;
    
    cell = [_tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"GitLogTableCell" owner:self options:nil] lastObject];
    }
    int index = indexPath.row;
    if (index > [self.commitsArray count])
        return cell;
    GTCommit* commit = [self.commitsArray objectAtIndex:index];
    
    // set date
    UILabel* dateLabel = (UILabel*)[cell viewWithTag:DATE_TAG];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    NSString *stringFromDate = [formatter stringFromDate:commit.author.time];
    [dateLabel setText:stringFromDate];
    
    // set author
    UILabel* authorLabel = (UILabel*)[cell viewWithTag:AUTHOR_TAG];
    NSString* author = [NSString stringWithFormat:@"Author: %@ (%@)", commit.author.name, commit.author.email];
    [authorLabel setText:author];
    
    UITextView* detailView = (UITextView*)[cell viewWithTag:DETAIL_TAG];
    UILabel* summaryView = (UILabel*)[cell viewWithTag:SUMMARY_TAG];
    if (selected != indexPath.row)
    {
        // set summary
        [summaryView setHidden:NO];
        [detailView setHidden:YES];
        NSString* detail = [NSString stringWithFormat:@"%@", commit.messageSummary];
        [summaryView setText:detail];
    }
    else
    {
        [summaryView setHidden:YES];
        [detailView setHidden:NO];
        NSMutableString* detail2 = [[NSMutableString alloc] initWithString:@""];
        GTTreeEntry* entry;
        for (int i=0; i<[commit.tree numberOfEntries]; i++) {
            entry = [[commit tree] entryAtIndex:i];
            [detail2 appendFormat:@"%@\n", entry.name];
        }
        [detailView setText:detail2];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.commitsArray count];
}

- (GLfloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == selected)
        return 150;
    return kCellHeight;
}

@end
