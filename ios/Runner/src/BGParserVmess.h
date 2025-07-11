//
//  BGProtocolParserVmess.h
//  bgtunnel
//
//  Created by cakra budiman on 09/08/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BGParserVmess : NSObject
+ (nullable NSDictionary *)parse:(NSString *)uri;

+ (void)setHttpProxyPort:(uint16_t)port;

+ (uint16_t)HttpProxyPort;

+ (void)setLogLevel:(NSString *)level;

@end

NS_ASSUME_NONNULL_END
