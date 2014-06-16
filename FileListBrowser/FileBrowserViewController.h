//
//  FileBrowserViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 9/17/13.
//
//

#import <UIKit/UIKit.h>
#import "FileBrowserViewProtocol.h"

@class FileListBrowserController;
#import "FileListBrowserProtocol.h"

@interface FileBrowserViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FileListBrowserDelegate>
{
    NSInteger needSelectRowAfterReload;
}

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

@property (unsafe_unretained, nonatomic) IBOutlet UISearchBar *fileSearchBar;

@property (strong, nonatomic) NSString *currentProjectPath;

@property (strong, nonatomic) FileListBrowserController* fileListBrowserController;

@property (strong, nonatomic) NSString *initialPath;

@property (assign, nonatomic) id< FileBrowserViewDelegate > fileBrowserViewDelegate;

- (void) setIsProjectFolder:(BOOL) _isProjectFolder;

- (void) gotoFile:(NSString *)filePath;

- (void) setNeedSelectRowAfterReload:(NSInteger)index;

@end
