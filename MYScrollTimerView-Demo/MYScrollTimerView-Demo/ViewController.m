//
//  ViewController.m
//  MYScrollTimerView-Demo
//
//  Created by Obj on 15/12/30.
//  Copyright © 2015年 梦阳 许. All rights reserved.
//

#import "ViewController.h"
#import "MYScrollTimerView.h"

@interface ViewController ()<MYScrollTimerViewDelegate>

@property (nonatomic, strong) MYScrollTimerView* timerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MYScrollTimerView* timerView = [[MYScrollTimerView alloc]initWithFrame:CGRectMake(100, 100, 100, 30)];
    timerView.borderColor = [UIColor greenColor];
    timerView.numberColor = [UIColor greenColor];
    timerView.delegate = self;
    [self.view addSubview:timerView];
    self.timerView = timerView;
}

- (IBAction)countUp:(id)sender {
    
    if (self.timerView.isCounting) {
        [self.timerView pause];
    }
    __weak typeof(self) weakSelf = self;
    [self.timerView setTotalTime:arc4random()%600
                withCountingMode:MYScrollTimerViewModeCountingUp
                     finishBlock:^(NSTimeInterval totalTime) {
                         NSString* alertText = [NSString stringWithFormat:@"count up finished, total time is %f",totalTime];
                         [weakSelf showAlertWithText:alertText];
                     }];
    [self.timerView start];
}
- (IBAction)countDown:(id)sender {
    if (self.timerView.isCounting) {
        [self.timerView pause];
    }
    __weak typeof(self) weakSelf = self;
    [self.timerView setTotalTime:arc4random()%600
                withCountingMode:MYScrollTimerViewModeCountingDown
                     finishBlock:^(NSTimeInterval totalTime) {
                         NSString* alertText = [NSString stringWithFormat:@"count down finished, total time is %f",totalTime];
                         [weakSelf showAlertWithText:alertText];
                     }];
    [self.timerView start];
}

- (void)showAlertWithText:(NSString*)text
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:text
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - MYScrollTimerViewDelegate
- (void)scrollTimerView:(MYScrollTimerView *)timerView countingTo:(NSTimeInterval)time
{
    NSLog(@"current time is %f",time);
}
@end
