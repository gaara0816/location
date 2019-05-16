/********* location.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <BMKLocationKit/BMKLocationComponent.h>
#import <CoreLocation/CoreLocation.h>

@interface location : CDVPlugin <BMKLocationManagerDelegate, BMKLocationAuthDelegate>{
  // Member variables go here.
}
@property(nonatomic, copy) NSString* commandId;
@property (nonatomic, strong)CLLocationManager *manager;
@property (nonatomic, strong)BMKLocationManager  *locationManager;
- (void)location:(CDVInvokedUrlCommand*)command;
@end

@implementation location


- (void)pluginInitialize {
    // 需要注意的是请在 SDK 任何类的初始化以及方法调用之前设置正确的 AK
    [[BMKLocationAuth sharedInstance] checkPermisionWithKey:@"1cvm0Ky08IOUdQimLqoIOFOilFTq0OX3" authDelegate:self];
    _manager = [CLLocationManager new];
    
    _locationManager = [[BMKLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    _locationManager.pausesLocationUpdatesAutomatically = NO;
    _locationManager.allowsBackgroundLocationUpdates = YES;
    _locationManager.locationTimeout = 10;
    _locationManager.reGeocodeTimeout = 10;
}

- (void)location:(CDVInvokedUrlCommand*)command {
    self.commandId = command.callbackId;
    [self requestLocation];
}

- (void)requestLocation {
    if([CLLocationManager locationServicesEnabled]) {
        if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
            NSLog(@"没打开");
            [_manager requestWhenInUseAuthorization];
        } else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
//            [_manager requestWhenInUseAuthorization];
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
//                if ([NSString stringWithFormat:"", [UIDevice currentDevice] systemVersion]>10.0) {
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
//                } else {
//                    [[UIApplication sharedApplication] openURL:url];
//                }
            }
        } else {
            [_locationManager requestLocationWithReGeocode:YES withNetworkState:YES completionBlock:^(BMKLocation * _Nullable location, BMKLocationNetworkState state, NSError * _Nullable error) {
                if(error){
                    NSDictionary* dic = [NSDictionary dictionaryWithObjects:@[@"FAILED"] forKeys:@[@"reCode"]];
                    CDVPluginResult* pluginResult = nil;
                    pluginResult =  [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dic];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandId];
                }else {
                    //获取经纬度和该定位点对应的位置信息
                    NSString* latitude = [NSString stringWithFormat:@"%.6f",location.location.coordinate.latitude];
                    NSString* longitude = [NSString stringWithFormat:@"%.6f",location.location.coordinate.longitude];
                    NSDictionary* dic = [NSDictionary dictionaryWithObjects:@[@"SUCCESS",latitude,longitude] forKeys:@[@"reCode",@"latitude",@"longitude"]];
                    CDVPluginResult* pluginResult = nil;
                    pluginResult =  [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandId];
                }
                
            }];
        }
    } else {
        
    }
    
}

- (void)onCheckPermissionState:(BMKLocationAuthErrorCode)iError{
    if(iError == BMKLocationAuthErrorSuccess){
        
    }else {
        
    }
}

- (void)onGetPermissionState:(int)iError {
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}

//- (void)BMKLocationManager:(BMKLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
//    if(status == kCLAuthorizationStatusAuthorizedWhenInUse){
//        [_locationManager requestLocationWithReGeocode:YES withNetworkState:YES completionBlock:^(BMKLocation * _Nullable location, BMKLocationNetworkState state, NSError * _Nullable error) {
//            if(error){
//                CDVPluginResult* pluginResult = nil;
//                pluginResult =  [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
//                [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandId];
//            } else {
//                //获取经纬度和该定位点对应的位置信息
//                NSString* latitude = [NSString stringWithFormat:@"%.6f",location.location.coordinate.latitude];
//                NSString* longitude = [NSString stringWithFormat:@"%.6f",location.location.coordinate.longitude];
//                NSDictionary* dic = [NSDictionary dictionaryWithObjects:@[latitude,longitude] forKeys:@[@"latitude",@"longitude"]];
//                CDVPluginResult* pluginResult = nil;
//                pluginResult =  [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
//                [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandId];
//            }
//        }];
//    } else if (status == kCLAuthorizationStatusDenied){
//        CDVPluginResult* pluginResult = nil;
//        pluginResult =  [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
//        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandId];
//    }
//}
//
//- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateNetworkState:(BMKLocationNetworkState)state orError:(NSError *)error{
//
//}
//
//- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
//
//}
@end
