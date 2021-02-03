//
//  PYNavigationController.m
//  example
//
//  Created by jimmy on 2021/2/2.
//

#import "PYNavigationController.h"

@interface PYNavigationController ()

@end

@implementation PYNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (BOOL)shouldAutorotate{
    return [self.topViewController shouldAutorotate];
    
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return [self.topViewController supportedInterfaceOrientations];
    
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
  return  [self.topViewController preferredInterfaceOrientationForPresentation];
}
@end
