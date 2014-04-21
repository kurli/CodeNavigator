//
//  VersionViewController.m
//  CodeNavigator
//
//  Created by Guozhen Li on 3/17/14.
//
//

#import "VersionViewController.h"
#import "Utils.h"
#import "DisplayController.h"

#define RELEASE_VERSION 2

@interface VersionViewController ()

@end

@implementation VersionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.versionDetailView setText:@"New Features & updates:\n\n\
     1. 28 themes are currently supported\n\
     2. Performance improvement for highlight\n\
     3. Show/Hide Line numbers\n\
     4. Auto fold multi-line comments\n\
     5. Remove animation in file browser\n\
     7. Bug fix."];
    [self.versionDetailView setFont:[UIFont systemFontOfSize:16]];
}

-(void) createProjectFolder {
    NSString* projectFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Projects"];
    BOOL isFolder = NO;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:projectFolder isDirectory:&isFolder];
    NSError *error;
    if (isExist == YES && isFolder == YES)
        return;
    
    [[NSFileManager defaultManager] createDirectoryAtPath:projectFolder withIntermediateDirectories:YES attributes:nil error:&error];
    
    // copy help files
    NSString* settings = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/"];
    NSString* helpHtml = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/Help.html"];
    [[NSFileManager defaultManager] copyItemAtPath:helpHtml toPath:[projectFolder stringByAppendingPathComponent:@"Help.html"] error:&error];
    NSString* jpg0 = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/1.jpeg"];
    [[NSFileManager defaultManager] copyItemAtPath:jpg0 toPath:[settings stringByAppendingPathComponent:@"1.jpeg"] error:&error];
}

-(void) copyDemoToProject {
    BOOL isExist;
    BOOL isFolder;
    // copy demo
    NSString* demoFolder = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/Projects/linux_0.1/"];
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:demoFolder isDirectory:&isFolder];
    NSString* demoBundle = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/linux_0.1"];
    if (isExist == NO || (isExist == YES && isFolder == NO))
    {
        [[NSFileManager defaultManager] copyItemAtPath:demoBundle toPath:demoFolder error:nil];
    }
}

-(void) initBuildInParser {
    BOOL isExist;
    BOOL isFolder;
    NSError* error;
    
    // Copy BuildInParser
    NSString* buildInParserPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/BuildInParser/"];
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:buildInParserPath isDirectory:&isFolder];
    NSString* buildInParserPathBundle = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/BuildInParser"];
    if (isExist == NO || (isExist == YES && isFolder == NO))
    {
        [[NSFileManager defaultManager] copyItemAtPath:buildInParserPathBundle toPath:buildInParserPath error:&error];
    }
    // Append mode
    if (isExist == YES) {
        NSArray* contentsInBundle = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:buildInParserPathBundle error:&error];
        NSArray* contentsInSetting = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:buildInParserPath error:&error];
        for (NSString* str in contentsInBundle) {
            int i;
            for (i = 0; i < [contentsInSetting count]; i++) {
                NSString* str2 = [contentsInSetting objectAtIndex:i];
                if ([str isEqualToString:str2]) {
                    break;
                }
            }
            if (i == [contentsInSetting count]) {
                NSString* srcPath = [buildInParserPathBundle stringByAppendingPathComponent:str];
                NSString* desPath = [buildInParserPath stringByAppendingPathComponent:str];
                [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:desPath error:&error];
            }
        }
    }
}

-(void) createSettingFolder {
    BOOL isExist = NO;
    NSString* settingsPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/.settings/"];
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:settingsPath];
    if (!isExist) {
        [[NSFileManager defaultManager] createDirectoryAtPath:settingsPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

-(void) displayVersionDialog {
    double delayInSeconds = 10;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        VersionViewController* viewController = [[VersionViewController alloc] init];
        viewController.modalPresentationStyle = UIModalPresentationFormSheet;
        [[Utils getInstance].splitViewController presentViewController:viewController animated:YES completion:nil];
    });
}

-(void) removeAnalyzeDB {
    NSError* error;
    BOOL isFolder;
    //for version 1_3 we need to delete all project files
    NSString* projectsFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Projects"];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:projectsFolder error:&error];
    for (int i=0; i<[contents count]; i++)
    {
        NSString *projPath = [projectsFolder stringByAppendingPathComponent:[contents objectAtIndex:i]];
        [[NSFileManager defaultManager] fileExistsAtPath:projPath isDirectory:&isFolder];
        if (YES == isFolder)
        {
            NSString* db = [projPath stringByAppendingPathComponent:@"project.lgz_db"];
            [[NSFileManager defaultManager] removeItemAtPath:db error:&error];
            NSString* fl = [projPath stringByAppendingPathComponent:@"db_files.lgz_proj_files"];
            [[NSFileManager defaultManager] removeItemAtPath:fl error:&error];
            fl = [projPath stringByAppendingPathComponent:@"search_files.lgz_proj_files"];
            [[NSFileManager defaultManager] removeItemAtPath:fl error:&error];
        }
    }
}

-(void) initJS {
    NSError* error;
    //for javascript
    NSString* js = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/lgz_javascript.js"];
    NSString* jsPath = [[[NSBundle mainBundle] resourcePath]  stringByAppendingPathComponent:@"lgz_javascript.js"];
    [[NSFileManager defaultManager] copyItemAtPath:jsPath toPath:js error:&error];
}

-(void) removeAllDisplayFiles {
    DisplayController* displayController = [[DisplayController alloc] init];
    [displayController removeAllDisplayFiles];
}

-(void) checkVersion {
    NSError* error;
    BOOL isExist = false;
    // When below statement changed, we need to change to latest version number
    // 1: html format changed
    // 2: cscope file content changed
    // 3: Added new parser config json file
    
    // Create .settings folder
    [self createSettingFolder];
    
    // Init themes
    [ThemeManager readColorScheme];
    
    NSString* versionFile = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/version"];
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:versionFile];
    
    if (isExist == NO)
    {
        // First version
        
        // Generate theme file
        NSString* css = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/theme.css"];
        [ThemeManager generateCSSScheme:css andTheme:[Utils getInstance].currentThemeSetting];

        // Write version code
        NSString* content = [NSString stringWithFormat:@"%d", RELEASE_VERSION];
        [content writeToFile:versionFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        // lgz_software.js
        [self initJS];
        
        // Create project folder
        [self createProjectFolder];
        
        // Copy demo
        [self copyDemoToProject];
        
        // Init build parser
        [self initBuildInParser];
        
#ifndef IPHONE_VERSION
        [self displayVersionDialog];
#endif
        return;
    }
    // Check version file
    NSString* content = [NSString stringWithContentsOfFile:versionFile encoding:NSUTF8StringEncoding error:nil];
    NSInteger integer = [content integerValue];
    
    // Same version
    if (integer == RELEASE_VERSION) {
        return;
    }
    
    if (integer < 2) {
        // Generate theme file
        NSString* css = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/.settings/theme.css"];
        [ThemeManager generateCSSScheme:css andTheme:[Utils getInstance].currentThemeSetting];
        
        // JS updated after V=1
        [self initJS];
        
        // Remove all display folder
        [self removeAllDisplayFiles];
    }

    // Write version code
    content = [NSString stringWithFormat:@"%d", RELEASE_VERSION];
    [content writeToFile:versionFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
#ifndef IPHONE_VERSION
    [self displayVersionDialog];
#endif
    
//    [self removeAnalyzeDB];
    
//    [self createProjectFolder];
    
    [self initBuildInParser];
}

@end
