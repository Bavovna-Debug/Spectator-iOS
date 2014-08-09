//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HALResourceRecorder : NSObject

- (void)serverDidConnect;

- (void)serverDidDisconnect;

- (void)resetData;

@end
