//
//  QXCamera.m
//  AVFoundation-capture
//
//  Created by 秦菥 on 2022/4/12.
//

#import "QXCamera.h"
#import <AssetsLibrary/AssetsLibrary.h>

static CGFloat const kMaxVideoScale = 6.0f;
static CGFloat const kMinVideoScale = 1.0f;


@interface QXCamera()<AVCaptureFileOutputRecordingDelegate>
@property (nonatomic, strong, readwrite) AVCaptureSession *captureSession;
@property (nonatomic, weak) AVCaptureDeviceInput *activeVideoInput;

@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieOutput;
@property (nonatomic, strong) NSURL *outputURL;

@property (nonatomic, assign) BOOL isRecording;
@end

@implementation QXCamera

+ (instancetype)shareManager
{
    static QXCamera *camera;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        camera = [[QXCamera alloc] init];
    });
    return camera;
}

#pragma mark - 捕捉
- (BOOL)setupSession:(NSError **)error
{
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    if (videoInput) {
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        }
    } else {
        return NO;
    }
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:error];
    if (audioInput) {
        if ([self.captureSession canAddInput:audioInput]) {
            [self.captureSession addInput:audioInput];
        }
    } else {
        return NO;
    }
    
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    self.imageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecTypeJPEG};
    
    if ([self.captureSession canAddOutput:self.imageOutput]) {
        [self.captureSession addOutput:self.imageOutput];
    }
    
    self.movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([self.captureSession canAddOutput:self.movieOutput]) {
        [self.captureSession addOutput:self.movieOutput];
    }
    
    return YES;
    
}

- (void)startSession
{
    if (![self.captureSession isRunning]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.captureSession startRunning];
        });
    }
}

- (void)stopSession
{
    if ([self.captureSession isRunning]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.captureSession stopRunning];
        });
    }
}

#pragma mark - 转换摄像头
- (BOOL)canSwitchCameras
{
    return self.cameraCount > 1;
}

- (NSUInteger)cameraCount
{
    return [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count;
}
- (BOOL)switchCameras
{
    if (![self canSwitchCameras]) return NO;
    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (videoInput) {
        [self.captureSession beginConfiguration];
        [self.captureSession removeInput:self.activeVideoInput];
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        } else {
            [self.captureSession addInput:self.activeVideoInput];
        }
        [self.captureSession commitConfiguration];
    } else {
        return NO;
    }
    return YES;
}
- (AVCaptureDevice *)inactiveCamera
{
    AVCaptureDevice *device = nil;
    if (self.cameraCount > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}
- (AVCaptureDevice *)activeCamera {
    return self.activeVideoInput.device;
}
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}


#pragma mark - 闪光灯
- (BOOL)cameraHasFlash
{
    return [[self activeCamera] hasFlash];
}
- (AVCaptureFlashMode)flashMode
{
    return [[self activeCamera] flashMode];
}
- (void)setFlashMode:(AVCaptureFlashMode)flashMode
{
    AVCaptureDevice *device = [self activeCamera];
    if (device.flashMode != flashMode && [device isFlashModeSupported:flashMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        } else {
            
        }
    }
}

#pragma mark - 手电筒
- (BOOL)cameraHasTorch
{
    return [[self activeCamera] hasTorch];
}

- (AVCaptureTorchMode)torchMode
{
    return [[self activeCamera] torchMode];
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode
{
    AVCaptureDevice *device = [self activeCamera];
    if (device.torchMode != torchMode && [device isTorchModeSupported:torchMode]) {
        
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        }
    }
}

#pragma mark - 焦距
- (BOOL)cameraSupportsTapToFocus
{
    return [[self activeCamera] isFocusPointOfInterestSupported];
}

- (void)focusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [self activeCamera];
    if (device.isFocusPointOfInterestSupported &&                           // 3
        [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {

        NSError *error;
        if ([device lockForConfiguration:&error]) {                         // 4
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        } else {
        }
    }
}

#pragma mark - 曝光
- (BOOL)cameraSupportsTapToExpose
{
    return [[self activeCamera] isExposurePointOfInterestSupported];
}

static const NSString * QXCameraAdjustingExposureContext;

- (void)exposeAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [self activeCamera];
    
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeAutoExpose;
    
    if (device.isExposurePointOfInterestSupported && [device isExposureModeSupported:exposureMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {                         // 3

            device.exposurePointOfInterest = point;
            device.exposureMode = exposureMode;

            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                [device addObserver:self                                    // 4
                         forKeyPath:@"adjustingExposure"
                            options:NSKeyValueObservingOptionNew
                            context:&QXCameraAdjustingExposureContext];
            }

            [device unlockForConfiguration];
        } else {
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    if (context == &QXCameraAdjustingExposureContext) {                     // 5

        AVCaptureDevice *device = (AVCaptureDevice *)object;

        if (!device.isAdjustingExposure &&                                  // 6
            [device isExposureModeSupported:AVCaptureExposureModeLocked]) {

            [object removeObserver:self                                     // 7
                        forKeyPath:@"adjustingExposure"
                           context:&QXCameraAdjustingExposureContext];

            dispatch_async(dispatch_get_main_queue(), ^{                    // 8
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                    device.exposureMode = AVCaptureExposureModeLocked;
                    [device unlockForConfiguration];
                } else {
                }
            });
        }

    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

- (void)resetFocusAndExposureModes {

    AVCaptureDevice *device = [self activeCamera];

    AVCaptureExposureMode exposureMode =
    AVCaptureExposureModeContinuousAutoExposure;

    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;

    BOOL canResetFocus = [device isFocusPointOfInterestSupported] &&        // 1
    [device isFocusModeSupported:focusMode];

    BOOL canResetExposure = [device isExposurePointOfInterestSupported] &&  // 2
    [device isExposureModeSupported:exposureMode];

    CGPoint centerPoint = CGPointMake(0.5f, 0.5f);                          // 3

    NSError *error;
    if ([device lockForConfiguration:&error]) {

        if (canResetFocus) {                                                // 4
            device.focusMode = focusMode;
            device.focusPointOfInterest = centerPoint;
        }

        if (canResetExposure) {                                             // 5
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centerPoint;
        }
        
        [device unlockForConfiguration];
        
    } else {
    }
}

- (void)setVideoScale:(CGFloat)scale
{
    scale = [self avaliableVideoScaleWithScale:scale];
    AVCaptureDevice *device = [self activeCamera];
    [device lockForConfiguration:nil];
    device.videoZoomFactor = scale;
    [device unlockForConfiguration];
}

- (CGFloat)avaliableVideoScaleWithScale:(CGFloat)scale
{
    AVCaptureDevice *device = [self activeCamera];
    
    CGFloat maxScale = kMaxVideoScale;
    CGFloat minScale = kMinVideoScale;
    if (@available(iOS 11.0, *)) {
        maxScale = device.maxAvailableVideoZoomFactor;
    }
    scale = MAX(scale, minScale);
    scale = MIN(scale, maxScale);
    return scale;
}

#pragma mark - 拍摄
- (void)captureStillImage
{
    AVCaptureConnection *connection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (connection.isVideoOrientationSupported) {
        connection.videoOrientation = [self currentVideoOrientation];
    }
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
       
        NSData *imageData =
            [AVCaptureStillImageOutput
                jpegStillImageNSDataRepresentation:imageDataSampleBuffer];

        UIImage *image = [[UIImage alloc] initWithData:imageData];
        [self writeImageToAssetsLibrary:image];
    }];
    
}
- (void)writeImageToAssetsLibrary:(UIImage *)image {

    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];              // 2

    [library writeImageToSavedPhotosAlbum:image.CGImage                     // 3
                              orientation:(NSInteger)image.imageOrientation // 4
                          completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"保存失败：%@",error.localizedDescription);
        } else {
            NSLog(@"保存成功");
        }
      }];
}

//- (BOOL)isRecording
//{
//    return self.movieOutput.isRecording;
//}

- (void)startRecording
{
    if (self.isRecording) return;
    
    AVCaptureConnection *videoConnection =                              // 2
        [self.movieOutput connectionWithMediaType:AVMediaTypeVideo];

    if ([videoConnection isVideoOrientationSupported]) {                // 3
        videoConnection.videoOrientation = self.currentVideoOrientation;
    }

    if ([videoConnection isVideoStabilizationSupported]) {              // 4
        
        videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        
        // Deprecated approach below
        // videoConnection.enablesVideoStabilizationWhenAvailable = YES;
    }

    AVCaptureDevice *device = [self activeCamera];

    if (device.isSmoothAutoFocusSupported) {                            // 5
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.smoothAutoFocusEnabled = NO;
            [device unlockForConfiguration];
        } else {
        }
    }

    self.outputURL = [self uniqueURL];                                  // 6
    [self.movieOutput startRecordingToOutputFileURL:self.outputURL      // 8
                                  recordingDelegate:self];
    self.isRecording = YES;
}

- (void)stopRecording {                                                     // 9
    if (self.isRecording) {
        self.isRecording = NO;
        [self.movieOutput stopRecording];
    }
}

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error
{
    if (!error) {
        [self writeVideoToAssetsLibrary:[self.outputURL copy]];
    } else {
        
    }
    self.outputURL = nil;
}
- (void)writeVideoToAssetsLibrary:(NSURL *)videoURL {

    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];              // 2

    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL]) {   // 3

        ALAssetsLibraryWriteVideoCompletionBlock completionBlock;

        completionBlock = ^(NSURL *assetURL, NSError *error){               // 4
            if (error) {
                NSLog(@"保存失败：%@",error.localizedDescription);
            } else {
                NSLog(@"保存成功");
            }
        };

        [library writeVideoAtPathToSavedPhotosAlbum:videoURL                // 8
                                    completionBlock:completionBlock];
    }
}

- (NSURL *)uniqueURL {                                                      // 7

    NSString *dirPath =
        [self temporaryDirectoryWithTemplateString:@"kamera.XXXXXX"];

    if (dirPath) {
        NSString *filePath =
            [dirPath stringByAppendingPathComponent:@"kamera_movie.mov"];
        return [NSURL fileURLWithPath:filePath];
    }

    return nil;
}

- (NSString *)temporaryDirectoryWithTemplateString:(NSString *)templateString {

    NSString *mkdTemplate =
        [NSTemporaryDirectory() stringByAppendingPathComponent:templateString];

    const char *templateCString = [mkdTemplate fileSystemRepresentation];
    char *buffer = (char *)malloc(strlen(templateCString) + 1);
    strcpy(buffer, templateCString);

    NSString *directoryPath = nil;

    char *result = mkdtemp(buffer);
    if (result) {
        directoryPath = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:buffer
                                                          length:strlen(result)];
    }
    free(buffer);
    return directoryPath;
}


- (AVCaptureVideoOrientation)currentVideoOrientation {

    AVCaptureVideoOrientation orientation;

    switch ([UIDevice currentDevice].orientation) {                         // 3
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }

    return orientation;
}

@end


