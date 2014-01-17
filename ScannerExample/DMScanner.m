//
//  DMScanner.m
//  Machine Readable Codes Scanner
//
//  Created by Deepu Mukundan on 1/17/14.
//  Copyright (c) 2014 DMUKUND. All rights reserved.
//

@import AVFoundation;
@import QuartzCore;
#import "DMScanner.h"

#define SCANQUEUE   "com.dmscanner.queue"

@interface DMScanner () <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *capturePreviewLayer;
@property (nonatomic, strong) AVCaptureVideoDataOutput *captureVideoDataOutput;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) NSString *foundCode;
@property (nonatomic, strong) NSString *foundType;
@property (nonatomic, assign) BOOL sessionIsSetup;
@end

@implementation DMScanner

#pragma mark - Main
- (void)startScanning {
    // Start a new capture session
    if (!_sessionIsSetup) {
        // Setup required params
        [self setupCameraSession];
        _sessionIsSetup = YES;
    }
    // Add a video preview layer so the user can see what is being scanned
    [self addPreviewLayer];
}

#pragma mark - Utility methods
- (void)setupCameraSession {
    
    // Creates a capture session
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
    }
    
    // Begins the capture session configuration
    [self.captureSession beginConfiguration];
    
    // Selects the rear camera
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error;
    // Adds the device input to capture session
    self.captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
    if ( [self.captureSession canAddInput:self.captureDeviceInput] )
        [self.captureSession addInput:self.captureDeviceInput];
    
    // Creates and adds the metadata output to the capture session
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    if ([self.captureSession canAddOutput:metadataOutput]) {
        [self.captureSession addOutput:metadataOutput];
    }
    
    // Creates a GCD queue to dispatch the metadata
    dispatch_queue_t metadataQueue = dispatch_queue_create(SCANQUEUE, DISPATCH_QUEUE_SERIAL);
    [metadataOutput setMetadataObjectsDelegate:self queue:metadataQueue];
    
    // Sets the metadata object types. Uncomment and use only the required ones to make scanning faster
    //    NSArray *metadataTypes = @[AVMetadataObjectTypeAztecCode,
    //                               AVMetadataObjectTypeCode128Code,
    //                               AVMetadataObjectTypeCode39Code,
    //                               AVMetadataObjectTypeCode39Mod43Code,
    //                               AVMetadataObjectTypeCode93Code,
    //                               AVMetadataObjectTypeEAN13Code,
    //                               AVMetadataObjectTypeEAN8Code,
    //                               AVMetadataObjectTypePDF417Code,
    //                               AVMetadataObjectTypeQRCode,
    //                               AVMetadataObjectTypeUPCECode];
    
    NSArray *metadataTypes = [metadataOutput availableMetadataObjectTypes];
    
    [metadataOutput setMetadataObjectTypes:metadataTypes];
    
    // Commits the camera configuration
    [self.captureSession commitConfiguration];
}

- (void)addPreviewLayer {
    // Adds the preview layer to the main view layer
    [self.delegate.view.layer insertSublayer:self.capturePreviewLayer above:self.delegate.view.layer];
    // Lock the camera focus to nearfield to better scan codes
    [self cameraFocusRangeNearField:YES];
    // Start the capture session
    [self.captureSession startRunning];
}

- (void)removePreviewLayer {
    // Remove the capture preview layer
    [self.capturePreviewLayer removeFromSuperlayer];
    // Unlock the camera focus so that normal camera functions are not restricted
    [self cameraFocusRangeNearField:NO];
    // Stop the barcode capture
    [self.captureSession stopRunning];
}

- (void)cameraFocusRangeNearField:(BOOL)lock {
    // Locks the configuration
    BOOL success = [self.captureDevice lockForConfiguration:nil];
    if (success) {
        if ([self.captureDevice isAutoFocusRangeRestrictionSupported]) {
            // Restricts the autofocus to near range (new in iOS 7)
            if (lock) {
                [self.captureDevice setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionNear];
            } else {
                [self.captureDevice setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionNone];
            }
        }
    }
    // unlocks the configuration
    [self.captureDevice unlockForConfiguration];
}

#pragma mark - Preview layer Instanciation
- (AVCaptureVideoPreviewLayer *)capturePreviewLayer {
    if (!_capturePreviewLayer) {
        // Prepares the preview layer
        self.capturePreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
        CGRect frame = [[UIScreen mainScreen] bounds];
        [self.capturePreviewLayer setFrame:frame];
        [self.capturePreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }
    return _capturePreviewLayer;
}

#pragma mark - Capture delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    if ([metadataObjects count] < 1) {
        return;
    }
    for (id item in metadataObjects) {
        if (item && [item isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.foundCode = [(AVMetadataMachineReadableCodeObject *)item stringValue];
                self.foundType = [(AVMetadataMachineReadableCodeObject *)item type];
                if (self.foundCode) {
                    // Remove the preview layer so that background items are visible
                    [self removePreviewLayer];
                    // Let the delegate know about the found code
                    [self.delegate scannerFoundMachineReadableCode:self.foundCode ofType:self.foundType];
                }
            });
        }
    }
}

@end
