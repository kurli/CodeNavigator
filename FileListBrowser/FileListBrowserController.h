//
//  FileListBrowserController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 9/12/13.
//
//

#import <UIKit/UIKit.h>
#import "FileListBrowserProtocol.h"

@interface FileListBrowserController : NSObject <UIAlertViewDelegate>
{
    BOOL isCurrentProjectFolder;
    NSInteger deleteItemId;
    BOOL enableFileInfoButton;
    BOOL isCurrentSearchFileMode;
}

@property (strong, nonatomic) NSMutableArray *currentDirectories;
@property (strong, nonatomic) NSMutableArray *currentFiles;
@property (strong, nonatomic) NSString *currentLocation;
@property (strong, nonatomic) UIAlertView* deleteAlertView;
@property (unsafe_unretained, nonatomic)  UITableView *_tableView;
@property (assign, nonatomic) id< FileListBrowserDelegate > fileListBrowserDelegate;
@property (strong, nonatomic) NSMutableArray* searchFileResultArray;

- (BOOL) getIsCurrentSearchFileMode;
- (NSString*) getDirectoryAtIndex:(NSInteger)index;
- (NSString*) getFileNameAtIndex:(NSInteger)index;
- (NSInteger)getCurrentDirectoriesCount;
- (void) reloadData;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void) setIsCurrentProjectFolder:(BOOL)_isProjectFolder;
- (BOOL) getIsCurrentProjectFolder;
- (void) setEnableFileInfoButton:(BOOL)enable;
- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar;
- (IBAction)searchFileDoneButtonClicked:(id)sender;
- (void) searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText andCurrentProjPath:(NSString*)currentProjectPath;
- (void) clearData;
- (void) setFocusItem:(NSString*)path;
@end
