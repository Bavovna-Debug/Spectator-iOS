//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HALServerPool : NSObject

@property (strong, nonatomic) NSMutableArray *servers;

+ (HALServerPool *)sharedServerPool;

- (id)init;

- (void)saveServerList;

- (void)loadServerList;

- (void)prepareForBackground;

@end
