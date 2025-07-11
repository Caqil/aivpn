//
//  BGVPNManager.h
//  BGExtension
//
//  Created by cakra budiman on 09/08/24.
//  Copyright © 2024 billiongroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NetworkExtension/NetworkExtension.h>
#import "BGParser.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^YDProviderManagerCompletion)(NETunnelProviderManager *_Nullable manager);
typedef void (^YDPingResponse)(NSString *url, long long rtt);
typedef void (^YDFetchCompletion)(NETunnelProviderManager *manager);
typedef void (^YDfetchStatisticsResponse)(int64_t downloadlink, int64_t uploadlink, int64_t mdownloadlink, int64_t muploadlink);

@class YDItemInfo;

typedef enum : NSUInteger
{
    YDVPNStatusIDLE = 0,
    YDVPNStatusConnecting,
    YDVPNStatusConnected,
    YDVPNStatusDisconnecting,
    YDVPNStatusDisconnected
} YDVPNStatus;

@protocol YDStorage <NSObject>

- (BOOL)setObject:(nullable NSObject<NSCoding> *)object forKey:(NSString *)key;

- (BOOL)setString:(NSString *)value forKey:(NSString *)key;

- (nullable id)getObjectOfClass:(Class)cls forKey:(NSString *)key;

- (nullable NSString *)getStringForKey:(NSString *)key;

- (void)removeValueForKey:(NSString *)key;

@end

@interface BGVPNManager : NSObject

/// Setel ID grup, digunakan untuk komunikasi antara proses ekstensi dan proses utama, kedua proses perlu memanggilnya, harap panggil saat aplikasi dimulai
/// - Parameter groupId: ID grup
+ (void)setGroupID:(NSString *)groupId;

@property(nonatomic, strong, readonly) NSString *groupId;

+ (instancetype)sharedManager;

// Panggilan dari proses utama, jangan panggil dari proses ekstensi
- (void)initializeVPNManager;

/// Penyimpanan
@property(nonatomic, strong) id<YDStorage> storage;

/// Status koneksi saat ini
@property(nonatomic, readonly) YDVPNStatus status;

/// Node yang terhubung saat ini
@property(nonatomic, strong, readonly) NSString *connectedURL;

@property(nonatomic, strong, readonly) NSString *xrayVersion;

/// Waktu koneksi VPN
@property(nonatomic, strong, readonly) NSDate *connectedDate;

@property(nonatomic, strong, readonly) NETunnelProviderManager *providerManager;

/// Apakah mode global, berlaku sebelum memulai VPN atau mengganti node
@property(nonatomic) BOOL isGlobalMode;

/// Mulai koneksi
/// - Parameter url: URL node
- (void)connect:(NSString *)url;

/// Putuskan koneksi
- (void)disconnect;

/// Ganti node
/// - Parameter url: URL node
- (void)updateURL:(NSString *)url;

/// Setel konfigurasi router
//    [
//        {
//          "method": "direct",
//          "type": "ip",
//          "content": "192.168.9.3"
//        },
//        {
//          "method": "proxy",
//          "type": "domain",
//          "content": "www.baidu.com"
//        },
//        {
//          "method": "block",
//          "type": "ip",
//          "content": "192.168.9.3"
//        }
//    ]
/// - Parameter router: konfigurasi router
- (void)setRouterConfiguration:(nullable NSArray<NSDictionary *> *)router;

- (void)fetchStatistics:(YDfetchStatisticsResponse)response;

- (void)reenableManager:(YDFetchCompletion)complection;

@property(nonatomic) NSInteger engineType;

@end

// Interface berikut dipanggil dalam proses ekstensi
@interface BGVPNManager (Extension)

/// Panggilan dari proses ekstensi, jangan panggil dari proses utama
/// - Parameter ips: daftar url
- (void)ping:(NSArray *)ips type:(int)type;

/// Panggilan dari proses ekstensi, jangan panggil dari proses utama
- (void)setupExtenstionApplication;

/// Hentikan TCP Ping
+ (void)stopPinger;


/// Ambil router
- (NSArray<NSDictionary *> *)getRouterConfiguration;
@end

NS_ASSUME_NONNULL_END
