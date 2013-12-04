//
//  MyWebView.m
//  CodeNavigator
//
//  Created by Guozhen Li on 12/2/13.
//
//

#import "MyWebView.h"

@implementation MyWebView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        UIMenuItem *menuItem0 = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"share",nil) action:@selector(item0:)];
        UIMenuItem *menuItem1 = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"111",nil) action:@selector(item1:)];
        UIMenuItem *menuItem2 = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"666",nil) action:@selector(item2:)];
        UIMenuItem *menuItem3 = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"分享到微博",nil) action:@selector(item3:)];
        
        NSArray *array = [NSArray arrayWithObjects:menuItem0, menuItem1, menuItem2, menuItem3, nil];
        [menuController setMenuItems:array];
    }
    return self;
}

- (IBAction)item0:(id)sender;
{
}

- (IBAction)item1:(id)sender;
{
}

- (IBAction)item2:(id)sender;
{
}
- (IBAction)item3:(id)sender;
{
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(item0:)||
        action == @selector(item1:)||
        action == @selector(item2:)||
        action == @selector(item3:)
        )
    {
        return YES;
    }
    //    return [super canPerformAction:action withSender:sender];
    return  NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
