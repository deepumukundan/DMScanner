//
//  DMViewController.m
//  ScannerExample
//
//  Created by Deepu Mukundan on 1/17/14.
//  Copyright (c) 2014 DMUKUND. All rights reserved.
//

#import "DMViewController.h"
#import "DMScanner.h"

@interface DMViewController () <DMScannerDelegate>
@property (strong,nonatomic) DMScanner *scanner;
@end

@implementation DMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Allocate an instance of the scanner
    self.scanner = [[DMScanner alloc] init];
    self.scanner.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DMScanner Delegate 
- (void)scannerFoundMachineReadableCode:(NSString *)code ofType:(NSString *)type {
    self.code.text = code;
    self.type.text = type;
}

- (IBAction)scan {
    [self.scanner startScanning];
}

@end
