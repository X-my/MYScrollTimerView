//
//  MYScrollTimerView.h
//  MYScrollTimerView
//
//  Created by Obj on 15/12/11.
//  Copyright © 2015年 梦阳 许. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MYScrollTimerView;

@protocol MYScrollTimerViewDelegate <NSObject>
@optional
-(void)scrollTimerView:(MYScrollTimerView*)timerView countingTo:(NSTimeInterval)time;
@end

typedef NS_ENUM(NSUInteger, MYScrollTimerViewMode) {
    MYScrollTimerViewModeCountingUp,
    MYScrollTimerViewModeCountingDown,
};

typedef void(^MYScrollTimerViewFinishHandler)(NSTimeInterval totalTime);

@interface MYScrollTimerView : UIView

@property (nonatomic, strong, readwrite) UIFont* numberFont;
@property (nonatomic, strong, readwrite) UIColor* numberColor;
@property (nonatomic, strong, readwrite) UIColor* borderColor;
@property (nonatomic, assign, readwrite) CGFloat paddingOfNumbers;
@property (nonatomic, copy, readwrite)   NSString* separatorString;

@property (nonatomic, assign, readonly)  MYScrollTimerViewMode mode;//default is counting up
@property (nonatomic, assign, readonly)  NSTimeInterval totalTime;//when count up is 0
@property (nonatomic, assign, readonly)  NSTimeInterval currentTime;
@property (nonatomic, assign, readonly)  BOOL isCounting;

@property (nonatomic, weak) id<MYScrollTimerViewDelegate> delegate;

- (void)setTotalTime:(NSTimeInterval)totalTime
    withCountingMode:(MYScrollTimerViewMode)mode
         finishBlock:(MYScrollTimerViewFinishHandler)finish;

- (void)start;
- (void)pause;
- (void)reset;

@end
