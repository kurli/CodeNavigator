//
//  OpenAsViewController.h
//  CodeNavigator
//
//  Created by Guozhen Li on 10/6/13.
//
//

#import <UIKit/UIKit.h>

@interface OpenAsViewController : UIViewController <UIPickerViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UIPickerView *parserTypePicker;

@property (strong, nonatomic) NSString* filePath;

@property (nonatomic, strong) NSMutableArray* parserArray;

@property (nonatomic, strong) NSArray* manuallyParserArray;

- (IBAction)addButtonClicked:(id)sender;

@end
