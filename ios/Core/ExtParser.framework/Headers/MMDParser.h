//
//  MDProtocolParser.h
//  xVPN
//
//  Created by LinkV on 2022/11/1.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MDProtocolVmess,
    MDProtocolVless,
    MDProtocolTrojan,
    MDProtocolSS,
} MDProtocol;


NS_ASSUME_NONNULL_BEGIN

@interface MMDParser : NSObject

+(void)setHttpProxyPort:(uint16_t)port;

+(uint16_t)HttpProxyPort;

+(void)setLogLevel:(NSString *)level;

+ (void)setGlobalProxyEnable:(BOOL)enable;

+ (void)setDirectDomainList:(NSArray *)list;

+ (void)setProxyDomainList:(NSArray *)list;

+ (void)setBlockDomainList:(NSArray *)list;

+ (void)setDirectIPList:(NSArray *)list;

+ (void)setProxyIPList:(NSArray *)list;

+ (void)setBlockIPList:(NSArray *)list;

+ (NSDictionary *)parseURI:(NSString *)uri;

+ (NSArray *)GetRules;

+(NSDictionary *)GetStatsPolicy;

@end

NS_ASSUME_NONNULL_END
