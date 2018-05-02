//
//  ViewController.m
//  XHDatePicker
//
//  Created by XH_J on 2016/10/25.
//  Copyright © 2016年 XHJCoder. All rights reserved.
//

#import "ViewController.h"
#import "RLKDatePickerViewController.h"
#import "NSDate+XHExtension.h"

@interface ViewController ()
- (IBAction)selelctTimeAction:(UIButton *)btn;
@property (weak, nonatomic) IBOutlet UITextField *startTimeText;
@property (weak, nonatomic) IBOutlet UITextField *endtimeText;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (IBAction)selelctTimeAction:(UIButton *)btn {
    XHDateStyle dateStyle;
    NSString *format;
    switch (btn.tag) {
        case 1:
            dateStyle = DateStyleShowYearMonthDayHourMinute;
            format = @"yyyy-MM-dd HH:mm";
            break;
        case 2:
            dateStyle = DateStyleShowMonthDayHourMinuteSecond;
            format = @"MM-dd HH:mm:ss";
            break;
        case 3:
            dateStyle = DateStyleShowYearMonthDay;
            format = @"yyyy-MM-dd";
            break;
        case 4:
            dateStyle = DateStyleShowMonthDay;
            format = @"MM-dd";
            break;
        case 5:
            dateStyle = DateStyleShowHourMinute;
            format = @"HH:mm";
            break;
            
        default:
            dateStyle = DateStyleShowYearMonthDayHourMinute;
            format = @"yyyy-MM-dd HH:mm";
            break;
    }
    
    
    RLKDatePickerViewController *datepicker = [[RLKDatePickerViewController alloc] initWithCurrentDate:[NSDate date]];
    

    datepicker.datePickerStyle = dateStyle;
    datepicker.dateType = DateTypeStartDate;
    datepicker.minLimitDate = [NSDate date:@"2017-2-28 12:22:34" WithFormat:@"yyyy-MM-dd HH:mm:ss"];
    datepicker.maxLimitDate = [NSDate date:@"2018-2-28 12:12:56" WithFormat:@"yyyy-MM-dd HH:mm:ss"];
    [self.navigationController pushViewController:datepicker animated:YES];
}
@end
