//
//  FileListBrowserProtocol.h
//  CodeNavigator
//
//  Created by Guozhen Li on 9/16/13.
//
//

#import <Foundation/Foundation.h>

@protocol FileListBrowserDelegate <NSObject>
- (IBAction) fileInfoButtonClicked:(id)sender;
- (void) folderClickedDelegate:(UITableView*) tableView andSelectedItem:(NSString*)selectedItem andPath:(NSString*)path;
- (void) fileClickedDelegate:(UITableView*) tableView andSelectedItem:(NSString*)selectedItem andPath:(NSString*)path;
- (NSString*) getCurrentProjectPath;
@end