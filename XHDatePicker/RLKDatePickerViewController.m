//
//  RLKDatePickerViewController.m
//  XHDatePicker
//
//  Created by Realank on 2017/10/13.
//  Copyright © 2017年 Realank. All rights reserved.
//
#import "RLKDatePickerViewController.h"
#import "NSDate+XHExtension.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kPickerSize self.datePicker.frame.size
#define RGBA(r, g, b, a) ([UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:a])
#define RGB(r, g, b) RGBA(r,g,b,1)


#define MAXYEAR 2050
#define MINYEAR 1970


@interface RLKDatePickerViewController ()<UIPickerViewDelegate,UIPickerViewDataSource,UIGestureRecognizerDelegate> {
    //日期存储数组
    NSMutableArray *_yearArray;
    NSMutableArray *_monthArray;
    NSMutableArray *_dayArray;
    NSMutableArray *_hourArray;
    NSMutableArray *_minuteArray;
    NSMutableArray *_secondArray;
    NSString *_dateFormatter;
    //记录位置
    NSInteger yearIndex;
    NSInteger monthIndex;
    NSInteger dayIndex;
    NSInteger hourIndex;
    NSInteger minuteIndex;
    NSInteger secondIndex;
    
    NSInteger preRow;
    
    NSDate *_startDate;
    NSDate *_endDate;
}
@property (weak, nonatomic) IBOutlet UIView *buttomView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentView;
@property (weak, nonatomic) IBOutlet UILabel *showYearView;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;


@property (nonatomic,strong)UIPickerView *datePicker;
@property (nonatomic, retain) NSDate *scrollToDate;//滚到指定日期
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;


@end

@implementation RLKDatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUI];
    [_datePicker reloadAllComponents];
}

-(instancetype)init{
    return [self initWithCurrentDate:nil];
}

-(instancetype)initWithCurrentDate:(NSDate *)currentDate{
    self = [super init];
    if (self) {
        _scrollToDate = currentDate;
        _dateFormatter = @"yyyy-MM-dd HH:mm:ss";
        
        [self defaultConfig];
    }
    return self;
}

-(void)setupUI {
    self.segmentView.selectedSegmentIndex = 0;
    [self.segmentView addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
    self.themeColor = RGB(247, 133, 51);
    
    [self.showYearView addSubview:self.datePicker];
    [self updateInfomationLabel];
}

- (void)updateInfomationLabel{
    NSString* fromString = @"--";
    NSString* toString = @"--";
    if (_startDate) {
        fromString = [_startDate stringWithFormat:@"MMM dd,yyyy HH:mm:ss"];
    }
    if (_endDate) {
        toString = [_endDate stringWithFormat:@"MMM dd,yyyy HH:mm:ss"];
    }
    NSString* result = [NSString stringWithFormat:@"%@ To %@",fromString,toString];
    _informationLabel.text = result;
}

-(void)defaultConfig {
    
    if (!_scrollToDate) {
        _scrollToDate = [NSDate date];
    }
    
    
    //循环滚动时需要用到
    preRow = (self.scrollToDate.year-MINYEAR)*12+self.scrollToDate.month-1;
    
    //设置年月日时分数据
    _yearArray = [self setArray:_yearArray];
    _monthArray = [self setArray:_monthArray];
    _dayArray = [self setArray:_dayArray];
    _hourArray = [self setArray:_hourArray];
    _minuteArray = [self setArray:_minuteArray];
    _secondArray = [self setArray:_secondArray];
    
    for (int i=0; i<60; i++) {
        NSString *num = [NSString stringWithFormat:@"%02d",i];
        if (0<i && i<=12)
            [_monthArray addObject:num];
        if (i<24)
            [_hourArray addObject:num];
        [_minuteArray addObject:num];
        [_secondArray addObject:num];
    }
    for (NSInteger i=MINYEAR; i<MAXYEAR; i++) {
        NSString *num = [NSString stringWithFormat:@"%ld",(long)i];
        [_yearArray addObject:num];
    }
    
    //最大最小限制
    if (!self.maxLimitDate) {
        self.maxLimitDate = [NSDate date:@"2049-12-31 23:59" WithFormat:@"yyyy-MM-dd HH:mm"];
    }
    //最小限制
    if (!self.minLimitDate) {
        self.minLimitDate = [NSDate dateWithTimeIntervalSince1970:0];
    }
    
}

-(void)addLabelWithName:(NSArray *)nameArr {
    for (id subView in self.showYearView.subviews) {
        if ([subView isKindOfClass:[UILabel class]]) {
            [subView removeFromSuperview];
        }
    }
    for (int i=0; i<nameArr.count; i++) {
        CGFloat labelX = kPickerSize.width/(nameArr.count*2)+10+kPickerSize.width/nameArr.count*i;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(labelX, self.showYearView.frame.size.height/2-15, 40, 15)];
        label.text = nameArr[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = self.themeColor;
        label.backgroundColor = [UIColor clearColor];
        [self.showYearView addSubview:label];
    }
}


- (NSMutableArray *)setArray:(id)mutableArray
{
    if (mutableArray)
        [mutableArray removeAllObjects];
    else
        mutableArray = [NSMutableArray array];
    return mutableArray;
}

#pragma mark - UIPickerViewDelegate,UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    switch (self.datePickerStyle) {
        case DateStyleShowYearMonthDayHourMinute:
            [self addLabelWithName:@[@"年",@"月",@"日",@"时",@"分"]];
            return 5;
        case DateStyleShowYearMonthDay:
            [self addLabelWithName:@[@"年",@"月",@"日"]];
            return 3;
        case DateStyleShowMonthDayHourMinute:
            [self addLabelWithName:@[@"月",@"日",@"时",@"分"]];
            return 4;
        case DateStyleShowMonthDay:
            [self addLabelWithName:@[@"月",@"日"]];
            return 2;
        case DateStyleShowHourMinute:
            [self addLabelWithName:@[@"时",@"分"]];
            return 2;
        case DateStyleShowMonthDayHourMinuteSecond:
            [self addLabelWithName:@[@"M",@"D",@"Hr",@"Min",@"Sec"]];
            return 5;
        default:
            return 0;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray *numberArr = [self getNumberOfRowsInComponent];
    return [numberArr[component] integerValue];
}

-(NSArray *)getNumberOfRowsInComponent {
    
    NSInteger yearNum = _yearArray.count;
    NSInteger monthNum = _monthArray.count;
    NSInteger dayNum = [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
    NSInteger hourNum = _hourArray.count;
    NSInteger minuteNum = _minuteArray.count;
    NSInteger secondNum = _secondArray.count;
    NSInteger timeInterval = MAXYEAR - MINYEAR;
    
    switch (self.datePickerStyle) {
        case DateStyleShowYearMonthDayHourMinute:
            return @[@(yearNum),@(monthNum),@(dayNum),@(hourNum),@(minuteNum)];
            break;
        case DateStyleShowMonthDayHourMinute:
            return @[@(monthNum*timeInterval),@(dayNum),@(hourNum),@(minuteNum)];
            break;
        case DateStyleShowYearMonthDay:
            return @[@(yearNum),@(monthNum),@(dayNum)];
            break;
        case DateStyleShowMonthDay:
            return @[@(monthNum*timeInterval),@(dayNum),@(hourNum)];
            break;
        case DateStyleShowHourMinute:
            return @[@(hourNum),@(minuteNum)];
            break;
        case DateStyleShowMonthDayHourMinuteSecond:
            return @[@(monthNum*timeInterval),@(dayNum),@(hourNum),@(minuteNum),@(secondNum)];
        default:
            return @[];
            break;
    }
    
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}


-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *customLabel = (UILabel *)view;
    if (!customLabel) {
        customLabel = [[UILabel alloc] init];
        customLabel.textAlignment = NSTextAlignmentCenter;
        [customLabel setFont:[UIFont systemFontOfSize:17]];
    }
    NSString *title;
    
    switch (self.datePickerStyle) {
        case DateStyleShowYearMonthDayHourMinute:
            if (component==0) {
                title = _yearArray[row];
            }else if (component==1) {
                title = _monthArray[row];
            }else if (component==2) {
                title = _dayArray[row];
            }else if (component==3) {
                title = _hourArray[row];
            }else if (component==4) {
                title = _minuteArray[row];
            }
            break;
        case DateStyleShowYearMonthDay:
            if (component==0) {
                title = _yearArray[row];
            }else if (component==1) {
                title = _monthArray[row];
            }else if (component==2) {
                title = _dayArray[row];
            }
            break;
        case DateStyleShowMonthDayHourMinute:
            if (component==0) {
                title = _monthArray[row%12];
            }else if (component==1) {
                title = _dayArray[row];
            }else if (component==2) {
                title = _hourArray[row];
            }else if (component==3) {
                title = _minuteArray[row];
            }
            break;
        case DateStyleShowMonthDay:
            if (component==0) {
                title = _monthArray[row%12];
            }else if (component==1) {
                title = _dayArray[row];
            }
            break;
        case DateStyleShowHourMinute:
            if (component==0) {
                title = _hourArray[row];
            }else if (component==1) {
                title = _minuteArray[row];
            }
            break;
        case DateStyleShowMonthDayHourMinuteSecond:
            if (component==0) {
                NSArray* monthArray = @[@"Jan",@"Feb",@"Mar",@"Apr",@"May",@"Jun",@"Jul",@"Aug",@"Sep",@"Oct",@"Nov",@"Dec"];
                NSInteger monthIndex = ((NSString*)(_monthArray[row%12])).integerValue - 1;
                title = monthArray[monthIndex];
            }else if (component==1) {
                title = _dayArray[row];
            }else if (component==2) {
                title = _hourArray[row];
            }else if (component==3) {
                title = _minuteArray[row];
            }else if (component==4) {
                title = _secondArray[row];
            }
            break;
        default:
            title = @"";
            break;
    }
    
    customLabel.text = title;
    customLabel.textColor = [UIColor blackColor];
    return customLabel;
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (self.datePickerStyle) {
        case DateStyleShowYearMonthDayHourMinute:{
            
            if (component == 0) {
                yearIndex = row;
                
                self.showYearView.text =_yearArray[yearIndex];
            }
            if (component == 1) {
                monthIndex = row;
            }
            if (component == 2) {
                dayIndex = row;
            }
            if (component == 3) {
                hourIndex = row;
            }
            if (component == 4) {
                minuteIndex = row;
            }
            if (component == 0 || component == 1){
                [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
                if (_dayArray.count-1<dayIndex) {
                    dayIndex = _dayArray.count-1;
                }
                
            }
        }
            break;
            
            
        case DateStyleShowYearMonthDay:{
            
            if (component == 0) {
                yearIndex = row;
                self.showYearView.text =_yearArray[yearIndex];
            }
            if (component == 1) {
                monthIndex = row;
            }
            if (component == 2) {
                dayIndex = row;
            }
            if (component == 0 || component == 1){
                [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
                if (_dayArray.count-1<dayIndex) {
                    dayIndex = _dayArray.count-1;
                }
            }
        }
            break;
            
            
        case DateStyleShowMonthDayHourMinute:{
            
            
            if (component == 1) {
                dayIndex = row;
            }
            if (component == 2) {
                hourIndex = row;
            }
            if (component == 3) {
                minuteIndex = row;
            }
            
            if (component == 0) {
                
                [self yearChange:row];
                
                if (_dayArray.count-1<dayIndex) {
                    dayIndex = _dayArray.count-1;
                }
            }
            [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
            
        }
            break;
            
        case DateStyleShowMonthDay:{
            if (component == 1) {
                dayIndex = row;
            }
            if (component == 0) {
                
                [self yearChange:row];
                
                if (_dayArray.count-1<dayIndex) {
                    dayIndex = _dayArray.count-1;
                }
            }
            [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
        }
            break;
            
        case DateStyleShowHourMinute:{
            if (component == 0) {
                hourIndex = row;
            }
            if (component == 1) {
                minuteIndex = row;
            }
        }
            break;
        case DateStyleShowMonthDayHourMinuteSecond:{
            
            
            if (component == 1) {
                dayIndex = row;
            }
            if (component == 2) {
                hourIndex = row;
            }
            if (component == 3) {
                minuteIndex = row;
            }
            if (component == 4) {
                secondIndex = row;
            }
            
            if (component == 0) {
                
                [self yearChange:row];
                
                if (_dayArray.count-1<dayIndex) {
                    dayIndex = _dayArray.count-1;
                }
            }
            [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
            
        }
            break;
        default:
            break;
    }
    
    [pickerView reloadAllComponents];
    
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@",_yearArray[yearIndex],_monthArray[monthIndex],_dayArray[dayIndex],_hourArray[hourIndex],_minuteArray[minuteIndex],_secondArray[secondIndex]];
    
    self.scrollToDate = [[NSDate date:dateStr WithFormat:@"yyyy-MM-dd HH:mm:ss"] dateWithFormatter:_dateFormatter];
    
    if ([self.scrollToDate compare:self.minLimitDate] == NSOrderedAscending) {
        self.scrollToDate = self.minLimitDate;
        [self getNowDate:self.minLimitDate animated:YES];
    }
    if ([self.scrollToDate compare:self.maxLimitDate] == NSOrderedDescending){
        self.scrollToDate = self.maxLimitDate;
        [self getNowDate:self.maxLimitDate animated:YES];
    }
    if (self.dateType == DateTypeEndDate && [self.scrollToDate compare:_startDate] == NSOrderedAscending){
        self.scrollToDate = _startDate;
        [self getNowDate:_startDate animated:YES];
    }
    
    switch (self.dateType) {
        case DateTypeStartDate:
            _startDate = self.scrollToDate;
            break;
            
        default:
            _endDate = self.scrollToDate;
            break;
    }
    
    
    NSLog(@"%@",self.scrollToDate);
    [self updateInfomationLabel];
}

-(void)yearChange:(NSInteger)row {
    
    monthIndex = row%12;
    
    //年份状态变化
    if (row-preRow <12 && row-preRow>0 && [_monthArray[monthIndex] integerValue] < [_monthArray[preRow%12] integerValue]) {
        yearIndex ++;
    } else if(preRow-row <12 && preRow-row > 0 && [_monthArray[monthIndex] integerValue] > [_monthArray[preRow%12] integerValue]) {
        yearIndex --;
    }else {
        NSInteger interval = (row-preRow)/12;
        yearIndex += interval;
    }
    
    self.showYearView.text = _yearArray[yearIndex];
    
    preRow = row;
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if( [touch.view isDescendantOfView:self.buttomView]) {
        return NO;
    }
    return YES;
}



#pragma mark - Action




-(void)segmentAction:(UISegmentedControl *)segment {
    self.dateType = (int)segment.selectedSegmentIndex;
    switch (self.dateType) {
        case DateTypeStartDate:
            if (_startDate) {
                self.scrollToDate = _startDate;
            }
            break;
            
        default:
            if (_endDate) {
                self.scrollToDate = _endDate;
            }
            break;
    }
    [self getNowDate:self.scrollToDate animated:_endDate];
}

- (IBAction)doneAction:(UIButton *)btn {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - tools
//通过年月求每月天数
- (NSInteger)DaysfromYear:(NSInteger)year andMonth:(NSInteger)month
{
    NSInteger num_year  = year;
    NSInteger num_month = month;
    
    BOOL isrunNian = num_year%4==0 ? (num_year%100==0? (num_year%400==0?YES:NO):YES):NO;
    switch (num_month) {
        case 1:case 3:case 5:case 7:case 8:case 10:case 12:{
            [self setdayArray:31];
            return 31;
        }
        case 4:case 6:case 9:case 11:{
            [self setdayArray:30];
            return 30;
        }
        case 2:{
            if (isrunNian) {
                [self setdayArray:29];
                return 29;
            }else{
                [self setdayArray:28];
                return 28;
            }
        }
        default:
            break;
    }
    return 0;
}

//设置每月的天数数组
- (void)setdayArray:(NSInteger)num
{
    [_dayArray removeAllObjects];
    for (int i=1; i<=num; i++) {
        [_dayArray addObject:[NSString stringWithFormat:@"%02d",i]];
    }
}

//滚动到指定的时间位置
- (void)getNowDate:(NSDate *)date animated:(BOOL)animated
{
    if (!date) {
        date = [NSDate date];
    }
    
    [self DaysfromYear:date.year andMonth:date.month];
    
    yearIndex = date.year-MINYEAR;
    monthIndex = date.month-1;
    dayIndex = date.day-1;
    hourIndex = date.hour;
    minuteIndex = date.minute;
    secondIndex = date.seconds;
    
    //循环滚动时需要用到
    preRow = (self.scrollToDate.year-MINYEAR)*12+self.scrollToDate.month-1;
    
    NSArray *indexArray;
    
    if (self.datePickerStyle == DateStyleShowYearMonthDayHourMinute){
        indexArray = @[@(yearIndex),@(monthIndex),@(dayIndex),@(hourIndex),@(minuteIndex)];
    }else if (self.datePickerStyle == DateStyleShowYearMonthDay){
        indexArray = @[@(yearIndex),@(monthIndex),@(dayIndex)];
    }else if (self.datePickerStyle == DateStyleShowMonthDayHourMinute){
        indexArray = @[@(monthIndex),@(dayIndex),@(hourIndex),@(minuteIndex)];
    }else if (self.datePickerStyle == DateStyleShowMonthDay){
        indexArray = @[@(monthIndex),@(dayIndex)];
    }else if (self.datePickerStyle == DateStyleShowHourMinute){
        indexArray = @[@(hourIndex),@(minuteIndex)];
    }else if (self.datePickerStyle == DateStyleShowMonthDayHourMinuteSecond){
        indexArray = @[@(monthIndex),@(dayIndex),@(hourIndex),@(minuteIndex),@(secondIndex)];
    }
    
    
    self.showYearView.text = _yearArray[yearIndex];
    
    [self.datePicker reloadAllComponents];
    
    for (int i=0; i<indexArray.count; i++) {
        if ((self.datePickerStyle == DateStyleShowMonthDayHourMinute || self.datePickerStyle == DateStyleShowMonthDay || self.datePickerStyle == DateStyleShowMonthDayHourMinuteSecond)&& i==0) {
            NSInteger mIndex = [indexArray[i] integerValue]+(12*(self.scrollToDate.year - MINYEAR));
            [self.datePicker selectRow:mIndex inComponent:i animated:animated];
        } else {
            [self.datePicker selectRow:[indexArray[i] integerValue] inComponent:i animated:animated];
        }
        
    }
}


#pragma mark - getter / setter
-(UIPickerView *)datePicker {
    if (!_datePicker) {
        [self.showYearView layoutIfNeeded];
        _datePicker = [[UIPickerView alloc] initWithFrame:self.showYearView.bounds];
        _datePicker.showsSelectionIndicator = YES;
        _datePicker.delegate = self;
        _datePicker.dataSource = self;
    }
    return _datePicker;
}

-(void)setMinLimitDate:(NSDate *)minLimitDate {
    _minLimitDate = minLimitDate;
    if ([_scrollToDate compare:self.minLimitDate] == NSOrderedAscending) {
        _scrollToDate = self.minLimitDate;
    }
    [self getNowDate:self.scrollToDate animated:NO];
}

-(void)setMaxLimitDate:(NSDate *)maxLimitDate {
    _maxLimitDate = maxLimitDate;
    if ([_scrollToDate compare:maxLimitDate] == NSOrderedDescending) {
        _scrollToDate = maxLimitDate;
    }
    [self getNowDate:self.scrollToDate animated:NO];
}

-(void)setThemeColor:(UIColor *)themeColor {
    _themeColor = themeColor;
    self.segmentView.tintColor = themeColor;
    self.doneBtn.backgroundColor = themeColor;
}

-(void)setDateType:(XHDateType)dateType {
    _dateType = dateType;
    switch (dateType) {
        case DateTypeStartDate:
            self.segmentView.selectedSegmentIndex = 0;
            break;
            
        default:
            self.segmentView.selectedSegmentIndex = 1;
            break;
    }
}
-(void)setDatePickerStyle:(XHDateStyle)datePickerStyle {
    _datePickerStyle = datePickerStyle;
    switch (datePickerStyle) {
            break;
        case DateStyleShowYearMonthDay:
        case DateStyleShowMonthDay:
            _dateFormatter = @"yyyy-MM-dd";
            break;
            
        default:
            break;
    }
}

@end

