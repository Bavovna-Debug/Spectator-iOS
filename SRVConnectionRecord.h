//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRVConnectionRecord : NSObject

@property (strong, nonatomic) NSDate    *openedStamp;
@property (strong, nonatomic) NSDate    *closedStamp;
@property (strong, nonatomic) NSString  *ipAddress;
@property (assign, nonatomic) UInt16    remotePort;
@property (assign, nonatomic) UInt16    localPort;

- (id)initWithIpAddress:(NSString *)ipAddress
             remotePort:(UInt16)remotePort
              localPort:(UInt16)localPort;

- (id)closed;

@end
