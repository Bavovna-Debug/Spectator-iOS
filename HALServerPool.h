//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HALServerPoolDelegate;

@interface HALServerPool : NSObject

@property (nonatomic, strong, readwrite) id delegate;

@property (strong, nonatomic) NSMutableArray *servers;

+ (HALServerPool *)sharedServerPool;

- (id)init;

- (void)saveServerList;

- (void)loadServerList;

- (void)prepareForBackground;

- (void)serverSatusChanged:(NSObject *)server;

@end

@protocol HALServerPoolDelegate <NSObject>

@required

- (void)serverSatusChanged:(NSObject *)server;

@end