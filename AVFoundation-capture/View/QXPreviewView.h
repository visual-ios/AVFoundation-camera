//
//  QXPreviewView.h
//  AVFoundation-capture
//
//  Created by 秦菥 on 2022/4/12.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@class QXPreviewView;

@class QXPreviewView;

@protocol QXPreviewViewDelegate <NSObject>
- (void)tappedToFocusAtPoint:(CGPoint)point;
- (void)tappedToExposeAtPoint:(CGPoint)point;
- (void)tappedToResetFocusAndExposure;

@end


@interface QXPreviewView : UIView
@property (nonatomic, weak) id<QXPreviewViewDelegate>delegate;

@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic) BOOL tapToFocusEnabled;
@property (nonatomic) BOOL tapToExposeEnabled;
@end

NS_ASSUME_NONNULL_END
