//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServerPoolDelegate;

@interface ServerPool : NSObject

@property (nonatomic, strong, readwrite) id delegate;

@property (strong, nonatomic) NSMutableArray *servers;

+ (ServerPool *)sharedServerPool;

- (id)init;

- (void)saveServerList;

- (void)loadServerList;

- (void)prepareForBackground;

- (void)serverSatusChanged:(NSObject *)server;

@end

@protocol ServerPoolDelegate <NSObject>

@required

- (void)serverSatusChanged:(NSObject *)server;

@end