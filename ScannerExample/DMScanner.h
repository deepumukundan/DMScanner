//
//  DMScanner.h
//  Machine Readable Codes Scanner
//
//  Created by Deepu Mukundan on 1/17/14.
//  Copyright (c) 2014 DMUKUND. All rights reserved.
//

@protocol DMScannerDelegate
// Return the machine readable code found while scanning
- (void)scannerFoundMachineReadableCode:(NSString *)code ofType:(NSString *)type;
@end

@interface DMScanner : NSObject
// The delegate should be a view controller for now.
@property (weak, nonatomic) UIViewController <DMScannerDelegate> *delegate;
// Start the scanning process
- (void)startScanning;
@end
