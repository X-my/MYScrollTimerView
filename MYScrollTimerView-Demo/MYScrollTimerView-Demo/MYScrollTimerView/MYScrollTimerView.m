//
//  MYScrollTimerView.m
//  MYScrollTimerView
//
//  Created by Obj on 15/12/11.
//  Copyright © 2015年 梦阳 许. All rights reserved.
//

#import "MYScrollTimerView.h"

#define MY_DIGIT_BORDER_WIDTH 1.0f

@interface MYScrollDigitView : UIScrollView
{
    NSUInteger _currentIndex;
}

@end

@implementation MYScrollDigitView

- (instancetype)initWithFrame:(CGRect)frame
                    digitFont:(UIFont*)digitFont
                   digitColor:(UIColor*)digitColor
                  borderColor:(UIColor*)borderColor
{
    self = [super initWithFrame:frame];
    if (self) {
        
        for (int i = 0; i < 10; i++) {
            UILabel* digitLabel = [self aDigitLabelWithFont:digitFont
                                                  textColor:digitColor];
            digitLabel.text = [NSString stringWithFormat:@"%d",i];
            [self addSubview:digitLabel];
        }
        self.userInteractionEnabled = NO;
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.layer.borderWidth = MY_DIGIT_BORDER_WIDTH;
        self.layer.borderColor = borderColor.CGColor;
        _currentIndex = 0;
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    for (int i = 0; i < 10; i++) {
        UILabel* digitLabel = self.subviews[i];
        digitLabel.frame = CGRectMake(0, i*self.frame.size.height, self.frame.size.width, self.frame.size.height);
    }
     self.contentSize = CGSizeMake(self.frame.size.width, 10*self.frame.size.height);
}
- (void)scrollToIndex:(NSUInteger)index animated:(BOOL)animated
{

    CGPoint contentOffset = CGPointMake(0, index*self.frame.size.height);
    [self setContentOffset:contentOffset animated:animated];
    _currentIndex = index;
}
- (UILabel*)aDigitLabelWithFont:(UIFont*)font
                      textColor:(UIColor*)textColor
{
    UILabel* label = [[UILabel alloc]init];
    label.font = font;
    label.textColor = textColor;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}
@end

@interface MYScrollTimerView ()
{
    NSTimer* _timer;
    NSTimeInterval _hasPassedTime;
}
@property (nonatomic, strong) NSArray* digitViews;
@property (nonatomic, strong) UILabel* separatorLabel;
@property (nonatomic, copy) MYScrollTimerViewFinishHandler finish;

@end

@implementation MYScrollTimerView

#pragma mark - Initialize

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}
- (void)setup
{
    [self configureDefaultValues];
    
    NSMutableArray* digitViews = [NSMutableArray new];
    for (int i = 0; i < 5; i++) {
        if (i == 2) {
            UILabel* separatorLabel = [[UILabel alloc]init];
            separatorLabel.text = self.separatorString;
            separatorLabel.textAlignment = NSTextAlignmentCenter;
            separatorLabel.font = self.numberFont;
            separatorLabel.textColor = self.numberColor;
            [self addSubview:separatorLabel];
            self.separatorLabel = separatorLabel;
        }else{
            MYScrollDigitView* aDigitView = [[MYScrollDigitView alloc]initWithFrame:(CGRect){{0,0},self.frame.size}
                                                                          digitFont:self.numberFont
                                                                         digitColor:self.numberColor
                                                                        borderColor:self.borderColor];
            [self addSubview:aDigitView];
            [digitViews addObject:aDigitView];
        }
    }
    self.digitViews = [digitViews copy];
}
- (void)configureDefaultValues
{
    self.numberFont = [UIFont systemFontOfSize:18];
    self.numberColor = [UIColor blackColor];
    self.borderColor = [UIColor blackColor];
    self.separatorString = @":";
    self.paddingOfNumbers = 5;
    _totalTime = HUGE_VAL;
    _mode = MYScrollTimerViewModeCountingUp;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateDigitViewsWithTime:self.currentTime animated:NO];
    [self.separatorLabel sizeToFit];
    CGFloat separatorW = self.separatorLabel.bounds.size.width;
    CGFloat digitW = (self.frame.size.width - 4*separatorW)/4;
    for (int i = 0; i < self.subviews.count; i++) {
        UIView* child = self.subviews[i];
        CGFloat x;
        CGFloat w = digitW;
        if (i < 3) {
            x = i*(digitW + self.paddingOfNumbers);
            if (i == 2) {
                w = separatorW;
            }
        }else {
            x = (i - 1) * digitW + separatorW + i*self.paddingOfNumbers;
        }
       child.frame = CGRectMake(x, 0, w, self.frame.size.height);
    }
}
#pragma mark - Public Methods
- (void)setTotalTime:(NSTimeInterval)totalTime
    withCountingMode:(MYScrollTimerViewMode)mode
         finishBlock:(MYScrollTimerViewFinishHandler)finish
{
    _mode = mode;
    _totalTime = totalTime;
    _finish = finish;
}
-(void)start
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1
                                              target:self
                                            selector:@selector(handleTimerUpdate)
                                            userInfo:nil
                                             repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    _isCounting = YES;
    [_timer fire];
}
- (void)pause
{
    if(_isCounting){
        [_timer invalidate];
        _timer = nil;
        _isCounting = NO;
    }
}
- (void)reset
{

}
#pragma mark - Private Methods
- (void)handleTimerUpdate
{
    _hasPassedTime++;
    if (_hasPassedTime > _totalTime) {
        [self pause];
        if (self.finish) {
            self.finish(self.totalTime);
        }
    }else{
        [self updateDigitViewsWithTime:self.currentTime animated:YES];
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(scrollTimerView:countingTo:)]) {
            [self.delegate scrollTimerView:self countingTo:self.currentTime];
        }
    }
}
- (void)updateDigitViewsWithTime:(NSTimeInterval)time animated:(BOOL)animated
{
    int second = (int)time  % 60;
    int minute = ((int)time / 60) % 60;
    int decadeOfMinute = minute / 10;
    int unitOfMinute = minute % 10;
    int decadeOfSecond = second / 10;
    int unitOfSecond = second % 10;
    NSArray* numbers = @[@(decadeOfMinute),@(unitOfMinute),@(decadeOfSecond),@(unitOfSecond)];
    for (int i = 0; i < self.digitViews.count; i++) {
        MYScrollDigitView* digitView = self.digitViews[i];
        [digitView scrollToIndex:[numbers[i]integerValue] animated:animated];
    }
}
- (void) removeFromSuperview {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    [super removeFromSuperview];
}
#pragma mark - Setters
- (void)setNumberColor:(UIColor *)numberColor
{
    _numberColor = numberColor;
    self.separatorLabel.textColor = numberColor;
    for (MYScrollDigitView* digitView in self.digitViews) {
        for (UILabel* child in digitView.subviews) {
            child.textColor = numberColor;
        }
    }
}
- (void)setNumberFont:(UIFont *)numberFont
{
    _numberFont = numberFont;
    for (MYScrollDigitView* digitView in self.digitViews) {
        for (UILabel* child in digitView.subviews) {
            child.font = numberFont;
        }
    }
}
- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    for (MYScrollDigitView* digitView in self.digitViews) {
        digitView.layer.borderColor = borderColor.CGColor;
    }
}
- (void)setSeparatorString:(NSString *)separatorString
{
    _separatorString = separatorString;
    self.separatorLabel.text = separatorString;
}
#pragma mark - Getters
- (NSTimeInterval)currentTime
{
    if (self.mode == MYScrollTimerViewModeCountingUp) {
        return _hasPassedTime;
    }else{
        return _totalTime - _hasPassedTime;
    }
}
@end


