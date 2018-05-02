//
//  RLKDatePickerViewController.h
//  XHDatePicker
//
//  Created by Realank on 2017/10/13.
//  Copyright © 2017年 Realank. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum{
    DateStyleShowYearMonthDayHourMinute  = 0,
    DateStyleShowMonthDayHourMinute,
    DateStyleShowYearMonthDay,
    DateStyleShowMonthDay,
    DateStyleShowHourMinute,
    DateStyleShowMonthDayHourMinuteSecond,
}XHDateStyle;

typedef enum{
    DateTypeStartDate,
    DateTypeEndDate
    
}XHDateType;




@interface RLKDatePickerViewController : UIViewController

@property (nonatomic,assign)XHDateStyle datePickerStyle;
@property (nonatomic,assign)XHDateType dateType;
@property (nonatomic,strong)UIColor *themeColor;

@property (nonatomic, retain) NSDate *maxLimitDate;//限制最大时间（没有设置默认2049）
@property (nonatomic, retain) NSDate *minLimitDate;//限制最小时间（没有设置默认1970）

-(instancetype)initWithCurrentDate:(NSDate *)currentDate;

@end
