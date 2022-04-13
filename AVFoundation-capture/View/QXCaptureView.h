//
//  QXCaptureView.h
//  AVFoundation-capture
//
//  Created by 秦菥 on 2022/4/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QXCaptureView;

@protocol QXCaptureViewDelegate <NSObject>

- (void)didCaptureStillImage;

- (void)didStartRecordVideo;

- (void)didStopRecordVideo;

@end


@interface QXCaptureView : UIView
@property (nonatomic, weak) id<QXCaptureViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
