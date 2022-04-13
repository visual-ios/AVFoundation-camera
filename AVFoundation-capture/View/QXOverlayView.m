//
//  QXOverlayView.m
//  AVFoundation-capture
//
//  Created by 秦菥 on 2022/4/13.
//

#import "QXOverlayView.h"

@interface QXOverlayView()
@property (nonatomic, strong) UIButton *flashBtn;
@property (nonatomic, strong) UIButton *torchBtn;


@end

@implementation QXOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    
    
}

- (void)setupFlashView
{
    self.flashBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 50, 120, 50);
        [btn addTarget:self action:@selector(didSelectFlash:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self addSubview:self.flashBtn];
}
- (void)setupTorchView
{
    self.torchBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(CGRectGetMaxX(self.flashBtn.frame) + 20, 50, 120, 50);
        [btn addTarget:self action:@selector(didSelectTorch:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self addSubview:self.torchBtn];
}
- (void)setupSwitchCameraView
{
    self.swichBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 100, 50, 100, 50);
        [btn setTitle:@"切换摄像头" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(didSelectCameraDirect:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self addSubview:self.swichBtn];
}

- (void)didSelectFlash:(UIButton *)sender
{
    switch (self.flashMode) {
        case AVCaptureFlashModeOn:
            self.flashMode = AVCaptureFlashModeOff;
            break;
        case AVCaptureFlashModeOff:
            self.flashMode = AVCaptureFlashModeAuto;
            break;
        case AVCaptureFlashModeAuto:
            self.flashMode = AVCaptureFlashModeOn;
            break;
    }
    if ([_delegate respondsToSelector:@selector(didSelectFlash:)]) {
        [_delegate didSelectFlash:_flashMode];
    }
}

- (void)didSelectTorch:(UIButton *)sender
{
    switch (self.torchMode) {
        case AVCaptureTorchModeOn:
            self.torchMode = AVCaptureTorchModeOff;
            break;
            
        case AVCaptureTorchModeOff:
            self.torchMode = AVCaptureTorchModeAuto;
            break;
            
        case AVCaptureTorchModeAuto:
            self.torchMode = AVCaptureTorchModeOn;
            break;
    }
    if ([_delegate respondsToSelector:@selector(didSelectTorch:)]) {
        [_delegate didSelectTorch:_torchMode];
    }
}

- (void)didSelectCameraDirect:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(didSwitchCamera)]) {
        [_delegate didSwitchCamera];
    }
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode
{
    _torchMode = torchMode;
    switch (torchMode) {
        case AVCaptureTorchModeAuto:
            [self.torchBtn setTitle:@"手电筒：自动" forState:UIControlStateNormal];
            break;
            
        case AVCaptureTorchModeOn:
            [self.torchBtn setTitle:@"手电筒：开" forState:UIControlStateNormal];
            break;
            
        case AVCaptureTorchModeOff:
            [self.torchBtn setTitle:@"手电筒：关" forState:UIControlStateNormal];
            break;
    }
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode
{
    _flashMode = flashMode;
    
    switch (flashMode) {
        case AVCaptureFlashModeAuto:
            [self.flashBtn setTitle:@"闪光灯：自动" forState:UIControlStateNormal];
            break;
        case AVCaptureFlashModeOn:
            [self.flashBtn setTitle:@"闪光灯：开" forState:UIControlStateNormal];
            break;
        case AVCaptureFlashModeOff:
            [self.flashBtn setTitle:@"闪光灯：关" forState:UIControlStateNormal];
            break;
    }
}




@end
