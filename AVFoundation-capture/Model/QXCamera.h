//
//  QXCamera.h
//  AVFoundation-capture
//
//  Created by 秦菥 on 2022/4/12.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QXCamera : UIView

+ (instancetype)shareManager;

@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;

- (BOOL)setupSession:(NSError **)error;
- (void)startSession;
- (void)stopSession;
//转换摄像头
- (BOOL)switchCameras;
- (BOOL)canSwitchCameras;
@property (nonatomic, assign, readonly) NSUInteger cameraCount;
@property (nonatomic, assign, readonly) BOOL cameraHasTorch;
@property (nonatomic, assign, readonly) BOOL cameraHasFlash;
@property (nonatomic, assign, readonly) BOOL cameraSupportsTapToFocus;
@property (nonatomic, assign, readonly) BOOL cameraSupportsTapToExpose;
//手电筒
@property (nonatomic, assign) AVCaptureTorchMode torchMode;
//闪光灯
@property (nonatomic, assign) AVCaptureFlashMode flashMode;
//聚焦
- (void)focusAtPoint:(CGPoint)point;
//曝光
- (void)exposeAtPoint:(CGPoint)point;
- (void)resetFocusAndExposureModes;
//缩放
- (void)setVideoScale:(CGFloat)scale;
- (CGFloat)avaliableVideoScaleWithScale:(CGFloat)scale;
//拍照
- (void)captureStillImage;
//录制视频
- (void)startRecording;
- (void)stopRecording;
- (BOOL)isRecording;
- (CMTime)recordDuration;

@end

NS_ASSUME_NONNULL_END
