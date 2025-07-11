//
//  BGVPNManager.m
//  BGExtension
//
//  Created by cakra budiman on 09/08/24.
//  Copyright © 2024 billiongroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BGVPNManager.h"
#import "BGParser.h"
#import <CommonCrypto/CommonCrypto.h>


NSString *const kApplicationVPNServerAddress = @"localhost";
NSString *const kApplicationVPNLocalizedDescription = @"360AIVPN";

static NSString *__auth__ = @"";
static NSString *__groundID__ = @"group.com.360aivpn";

typedef void(^YDFetchCompletion)(NETunnelProviderManager *manager);


@interface BGVPNManager ()

@end

@interface BGVPNManager ()
@property (nonatomic, strong)NSUserDefaults *userDefaults;
@property (nonatomic)BOOL isExtension;
@property (nonatomic)NSInteger notifier;
@property (nonatomic, strong)NSMutableDictionary *info;
@property (nonatomic, strong)NSLock *lock;
@end


@implementation BGVPNManager
{
    NSTimer *_durationTimer;
    NSTimer *_pingTimer;
    dispatch_queue_t _worker;
    dispatch_semaphore_t _sem;
}
+(instancetype)sharedManager{
    static BGVPNManager *__manager__;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __manager__ = [[self alloc] init];
        [__manager__ configure];
    });
    return __manager__;
}

+ (NSString *)md5:(NSString *)content{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    NSData *fileData = [content dataUsingEncoding:NSUTF8StringEncoding];
    CC_MD5_Update(&md5, [fileData bytes], (CC_LONG)[fileData length]);
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString *result = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                        digest[0], digest[1],
                        digest[2], digest[3],
                        digest[4], digest[5],
                        digest[6], digest[7],
                        digest[8], digest[9],
                        digest[10], digest[11],
                        digest[12], digest[13],
                        digest[14], digest[15]];
#pragma clang diagnostic pop
    return result;
}

+(void)setGroupID:(NSString *)groupId {
    __groundID__ = groupId;
}

-(NSString *)groupId {
    return __groundID__;
}

-(void)configure {
    _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:__groundID__];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionStatusDidChangeNotification:) name:NEVPNStatusDidChangeNotification object:nil];
    _worker = dispatch_queue_create("com.360aivpn",  DISPATCH_QUEUE_CONCURRENT);
    _sem = dispatch_semaphore_create(6);
    _lock = [[NSLock alloc] init];
}

-(void)initializeVPNManager:(YDFetchCompletion)completion {
    [_userDefaults addObserver:self forKeyPath:@"notifier" options:(NSKeyValueObservingOptionNew) context:nil];
    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * _Nullable managers, NSError * _Nullable error) {
        if (managers.count == 0) {
            [self createVPNConfiguration:completion];
            if (error) {
                NSLog(@"loadAllFromPreferencesWithCompletionHandler: %@", error);
            }
            return;
        }
        [self handlePreferences:managers completion:completion];
    }];
    
}

-(void)initializeVPNManager {
    [self initializeVPNManager:^(NETunnelProviderManager *manager) {
        [self setupConnection:manager];
    }];
}

-(void)setupConnection:(NETunnelProviderManager *)manager {
    _providerManager = manager;
    NEVPNConnection *connection = manager.connection;
    if (connection.status == NEVPNStatusConnected) {
        _status = YDVPNStatusConnected;
        NETunnelProviderProtocol *protocolConfiguration = (NETunnelProviderProtocol *)_providerManager.protocolConfiguration;
        NSDictionary *copy = protocolConfiguration.providerConfiguration;
        NSDictionary *configuration = copy[@"configuration"];
        _connectedDate = [_userDefaults objectForKey:@"connectedDate"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kApplicationVPNStatusDidChangeNotification" object:nil];
    }
}

-(void)setupExtenstionApplication {
    _isExtension = YES;
    _info = [NSMutableDictionary new];
    _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:__groundID__];
    [_userDefaults setObject:NSDate.date forKey:@"connectedDate"];
}



-(void)reenableManager:(YDFetchCompletion)complection {
    if (_providerManager) {
        if(_providerManager.enabled == NO) {
            NSLog(@"providerManager is disabled, so reenable");
            _providerManager.enabled = YES;
            [_providerManager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"saveToPreferencesWithCompletionHandler:%@", error);
                }
            }];
        }
        complection(_providerManager);
    }
    else {
        [self initializeVPNManager:^(NETunnelProviderManager *manager) {
            [self setupConnection:manager];
            complection(manager);
        }];
    }
}

-(void)connect:(NSString *)url {
    _connectedURL = url;
    [self reenableManager:^(NETunnelProviderManager *manager) {
        if (!manager){
            return;
        }
        NETunnelProviderSession *session = (NETunnelProviderSession *)self->_providerManager.connection;
        NSString *uri = url;
        NSError *error;
        NSDictionary *providerConfiguration = @{@"type":@(0), @"uri":uri, @"global":@(self.isGlobalMode)};
        NETunnelProviderProtocol *protocolConfiguration = (NETunnelProviderProtocol *)self->_providerManager.protocolConfiguration;
        NSMutableDictionary *copy = protocolConfiguration.providerConfiguration.mutableCopy;
        copy[@"configuration"] = providerConfiguration;
        NSLog(@"connect using: %@", providerConfiguration);
        protocolConfiguration.providerConfiguration = copy;
        [self->_providerManager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"saveToPreferencesWithCompletionHandler:%@", error);
            }
        }];
        [session startVPNTunnelWithOptions:@{@"uri":uri, @"global":@(self.isGlobalMode)} andReturnError:&error];
        if (error) {
            NSLog(@"startVPNTunnelWithOptions:%@", error);
        }
    }];

}

-(void)setIsGlobalMode:(BOOL)isGlobalMode {
    if (_isGlobalMode == isGlobalMode) return;
    _isGlobalMode = isGlobalMode;
    if (self.status == YDVPNStatusConnected) {
        [self updateURL:self.connectedURL force:YES];
    }
}

-(void)xrayVerson:(NSString *)version {
    [self xrayVerson:version];
}

-(void)updateURL:(NSString *)uri force:(BOOL)force{
    if ([uri isEqualToString:_connectedURL] && force == NO) {
        return;
    }
    [self reenableManager:^(NETunnelProviderManager *manager) {
        if (!manager){
            return;
        }
        self->_connectedURL = uri;
        NETunnelProviderSession *connection = (NETunnelProviderSession *)self->_providerManager.connection;
        NSDictionary *providerConfiguration = @{@"type":@(0), @"uri":uri, @"global":@(self.isGlobalMode)};
        NETunnelProviderProtocol *protocolConfiguration = (NETunnelProviderProtocol *)self->_providerManager.protocolConfiguration;
        NSMutableDictionary *copy = protocolConfiguration.providerConfiguration.mutableCopy;
        copy[@"configuration"] = providerConfiguration;
        NSLog(@"updateURL using: %@", providerConfiguration);
        protocolConfiguration.providerConfiguration = copy;
        [self->_providerManager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"saveToPreferencesWithCompletionHandler:%@", error);
            }
        }];
        NSDictionary *echo = @{@"type":@2, @"uri":uri, @"global":@(self.isGlobalMode)};
        [connection sendProviderMessage:[NSJSONSerialization dataWithJSONObject:echo options:(NSJSONWritingPrettyPrinted) error:nil] returnError:nil responseHandler:^(NSData * _Nullable responseData) {
            NSString *x = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", x);
        }];
    }];
}

-(void)disconnect {
    NETunnelProviderSession *session = (NETunnelProviderSession *)_providerManager.connection;
    [session stopVPNTunnel];
    NSLog(@"disconnect");
}

-(void)setRouterConfiguration:(nullable NSArray <NSDictionary *> *)router {
    if (!router) {
        [_userDefaults removeObjectForKey:@"kApplicationVPNRouter"];
    }
    else {
        [_userDefaults setObject:router forKey:@"kApplicationVPNRouter"];
    }
}

-(NSArray <NSDictionary *> *)getRouterConfiguration {
    return [_userDefaults objectForKey:@"kApplicationVPNRouter"];
}

-(void)connectionStatusDidChangeNotification:(NSNotification *)notification {
    NEVPNConnection *connection = _providerManager.connection;
    switch (connection.status) {
        case NEVPNStatusInvalid:
            _status = YDVPNStatusDisconnected;
            break;
            
        case NEVPNStatusConnected:{
            _status = YDVPNStatusConnected;
            _connectedDate = NSDate.date;
        }
            break;
            
        case NEVPNStatusConnecting: {
            _status = YDVPNStatusConnecting;
        }
            break;
            
        case NEVPNStatusDisconnected:{
            _status = YDVPNStatusDisconnected;
        }
            break;
            
        case NEVPNStatusReasserting:{
            _status = YDVPNStatusDisconnected;
        }
            break;
        case NEVPNStatusDisconnecting: {
            _status = YDVPNStatusDisconnecting;
        }
            break;
            
        default:
            break;
    }
    NSLog(@"extension status did change:%d", (int)connection.status);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kApplicationVPNStatusDidChangeNotification" object:nil];
}

- (void)handlePreferences:(NSArray<NETunnelProviderManager *> * _Nullable)managers completion:(YDProviderManagerCompletion)completion{
    NETunnelProviderManager *manager;
    for (NETunnelProviderManager *item in managers) {
        if ([item.localizedDescription isEqualToString:kApplicationVPNLocalizedDescription]) {
            manager = item;
            break;
        }
    }
    if (manager.enabled == NO) {
        manager.enabled = YES;
        [manager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
            completion(manager);
        }];
    }
    else {
        completion(manager);
    }
    NSLog(@"Found a vpn configuration");
}

- (void)createVPNConfiguration:(YDProviderManagerCompletion)completion {
        
    NETunnelProviderManager *manager = [NETunnelProviderManager new];
    NETunnelProviderProtocol *protocolConfiguration = [NETunnelProviderProtocol new];
    
    protocolConfiguration.serverAddress = kApplicationVPNServerAddress;
    
    // providerConfiguration 可以自定义进行存储
    protocolConfiguration.providerConfiguration = @{};
    manager.protocolConfiguration = protocolConfiguration;

    manager.localizedDescription = kApplicationVPNLocalizedDescription;
    manager.enabled = YES;
    [manager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"saveToPreferencesWithCompletionHandler:%@", error);
            completion(nil);
            return;
        }
        [manager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
            
            if (error) {
                NSLog(@"loadFromPreferencesWithCompletionHandler:%@", error);
                completion(nil);
            }
            else {
                completion(manager);
            }
        }];
    }];
}

-(void)fetchStatistics:(YDfetchStatisticsResponse) response {
    NETunnelProviderSession *connection = (NETunnelProviderSession *)_providerManager.connection;
    if (!connection || _status != YDVPNStatusConnected) return response(-1, -1, -1, -1);
    NSDictionary *echo = @{@"type":@5};
    [connection sendProviderMessage:[NSJSONSerialization dataWithJSONObject:echo options:(NSJSONWritingPrettyPrinted) error:nil] returnError:nil responseHandler:^(NSData * _Nullable responseData) {
        if (responseData) {
            NSDictionary *rsp = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
            int64_t downloadlink = [rsp[@"downloadlink"] longLongValue];
            int64_t uploadlink = [rsp[@"uploadlink"] longLongValue];
            int64_t mdownloadlink = [rsp[@"mdownloadlink"] longLongValue];
            int64_t muploadlink = [rsp[@"muploadlink"] longLongValue];
            return response(downloadlink, uploadlink, mdownloadlink, muploadlink);
        }
        response(-1, -1, -1, -1);
    }];
}



@end
