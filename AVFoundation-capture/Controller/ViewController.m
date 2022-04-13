//
//  ViewController.m
//  AVFoundation-capture
//
//  Created by 秦菥 on 2022/4/12.
//

#import "ViewController.h"
#import "QXCamera.h"
#import "QXPreviewView.h"
#import "QXOverlayView.h"
#import "QXCaptureView.h"

@interface ViewController ()<QXOverlayViewDelegate,QXPreviewViewDelegate,QXCaptureViewDelegate>
@property (nonatomic, strong) QXCamera *camera;
@property (nonatomic, strong) QXPreviewView *previewView;
@property (nonatomic, strong) QXOverlayView *overlayView;
@property (nonatomic, strong) QXCaptureView *captureView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.camera = [QXCamera shareManager];
    NSError *error;
    if ([self.camera setupSession:&error]) {
        self.previewView = [[QXPreviewView alloc] initWithFrame:self.view.bounds];
        _previewView.delegate = self;
        [self.view addSubview:_previewView];
        [_previewView setSession:self.camera.captureSession];
        [self.camera startSession];
        //设置曝光和聚焦
        _previewView.tapToExposeEnabled = _camera.cameraSupportsTapToExpose;
        _previewView.tapToFocusEnabled = _camera.cameraSupportsTapToFocus;
        
        
        [self setupOverlayView];
        [self setupCaptureView];
        
    } else {
        NSLog(@"Error:%@",[error localizedDescription]);
    }

}

- (void)setupOverlayView
{
    self.overlayView = [[QXOverlayView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100)];
    _overlayView.delegate = self;
    [self.view addSubview:_overlayView];
    if ([_camera canSwitchCameras]) {
        [_overlayView setupSwitchCameraView];
    }
    if (_camera.cameraHasFlash) {
        [_overlayView setupFlashView];
    }
    if (_camera.cameraHasTorch) {
        [_overlayView setupTorchView];
    }
    _overlayView.flashMode = _camera.flashMode;
    _overlayView.torchMode = _camera.torchMode;
}

- (void)setupCaptureView
{
    self.captureView = [[QXCaptureView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 100, [UIScreen mainScreen].bounds.size.width, 50)];
    _captureView.delegate = self;
    [self.view addSubview:self.captureView];
}

#pragma mark - 转换摄像头
- (void)didSwitchCamera
{
    [_camera switchCameras];
}

#pragma mark - 修改手电筒模式
- (void)didSelectTorch:(AVCaptureTorchMode)torch
{
    _camera.torchMode = torch;
}
#pragma mark - 修改闪光灯模式
- (void)didSelectFlash:(AVCaptureFlashMode)flash
{
    _camera.flashMode = flash;
}
#pragma mark - 聚焦
- (void)tappedToFocusAtPoint:(CGPoint)point
{
    [_camera focusAtPoint:point];
}
#pragma mark - 曝光
- (void)tappedToExposeAtPoint:(CGPoint)point
{
    [_camera exposeAtPoint:point];
}
#pragma mark - 重置
- (void)tappedToResetFocusAndExposure
{
    [_camera resetFocusAndExposureModes];
}


#pragma mark - 拍照
- (void)didCaptureStillImage
{
    [_camera captureStillImage];
}

#pragma mark - 录制
- (void)didStartRecordVideo
{
    [_camera startRecording];
    _overlayView.swichBtn.hidden = YES;
}

- (void)didStopRecordVideo
{
    [_camera stopRecording];
    _overlayView.swichBtn.hidden = NO;
}
@end
