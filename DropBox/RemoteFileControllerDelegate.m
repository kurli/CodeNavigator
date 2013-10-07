//
//  RemoteFileControllerDelegate.m
//  CodeNavigator
//
//  Created by Guozhen Li on 4/7/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "RemoteFileControllerDelegate.h"
#import <DropboxSDK/DropboxSDK.h>

@implementation SelectionItem

@synthesize path;
@synthesize fileName;

@end

@implementation RemoteFileControllerDelegate

@synthesize titleLabel;
@synthesize remoteTableView;
@synthesize backButton;
@synthesize restClient;
@synthesize metaData;
@synthesize currentLocation;
@synthesize currentFiles;
@synthesize currentDirectories;
@synthesize remoteIndicator;
@synthesize selectedArray;
@synthesize refreshButton;

- (id)init
{
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
    [self.selectedArray removeAllObjects];
    [self setSelectedArray:nil];
    [self setRemoteTableView:nil];
    [self setTitleLabel:nil];
    [self setRefreshButton:nil];
    [self setBackButton:nil];
    [self setRemoteIndicator:nil];
    [self setRestClient:nil];
    [self setMetaData:nil];
}

- (int) whetherExistInTheSelectionList:(NSString*)fileName andPath:(NSString*)path
{
    // check item is a folder
    if (fileName == nil) {
        for (int i = 0; i<[selectedArray count]; i++) {
            SelectionItem* item = [selectedArray objectAtIndex:i];
            //skip file item
            if (item.fileName != nil) {
                continue;
            }
            
            //path name same
            if ([path compare:item.path] == NSOrderedSame) {
                return i;
            }
            
            // path is in subfolder of item's path, we add it.
            // We do it when receive data, not here
            //            if ([path rangeOfString:item.path].location == 0) {
            //                SelectionItem* item = [[SelectionItem alloc] init];
            //                item.path = path;
            //                item.fileName = fileName;
            //                [selectedArray addObject:item];
            //                return [selectedArray count] -1;
            //            }
        }
        // path not found
        return -1;
    }
    
    //    int foundPathChecked = -1;
    int foundFileExist = -1;
    // check item is a file
    for (int i = 0; i<[selectedArray count]; i++) {
        SelectionItem* item = [selectedArray objectAtIndex:i];
        if (item.fileName != nil && [path compare:item.path] == NSOrderedSame &&
            [fileName compare:item.fileName] == NSOrderedSame) {
            // foreach item is a file, and this item exist
            foundFileExist = i;
            break;
        }
        //        if (item.fileName == nil) {
        //            // foreach item is a path
        //            if ([item.path compare:path] == NSOrderedSame) {
        //                foundPathChecked = i;
        //            }
        //        }
    }
    
    if (foundFileExist != -1) {
        return foundFileExist;
    }
    //    else if (foundPathChecked != -1) {
    //        // This item not exist in the Array, but the path has been selected
    //        SelectionItem* item = [[SelectionItem alloc] init];
    //        item.path = path;
    //        item.fileName = fileName;
    //        [selectedArray addObject:item];
    //        return [selectedArray count] -1;
    //    }
    return -1;
}

- (void) reloadWithMetaData:(id)_metaData
{
    if (_metaData == nil) {
        [self.remoteIndicator stopAnimating];
        [self.remoteIndicator setHidden:YES];
        [self.refreshButton setHidden:NO];
        [self.refreshButton setImage:[UIImage imageNamed:@"refresh_error.png"] forState:UIControlStateNormal];
        return;
    }
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
    self.metaData = _metaData;
    int currentFolderSelected = [self whetherExistInTheSelectionList:nil andPath:self.currentLocation];
    for (DBMetadata* child in metaData.contents) {
        if (child.isDirectory) {
            [self.currentDirectories addObject:child.filename];
            if (currentFolderSelected != -1) {
                NSString* path = [self.currentLocation stringByAppendingPathComponent:child.filename];
                int index = [self whetherExistInTheSelectionList:nil andPath:path];
                if (index == -1) {
                    SelectionItem* selection = [[SelectionItem alloc] init];
                    selection.path = [NSString stringWithString:path];
                    selection.fileName = nil;
                    [self.selectedArray addObject:selection];
                }
            }
        }
        else {
            [self.currentFiles addObject:child.filename];
            if (currentFolderSelected != -1) {
                NSString* path = self.currentLocation;
                int index = [self whetherExistInTheSelectionList:child.filename andPath:path];
                if (index == -1) {
                    SelectionItem* selection = [[SelectionItem alloc] init];
                    selection.path = [NSString stringWithString:path];
                    selection.fileName = [NSString stringWithString:child.filename];
                    [self.selectedArray addObject:selection];
                }
            }
        }
    }
    [self.remoteTableView reloadData];
    [self.remoteIndicator stopAnimating];
    [self.remoteIndicator setHidden:YES];
    [self.refreshButton setHidden:NO];
    [self.refreshButton setImage:[UIImage imageNamed:@"refresh.png"] forState:UIControlStateNormal];
}

- (void) backButtonClicked
{
    if (depth <= 0) {
        return;
    }
    depth--;
    if (depth == 0) {
        [self.backButton setHidden:YES];
    }
    self.currentLocation = [self.currentLocation stringByDeletingLastPathComponent];
    NSString* title = self.titleLabel.text;
    title = [title stringByDeletingLastPathComponent];
    [self.titleLabel setText:title];
    [self.remoteIndicator startAnimating];
    [self.remoteIndicator setHidden:NO];
    [self.refreshButton setHidden:YES];
    [self.restClient loadMetadata:self.currentLocation];
}

- (void) deleteFolderInArray:(NSString*)path
{
    int count = [selectedArray count];
    for (int i = 0; i<count; i++) {
        SelectionItem* item = [selectedArray objectAtIndex:i];
        NSRange range = [item.path rangeOfString:path];
        if (range.location == 0) {
            if (range.length == [item.path length] || [item.path characterAtIndex:range.length] == '/') {
                [selectedArray removeObjectAtIndex:i];
                i = i-1;
                count --;
            }
        }
    }    
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
        [self.remoteIndicator setHidden:NO];
        [self.remoteIndicator startAnimating];
        [self.refreshButton setHidden:YES];
        [self.restClient loadMetadata:self.currentLocation];
    }
}

- (IBAction)checkBoxButtonClicked:(id)sender
{
    UIButton* checkBox = (UIButton*)sender;
    UIView* superView = [checkBox superview];
    UITableViewCell *cell = (UITableViewCell*)[superView superview];
    
    int index = [self.remoteTableView indexPathForCell:cell].row;
    SelectionItem* selectionItem = [[SelectionItem alloc] init];
        
    if (index < [self.currentDirectories count]) {
        selectionItem.path = [self.currentLocation stringByAppendingPathComponent:[self.currentDirectories objectAtIndex:index]];
        selectionItem.fileName = nil;
    } else {
        index -= [self.currentDirectories count];
        if (index < 0) {
            return;
        }
        if (index >= [self.currentFiles count]) {
            return;
        }
        selectionItem.path = [NSString stringWithString:self.currentLocation];
        selectionItem.fileName = [NSString stringWithString:[self.currentFiles objectAtIndex:index]];
    }
    NSLog(@"selectionItem %@, %@", selectionItem.path, selectionItem.fileName);
    if (selectedArray == nil) {
        selectedArray = [[NSMutableArray alloc] init];
    }
    else {
        index = [self whetherExistInTheSelectionList:selectionItem.fileName andPath:selectionItem.path];
        if (index != -1) {
            // need to unselect
            [checkBox setImage:[UIImage imageNamed:@"checkbox_no.png"] forState:UIControlStateNormal];
            NSLog(@"Remove file: %@ %@", selectionItem.path, selectionItem.fileName);
            [selectedArray removeObjectAtIndex:index];
            if (selectionItem.fileName == nil) {
                // if it's a path
                //we need to unselect all the files&folder in the folder
                [self deleteFolderInArray:selectionItem.path];
                NSLog(@"Delete all in path:%@",selectionItem.path);
            } else {
                // it's a file
                index = [self whetherExistInTheSelectionList:nil andPath:selectionItem.path];
                NSLog(@"Unselect current path %@", selectionItem.path);
                if (index != -1) {
                    [selectedArray removeObjectAtIndex:index];
                }
            }
            //deselect all the upper folder
            NSString* checkPath = selectionItem.path;
            int length = [checkPath length];
            checkPath = [checkPath stringByDeletingLastPathComponent];
            if (length == [checkPath length]) {
                return;
            }
            while (true) {
                NSLog(@"Remove path: %@", checkPath);
                index = [self whetherExistInTheSelectionList:nil andPath:checkPath];
                if (index != -1) {
                    [selectedArray removeObjectAtIndex:index];
                }
                int length = [checkPath length];
                checkPath = [checkPath stringByDeletingLastPathComponent];
                if (length == [checkPath length]) {
                    break;
                }
            }
            
            NSLog(@"NO");
            return;
        }
    }
    NSLog(@"YES");
    [checkBox setImage:[UIImage imageNamed:@"checkbox_yes.png"] forState:UIControlStateNormal];
    [selectedArray addObject:selectionItem];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *itemIdentifier = @"ProjectCell";
    UITableViewCell *cell;
    
    UIButton* checkBox;
    UIImageView* iconImg;
    UILabel* label;
    cell = [tableView dequeueReusableCellWithIdentifier:itemIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SelectionTableCell" owner:self options:nil] lastObject];
        [cell setValue:itemIdentifier forKey:@"reuseIdentifier"];
        checkBox = (UIButton*)[cell viewWithTag:101];
        iconImg = (UIImageView*)[cell viewWithTag:102];
        label = (UILabel*)[cell viewWithTag:103];
        //TODO
        [checkBox addTarget:self action:@selector(checkBoxButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        checkBox = (UIButton*)[cell viewWithTag:101];
        iconImg = (UIImageView*)[cell viewWithTag:102];
        label = (UILabel*)[cell viewWithTag:103];
    }
    [iconImg setHidden:NO];
    [checkBox setHidden:NO];
    
    NSString* fileName;
    NSString* path;
    if (indexPath.row < [self.currentDirectories count])
    {
        if (depth == 0) {
            iconImg.image = [UIImage imageNamed:@"project.png"];
        }
        else {
            iconImg.image = [UIImage imageNamed:@"folder.png"];
        }
        label.text = [self.currentDirectories objectAtIndex:indexPath.row];
        fileName = nil;
        path = [self.currentLocation stringByAppendingPathComponent:[self.currentDirectories objectAtIndex:indexPath.row]];
    }
    else
    {
        fileName = [self.currentFiles objectAtIndex:indexPath.row-[self.currentDirectories count]];
        if (depth == 0) {
            label.text = [NSString stringWithFormat:@"Please upload to a Project (Folder)!--%@", fileName];
            [iconImg setHidden:YES];
            [checkBox setHidden:YES];
        }
        else {
            path = self.currentLocation;
            NSString* extension = [fileName pathExtension];
            extension = [extension lowercaseString];
            if ([extension compare:@"cc"] == NSOrderedSame) {
                iconImg.image = [UIImage imageNamed:@"ccFile.png"];
            }
            else if ([extension compare:@"c"] == NSOrderedSame) {
                iconImg.image = [UIImage imageNamed:@"cFile.png"];
            }
            else if ([extension compare:@"cpp"] == NSOrderedSame) {
                iconImg.image = [UIImage imageNamed:@"cppFile.png"];
            }
            else if ([extension compare:@"cs"] == NSOrderedSame) {
                iconImg.image = [UIImage imageNamed:@"csFile.png"];
            }
            else if ([extension compare:@"h"] == NSOrderedSame) {
                iconImg.image = [UIImage imageNamed:@"hFile.png"];
            }
            else if ([extension compare:@"hpp"] == NSOrderedSame) {
                iconImg.image = [UIImage imageNamed:@"hppFile.png"];
            }
            else if ([extension compare:@"java"] == NSOrderedSame) {
                iconImg.image = [UIImage imageNamed:@"javaFile.png"];
            }
            else if ([extension compare:@"m"] == NSOrderedSame) {
                iconImg.image = [UIImage imageNamed:@"mFile.png"];
            }
            else if ([extension compare:@"s"] == NSOrderedSame) {
                iconImg.image = [UIImage imageNamed:@"sFile.png"];
            }
            else if ([extension compare:@"mm"] == NSOrderedSame) {
                iconImg.image = [UIImage imageNamed:@"mmFile.png"];
            }
            else {
                NSString* name = [[fileName pathComponents] lastObject];
                name = [name lowercaseString];
                if ([name compare:@"makefile"] == NSOrderedSame)
                    iconImg.image = [UIImage imageNamed:@"mkFile.png"];
                else
                    iconImg.image = [UIImage imageNamed:@"File.png"];
            }
            
            label.text = fileName;
        }
    }
    
    //TODO selection support
    int index = [self whetherExistInTheSelectionList:fileName andPath:path];
    if (index != -1) {
        [checkBox setImage:[UIImage imageNamed:@"checkbox_yes.png"] forState:UIControlStateNormal];
        return cell;
    }
    [checkBox setImage:[UIImage imageNamed:@"checkbox_no.png"] forState:UIControlStateNormal];
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
