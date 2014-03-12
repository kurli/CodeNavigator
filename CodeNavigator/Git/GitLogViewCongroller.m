//
//  GitLogViewCongroller.m
//  CodeNavigator
//
//  Created by Guozhen Li on 3/18/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "GitLogViewCongroller.h"
#import "ObjectiveGit.h"
#import "Utils.h"
#import "GitDiffViewController.h"

#define DETAIL_BUTTON_TAG 101
#define AUTHOR_TAG 102
#define DETAIL_TAG 103
#define SUMMARY_TAG 104
#define DATE_TAG 105

#define kCellHeight 120;

@implementation PendingData

@synthesize path;
@synthesize neObj;
@synthesize oldObj;

-(void) dealloc
{
    [self setPath:nil];
    [self setNeObj:nil];
    [self setOldObj:nil];
}

@end

@implementation GitLogViewCongroller

@synthesize repo;
@synthesize commitsArray;
@synthesize tableView = _tableView;
@synthesize diffFileArray;
@synthesize compareContainsPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        selected = -1;
        diffFileArray = [[NSMutableArray alloc] init];
        isLogForProject = NO;
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
    [self setTableView:nil];
    [self.diffFileArray removeAllObjects];
    [self setDiffFileArray:nil];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    //[self setRepo:nil];
    //[self setCommitsArray:nil];
    //[self.pendingDiffTree removeAllObjects];
    //[self setPendingDiffTree:nil];
    [self setTableView:nil];
    //[self.diffFileArray removeAllObjects];
    //[self setDiffFileArray:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!isLogForProject) {
        [self.showMergesBarButton setEnabled:NO];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void) showModualView
{
    if (repo == nil) {
        [[Utils getInstance] alertWithTitle:@"Git" andMessage:@"No Git database found!\n Please upload git database (.git folder) first."];
        return;
    }
    [[Utils getInstance].splitViewController presentViewController:self animated:YES completion:nil];
}

- (IBAction)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark GitWrapper
- (IBAction)showMergesClicked:(id)sender {
    [self.tableView scrollsToTop];
    if ([self.showMergesBarButton.title compare:@"Show Merges"] == NSOrderedSame) {
        self.commitsArray = [self getCommitArray];
        [self.showMergesBarButton setTitle:@"Hide Merges"];
        [self.tableView reloadData];
    } else {
        self.commitsArray = [self commitsArrayWithNoMerge:self.commitsArray];
        [self.showMergesBarButton setTitle:@"Show Merges"];
        [self.tableView reloadData];
    }
}

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
    if ([compareContainsPath length] != 0 && [compareContainsPath compare:project] != NSOrderedSame) {
        compareContainsPath = [compareContainsPath stringByReplacingOccurrencesOfString:[project stringByAppendingString:@"/"] withString:@""];
        [self checkPathSpec];
        isLogForProject = NO;
    } else {
        isLogForProject = YES;
        self.commitsArray = [self getCommitArray];
        self.commitsArray = [self commitsArrayWithNoMerge:self.commitsArray];
    }
}

-(void) checkPathSpec {
    NSArray* commitArray = [self getCommitArray];
    commitArray = [self commitsArrayWithNoMerge:commitArray];
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for (int i=0; i<[commitArray count]; i++) {
        GTCommit* commit = [commitArray objectAtIndex:i];
        NSArray* parents = [commit parents];
        if ([parents count] > 1) {
            continue;
        }
        if ([parents count] == 0) {
            GTTreeEntry* entry;
            BOOL found = NO;
            for (int i=0; i<[commit.tree entryCount]; i++) {
                entry = [[commit tree] entryAtIndex:i];
                NSRange range;
                range = [entry.name rangeOfString:compareContainsPath];
                if (range.location == 0 && range.length == [compareContainsPath length]) {
                    found = YES;
                    break;
                }
            }
            if (found) {
                [result addObject:commit];
            }
            continue;
        }
        NSError* error;
        GTCommit* parent = [parents objectAtIndex:0];
        GTTree* tree1 = commit.tree;
        GTTree* tree2 = parent.tree;
        NSArray* pathspec = [[NSArray alloc] initWithObjects:compareContainsPath, nil];
		NSDictionary *options = @{ GTDiffOptionsPathSpecArrayKey: pathspec};
        GTDiff* diff = [GTDiff diffOldTree:tree1 withNewTree:tree2 inRepository:repo options:options error:&error];
        if (diff.deltaCount > 0) {
            [result addObject:commit];
        }
    }
    self.commitsArray = result;
}

-(NSArray*) getCommitArray {
    GTEnumerator* enumerator = [[GTEnumerator alloc] initWithRepository:repo error:NULL];
    [enumerator resetWithOptions:GTEnumeratorOptionsTimeSort];
    GTReference *headRef = [repo headReferenceWithError:NULL];
    [enumerator pushSHA:headRef.targetSHA error:NULL];
    return [enumerator allObjects];
}

-(NSArray*) commitsArrayWithNoMerge:(NSArray*)commits {
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for (int i=0; i<[commits count]; i++) {
        GTCommit* commit = [commits objectAtIndex:i];
        int parents = git_commit_parentcount(commit.git_commit);
        if (parents <= 1) {
            [result addObject:commit];
        }
    }
    return result;
}

#pragma mark libgit2 related

//typedef void (^GTTreeDiffStatusBlock)(const git_tree_diff_data *ptr, BOOL *stop);
//
//struct gitDiffData {
//    __unsafe_unretained GTTreeDiffStatusBlock block;
//};
//
//int gitTreeDiffCallback(const git_tree_diff_data *ptr, void *data);
//int gitTreeDiffCallback(const git_tree_diff_data *ptr, void *data)
//{
//    struct gitDiffData* diff = data;
//    BOOL stop = NO;
//    diff->block(ptr, &stop);
//    return (stop ? GIT_ERROR : GIT_OK);
//}

//-(void) gitDiff:(GTTree*)old andNewer:(GTTree*)newer andBlock:(GTTreeDiffStatusBlock)block
//{
//    struct gitDiffData diff;
//    diff.block = block;
//    git_diff_list *diffList;
//    git_diff_tree_to_tree(&diffList, old.repository.git_repository, old.git_tree, newer.git_tree, 0);
//
////    git_tree_diff(old.git_tree, newer.git_tree, gitTreeDiffCallback, &diff);
//}

#pragma mark TableView related

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        UIButton* detailButton = (UIButton*)[cell viewWithTag:DETAIL_BUTTON_TAG];
        [summaryView setHidden:NO];
        [detailView setHidden:YES];
        [detailButton setHidden:YES];
        NSString* detail = [NSString stringWithFormat:@"%@", commit.message];
        [summaryView setText:detail];
    }
    selected = indexPath.row;
    
    NSMutableString* fileList = [[NSMutableString alloc] init];
    UITableViewCell *cell2 = [tableView cellForRowAtIndexPath:indexPath];
    UITextView* detailView2 = (UITextView*)[cell2 viewWithTag:DETAIL_TAG];
    UILabel* summaryView2 = (UILabel*)[cell2 viewWithTag:SUMMARY_TAG];
    UIButton* detailButton2 = (UIButton*)[cell2 viewWithTag:DETAIL_BUTTON_TAG];
    [summaryView2 setHidden:NO];
    [detailView2 setHidden:NO];
    [detailButton2 setHidden:NO];
    
    GTCommit* commitCurrent = [self.commitsArray objectAtIndex:selected];
    [summaryView2 setText:[commitCurrent messageSummary]];
    [detailView2 setText:[commitCurrent messageDetails]];

    int parents = git_commit_parentcount(commitCurrent.git_commit);
    if (parents > 1) {
        [detailButton2 setHidden:YES];
        [tableView endUpdates];
        return;
    }
    if (parents == 0) {
        [detailButton2 setHidden:YES];
        [tableView endUpdates];
        return;
    }

    NSMutableArray* pendingDiffTree = [[NSMutableArray alloc] init];

//    GTCommit* commitNext = [self.commitsArray objectAtIndex:selected+1];
    NSArray* parentsArray = [commitCurrent parents];
    GTCommit* commitNext = [parentsArray objectAtIndex:0];
    
    PendingData *pending = [[PendingData alloc] init];
    [pending setNeObj:commitCurrent.tree];
    [pending setOldObj:commitNext.tree];
    [pending setPath:@"/"];
    
    [pendingDiffTree addObject:pending];
    
    [diffFileArray removeAllObjects];
    
    while ([pendingDiffTree count] > 0) {
        GTObject* newObj;
        GTObject* oldObj;
        
        pending = [pendingDiffTree objectAtIndex:0];
        oldObj = pending.oldObj;
        newObj = pending.neObj;
        [pendingDiffTree removeObjectAtIndex:0];
                
        NSError *error;
        GTDiff* diff = [GTDiff diffOldTree:(GTTree*)oldObj withNewTree:(GTTree*)newObj inRepository:repo options:NULL error:&error];
        if (diff == NULL || error != NULL)
        {
            continue;
        }
        [diff enumerateDeltasUsingBlock:^(GTDiffDelta *delta, BOOL *stop){
            NSError *error;
            git_oid new_oid = delta.git_diff_delta.new_file.id;
            git_oid old_oid = delta.git_diff_delta.old_file.id;
            GTOID* new_OID = [[GTOID alloc] initWithGitOid:&new_oid];
            GTOID* old_OID = [[GTOID alloc] initWithGitOid:&old_oid];
            NSString* newPath;
            NSString* oldPath;
            GTObject* newObj1 = [self.repo lookUpObjectByOID:new_OID error:&error];
            if (error == nil) {
                newPath = [NSString stringWithFormat:@"%@%@",pending.path, delta.newFile.path];
            }
            error = nil;
            GTObject* oldObj1 = [self.repo lookUpObjectByOID:old_OID error:&error];
            if (error == nil) {
                oldPath = [NSString stringWithFormat:@"%@%@",pending.path, delta.oldFile.path];
            }
            
//            if ([[newObj1 type] compare:@"tree"] == NSOrderedSame) {
//                path = [NSString stringWithFormat:@"%@%@/", pending.path, path];
//                PendingData *pending = [[PendingData alloc] init];
//                [pending setNeObj:newObj1];
//                [pending setOldObj:oldObj1];
//                [pending setPath:path];
//                [pendingDiffTree addObject:pending];
//                return;
//            }
            PendingData *pending = [[PendingData alloc] init];
            switch (delta.type) {
                case GTDiffFileDeltaAdded:
                    [fileList appendFormat:@"[A] %@\n", newPath];
                    [pending setPath:newPath];
                    break;
                case GTDiffFileDeltaModified:                    
                    [fileList appendFormat:@"[M] %@\n", newPath];
                    [pending setPath:newPath];
                    break;
                case GTDiffFileDeltaDeleted:
                    [fileList appendFormat:@"[D] %@\n", oldPath];
                    [pending setPath:oldPath];
                    break;
                case GIT_DELTA_RENAMED:
                    [fileList appendFormat:@"%@-->%@\n", oldPath, newPath];
                    [pending setPath:newPath];
                    break;
                default:
                    break;
            }
                        
            [pending setNeObj:newObj1];
            [pending setOldObj:oldObj1];
            //add file to array
            [diffFileArray addObject:pending];
        }];
        
//        [self gitDiff:(GTTree*)oldObj andNewer:(GTTree*)newObj andBlock:^(const git_tree_diff_data *ptr, BOOL *stop){
//            NSError* error;
//            GTObject* newObj1 = [self.repo lookupObjectByOid:(git_oid*)(&(ptr->new_oid)) error:&error];
//            if (error != nil) {
//                return;
//            }
//            GTObject* oldObj1 = [self.repo lookupObjectByOid:(git_oid*)(&(ptr->old_oid)) error:&error];
//            if (error != nil) {
//                return;
//            }
//            if (oldObj1 == nil) {
//                oldObj1 = newObj;
//            }
//            if (newObj1 == nil) {
//                newObj1 = oldObj;
//            }
//            if (newObj1 == nil) {
//                return;
//            }
//            NSString* path = [NSString stringWithCString:ptr->path encoding:NSUTF8StringEncoding];
//            
//            if ([[newObj1 type] compare:@"tree"] == NSOrderedSame) {
//                path = [NSString stringWithFormat:@"%@%@/", pending.path, path];
//                PendingData *pending = [[PendingData alloc] init];
//                [pending setNeObj:newObj1];
//                [pending setOldObj:oldObj1];
//                [pending setPath:path];
//                
//                [pendingDiffTree addObject:pending];
//            }
//            else
//            {
//                path = [NSString stringWithFormat:@"%@%@",pending.path, path];
//                git_status_t status = ptr->status;
//                switch (status) {
//                    case GIT_STATUS_ADDED:
//                        [fileList appendFormat:@"[A] %@\n", path];
//                        break;
//                    case GIT_STATUS_DELETED: 
//                        [fileList appendFormat:@"[D] %@\n", path];
//                        break;
//                    case GIT_STATUS_MODIFIED:
//                        [fileList appendFormat:@"[M] %@\n", path];
//                        break;
//                    default:
//                        break;
//                }
//                PendingData *pending = [[PendingData alloc] init];
//                [pending setPath:path];
//                [pending setNeObj:newObj1];
//                [pending setOldObj:oldObj1];
//                //add file to array
//                [diffFileArray addObject:pending];
//            }
//        }];
    }
    NSString* str = [NSString stringWithFormat:@"%@\n%@",detailView2.text, fileList];
    [detailView2 setText:str];
	[tableView endUpdates];
}

-(IBAction)detailButtonClicked:(id)sender
{
    GitDiffViewController* gitDiffView = [[GitDiffViewController alloc] initWithNibName:@"GitDiffViewController" bundle:[NSBundle mainBundle]];
    [gitDiffView setDiffFileArray:diffFileArray];
    [self presentViewController:gitDiffView animated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"commitLogCell";
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"GitLogTableCell" owner:self options:nil] lastObject];
        [cell setValue:identifier forKey:@"reuseIdentifier"];
        UIButton* detailButton = (UIButton*)[cell viewWithTag:DETAIL_BUTTON_TAG];
        [detailButton addTarget:self action:@selector(detailButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    int index = indexPath.row;
    if (index > [self.commitsArray count])
        return cell;
    UIButton* detailButton = (UIButton*)[cell viewWithTag:DETAIL_BUTTON_TAG];
    if (selected == index) {
        [detailButton setHidden:NO];
    } else {
        [detailButton setHidden:YES];
    }
    
    GTCommit* commit = [self.commitsArray objectAtIndex:index];
    
    // set date
    UILabel* dateLabel = (UILabel*)[cell viewWithTag:DATE_TAG];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    NSString *stringFromDate = [formatter stringFromDate:commit.author.time];
    [dateLabel setText:stringFromDate];
    
    // set author
    UILabel* authorLabel = (UILabel*)[cell viewWithTag:AUTHOR_TAG];
    NSString* author = [NSString stringWithFormat:@"Author: %@ <%@>", commit.author.name, commit.author.email];
    [authorLabel setText:author];
    
    UITextView* detailView = (UITextView*)[cell viewWithTag:DETAIL_TAG];
    UILabel* summaryView = (UILabel*)[cell viewWithTag:SUMMARY_TAG];
    
//    if (selected != indexPath.row)
    {
        // set summary
        [summaryView setHidden:NO];
        [detailView setHidden:YES];
        NSString* detail = [NSString stringWithFormat:@"%@", commit.messageSummary];
        [summaryView setText:detail];
    }
//    else
//    {
//        [summaryView setHidden:NO];
//        NSString* detail = [NSString stringWithFormat:@"%@", commit.messageSummary];
//        [summaryView setText:detail];
//        [detailView setHidden:NO];
//        NSMutableString* detail2 = [[NSMutableString alloc] initWithString:@""];
//        GTTreeEntry* entry;
//        for (int i=0; i<[commit.tree entryCount]; i++) {
//            entry = [[commit tree] entryAtIndex:i];
//            [detail2 appendFormat:@"%@\n", entry.name];
//        }
//        [detailView setText:detail2];
//    }
    
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
        return 200;
    return kCellHeight;
}

@end
