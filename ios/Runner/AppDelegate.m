//
//  AppDelegate.m
//  Runner
//
//  Created by cakra budiman on 13/08/24.
//

#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import "BGVPNManager.h"

@interface AppDelegate ()
@property (nonatomic, strong) FlutterMethodChannel *channel;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"🚀 [APP] Application starting...");
    
    FlutterViewController *flutterViewController = (FlutterViewController *)self.window.rootViewController;
    
    self.channel = [FlutterMethodChannel
        methodChannelWithName:@"aivpn"
              binaryMessenger:flutterViewController.binaryMessenger];
    
    NSLog(@"✅ [APP] Flutter method channel 'aivpn' created");
    
    // Register for VPN status change notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(vpnConnectionStatusDidChanged)
                                                 name:@"kApplicationVPNStatusDidChangeNotification"
                                               object:nil];
    NSLog(@"✅ [APP] VPN status notification observer registered");
    
    [self.channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        NSLog(@"📱 [FLUTTER] Received method call: %@", call.method);
        
        if ([@"getPlatformVersion" isEqualToString:call.method]) {
            NSString *version = [@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]];
            NSLog(@"📱 [FLUTTER] getPlatformVersion: %@", version);
            result(version);
            
        } else if ([@"initializeVPNManager" isEqualToString:call.method]) {
            NSLog(@"🔄 [VPN] Starting VPN Manager initialization...");
            
            @try {
                // Check if BGVPNManager is available
                if (![BGVPNManager sharedManager]) {
                    NSLog(@"❌ [VPN] BGVPNManager sharedManager is nil!");
                    result([FlutterError errorWithCode:@"MANAGER_NIL" 
                                               message:@"BGVPNManager instance is nil" 
                                               details:nil]);
                    return;
                }
                
                NSLog(@"✅ [VPN] BGVPNManager instance available");
                NSLog(@"📊 [VPN] Current status before init: %ld", (long)[BGVPNManager sharedManager].status);
                
                // Call the initialization method
                [[BGVPNManager sharedManager] initializeVPNManager];
                
                // Wait a moment and check status
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSInteger statusAfterInit = [BGVPNManager sharedManager].status;
                    NSLog(@"📊 [VPN] Status after initialization: %ld", (long)statusAfterInit);
                    
                    if (statusAfterInit == 4 || statusAfterInit == -1) {
                        NSLog(@"❌ [VPN] Error status detected after initialization!");
                        NSLog(@"❌ [VPN] This usually indicates a permission or configuration issue");
                    }
                });
                
                NSLog(@"✅ [VPN] VPN Manager initialization completed");
                result(nil);
                
            } @catch (NSException *exception) {
                NSLog(@"❌ [VPN] Exception during initialization: %@", exception.reason);
                NSLog(@"❌ [VPN] Exception details: %@", exception.userInfo);
                result([FlutterError errorWithCode:@"INIT_EXCEPTION" 
                                           message:exception.reason 
                                           details:exception.userInfo]);
            }
            
        } else if ([@"connect" isEqualToString:call.method]) {
            NSString *uri = call.arguments[@"uri"];
            
            NSLog(@"🔄 [VPN] Starting connection process...");
            NSLog(@"🔗 [VPN] URI: %@", uri ? [uri substringToIndex:MIN(50, uri.length)] : @"NULL");
            NSLog(@"🔗 [VPN] URI length: %lu", (unsigned long)(uri ? uri.length : 0));
            
            // Validate input
            if (!uri || uri.length == 0) {
                NSLog(@"❌ [VPN] Invalid URI: URI is empty or null");
                result([FlutterError errorWithCode:@"INVALID_URI" 
                                           message:@"URI is empty or null" 
                                           details:nil]);
                return;
            }
            
            // Check manager availability
            if (![BGVPNManager sharedManager]) {
                NSLog(@"❌ [VPN] BGVPNManager is not available");
                result([FlutterError errorWithCode:@"MANAGER_UNAVAILABLE" 
                                           message:@"VPN Manager is not available" 
                                           details:nil]);
                return;
            }
            
            // Check current status
            NSInteger currentStatus = [BGVPNManager sharedManager].status;
            NSLog(@"📊 [VPN] Current status before connect: %ld", (long)currentStatus);
            
            // If already connected or connecting, handle appropriately
            if (currentStatus == 1) {
                NSLog(@"⚠️ [VPN] Already connecting, ignoring new connect request");
                result(nil);
                return;
            } else if (currentStatus == 2) {
                NSLog(@"⚠️ [VPN] Already connected, disconnecting first...");
                [[BGVPNManager sharedManager] disconnect];
                // Wait a bit before connecting
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSLog(@"🔄 [VPN] Now attempting new connection after disconnect...");
                    [[BGVPNManager sharedManager] connect:uri];
                });
                result(nil);
                return;
            }
            
            @try {
                NSLog(@"🔄 [VPN] Calling BGVPNManager connect method...");
                NSLog(@"👀 [VPN] WATCH DEVICE - VPN permission dialog should appear if first time!");
                [[BGVPNManager sharedManager] connect:uri];
                NSLog(@"✅ [VPN] Connect method call completed without exception");
                
                // Monitor status changes for first few seconds
                __block int monitorCount = 0;
                NSTimer *statusMonitor = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
                    monitorCount++;
                    NSInteger status = [BGVPNManager sharedManager].status;
                    NSLog(@"📊 [VPN] Status monitor %d: %ld", monitorCount, (long)status);
                    
                    if (monitorCount >= 10 || status == 2 || status == 4 || status == -1) {
                        [timer invalidate];
                        if (status == 4 || status == -1) {
                            NSLog(@"❌ [VPN] Connection failed with error status: %ld", (long)status);
                        } else if (status == 2) {
                            NSLog(@"✅ [VPN] Connection successful!");
                        }
                    }
                }];
                
                result(nil);
                
            } @catch (NSException *exception) {
                NSLog(@"❌ [VPN] Exception during connect: %@", exception.reason);
                NSLog(@"❌ [VPN] Exception details: %@", exception.userInfo);
                result([FlutterError errorWithCode:@"CONNECT_EXCEPTION" 
                                           message:exception.reason 
                                           details:exception.userInfo]);
            }
            
        } else if ([@"disconnect" isEqualToString:call.method]) {
            NSLog(@"🔄 [VPN] Disconnecting...");
            @try {
                [[BGVPNManager sharedManager] disconnect];
                NSLog(@"✅ [VPN] Disconnect method called successfully");
                result(nil);
            } @catch (NSException *exception) {
                NSLog(@"❌ [VPN] Exception during disconnect: %@", exception.reason);
                result([FlutterError errorWithCode:@"DISCONNECT_EXCEPTION" 
                                           message:exception.reason 
                                           details:exception.userInfo]);
            }
            
        } else if ([@"updateURL" isEqualToString:call.method]) {
            NSString *uri = call.arguments[@"uri"];
            NSLog(@"🔄 [VPN] Updating URL: %@", uri ? [uri substringToIndex:MIN(50, uri.length)] : @"NULL");
            @try {
                [[BGVPNManager sharedManager] updateURL:uri];
                NSLog(@"✅ [VPN] URL updated successfully");
                result(nil);
            } @catch (NSException *exception) {
                NSLog(@"❌ [VPN] Exception during updateURL: %@", exception.reason);
                result([FlutterError errorWithCode:@"UPDATE_URL_EXCEPTION" 
                                           message:exception.reason 
                                           details:exception.userInfo]);
            }
            
        } else if ([@"setGlobalMode" isEqualToString:call.method]) {
            BOOL globalMode = [call.arguments[@"globalMode"] boolValue];
            NSLog(@"🔄 [VPN] Setting global mode: %@", globalMode ? @"YES" : @"NO");
            @try {
                [BGVPNManager sharedManager].isGlobalMode = globalMode;
                NSLog(@"✅ [VPN] Global mode set successfully");
                result(nil);
            } @catch (NSException *exception) {
                NSLog(@"❌ [VPN] Exception during setGlobalMode: %@", exception.reason);
                result([FlutterError errorWithCode:@"SET_GLOBAL_MODE_EXCEPTION" 
                                           message:exception.reason 
                                           details:exception.userInfo]);
            }
            
        } else if ([@"parseURI" isEqualToString:call.method]) {
            NSDictionary *dict = call.arguments;
            NSString *url = dict[@"uri"];
            
            NSLog(@"🔄 [VPN] Parsing URI: %@", url ? [url substringToIndex:MIN(50, url.length)] : @"NULL");
            
            if ([url hasPrefix:@"http"]) {
                NSLog(@"🌐 [VPN] Downloading config from HTTP URL...");
                [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] 
                                             completionHandler:^(NSData * _Nullable data, 
                                                               NSURLResponse * _Nullable response, 
                                                               NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"❌ [VPN] Network error during parseURI: %@", error.localizedDescription);
                        result(nil);
                        return;
                    }
                    
                    if (!data || data.length == 0) {
                        NSLog(@"❌ [VPN] Empty response during parseURI");
                        result(nil);
                        return;
                    }
                    
                    NSLog(@"✅ [VPN] Downloaded %lu bytes for parsing", (unsigned long)data.length);
                    
                    NSMutableArray *configurations = [NSMutableArray new];
                    NSString *more = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    
                    if (!more) {
                        NSLog(@"❌ [VPN] Failed to decode data as UTF-8");
                        result(nil);
                        return;
                    }
                    
                    more = [more base64DecodedString];
                    if (!more) {
                        NSLog(@"❌ [VPN] Failed to decode base64 content");
                        result(nil);
                        return;
                    }
                    
                    NSMutableArray <NSString *>*x = [more componentsSeparatedByString:@"\n"].mutableCopy;
                    NSLog(@"🔍 [VPN] Found %lu configuration lines", (unsigned long)x.count);
                    
                    [x enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (obj.length > 0) {
                            @try {
                                NSDictionary *information = [BGParser parseURI:obj];
                                if (information) {
                                    NSMutableDictionary *pp = information.mutableCopy;
                                    pp[@"uri"] = obj;
                                    pp[@"rtt"] = @(0);
                                    [configurations addObject:pp];
                                    NSLog(@"✅ [VPN] Parsed config %lu successfully", (unsigned long)idx);
                                } else {
                                    NSLog(@"⚠️ [VPN] Failed to parse config line %lu: %@", (unsigned long)idx, [obj substringToIndex:MIN(50, obj.length)]);
                                }
                            } @catch (NSException *exception) {
                                NSLog(@"❌ [VPN] Exception parsing config line %lu: %@", (unsigned long)idx, exception.reason);
                            }
                        }
                    }];
                    
                    NSLog(@"✅ [VPN] Total parsed configurations: %lu", (unsigned long)configurations.count);
                    result(configurations);
                }] resume];
            } else {
                // Handle direct URI parsing
                NSLog(@"🔄 [VPN] Parsing direct URI (not HTTP)");
                @try {
                    NSDictionary *information = [BGParser parseURI:url];
                    if (information) {
                        NSMutableDictionary *pp = information.mutableCopy;
                        pp[@"uri"] = url;
                        pp[@"rtt"] = @(0);
                        NSLog(@"✅ [VPN] Direct URI parsed successfully");
                        result(@[pp]);
                    } else {
                        NSLog(@"❌ [VPN] Failed to parse direct URI");
                        result(nil);
                    }
                } @catch (NSException *exception) {
                    NSLog(@"❌ [VPN] Exception parsing direct URI: %@", exception.reason);
                    result(nil);
                }
            }
            
        } else if ([@"activeURL" isEqualToString:call.method]) {
            NSString *activeURL = [BGVPNManager sharedManager].connectedURL;
            NSLog(@"📊 [VPN] Active URL: %@", activeURL ? [activeURL substringToIndex:MIN(50, activeURL.length)] : @"NULL");
            result(activeURL);
            
        } else if ([@"activeState" isEqualToString:call.method]) {
            NSInteger status = [BGVPNManager sharedManager].status;
            NSLog(@"📊 [VPN] Active state: %ld", (long)status);
            result(@(status));
            
        } else if ([@"fetchStatistics" isEqualToString:call.method]) {
            NSLog(@"📊 [VPN] Fetching connection statistics...");
            [[BGVPNManager sharedManager] fetchStatistics:^(int64_t downloadlink, int64_t uploadlink, int64_t mdownloadlink, int64_t muploadlink) {
                NSDictionary *rsp = @{
                    @"downloadlink": @(downloadlink), 
                    @"uploadlink": @(uploadlink), 
                    @"mdownloadlink": @(mdownloadlink), 
                    @"muploadlink": @(muploadlink)
                };
                NSLog(@"📊 [VPN] Statistics: %@", rsp);
                result(rsp);
            }];
            
        } else if ([@"checkVPNPermission" isEqualToString:call.method]) {
            NSLog(@"🔄 [VPN] Checking VPN permission status...");
            
            // This is a placeholder - adjust based on your BGVPNManager capabilities
            // Some possible checks:
            
            @try {
                // If BGVPNManager has a method to check permission, use it here
                // For now, we'll return true and let the actual connection handle permission
                NSLog(@"📊 [VPN] Permission check: Assuming granted (no specific check available)");
                result(@(YES));
            } @catch (NSException *exception) {
                NSLog(@"❌ [VPN] Permission check failed: %@", exception.reason);
                result(@(NO));
            }
            
        } else {
            NSLog(@"❌ [FLUTTER] Method not implemented: %@", call.method);
            result(FlutterMethodNotImplemented);
        }
    }];
    
    if (@available(iOS 10.0, *)) {
        [UNUserNotificationCenter currentNotificationCenter].delegate = (id<UNUserNotificationCenterDelegate>) self;
    }
    
    [GeneratedPluginRegistrant registerWithRegistry:self];
    NSLog(@"✅ [APP] Application initialization completed");
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)vpnConnectionStatusDidChanged {
    if (BGVPNManager.sharedManager.engineType == 0) {
        NSInteger status = [BGVPNManager sharedManager].status;
        
        // Detailed status logging
        NSString *statusName = @"Unknown";
        NSString *statusDescription = @"";
        
        switch (status) {
            case 0:
                statusName = @"Disconnected";
                statusDescription = @"VPN is disconnected";
                break;
            case 1:
                statusName = @"Connecting";
                statusDescription = @"VPN is attempting to connect";
                break;
            case 2:
                statusName = @"Connected";
                statusDescription = @"VPN is connected successfully";
                break;
            case 3:
                statusName = @"Disconnecting";
                statusDescription = @"VPN is disconnecting";
                break;
            case 4:
                statusName = @"Error";
                statusDescription = @"VPN connection failed with error";
                break;
            case -1:
                statusName = @"Failed";
                statusDescription = @"VPN connection failed";
                break;
            default:
                statusName = [NSString stringWithFormat:@"Unknown(%ld)", (long)status];
                statusDescription = @"Unexpected VPN status";
                break;
        }
        
        NSLog(@"📱 [VPN] Status changed to: %ld (%@)", (long)status, statusName);
        NSLog(@"📱 [VPN] Description: %@", statusDescription);
        
        // Check for specific error conditions
        if (status == 4 || status == -1) {
            NSLog(@"❌ [VPN] ERROR STATUS DETECTED!");
            NSLog(@"❌ [VPN] Possible causes:");
            NSLog(@"   - VPN permission denied by user");
            NSLog(@"   - Invalid VPN configuration");
            NSLog(@"   - Network connectivity issues");
            NSLog(@"   - VPN server unreachable");
            NSLog(@"   - BGVPNManager internal error");
            NSLog(@"   - Missing VPN entitlements in app");
            
            // Additional debugging info
            NSLog(@"📊 [VPN] Engine type: %ld", (long)BGVPNManager.sharedManager.engineType);
            NSLog(@"📊 [VPN] Connected URL: %@", [BGVPNManager sharedManager].connectedURL ?: @"NULL");
            NSLog(@"📊 [VPN] Global mode: %@", [BGVPNManager sharedManager].isGlobalMode ? @"YES" : @"NO");
            
            // If BGVPNManager has error properties, log them here
            // Example (adjust based on your BGVPNManager API):
            // if ([BGVPNManager sharedManager].lastError) {
            //     NSLog(@"❌ [VPN] Last error: %@", [BGVPNManager sharedManager].lastError);
            // }
        } else if (status == 2) {
            NSLog(@"✅ [VPN] CONNECTION SUCCESSFUL!");
            NSLog(@"📊 [VPN] Connected URL: %@", [BGVPNManager sharedManager].connectedURL ?: @"NULL");
        }
        
        // Notify Flutter
        [self.channel invokeMethod:@"stateDidChangeNotification" 
                         arguments:@{@"state": @(status)}];
    } else {
        NSLog(@"📱 [VPN] Status change ignored (engineType != 0): %ld", (long)BGVPNManager.sharedManager.engineType);
    }
}

@end