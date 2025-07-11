//
//  PacketTunnelProvider.m
//  VPNPacketTunnel
//
//  Created by cakra budiman on 09/08/24.
//

#import "PacketTunnelProvider.h"
#import "YDTunnelManager.h"
#import <ExtParser/ExtParser.h>

@interface PacketTunnelProvider ()
{
    int64_t _downloadlink;
    int64_t _uploadlink;
}
@end

@implementation PacketTunnelProvider

-(void)setupUserDefaults {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [MMDVPNManager setGroupID:@"group.app.bgtunnel"];
        [[MMDVPNManager sharedManager] setupExtenstionApplication];
    });
}

+ (void)LOGRedirect {
    NSString *logFilePath = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), @"xray.log"];
    [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:logFilePath] error:nil];
    [[NSFileManager defaultManager] createFileAtPath:logFilePath contents:nil attributes:nil];
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "w+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "w+", stderr);
}

- (void)startTunnelWithOptions:(NSDictionary *)options completionHandler:(void (^)(NSError *))completionHandler {
    [PacketTunnelProvider LOGRedirect];
    [self setupUserDefaults];
    [YDTunnelManager setLogLevel:(xLogLevelError)];
    if (!options) {
        NETunnelProviderProtocol *protocolConfiguration = (NETunnelProviderProtocol *)self.protocolConfiguration;
        NSMutableDictionary *copy = protocolConfiguration.providerConfiguration.mutableCopy;
        options = copy[@"configuration"];
    }
    
    BOOL isGlobalMode = [options[@"global"] boolValue];
    [YDTunnelManager setGlobalProxyEnable:isGlobalMode];
    
    // Add code here to start the process of connecting the tunnel.
    [[YDTunnelManager sharedManager] setPacketTunnelProvider:self];
    [[YDTunnelManager sharedManager] startTunnelWithOptions:options completionHandler:completionHandler];
}

- (void)stopTunnelWithReason:(NEProviderStopReason)reason completionHandler:(void (^)(void))completionHandler {
    // Add code here to start the process of stopping the tunnel.
    [[YDTunnelManager sharedManager] stopTunnelWithReason:reason completionHandler:completionHandler];
}

- (void)handleAppMessage:(NSData *)messageData completionHandler:(void (^)(NSData *))completionHandler {
    [self setupUserDefaults];
    // Add code here to handle the message.
    NSDictionary *app = [NSJSONSerialization JSONObjectWithData:messageData options:NSJSONReadingMutableContainers error:nil];
    NSInteger type = [app[@"type"] integerValue];
    // 设置配置文件
    BOOL done = NO;
    int64_t downloadlink = 0;
    int64_t uploadlink = 0;
    if (type == 2) {
        // changeURL
        NSString *uri = app[@"uri"];
        BOOL shareable = [app[@"shareable"] boolValue];
        BOOL isGlobalMode = [app[@"global"] boolValue];
        BOOL udpSocks = app[@"udp_socks"] ? [app[@"udp_socks"] boolValue] : YES;
        [YDTunnelManager setGlobalProxyEnable:isGlobalMode];
//        [YDTunnelManager setShareProxyEnable:shareable];
//        [YDTunnelManager setSocksUDPEnable:udpSocks];
        //done = [[YDTunnelManager sharedManager] changeURL:uri];
    }
    else if (type == 3) {
        // udp ping
        NSArray *urls = app[@"urls"];
        [[MMDVPNManager sharedManager] ping:urls type:0];
    }
    else if (type == 4) {
        // tcp ping
        NSArray *urls = app[@"urls"];
        [[MMDVPNManager sharedManager] ping:urls type:1];
    }
    else if (type == 5) {
        downloadlink = [[YDTunnelManager sharedManager] GetStatistics:@"proxy" direction:@"downlink"];
        uploadlink = [[YDTunnelManager sharedManager] GetStatistics:@"proxy" direction:@"uplink"];
        _downloadlink += downloadlink;
        _uploadlink += uploadlink;
    }
    
    NSDictionary *response = @{@"desc":@(200), @"tunnel_version":@"1.0.8", @"done":@(done), @"duration":@(YDTunnelManager.duration), @"downloadlink":@(downloadlink), @"uploadlink":@(uploadlink), @"mdownloadlink":@(_downloadlink), @"muploadlink":@(_uploadlink)};
    NSData *ack = [NSJSONSerialization dataWithJSONObject:response options:NSJSONWritingPrettyPrinted error:nil];
    completionHandler(ack);
}

#pragma mark SimplePingDelegate - end

- (void)sleepWithCompletionHandler:(void (^)(void))completionHandler {
    // Add code here to get ready to sleep.
    completionHandler();
}

- (void)wake {
    // Add code here to wake up.
}

@end
