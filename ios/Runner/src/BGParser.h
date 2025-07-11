//
//  BGProtocolParser.h
//  bgtunnel
//
//  Created by cakra budiman on 09/08/24.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger
{
    BGProtocolVmess,
    BGProtocolVless,
    BGProtocolTrojan,
    BGProtocolSS,
} BGProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface BGParser : NSObject
+(nullable NSDictionary *)parse:(NSString *)uri protocol:(BGProtocol)protocol;
+ (void)setHttpProxyPort:(uint16_t)port;

+ (uint16_t)HttpProxyPort;

+ (void)setLogLevel:(NSString *)level;

+ (void)setGlobalProxyEnable:(BOOL)enable;

+ (void)setDirectDomainList:(NSArray *)list;

+ (void)setProxyDomainList:(NSArray *)list;

+ (void)setBlockDomainList:(NSArray *)list;

+ (void)setDirectIPList:(NSArray *)list;

+ (void)setProxyIPList:(NSArray *)list;

+ (void)setBlockIPList:(NSArray *)list;

+ (NSDictionary *)parseURI:(NSString *)uri;

+ (NSArray *)GetRules;

+ (NSDictionary *)GetStatsPolicy;

@end

NS_ASSUME_NONNULL_END
