//
//  QXCaptureView.m
//  AVFoundation-capture
//
//  Created by 秦菥 on 2022/4/13.
//

#import "QXCaptureView.h"

@interface QXCaptureView()
@property (nonatomic, strong) UIButton *cameraBtn;
@property (nonatomic, strong) UIButton *videoBtn;
@end

@implementation QXCaptureView

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
    self.cameraBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width / 2, 50);
        [btn setTitle:@"拍照" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(didSaveStillImage:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self addSubview:self.cameraBtn];
    
    self.videoBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2, 0, [UIScreen mainScreen].bounds.size.width / 2, 50);
        [btn setTitle:@"开始录制" forState:UIControlStateNormal];
        [btn setTitle:@"停止录制" forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(didRecordVideo:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self addSubview:self.videoBtn];
}

- (void)didSaveStillImage:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(didCaptureStillImage)]) {
        [_delegate didCaptureStillImage];
    }
}

- (void)didRecordVideo:(UIButton *)sender
{
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        if ([_delegate respondsToSelector:@selector(didStartRecordVideo)]) {
            [_delegate didStartRecordVideo];
        }
    } else {
        if ([_delegate respondsToSelector:@selector(didStopRecordVideo)]) {
            [_delegate didStopRecordVideo];
        }
    }
}
@end
