//
//  DMViewController.h
//  ScannerExample
//
//  Created by Deepu Mukundan on 1/17/14.
//  Copyright (c) 2014 DMUKUND. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *code;
@property (weak, nonatomic) IBOutlet UILabel *type;
- (IBAction)scan;
@end
