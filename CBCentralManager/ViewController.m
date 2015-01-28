//
//  ViewController.m
//  CBCentralManager
//
//  Created by chunfeng on 14/11/30.
//  Copyright (c) 2014年 chunfeng. All rights reserved.
//

#import "ViewController.h"







#import <CoreBluetooth/CoreBluetooth.h>
static NSString * const kServiceUUID = @"312700E2-E798-4D5C-8DCF-49908332DF9F";
static NSString * const kCharacteristicUUID = @"72C7EA94-A545-B363-2D04-BE44894277A3";

@interface ViewController ()<CBCentralManagerDelegate,
CBPeripheralDelegate>
@property (nonatomic, strong) CBCentralManager *manager;

@property (nonatomic, strong) NSMutableData *data;

@property (nonatomic, strong) CBPeripheral *peripheral;



@property (nonatomic, strong) CBPeripheralManager *managerkk;

@property (nonatomic, strong) CBMutableCharacteristic *customCharacteristic;
@property (nonatomic, strong) CBMutableService *customService;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //1建立中心角色
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    

}

//- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
//    
//    switch (central.state) {
//        case CBCentralManagerStatePoweredOn:
//            break;
//        case CBCentralManagerStatePoweredOff:
//            break;
//            
//        case CBCentralManagerStateUnsupported: {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dang."
//                                                            message:@"Unfortunately this device can not talk to Bluetooth Smart (Low Energy) Devices"
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"Dismiss"
//                                                  otherButtonTitles:nil];
//            
//            [alert show];
//            break;
//        }
//        case CBCentralManagerStateResetting: {
////            [self.peripheralsTableView reloadData];
//            break;
//        }
//        case CBCentralManagerStateUnauthorized:
//            break;
//            
//        case CBCentralManagerStateUnknown:
//            break;
//            
//        default:
//            break;
//    }
//    
//    
//    
//}



//-(void)centralManagerDidUpdateState:(CBCentralManager*)cManager
//{
//    NSMutableString* nsmstring=[NSMutableString stringWithString:@"UpdateState:"];
//    BOOL isWork=FALSE;
//    switch (cManager.state) {
//        case CBCentralManagerStateUnknown:
//            [nsmstring appendString:@"Unknown\n"];
//            break;
//        case CBCentralManagerStateUnsupported:
//            [nsmstring appendString:@"Unsupported\n"];
//            break;
//        case CBCentralManagerStateUnauthorized:
//            [nsmstring appendString:@"Unauthorized\n"];
//            break;
//        case CBCentralManagerStateResetting:
//            [nsmstring appendString:@"Resetting\n"];
//            break;
//        case CBCentralManagerStatePoweredOff:
//            [nsmstring appendString:@"PoweredOff\n"];
////            if (connectedPeripheral!=NULL){
////                [CM cancelPeripheralConnection:connectedPeripheral];
////            }
//            break;
//        case CBCentralManagerStatePoweredOn:
//            [nsmstring appendString:@"PoweredOn\n"];
//            isWork=TRUE;
//            break;
//        default:
//            [nsmstring appendString:@"none\n"];
//            break;
//    }
//    NSLog(@"%@",nsmstring);
////    [delegate didUpdateState:isWork message:nsmstring getStatus:cManager.state];
//}

- (void)centralManagerDidUpdateState:
(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            // Scans for any peripheral
//            [self.manager scanForPeripheralsWithServices:
//  @[ [CBUUID UUIDWithString:kServiceUUID] ]
//                                                 options:@{CBCentralManagerScanOptionAllowDuplicatesKey :
//                                                               @YES }];
            //2扫描外设（discover）
            [self.manager scanForPeripheralsWithServices:nil options:nil];
            
            
            break;
        default:
            NSLog(@"Central Manager did change state");
            break;
    }
}


- (void)setupService {
    // Creates the characteristic UUID
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:kCharacteristicUUID];
    // Creates the characteristic
    self.customCharacteristic = [[CBMutableCharacteristic alloc] initWithType:
                                 characteristicUUID properties:CBCharacteristicPropertyNotify
                                                                        value:nil permissions:CBAttributePermissionsReadable];
    // Creates the service UUID
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];
    // Creates the service and adds the characteristic to it
    self.customService = [[CBMutableService alloc] initWithType:serviceUUID
                                                        primary:YES];
    // Sets the characteristics for this service
    [self.customService setCharacteristics:
     @[self.customCharacteristic]];
    // Publishes the service
    //    [self.peripheralManager addService:self.customService];
    [self.managerkk addService:self.customService];
}

//当周边管理者开始广播服务，他的代理接收-peripheralManagerDidStartAdvertising:error: 消息，并且当中央预定了这个服务，他的代理接收 -peripheralManager:central:didSubscribeToCharacteristic:消息，这儿是你给中央生成动态数据的地方。
//现在，要发送数据到中央，你需要准备一些数据，然后发送updateValue:forCharacteristic:onSubscribedCentrals: 到周边。

- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)service error:(NSError *)error {
    if (error == nil) {
        // Starts advertising the service
        [self.managerkk startAdvertising:
         @{ CBAdvertisementDataLocalNameKey :
                @"ICServer", CBAdvertisementDataServiceUUIDsKey :
                @[[CBUUID UUIDWithString:kServiceUUID]] }];
    }
}

//一旦一个周边在寻找的时候被发现，中央的代理会收到以下回调：这个调用通知Central Manager代理（在这个例子中就是view controller），一个附带着广播数据和信号质量(RSSI-Received Signal Strength Indicator)的周边被发现。这是一个很酷的参数，知道了信号质量，你可以用它去判断远近。
//任何广播、扫描的响应数据保存在advertisementData 中，可以通过CBAdvertisementData 来访问它。现在，你可以停止扫描，而去连接周边了：
- (void)centralManager:(CBCentralManager *)
central didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI{
    
    
    //停止扫描
    // Stops scanning for peripheral
    
//    [self.manager stopScan];
    if (self.peripheral != peripheral) {
        self.peripheral = peripheral;
        NSLog(@"Connecting to peripheral %@", peripheral);
        // Connects to the discovered peripheral
        
        //3连接外设(connect)
        [self.manager connectPeripheral:peripheral options:nil];
    }
    
//    if(![_dicoveredPeripherals containsObject:peripheral])
//        [_dicoveredPeripherals addObject:peripheral];
//    
//    NSLog(@"dicoveredPeripherals:%@", _dicoveredPeripherals);
    
}

//基于连接的结果，代理（这个例子中是view controller）会接收centralManager:didFailToConnectPeripheral:error:或者centralManager:didConnectPeripheral:。如果成功了，你可以问广播服务的那个周边。因此，在didConnectPeripheral 回调中，你可以写以下代码：
- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral {
    
    
    //4扫描外设中的服务和特征(discover)
    
    // Clears the data that we may already have
    [self.data setLength:0];
    // Sets the peripheral delegate
    [self.peripheral setDelegate:self];
    // Asks the peripheral to discover the service
//    [self.peripheral discoverServices:
//  @[ [CBUUID UUIDWithString:kServiceUUID] ]];
    
    [self.peripheral discoverServices:nil];
    
    
}
//现在，周边开始用一个回调通知它的代理。在上一个方法中，我请求周边去寻找服务，周边代理接收-peripheral:didDiscoverServices:。如果没有Error，可以请求周边去寻找它的服务所列出的特征，像以下这么做：
- (void)peripheral:(CBPeripheral *)aPeripheral
didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering service:%@", [error localizedDescription]);
//              [self cleanup];
              return;
              }
    
    //一个设备里的服务和特征往往比较多，大部分情况下我们只是关心其中几个，所以一般会在发现服务和特征的回调里去匹配我们关心那些，比如下面的代码:
for (CBService *service in aPeripheral.services) {
          NSLog(@"Service found with UUID: %@",
                service.UUID);
          // Discovers the characteristics for a given service
//          if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]]) {
//              
//              [self.peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kCharacteristicUUID]] forService:service];
//          
//          }
    [self.peripheral discoverCharacteristics:nil forService:service];
    
}
    

    
}

//现在，如果一个特征被发现，周边代理会接收-peripheral:didDiscoverCharacteristicsForService:error:。现在，一旦特征的值被更新，用-setNotifyValue:forCharacteristic:，周边被请求通知它的代理。
- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:
(CBService *)service error:(NSError *)error {
    
  if (error) {
//      NSLog(@"Error discovering characteristic:%@", [error localizedDescription]);
//            [self cleanup];
       NSLog(@"Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
            return;
            }
    
    
if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]]) {
    
          for (CBCharacteristic *characteristic in service.characteristics) {
              if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicUUID]]) {
                  
                  [peripheral setNotifyValue:YES forCharacteristic:characteristic];
              }
          }
      }
    
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        
            NSLog(@"Discovered read characteristics:%@ for service: %@ -------%@-----%@", characteristic.UUID, service.UUID, characteristic, service);
            
//            _readCharacteristic = characteristic;//保存读的特征
        
//            if ([self.delegate respondsToSelector:@selector(DidFoundReadChar:)])
//                [self.delegate DidFoundReadChar:characteristic];
//            
//            break;
        
    }
    
}
//这儿，如果一个特征的值被更新，然后周边代理接收-peripheral:didUpdateNotificationStateForCharacteristic:error:。你可以用-readValueForCharacteristic:读取新的值：
- (void)peripheral:(CBPeripheral *)peripheral
didUpdateNotificationStateForCharacteristic:
(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error changing notification state:%@", error.localizedDescription);
              }
              // Exits if it's not the transfer characteristic
              if (![characteristic.UUID isEqual:[CBUUID
                                                 UUIDWithString:kCharacteristicUUID]]) {
            return;
        }
              // Notification has started
              if (characteristic.isNotifying) {
                  NSLog(@"Notification began on %@", characteristic);
                  [peripheral readValueForCharacteristic:characteristic];
              } else { // Notification has stopped
                  // so disconnect from the peripheral
                  NSLog(@"Notification stopped on %@.Disconnecting", characteristic);
                        [self.manager cancelPeripheralConnection:self.peripheral];
                  
              }
    
}


//主动断开设备
-(void)disConnect
{
    
    if (_peripheral != nil)
    {
        NSLog(@"disConnect start");
        [self.manager cancelPeripheralConnection:_peripheral];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
