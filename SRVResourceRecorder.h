//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRVResourceRecorder : NSObject

@property (nonatomic, strong, readwrite) id delegate;

- (void)serverDidConnect;

- (void)serverDidDisconnect;

- (void)resetData;

@end
