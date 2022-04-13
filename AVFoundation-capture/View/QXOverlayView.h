//
//  QXOverlayView.h
//  AVFoundation-capture
//
//  Created by 秦菥 on 2022/4/13.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@class QXOverlayView;

@protocol QXOverlayViewDelegate <NSObject>

- (void)didSwitchCamera;

- (void)didSelectTorch:(AVCaptureTorchMode)torch;

- (void)didSelectFlash:(AVCaptureFlashMode)flash;


@end


@interface QXOverlayView : UIView

@property (nonatomic, strong) UIButton *swichBtn;
//手电筒
@property (nonatomic, assign) AVCaptureTorchMode torchMode;
//闪光灯
@property (nonatomic, assign) AVCaptureFlashMode flashMode;

@property (nonatomic, weak) id<QXOverlayViewDelegate>delegate;

- (void)setupFlashView;
- (void)setupTorchView;
- (void)setupSwitchCameraView;
@end

NS_ASSUME_NONNULL_END
