//
//  FileBrowserTreeViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 7/1/14.
//
//

#import <UIKit/UIKit.h>
#import "FileListBrowserProtocol.h"

@protocol FileBrowserTreeDelegate <NSObject>
- (void) onParentNeedChangePath:(NSString*)path;
- (void) onTreeViewDismissed;
- (void) setFocusItem:(NSString*)path;
- (void) onFileClickedFromTreeView:(NSString*)selectedItem andPath:(NSString*)path;
@end

@interface FileBrowserTreeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, FileListBrowserDelegate>

@property (strong, nonatomic) NSString* currentPath;
@property (strong, nonatomic) id<FileBrowserTreeDelegate> parentDelegate;

-(void)changeToPath:(NSString*)path;
-(void)pathBack;
@end
