//
//  ViewController.m
//  VsonBleLibDemo
//
//  Created by kakaxi on 15/9/1.
//  Copyright (c) 2015年 kakaxi. All rights reserved.
//

#import "ViewController.h"
#import "VsonBleProcess.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define SCREEN_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define SCREEN_WIDTH  [[UIScreen mainScreen]bounds].size.width
#define LastConnectPeripheralUUID   @"LastConnectPeripheralUUID"

@interface ViewController ()<VsonBLEDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    VsonBleProcess *m_vsonBle;
    UITableView  *m_tableView_peripherals;
    NSMutableArray *m_array_peripherals;
    UITextField *m_textfield_interval;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    /*It is very important set delegate */
    m_vsonBle = [VsonBleProcess sharedInstance];
    m_vsonBle.delegate = self;
    
    [self setupView];
    
}

-(void)viewWillAppear:(BOOL)animated
{
     m_vsonBle.delegate = self;
}
-(void)viewWillDisappear:(BOOL)animated
{
     m_vsonBle.delegate = nil;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [m_textfield_interval resignFirstResponder];
}

-(void)setupView
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button_scan = [UIButton buttonWithType:UIButtonTypeCustom];
    button_scan.frame = CGRectMake(100, 40, SCREEN_WIDTH-200, 40);
    button_scan.layer.cornerRadius = 6.0;
    [button_scan setBackgroundImage:[UIImage imageNamed:@"btn_SendData.png"] forState:0];
    [button_scan setBackgroundImage:[UIImage imageNamed:@"btn_SendDataTouchDown.png"] forState:UIControlStateHighlighted];
    [button_scan setTitle:NSLocalizedString(@"SCAN", nil) forState:0];
    [button_scan addTarget:self action:@selector(scanPeripheral:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_scan];
    
    m_tableView_peripherals            = [[UITableView alloc]initWithFrame:CGRectMake(10, 90, SCREEN_WIDTH-20, 150)];
    m_tableView_peripherals.delegate   = self;
    m_tableView_peripherals.dataSource = self;
    m_tableView_peripherals.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
    
    m_array_peripherals = [[NSMutableArray alloc]init];
    [self.view addSubview:m_tableView_peripherals];
    
    
    //init device
    UILabel *lable_initDeveice = [[UILabel alloc]initWithFrame:CGRectMake(10, 250, 50, 30)];
    lable_initDeveice.text     = @"Init";
    [self.view addSubview:lable_initDeveice];
    
    UIButton *button_initDevice = [UIButton buttonWithType:UIButtonTypeSystem];
    button_initDevice.frame     = CGRectMake(SCREEN_WIDTH-60, 250, 50, 30);
    [button_initDevice setTitle:@"SET" forState:0];
    [button_initDevice addTarget:self action:@selector(initPeripheral:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_initDevice];
    
    UIImageView *imageView_line0 = [[UIImageView alloc]initWithFrame:CGRectMake(10, 280, SCREEN_WIDTH, 1)];
    imageView_line0.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:imageView_line0];

    
    //open device SPK
    UILabel *lable_openSPK = [[UILabel alloc]initWithFrame:CGRectMake(10, 285, 50, 30)];
    lable_openSPK.text     = @"SPK";
    [self.view addSubview:lable_openSPK];
    
    UISwitch *switch_openSPK = [[UISwitch alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-60, 285, 50, 30)];
    [switch_openSPK addTarget:self action:@selector(openPeripheralSPK:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:switch_openSPK];
    
    UIImageView *imageView_line = [[UIImageView alloc]initWithFrame:CGRectMake(10, 315, SCREEN_WIDTH, 1)];
    imageView_line.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:imageView_line];
    
    
    // device InterVal
    UILabel *lable_remindInterval = [[UILabel alloc]initWithFrame:CGRectMake(10, 320, 100, 30)];
    lable_remindInterval.text     = @"Alert InterVal";
    [self.view addSubview:lable_remindInterval];
    
    m_textfield_interval = [[UITextField alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2, 320, 50, 30)];
    m_textfield_interval.borderStyle  = UITextBorderStyleRoundedRect;
    m_textfield_interval.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:m_textfield_interval];
    
    UIButton *button_interval = [UIButton buttonWithType:UIButtonTypeSystem];
    button_interval.frame     = CGRectMake(SCREEN_WIDTH-60, 320, 50, 30);
    [button_interval setTitle:@"SET" forState:0];
    //button_interval.backgroundColor = [UIColor colorWithRed:100/255.0 green:200/255.0 blue:100/255.0 alpha:1.0];
    [button_interval addTarget:self action:@selector(setPeripheralRemindInterVal:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_interval];
    
    UIImageView *imageView_line2 = [[UIImageView alloc]initWithFrame:CGRectMake(10, 350, SCREEN_WIDTH, 1)];
    imageView_line2.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:imageView_line2];
    
}


#pragma mark-VsonBleDelegate
-(void) peripheralDidUpdateValue:(unsigned char *)receiveData DataLength:(UInt16)length DataType:(Const_receive_data_type)dataType ;
{
    
    unsigned char * recdata = receiveData;
    unsigned char temp=0x00;
    
    switch (dataType) {
        case const_drink_one_more:
        {
            NSLog(@"const_drink_one_more");
            NSDate *now = [NSDate date];
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSUInteger unitFlags  = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
            NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
            
            if((recdata[0]>99) || (recdata[0]==0) || (recdata[1]>12) || (recdata[1]==0) || (recdata[2]>31 ) || (recdata[2]==0) || (recdata[3]>24) || (recdata[4]>60) || (recdata[5]>60))
            {
               return;
            }
            
            int year = (int)[dateComponent year];
            int month = (int)[dateComponent month];
            int day = (int)[dateComponent day];
            int drink_vol = (recdata[6]<<8)  + recdata[7];
            
            
            int idata_year = recdata[0];
            if(idata_year > year-2000)
            {
                idata_year = idata_year -1;
            }
            
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            NSString *tempdate   = [NSString stringWithFormat:@"%d%d%d%d%d%d",recdata[0],recdata[1],recdata[2],recdata[3],recdata[4],recdata[5]];
            NSString *tempbefore = [user objectForKey:@"LastRecordTime"];
            if (tempbefore!=nil && [tempbefore isEqualToString:tempdate]) {
                /* this is repeat data ,not need save*/
                return;
            }
            [user setObject:tempdate forKey:@"LastRecordTime"];
            
            
            if((idata_year != year-2000) || (recdata[1] != month) || (recdata[2] != day))
            {
                //this is history drink data, you need save this drink data
                NSLog(@"drink_vol  history= %d",drink_vol);
            }
            else
            {
                //this is current drink data, you need save this drink data
                 NSLog(@"drink_vol now = %d",drink_vol);
            }
        }
            break;
        case const_charge_status:
        {
            //battery values is  1--100
            temp = recdata[0];
            NSLog(@"current battery is %d",temp);
        }
            break;
        case const_device_output_vol:
        {
             NSLog(@"const_device_output_vol %s ",receiveData);
        }
            break;
        case const_generor_comm_data:
        {
            NSLog(@"receive general data is %s , now not use",receiveData);
        }
            break;
        default:
            break;
    }
}
-(void) scanResult:(NSMutableArray *)peripherals_name;
{
    if (peripherals_name.count < 1) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"No cup to be scanned", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSLog(@"peripherals_name");
    m_array_peripherals = peripherals_name;
    [m_tableView_peripherals reloadData];
    
}

-(void)afterConnectedPeripheral;
{
    [m_vsonBle sendRemindIntervalDataToPeripheralWithRemindInterval:0];
    
}
-(void) peripheralConnectStateChanged:(Const_ble_status)inStatuCode;
{
    switch (inStatuCode) {
        case const_ble_status_scaning:
        {
            NSLog(@"const_ble_status_scaning");
        }
            break;
        case const_ble_status_connecting:
        {
            NSLog(@"const_ble_status_connecting");
        }
            break;
        case const_ble_status_connceted:
        {
            NSLog(@"const_ble_status_connceted");
        }
            break;
        case const_ble_status_disconnected:
        {
            NSLog(@"const_ble_status_disconnected");
        }
            break;
        default:
            break;
    }
}
-(void) setPeripheralSuccessResponse:(SetPeripheralSuccessType)SuccessType;
{
    switch (SuccessType) {
        case SuccessType_SetName:
        {
            NSLog(@"SetName Success");
        }
            break;
        case SuccessType_Init:
        {
             NSLog(@"Init Success");
        }
            break;
        case SuccessType_Normal:
        {
            NSLog(@"Set Success");
        }
            break;
        default:
            break;
    }
    
}

#pragma mark
#pragma mark-Demo Method
-(void)scanPeripheral:(UIButton *)sender
{
    /**
     * if you want to connect last Connected perihperal ,you can put the UUID save in NSUserDefaults to  connectedPeripheralUUID param
     * else you can put the Param is NULL
    */
    NSString *lastConnectedPeripheralUUID = [[NSUserDefaults standardUserDefaults] stringForKey:LastConnectPeripheralUUID];
    if (lastConnectedPeripheralUUID.length>10) {
        [m_vsonBle scanPeripheralsWithTimer:6 connectedPeripheralUUID:lastConnectedPeripheralUUID];
    }else{
        [m_vsonBle scanPeripheralsWithTimer:6 connectedPeripheralUUID:NULL];
    }

}

/**
 * @brief open/close cup SPK
 */
-(void)openPeripheralSPK:(UISwitch *)sender
{
     if ([m_vsonBle checkPeripheralConnectStatus]) {
         [m_vsonBle sendOpenSPKDataToDevice:sender.on];
     }
}

/**
 * @brief init cup weight
 */
-(void)initPeripheral:(UIButton *)sender
{
    if ([m_vsonBle checkPeripheralConnectStatus]) {
        [m_vsonBle SendInitDeviceWeightToDevice];
    }
}

/**
 * @brief set peripheral Remind InterVal
 */
-(void)setPeripheralRemindInterVal:(UIButton *)sender
{
    [m_textfield_interval resignFirstResponder];
    int interval = [m_textfield_interval.text intValue];
    if (interval>24*60) {
        NSLog(@"too big");
        return;
    }
    if ([m_vsonBle checkPeripheralConnectStatus]) {
        [m_vsonBle sendRemindIntervalDataToPeripheralWithRemindInterval:interval];
    }
}


/**
 * @brief newName   Name only support length is 6 alphanumeric combination  like :cup888 / abc123 / 123uuu
 */
-(void)setPeripheralName:(NSString *)newName
{
    if(newName.length>=6)
    {
        NSLog(@"new name too long");
    }
    
    if ([m_vsonBle checkPeripheralConnectStatus]) {
        NSData *namedata = [newName dataUsingEncoding: NSUTF8StringEncoding];
        Byte *namebyte = (Byte *)[namedata bytes];
        
        Byte send_data[7]={0};
        int i=0;
        
        send_data[0] = 0x01;
        
        if(newName.length>=6)
        {
            send_data[1] = namebyte[0];
            send_data[2] = namebyte[1];
            send_data[3] = namebyte[2];
            send_data[4] = namebyte[3];
            send_data[5] = namebyte[4];
            send_data[6] = namebyte[5];
        }
        else
        {
            for(i=1;i<newName.length+1;i++)
                send_data[i] = namebyte[i-1];
            
            for(i=newName.length+1;i<7;i++)
                send_data[i] = 0x00;
        }
        
        NSData *adata = [[NSData alloc] initWithBytes:send_data length:7];
        [m_vsonBle sendDeviceNewNameToDeviceWithName:adata];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_array_peripherals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *const iden = @"iden";
    UITableViewCell *_tableCell = [tableView dequeueReusableCellWithIdentifier:iden];
    if (!_tableCell) {
        _tableCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:iden];
        _tableCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    _tableCell.textLabel.text = [m_array_peripherals objectAtIndex:indexPath.row];
    return _tableCell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 0.4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
{
    return 0.4;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    /*you can save this peripheral UUID ,for next connect can use it direct connect this one */
    NSString *currentPeripheralUUID  = [m_vsonBle connectPeripheralWithIndex:(int)indexPath.row];
    NSLog(@"currentPeripheralUUID = %@",currentPeripheralUUID);
    
    [[NSUserDefaults standardUserDefaults]setObject:currentPeripheralUUID forKey:LastConnectPeripheralUUID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [m_array_peripherals removeAllObjects];
    [m_tableView_peripherals reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
