//
//  BGProtocolParser.m
//  bgtunnel
//
//  Created by cakra budiman on 09/08/24.
//

#import "BGParser.h"
#import "BGParserVless.h"
#import "BGParserVmess.h"
#import "BGParserTrojan.h"
#import "BGParserSS.h"

static uint16_t __http_proxy_port__ = 1082;

static NSMutableArray *__directDomainList__ = nil;
static NSMutableArray *__proxyDomainList__ = nil;
static NSMutableArray *__blockDomainList__ = nil;

static NSMutableArray *__directIPList__ = nil;
static NSMutableArray *__proxyIPList__ = nil;
static NSMutableArray *__blockIPList__ = nil;


static bool __global_geosite_enable__ = false;
static bool __global_geoip_enable__ = false;

@implementation BGParser

+(void)setHttpProxyPort:(uint16_t)port {
    __http_proxy_port__ = port;
    [BGParserVless setHttpProxyPort:port];
    [BGParserVmess setHttpProxyPort:port];
    [BGParserTrojan setHttpProxyPort:port];
    [BGParserSS setHttpProxyPort:port];
}

+(uint16_t)HttpProxyPort {
    return __http_proxy_port__;
}

+(void)setLogLevel:(NSString *)level {
    [BGParserVless setLogLevel:level];
    [BGParserVmess setLogLevel:level];
    [BGParserTrojan setLogLevel:level];
    [BGParserSS setLogLevel:level];
}

+ (void)setGlobalProxyEnable:(BOOL)enable {
    __global_geosite_enable__ = !enable;
    __global_geoip_enable__ = !enable;
}

+ (void)setDirectDomainList:(NSArray *)list {
    __directDomainList__ = list.mutableCopy;
}

+ (void)setProxyDomainList:(NSArray *)list {
    __proxyDomainList__ = list.mutableCopy;
}

+ (void)setBlockDomainList:(NSArray *)list {
    __blockDomainList__ = list.mutableCopy;
}

+ (void)setDirectIPList:(NSArray *)list {
    __directIPList__ = [list mutableCopy];
}

+ (void)setProxyIPList:(NSArray *)list {
    __proxyIPList__ = [list mutableCopy];
}

+ (void)setBlockIPList:(NSArray *)list {
    __blockIPList__ = [list mutableCopy];
}

+(nullable NSDictionary *)parse:(NSString *)uri protocol:(BGProtocol)protocol {
    
    switch (protocol) {
        case BGProtocolVmess:
            return [BGParserVmess parse:uri];
            
        case BGProtocolVless:
            return [BGParserVless parse:uri];
            
        case BGProtocolTrojan:
            return [BGParserTrojan parse:uri];
            
        case BGProtocolSS:
            return [BGParserSS parse:uri];
        default:
            break;
    }
    return nil;
}

+ (NSDictionary *)parseURI:(NSString *)uri {
    NSArray <NSString *>*list = [uri componentsSeparatedByString:@"//"];
    BGProtocol protocol;
    if (list.count != 2) {
        list = [uri componentsSeparatedByString:@":"];
        if (list.count != 2) {
            return nil;
        }
    }
    if ([list[0] hasPrefix:@"vmess"]) {
        protocol = BGProtocolVmess;
    }
    else if ([list[0] hasPrefix:@"vless"]) {
        protocol = BGProtocolVless;
    }
    else if ([list[0] hasPrefix:@"trojan"]) {
        protocol = BGProtocolTrojan;
    }
    else if ([list[0] hasPrefix:@"ss"]) {
        protocol = BGProtocolSS;
    }
    else {
        return nil;
    }
    NSDictionary *configuration = [BGParser parse:list[1] protocol:protocol];
    return configuration;
}

+(NSDictionary *)GetStatsPolicy {
    NSDictionary *policy = @{
        @"system": @{
            @"statsOutboundUplink": [NSNumber numberWithBool:true],
            @"statsOutboundDownlink": [NSNumber numberWithBool:true]
        }
    };
    return policy;
}

+(NSArray *)GetRules {
    
    NSMutableArray *rules = @[].mutableCopy;
    
    if (__proxyDomainList__.count > 0) {
        NSDictionary *A = @{
            @"type": @"field",
            @"domain": __proxyDomainList__,
            @"outboundTag": @"proxy"
        };
        [rules addObject:A];
    }

    if (__blockDomainList__.count > 0) {
        NSDictionary *A = @{
            @"type": @"field",
            @"domain": __blockDomainList__,
            @"outboundTag": @"block"
        };
        [rules addObject:A];
    }
    
    if (__directDomainList__.count > 0) {
        NSDictionary *A = @{
            @"type": @"field",
            @"domain": __directDomainList__,
            @"outboundTag": @"direct"
        };
        [rules addObject:A];
    }
    
    if (__proxyIPList__.count > 0) {
        NSDictionary *A = @{
            @"type": @"field",
            @"ip": __proxyIPList__,
            @"outboundTag": @"proxy"
        };
        [rules addObject:A];
    }

    if (__blockIPList__.count > 0) {
        NSDictionary *A = @{
            @"type": @"field",
            @"ip": __blockIPList__,
            @"outboundTag": @"block"
        };
        [rules addObject:A];
    }
    
    if (__directIPList__.count > 0) {
        NSDictionary *A = @{
            @"type": @"field",
            @"ip": __directIPList__,
            @"outboundTag": @"direct"
        };
        [rules addObject:A];
    }
    
    if (__global_geosite_enable__) {
        NSDictionary *A = @{
            @"type": @"field",
            @"domain": @[@"geosite:category-ads-all"],
            @"outboundTag": @"block"
        };
        NSDictionary *B = @{
            @"type": @"field",
            @"domain": @[@"geosite:cn"],
            @"outboundTag": @"direct"
        };
        [rules addObject:A];
        [rules addObject:B];
    }
    
    if (__global_geoip_enable__) {
        NSDictionary *A = @{
            @"type": @"field",
            @"ip": @[@"geoip:private", @"geoip:cn"],
            @"outboundTag": @"direct"
        };
        [rules addObject:A];
    }
    
    if (__global_geoip_enable__ || __global_geosite_enable__) {
        NSDictionary *C = @{
            @"type": @"field",
            @"domain": @[@"geosite:geolocation-!cn"],
            @"outboundTag": @"proxy"
        };
        [rules addObject:C];
    }
    
    if (!__global_geoip_enable__ && !__global_geosite_enable__) {
        NSDictionary *all = @{
            @"type":@"field",
            @"outboundTag":@"proxy",
            @"port":@"0-65535"
        };
        [rules addObject:all];
    }
    return rules;
}

@end

