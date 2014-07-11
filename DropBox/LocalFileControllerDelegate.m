//
//  LocalFileControllerDelegate.m
//  CodeNavigator
//
//  Created by Guozhen Li on 4/7/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "LocalFileControllerDelegate.h"
#import "Utils.h"

@implementation LocalFileControllerDelegate

@synthesize currentFiles;
@synthesize currentDirectories;
@synthesize currentLocation;
@synthesize localTableView;
@synthesize titleLabel;
@synthesize backButton;
@synthesize refreshButton;

- (id)init
{
    isProjectFolder = YES;
    depth = 0;
    return [super init];
}

- (void)dealloc
{
    
    [self.currentDirectories removeAllObjects];
    [self setCurrentDirectories:nil];
    [self.currentFiles removeAllObjects];
    [self setCurrentFiles:nil];
    [self setCurrentLocation:nil];
    [self setLocalTableView:nil];
    [self setTitleLabel:nil];
    [self setRefreshButton:nil];
    [self setBackButton:nil];
}

-(void) backButtonClicked
{
    if (depth <= 0) {
        return;
    }
    depth--;
    if (depth == 0) {
        isProjectFolder = YES;
        [self.backButton setHidden:YES];
    }
    self.currentLocation = [self.currentLocation stringByDeletingLastPathComponent];
    NSString* title = self.titleLabel.text;
    title = [title stringByDeletingLastPathComponent];
    [self.titleLabel setText:title];
    [self reloadData];
}

-(void) reloadData
{
    if (nil == self.currentDirectories)
    {
        self.currentDirectories = [NSMutableArray array];
    }
    else
    {
        [self.currentDirectories removeAllObjects];
    }
    
    if (nil == self.currentFiles)
    {
        self.currentFiles = [NSMutableArray array];
    }
    else
    {
        [self.currentFiles removeAllObjects];
    }
    
    //Search projects
    NSError *error;
    NSString *projectFolder;
    if (nil == self.currentLocation)
    {
        projectFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/.Projects"];
        self.currentLocation = [NSString stringWithString:projectFolder];
    }
    else
    {
        projectFolder = [NSString stringWithString:self.currentLocation];
    }
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:projectFolder error:&error];
    for (int i=0; i<[contents count]; i++)
    {
//        //Hide hidden files such as .git .DS_Store
//        if ([[[contents objectAtIndex:i] substringToIndex:1] compare:@"."] == NSOrderedSame) {
//            continue;
//        }
        
        NSString *currentPath = [projectFolder stringByAppendingPathComponent:[contents objectAtIndex:i]];
        BOOL isFolder = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:currentPath isDirectory:&isFolder];
        if (YES == isFolder)
        {
            [self.currentDirectories addObject:[contents objectAtIndex:i]];
        }
        else
        {
            if ([[Utils getInstance] isProjectDatabaseFile:[contents objectAtIndex:i]] == YES)
                continue;
            [self.currentFiles addObject:[contents objectAtIndex:i]];
        }
    }
    [self.localTableView reloadData];
}

#pragma tableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedItem;
    
    // For directories
    if (indexPath.row < [self.currentDirectories count])
    {
        selectedItem = [self.currentDirectories objectAtIndex:indexPath.row];
        self.currentLocation = [self.currentLocation stringByAppendingPathComponent:selectedItem];
        
        // Show back button
        NSString* title = self.titleLabel.text;
        title = [title stringByAppendingPathComponent:selectedItem];
        [self.titleLabel setText:title];
        [self.backButton setHidden:NO];
        depth++;
        isProjectFolder = NO;
        [self reloadData];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *itemIdentifier = @"ProjectCell";
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:itemIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:itemIdentifier];
        [cell setValue:itemIdentifier forKey:@"reuseIdentifier"];
    }
    
    if (indexPath.row < [self.currentDirectories count])
    {
        if (isProjectFolder == YES)
        {
            cell.imageView.image = [UIImage imageNamed:@"project.png"];
        }
        else
        {
            cell.imageView.image = [UIImage imageNamed:@"folder.png"];
        }
        cell.textLabel.text = [self.currentDirectories objectAtIndex:indexPath.row];
    }
    else
    {
        NSString* fileName = [self.currentFiles objectAtIndex:indexPath.row-[self.currentDirectories count]];
        NSString* extension = [fileName pathExtension];
        extension = [extension lowercaseString];
        if ([extension compare:@"cc"] == NSOrderedSame) {
            cell.imageView.image = [UIImage imageNamed:@"ccFile.png"];
        }
        else if ([extension compare:@"c"] == NSOrderedSame) {
            cell.imageView.image = [UIImage imageNamed:@"cFile.png"];
        }
        else if ([extension compare:@"cpp"] == NSOrderedSame) {
            cell.imageView.image = [UIImage imageNamed:@"cppFile.png"];
        }
        else if ([extension compare:@"cs"] == NSOrderedSame) {
            cell.imageView.image = [UIImage imageNamed:@"csFile.png"];
        }
        else if ([extension compare:@"h"] == NSOrderedSame) {
            cell.imageView.image = [UIImage imageNamed:@"hFile.png"];
        }
        else if ([extension compare:@"hpp"] == NSOrderedSame) {
            cell.imageView.image = [UIImage imageNamed:@"hppFile.png"];
        }
        else if ([extension compare:@"java"] == NSOrderedSame) {
            cell.imageView.image = [UIImage imageNamed:@"javaFile.png"];
        }
        else if ([extension compare:@"m"] == NSOrderedSame) {
            cell.imageView.image = [UIImage imageNamed:@"mFile.png"];
        }
        else if ([extension compare:@"s"] == NSOrderedSame) {
            cell.imageView.image = [UIImage imageNamed:@"sFile.png"];
        }
        else if ([extension compare:@"mm"] == NSOrderedSame) {
            cell.imageView.image = [UIImage imageNamed:@"mmFile.png"];
        }
        else {
            NSString* name = [[fileName pathComponents] lastObject];
            name = [name lowercaseString];
            if ([name compare:@"makefile"] == NSOrderedSame)
                cell.imageView.image = [UIImage imageNamed:@"mkFile.png"];
            else
                cell.imageView.image = [UIImage imageNamed:@"File.png"];
        }
        
        cell.textLabel.text = fileName;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (nil != self.currentDirectories)
        count += [self.currentDirectories count];
    if (nil != self.currentFiles)
        count += [self.currentFiles count];
    return count;
}

@end
