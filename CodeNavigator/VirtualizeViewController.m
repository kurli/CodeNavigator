//
//  VirtualizeViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 2/4/12.
//  Copyright (c) 2012 Siemens Corporate Research. All rights reserved.
//

#import "VirtualizeViewController.h"
#import "VirtualizeWrapper.h"
#import "Utils.h"
#import "DetailViewController.h"
#import "FileManagerController.h"
#import "ProjectListController.h"
#import "MasterViewController.h"
#import "ImagePreviewController.h"

@implementation VirtualizeViewController
@synthesize imageView;
@synthesize scrollView;
@synthesize entryFindChildButton;
@synthesize entryFindParentButton;
@synthesize entryDeleteButton;
@synthesize entryConnectButton;
@synthesize singleFingerTap;
@synthesize longPressGesture;
@synthesize isNeedGetResultFromCscope;
@synthesize tableView;
@synthesize backgroundImageView;
@synthesize showSelectedVirButton;
@synthesize fileManagerController;
@synthesize currentProjectFolder;
@synthesize currentSelectedVirImg;
@synthesize fileName;
@synthesize virtualizeWrapper;
@synthesize imagePreviewController;
@synthesize popOverController;
@synthesize nToolBarButton;
@synthesize xToolBarButton;
@synthesize projectListToolBarButton;
@synthesize saveToolBarButton;
@synthesize trashToolBarButton;
@synthesize fullScreenToolBarButton;
@synthesize nEntryToolBarButton;
@synthesize toolBar;
@synthesize fileManagerToolBarsArray;
@synthesize fsViewToolBarsArray;
@synthesize projectListPopoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        getEntryFromWebView = NO;
        // Custom initialization        
        singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapInImageView:)];
        
        longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressInImageView:)];
                
        viewInitedForEdit = NO;
        isCurrentFileManager = YES;
        
        MasterViewController* masterViewController = nil;
        NSArray* controllers = [[Utils getInstance].splitViewController viewControllers];
        masterViewController = (MasterViewController*)((UINavigationController*)[controllers objectAtIndex:0]).visibleViewController;    
        [self setCurrentProjectFolder:[masterViewController.currentProjectPath copy]];

        self.fileManagerController = [[FileManagerController alloc] init];
        [fileManagerController setCurrentProjectFolder:currentProjectFolder];
        [fileManagerController searchVirtualizeFiles];
        [self.tableView reloadData];
    }
    return self;
}

- (void) initVirShowView
{
    if (viewInitedForEdit)
        return;
    viewInitedForEdit = YES;
    singleFingerTap.numberOfTapsRequired = 1;
    [imageView addGestureRecognizer:singleFingerTap];
    [imageView addGestureRecognizer:longPressGesture];
    //[[Utils getInstance] changeUIViewStyle:self.view];
    [[Utils getInstance] changeUIViewStyle:self.scrollView];  
}

- (void) viewDidLoad
{
    fileManagerToolBarsArray = [NSArray arrayWithObjects:xToolBarButton, projectListToolBarButton, nToolBarButton, trashToolBarButton, nil];
    
    fsViewToolBarsArray = [NSArray arrayWithObjects:xToolBarButton, projectListToolBarButton, saveToolBarButton, nEntryToolBarButton, fullScreenToolBarButton, nil];  
    
    if (isCurrentFileManager == YES)
        [self.toolBar setItems:fileManagerToolBarsArray animated:YES];
    else
        [self.toolBar setItems:fsViewToolBarsArray animated:YES];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [imageView removeGestureRecognizer:singleFingerTap];
    [imageView removeGestureRecognizer:longPressGesture];
    [self setFileManagerToolBarsArray:nil];
    [self setFsViewToolBarsArray:nil];
    [self setCurrentProjectFolder:nil];
    [self setSingleFingerTap:nil];
    [self setLongPressGesture:nil];
    [self setFileManagerController:nil];
    [self setVirtualizeWrapper:nil];
    [self setFileName:nil];
    [self setImageView:nil];
    [self setScrollView:nil];
    [self setEntryFindChildButton:nil];
    [self setEntryFindParentButton:nil];
    [self setEntryDeleteButton:nil];
    [self setTableView:nil];
    [self setBackgroundImageView:nil];
    [self setShowSelectedVirButton:nil];
    [self setImagePreviewController:nil];
    [self setPopOverController:nil];
    [self setNToolBarButton:nil];
    [self setXToolBarButton:nil];
    [self setProjectListToolBarButton:nil];
    [self setSaveToolBarButton:nil];
    [self setTrashToolBarButton:nil];
    [self setNEntryToolBarButton:nil];
    [self setFullScreenToolBarButton:nil];
    [self setProjectListPopoverController:nil];
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [imageView removeGestureRecognizer:singleFingerTap];
    [imageView removeGestureRecognizer:longPressGesture];
    [self setFileManagerToolBarsArray:nil];
    [self setFsViewToolBarsArray:nil];
    [self setCurrentProjectFolder:nil];
    [self setSingleFingerTap:nil];
    [self setLongPressGesture:nil];
    [self setFileManagerController:nil];
    [self setVirtualizeWrapper:nil];
    [self setFileName:nil];
    [self setImageView:nil];
    [self setScrollView:nil];
    [self setEntryFindChildButton:nil];
    [self setEntryFindParentButton:nil];
    [self setEntryDeleteButton:nil];
    [self setTableView:nil];
    [self setBackgroundImageView:nil];
    [self setShowSelectedVirButton:nil];
    [self setImagePreviewController:nil];
    [self setPopOverController:nil];
    [self setNToolBarButton:nil];
    [self setXToolBarButton:nil];
    [self setProjectListToolBarButton:nil];
    [self setSaveToolBarButton:nil];
    [self setTrashToolBarButton:nil];
    [self setFullScreenToolBarButton:nil];
    [self setToolBar:nil];
    [self setEntryConnectButton:nil];
    [self setNEntryToolBarButton:nil];
    [self setProjectListPopoverController:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)projectListClicked:(id)sender {
    UIBarButtonItem* barItem = (UIBarButtonItem*)sender;
    
    if ([projectListPopoverController isPopoverVisible] == YES) {
        [projectListPopoverController dismissPopoverAnimated:YES];
        return;
    }
    
    ProjectListController* projectListController = [[ProjectListController alloc] init];
    [projectListController setViewController:self];
    
    if (currentProjectFolder == nil)
    {
        MasterViewController* masterViewController = nil;
        NSArray* controllers = [[Utils getInstance].splitViewController viewControllers];
        masterViewController = (MasterViewController*)((UINavigationController*)[controllers objectAtIndex:0]).visibleViewController;    
        NSString* currentProject = [masterViewController.currentProjectPath lastPathComponent];
        [projectListController setCurrentProject:currentProject];
        [self setCurrentProjectFolder:[masterViewController.currentProjectPath copy]];
    }

    [projectListController setCurrentProject:[currentProjectFolder lastPathComponent]];
    
    self.projectListPopoverController = [[UIPopoverController alloc] initWithContentViewController:projectListController];
    projectListPopoverController.popoverContentSize = projectListController.view.frame.size;

    [projectListPopoverController presentPopoverFromBarButtonItem:barItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (IBAction)deleteButtonClicked:(id)sender {
    [projectListPopoverController dismissPopoverAnimated:YES];
    if (self.currentSelectedVirImg == nil)
        return;
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"CodeNavigator" message:@"Would you like to delete this file?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [myAlertView show];
    alertType = ALERT_DELETE;
}

- (BOOL) isGetEntryFromWebView
{
    return getEntryFromWebView;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertType == ALERT_NEW_FILE)
    {
        if (buttonIndex == 1)
        {
            UITextField* textField;
            if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                textField = [alertView textFieldAtIndex:0];
            } else {
                textField = (UITextField*)[alertView viewWithTag:123];
            }
            NSString* str = textField.text;
            
            //New button clicked
            // if in FileManager mode
            if (isCurrentFileManager == YES)
            {
                // if no project selected
                if (self.fileManagerController.currentProjectFolder == nil ||
                    [self.fileManagerController.currentProjectFolder length] == 0)
                {
                    [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please choose a project first"];
                    return;
                }
                NSString* path = [self.fileManagerController.currentProjectFolder stringByAppendingPathComponent:str];
                [self setCurrentSelectedVirImg:[path stringByAppendingPathExtension:@"lgz_vir_img"]];
                [self hideFileManagerAndShowEditView];
                getEntryFromWebView = YES;
                [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please select a function in the source view"];   
            }
            else
            {
                //we are currently in edit view
                NSString* path = [self.fileManagerController.currentProjectFolder stringByAppendingPathComponent:str];
                [self setCurrentSelectedVirImg:[path stringByAppendingPathExtension:@"lgz_vir_img"]];
                [self setVirtualizeWrapper:nil];
                self.virtualizeWrapper = [[VirtualizeWrapper alloc] init];
                [self.virtualizeWrapper setImageView:imageView];
                [self.virtualizeWrapper setScrollView:scrollView];
                [self.virtualizeWrapper setViewController:self];
                [self.virtualizeWrapper setFilePath:[self.currentSelectedVirImg stringByDeletingPathExtension]];
                [self.virtualizeWrapper openFile];
                getEntryFromWebView = YES;
                [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please select a function in the source view"];
            }
        }
    }
    else if (alertType == ALERT_DELETE)
    {
        if (buttonIndex == 1)
        {
            NSError *error;
            NSString* path = [self.currentSelectedVirImg stringByDeletingPathExtension];
            NSString* virData = [path stringByAppendingPathExtension:@"lgz_virtualize"];
            NSString* virImg = [path stringByAppendingPathExtension:@"lgz_vir_img"];
            [[NSFileManager defaultManager] removeItemAtPath:virData error:&error];
            [[NSFileManager defaultManager] removeItemAtPath:virImg error:&error];
            [self.fileManagerController searchVirtualizeFiles];
            [self.tableView reloadData];
            if (isCurrentFileManager == YES)
            {
                [self.fileManagerController clearScreen];
            }
            else
            {
                [self hideEditViewAndshowFileManager];
                isCurrentFileManager = YES;
            }
        }
    }
    else if (alertType == ALERT_SAVE)
    {
        if (buttonIndex == 1)
        {
            [self.virtualizeWrapper saveToFile];
        }
        [self hideEditViewAndshowFileManager];
    }
}

- (IBAction)newButtonClicked:(id)sender {
    [projectListPopoverController dismissPopoverAnimated:YES];
    if (isCurrentFileManager == NO)
    {
        if ([self.virtualizeWrapper isDirty] == YES)
        {
            [self saveCurrentFileConfirm];
            return;
        }
    }
    
    if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Please enter name!" message:@"\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        myAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [myAlertView show];
    } else {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Please enter name!" message:@"\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 60.0, 260.0, 25.0)];
        [myTextField setBackgroundColor:[UIColor whiteColor]];
        [myTextField setTag:123];
        [myAlertView addSubview:myTextField];
        [myAlertView show];
    }
    alertType = ALERT_NEW_FILE;
}

- (void) addEntry:(NSString *)entry andFile:(NSString*)file andLine:(int)line andProject:(NSString *)project
{
    if (isCurrentFileManager == YES)
        return;
//    UIBarButtonItem* button = [Utils getInstance].detailViewController.virtualizeButton;
//    [[Utils getInstance].detailViewController virtualizeButtonClicked:button];
    [[Utils getInstance].detailViewController.popoverController dismissPopoverAnimated:NO];
    getEntryFromWebView = NO;
//    NSString* path = [project stringByAppendingPathComponent:fileName];
//    path = [path stringByAppendingPathExtension:@"lgz_virtualize"];

    [self.virtualizeWrapper addEntry:entry andFile:file andLine:line];
}

- (IBAction)maxButtonClicked:(id)sender {
    if (isCurrentFileManager == YES)
        return;
    self.imagePreviewController = [[ImagePreviewController alloc] init];
    [self.imagePreviewController setViewController:self];
    self.popOverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePreviewController];
    CGSize size = self.imagePreviewController.view.frame.size;
    self.popOverController.popoverContentSize = size;
    [self.popOverController presentPopoverFromBarButtonItem:[Utils getInstance].detailViewController.virtualizeButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)cloceImgPreview
{
    [self.popOverController dismissPopoverAnimated:YES];
    [self setPopOverController:nil];
    [self setImagePreviewController:nil];
}

- (IBAction)closeButtonClicked:(id)sender {
    [projectListPopoverController dismissPopoverAnimated:YES];
    if (isCurrentFileManager == YES)
        [[Utils getInstance].detailViewController hideVirtualizeView];
    else
    {
        if ([self.virtualizeWrapper isDirty] == NO)
            [[Utils getInstance].detailViewController hideVirtualizeView];
        else
        {
            [self saveCurrentFileConfirm];
        }
    }
}

- (IBAction)showSelectedVirImgClicked:(id)sender {
    [projectListPopoverController dismissPopoverAnimated:YES];
    if (self.currentSelectedVirImg == nil)
        return;
    isCurrentFileManager = NO;
    [self hideFileManagerAndShowEditView];
}

- (IBAction)newEntryButtonClicked:(id)sender {
    if (isCurrentFileManager == YES)
        return;
    if (virtualizeWrapper.entryHead == nil)
        return;
    [virtualizeWrapper addEmptyEntry];
}

- (void) hideFileManagerAndShowEditView
{
    [UIView beginAnimations:@"hideFileManager"context:nil];         
    [UIView setAnimationDuration:0.30];           
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hideFileManagerAnimationFinished:)];

    CGRect scrollViewRect = self.scrollView.frame;
    CGRect tableViewRect = self.tableView.frame;
    CGRect backgroundViewRect = self.backgroundImageView.frame;
    
    [self.showSelectedVirButton setHidden:YES];
    
    scrollViewRect.origin.y += scrollViewRect.size.height;
    tableViewRect.origin.y += tableViewRect.size.height;
    backgroundViewRect.origin.y += backgroundViewRect.size.height;

    [self.scrollView setFrame:scrollViewRect];
    [self.tableView setFrame:tableViewRect];
    [self.backgroundImageView setFrame:backgroundViewRect];
    [UIView commitAnimations];
}

- (void) hideFileManagerAnimationFinished:(id)sender
{
    if (self.virtualizeWrapper == nil)
    {
        self.virtualizeWrapper = [[VirtualizeWrapper alloc] init];
        [self.virtualizeWrapper setImageView:imageView];
        [self.virtualizeWrapper setScrollView:scrollView];
        [self.virtualizeWrapper setViewController:self];
    }
    [self.virtualizeWrapper setFilePath:[self.currentSelectedVirImg stringByDeletingPathExtension]];
    [self.virtualizeWrapper openFile];
    
    [self.tableView setHidden:YES];
    [self.backgroundImageView setHidden:YES];
    
    [UIView beginAnimations:@"showVirEditView"context:nil];         
    [UIView setAnimationDuration:0.30];           
    [UIView setAnimationDelegate:self];
    CGRect scrollViewRect = self.scrollView.frame;
    
    scrollViewRect.origin.y = 44;
    [self.scrollView setFrame:scrollViewRect];
    [UIView commitAnimations];
    [self initVirShowView];
    isCurrentFileManager = NO;
    [self.toolBar setItems:fsViewToolBarsArray animated:YES];
}

- (void) hideEditViewAndshowFileManager
{
    [self.tableView setHidden:NO];
    [self.backgroundImageView setHidden:NO];
    [self.showSelectedVirButton setHidden:NO];
    
    [UIView beginAnimations:@"showFileManager"context:nil];         
    [UIView setAnimationDuration:0.30];           
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hideEditViewAnimationFinished:)];
    CGRect scrollViewRect = self.scrollView.frame;

    scrollViewRect.origin.y += scrollViewRect.size.height;

    [self.scrollView setFrame:scrollViewRect];
    [UIView commitAnimations];
    
    [self.virtualizeWrapper deselectHighlighted:self.virtualizeWrapper.currentEntry];
    [self hideEntryButtons];
    [self.virtualizeWrapper setCurrentEntry:nil];
}

- (void) hideEditViewAnimationFinished:(id)sender
{    
    [UIView beginAnimations:@"showFileManager2"context:nil];         
    [UIView setAnimationDuration:0.30];           
    [UIView setAnimationDelegate:self];
    CGRect scrollViewRect = self.scrollView.frame;
    CGRect tableViewRect = self.tableView.frame;
    CGRect backgroundViewRect = self.backgroundImageView.frame;
    
    scrollViewRect.origin.y = 44;
    tableViewRect.origin.y = 54;
    backgroundViewRect.origin.y = 44;

    [self.scrollView setFrame:scrollViewRect];
    [self.tableView setFrame:tableViewRect];
    [self.backgroundImageView setFrame:backgroundViewRect];
    [UIView commitAnimations];
    
    viewInitedForEdit = NO;
    [imageView removeGestureRecognizer:singleFingerTap];
    [imageView removeGestureRecognizer:longPressGesture];
    [self.scrollView setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
    [self.fileManagerController clearScreen];
    [self setVirtualizeWrapper:nil];
    isCurrentFileManager = YES;
    [self.fileManagerController searchVirtualizeFiles];
    [self.tableView reloadData];
    [self.toolBar setItems:fileManagerToolBarsArray animated:YES];
}

- (void)handleSingleTapInImageView:(UIGestureRecognizer*)sender
{
    CGPoint point = [sender locationInView:imageView];
    [self.virtualizeWrapper touchEvent:point];
}

- (void) handleLongPressInImageView:(UIGestureRecognizer *)sender
{
    if (isCurrentFileManager == YES)
        return;
    
    CGPoint point = [sender locationInView:imageView];
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        [self.virtualizeWrapper dragStart:point];
    }
    else if (sender.state == UIGestureRecognizerStateChanged)
    {
        [virtualizeWrapper handleDragEvent:point];
    }
    else if (sender.state == UIGestureRecognizerStateCancelled ||
             sender.state == UIGestureRecognizerStateEnded ||
             sender.state == UIGestureRecognizerStateFailed)
    {
        [self.virtualizeWrapper dragEnd:point];
    }
}

- (IBAction)entryFindChildClicked:(id)sender {
    Entry* entry = virtualizeWrapper.currentEntry;
    if (entry == nil)
    {
        NSLog(@"ERROR: currentEntry is NIL when entryFindChildClicked");
        return;
    }
    if (entry.entryName == nil)
        return;
    NSString* name = entry.entryName;
    NSString* project = [[Utils getInstance] getProjectFolder:entry.filePath];
    NSString* sourcePath = [[Utils getInstance] getPathFromProject:entry.filePath];
    [virtualizeWrapper setNewEntryType:NEW_ENTRY_CHILD];
    [self setIsNeedGetResultFromCscope:YES];
    if (project == nil)
    {
        project = [[Utils getInstance] getProjectFolder:virtualizeWrapper.filePath];
        sourcePath = nil;
    }
    [[Utils getInstance] cscopeSearch:name andPath:sourcePath andProject:project andType:FIND_CALLED_FUNCTIONS andFromVir:YES];
}

- (IBAction)entryDeleteButtonClicked:(id)sender {
    [self.virtualizeWrapper deleteCurrentEntry];
}

- (IBAction)entryConnectClicked:(id)sender {
    Entry* entry = virtualizeWrapper.currentEntry;
    if (entry == nil)
    {
        NSLog(@"ERROR: currentEntry is NIL when entryConnectChildClicked");
        return;
    }
    getEntryFromWebView = YES;
    [self.virtualizeWrapper setIsNeedGetDefinition:YES];
    [[Utils getInstance] alertWithTitle:@"CodeNavigator" andMessage:@"Please select a function in the source view"];  
}

- (IBAction)childDragStart:(id)sender {
}

- (IBAction)childDragEnd:(id)sender {
    Entry* entry = [virtualizeWrapper checkInChild:panPoint];
    [virtualizeWrapper manuallyAddChild:entry];
}

- (IBAction)saveButtonClicked:(id)sender {
    if (isCurrentFileManager == NO)
        [virtualizeWrapper saveToFile];
}

- (IBAction)entryFindParentClicked:(id)sender {
    Entry* entry = virtualizeWrapper.currentEntry;
    if (entry == nil)
    {
        NSLog(@"ERROR: currentEntry is NIL when entryFindChildClicked");
        return;
    }
    if (entry.entryName == nil)
        return;
    NSString* name = entry.entryName;
    NSString* project = [[Utils getInstance] getProjectFolder:entry.filePath];
    [virtualizeWrapper setNewEntryType:NEW_ENTRY_PARENT];
    [self setIsNeedGetResultFromCscope:YES];
    if (project == nil)
    {
        project = [[Utils getInstance] getProjectFolder:virtualizeWrapper.filePath];
    }
    [[Utils getInstance] cscopeSearch:name andPath:entry.filePath andProject:project andType:FIND_F_CALL_THIS_F andFromVir:YES];
}

- (void) showEntryButtons:(CGPoint)point
{
    point.x = point.x - scrollView.contentInset.left;
    point.y = point.y - scrollView.contentInset.bottom;
    CGRect rect = entryFindChildButton.frame;
    //find child button
    rect.origin.x = point.x+ENTRY_WIDTH;
    rect.origin.y = point.y+(ENTRY_HEIGHT-rect.size.height)/2;
    entryFindChildButton.frame = rect;
    [entryFindChildButton setHidden:NO];
    
    // find parent button
    rect = entryFindParentButton.frame;
    rect.origin.x = point.x-rect.size.width;
    rect.origin.y = point.y+(ENTRY_HEIGHT-rect.size.height)/2;
    [entryFindParentButton setFrame:rect];
    [entryFindParentButton setHidden:NO];
    
    // delete button
    rect = entryDeleteButton.frame;
    rect.origin.x = point.x+ENTRY_WIDTH-rect.size.width;
    rect.origin.y = point.y-rect.size.height;
    [entryDeleteButton setFrame:rect];
    [entryDeleteButton setHidden:NO];
    
    // connect button
    rect = entryFindChildButton.frame;
    rect.origin.x -= (entryConnectButton.frame.size.width+5);
    [entryConnectButton setFrame:rect];
    [entryConnectButton setHidden:NO];
}

- (void) hideEntryButtons
{
    [entryFindParentButton setHidden:YES];
    [entryFindChildButton setHidden:YES];
    [entryDeleteButton setHidden:YES];
    [entryConnectButton setHidden:YES];
}

- (void) setNeedhighlightChildKeyword:(BOOL)b
{
    [self.virtualizeWrapper setNeedhighlightChildKeyword:b];
}

- (BOOL) isNeedHighlightChildKeyword
{
    return [self.virtualizeWrapper isNeedHighlightChildKeyword];
}

- (void) highlightAllChildrenKeyword
{
    [self.virtualizeWrapper highlightAllChildrenKeyword];
}

- (BOOL) checkWhetherExistInCurrentEntry:(NSString *)name andLine:(NSString*)line
{
    return [self.virtualizeWrapper checkWhetherExistInCurrentEntry:name andLine:line];
}

- (void) saveCurrentFileConfirm
{
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"CodeNavigator" message:@"File has been modified, Would you like to save current file?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [myAlertView show];
    alertType = ALERT_SAVE;
}

- (void) displayVirtualizeFilesInProject:(NSString *)project
{
    [self.projectListPopoverController dismissPopoverAnimated:YES];
    
    NSString* projectFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Projects"];
    [self setCurrentProjectFolder:[projectFolder stringByAppendingPathComponent:project]];
    
    [fileManagerController setCurrentProjectFolder:currentProjectFolder];
    [fileManagerController searchVirtualizeFiles];
    [self.tableView reloadData];
    if (isCurrentFileManager == NO)
    {
        if ([self.virtualizeWrapper isDirty] == YES)
        {
            [self saveCurrentFileConfirm];
        }
        else
        {
            [self hideEditViewAndshowFileManager];
        }
    }
    isCurrentFileManager = YES;
}

#pragma tableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [fileManagerController setViewController:self];
    [fileManagerController setImageView:self.imageView];
    [fileManagerController setScrollView:self.scrollView];
    [self setCurrentSelectedVirImg:[fileManagerController.imagesPathList objectAtIndex:indexPath.row]];

    [self.fileManagerController clearScreen];
    [self.fileManagerController displayImage:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"imageCell";
    UITableViewCell *cell;
    
    cell = [_tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [[[self.fileManagerController.imagesPathList objectAtIndex:indexPath.row] lastPathComponent] stringByDeletingPathExtension];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fileManagerController.imagesPathList count];
}

@end
