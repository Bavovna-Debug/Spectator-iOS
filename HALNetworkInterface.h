//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HALNetworkInterface : NSObject

@property (strong, nonatomic) NSString *interfaceName;
@property (assign, nonatomic) UInt64 rxBytesTotal;
@property (assign, nonatomic) UInt64 txBytesTotal;
@property (assign, nonatomic) UInt64 rxBytesGaging;
@property (assign, nonatomic) UInt64 txBytesGaging;
@property (assign, nonatomic) Boolean gaging;
@property (strong, nonatomic) NSDate *gagingBegin;
@property (strong, nonatomic) NSDate *gagingEnd;

- (id)initWithInterfaceName:(NSString *)interfaceName
               rxBytesTotal:(UInt64)rxBytesTotal
               txBytesTotal:(UInt64)txBytesTotal;

- (void)trafficRxBytes:(UInt64)rxBytes
               txBytes:(UInt64)txBytes;

- (Boolean)gaging;

- (void)setGaging:(Boolean)gaging;

@end
