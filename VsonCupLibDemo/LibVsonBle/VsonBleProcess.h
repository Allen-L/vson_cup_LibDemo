//
//  VsonBleProcess.h
//  libVsonBle
//
//  Created by vson on 15/7/6.
//  Copyright (c) 2015年 vson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

//SINGLETON
#undef	AS_SINGLETON
#define AS_SINGLETON( __class ) \
    + (__class *)sharedInstance;

#undef	DEF_SINGLETON
#define DEF_SINGLETON( __class ) \
    + (__class *)sharedInstance \
    { \
        static dispatch_once_t once; \
        static __class * __singleton__; \
        dispatch_once( &once, ^{ __singleton__ = [[__class alloc] init]; } ); \
        return __singleton__; \
    }


typedef NS_ENUM(NSInteger, Const_ble_status) {
    const_ble_status_scan = 0,
    const_ble_status_scaning = 1,
    const_ble_status_connecting = 2,
    const_ble_status_connceted = 3,
    const_ble_status_disconnected = 4
};

typedef NS_ENUM(NSInteger, Const_receive_data_type) {
    const_invalid_data = -1,      //Invalid data
    const_drink_one_more = 0,     //drink data
    const_charge_status = 1,      //current peripheral battery state
    const_device_output_vol = 2,  //Deprecated
    const_generor_comm_data = 3   //General data
};

typedef NS_ENUM(NSInteger, SetPeripheralSuccessType) {
    SuccessType_CallBrate = 0,      //Deprecated
    SuccessType_SetName   = 1,      //Set Name Success
    SuccessType_Bind      = 2,      //Deprecated
    SuccessType_UnBind    = 3,      //Deprecated
    SuccessType_Init      = 4,      //init Success
    SuccessType_Normal    = 5       //General Settings peripherals, such as modified water plan, switch peripherals buzzer Success
};


#pragma mark
#pragma mark-All of the protocol, please implement in your program

@protocol VsonBLEDelegate

/**
 *@brief    This method is active when peripherals to mobile phones to send data by the method called, all of the peripherals sent to mobile phone Numbers are callback this method
 *@param receiveData  phone receive data
 *@param length       data length
 *@param dataType     data type
 */
-(void) peripheralDidUpdateValue:(unsigned char *)receiveData DataLength:(UInt16)length DataType:(Const_receive_data_type)dataType ;


/**
 *@brief This method is that when you call a method  -(int) scanPeripheralsWithTimer:(int) timeout  connectedPeripheralUUID:(NSString *)PeripheralUUID; ，Timer stopScan, is returned to you scan to the total number of peripherals
 *@param peripherals_name  the array name of peripherals
 */
-(void) scanResult:(NSMutableArray *)peripherals_name;

/**
 *@brief This method is when peripheral bluetooth state change callback methods, such as have connected/disconnection
 *@param inStatuCode Current state of the peripheral
 */
-(void) peripheralConnectStateChanged:(Const_ble_status)inStatuCode;


/**
 *@brief  This Method is used to show that has been connected to the peripherals
 */
-(void)afterConnectedPeripheral;

/**
 *@brief This method is when phone set peripheral, set up the success will callback method, you need to determine type of success, to perform the corresponding operation
 *@param SuccessType Set the type of success
 */
-(void) setPeripheralSuccessResponse:(SetPeripheralSuccessType)SuccessType;

@end


@interface VsonBleProcess : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate> {
}

AS_SINGLETON(VsonBleProcess)

@property (nonatomic,assign) id <VsonBLEDelegate> delegate;

/**
 *@brief This method is used for active scan peripherals,
 *@param timeout           Scan time for timer
 *@param PeripheralUUID    last time had connected peripherals UUID
 */
-(int) scanPeripheralsWithTimer:(int) timeout  connectedPeripheralUUID:(NSString *)PeripheralUUID;

/**
 *@brief  This method is used to check whether the current connection of peripheral you is still in the connection status  ture: show already connected  false:not connect
 */
-(BOOL) checkPeripheralConnectStatus;

/**
 *@brief Method is used to connect you to specify an array subscript peripherals, when you call after scanning methods, will give you a scan to peripheral array, by specifying the array subscript to connect to the peripherals, the return value for the current want to link the peripheral UUID
 *@param inindex        Want to connect a peripheral array index
 */
-(NSString*) connectPeripheralWithIndex:(int)inindex;

/**
 *@brief This method is applied to disconnect peripherals
 */
-(void) disConnectPeripheral;


/**
 *@brief Initialization method is used to send data to the peripherals, the method is used to initialize the weight of the cup mat, also is the own weight of calibration coasters, send data should prompt the user before take off cup mat cup body
 */
-(void) SendInitDeviceWeightToDevice;

/**
 *@brief This method is used to send data to the peripherals peripherals whether to open the buzzer, speaker
 *@param isNeedOpen     Whether you need to open the speaker
 */
-(void) sendOpenSPKDataToDevice:(BOOL)isNeedOpen;

/**
 *@brief Method is used to send user set the new name for the peripheral devices, type in Chinese is not currently supported
 *@param indata     Need to send the name of the data
 */
-(void) sendDeviceNewNameToDeviceWithName:(NSData * )indata;

/**
 *@brief Method is used to set the type of data to the peripherals
 *@param indata  Need to send the set of the data
 */
-(void) sendSetTypeDataToDevice:(NSData * )indata;


/**
 *@brief    Method is used to set reminder water interval data to the peripherals
 *@param interval   Remind drink interval
 */
-(void)sendRemindIntervalDataToPeripheralWithRemindInterval:(int)interval;
/**
 *@brief Method is used to set free to disturb the time data to the peripheral
 *@param sessionOneBeginHour        SessionOneBeginHour
 *@param sessionOneBeginMin         SessionOneBeginMin
 *@param sessionOneEndHour          SessionOneEndHour
 *@param sessionOneEndMin           SessionOneEndMin
 *@param sessionTwoBeginHour        SessionTwoBeginHour
 *@param sessionTwoBeginMin         SessionTwoBeginMin
 *@param sessionTwoEndHour          SessionTwoEndHour
 *@param sessionTwoEndMin           SessionTwoEndMin
 */
- (void) SendNoRemindDataToPeripheralWithSessionOneBeginHour:(int)sessionOneBeginHour SessionOneBeginMin:(int)sessionOneBeginMin SessionOneEndHour:(int)sessionOneEndHour SessionOneEndMin:(int)sessionOneEndMin SessionTwoBeginHour:(int)sessionTwoBeginHour SessionTwoBeginMin:(int)sessionTwoBeginMin SessionTwoEndHour:(int)sessionTwoEndHour SessionTwoEndMin:(int)sessionTwoEndMin;



/**
 *@brief        Method is through the general channel, send data to the hardware, the general channels: refers to the mobile terminal to invoke this method to the peripherals to send data, the library will not do any processing, will send the customer data was sent to a peripheral side, facilitating the clients to their custom other data you want to add
 *@param command    Data types (late after the user to identify, can with our hardware engineer agree on the meaning of the command code)
 *@param length     Data length, the length does not include the length bytes per se, just behind the value with the length of the data parameter
 *@param data       Send the specific data
 */
-(void) sendGeneralDatasToDeviceWithCommandType:(Byte)command  DataLength:(Byte)length Data:(NSData *)data;

#pragma mark
#pragma mark  Deprecated Method 已经弃用


/**
 *@brief 方法用于发送请求绑定的数据给外设
 *@param isNeedBind  是否需要绑定当前连接的设备
 */
-(void) sendBindDataToDevice:(BOOL)isNeedBind;

@end
