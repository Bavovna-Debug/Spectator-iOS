//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "Server.h"
#import "ServerPool.h"

@implementation ServerPool

+ (ServerPool *)sharedServerPool
{
    static dispatch_once_t onceToken;
    static ServerPool *pool;
    
    dispatch_once(&onceToken, ^{
        pool = [[ServerPool alloc] init];
    });
    
    return pool;
}

#pragma mark Object cunstructors/destructors

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
    self.servers = [NSMutableArray array];
    
#ifdef SCREENSHOTING
    Server *server;
    server = [[Server alloc] initWithName:@"Dr. Zoidberg" dnsName:@"zoidberg.meine-werke.com"];
    [self.servers addObject:server];
    server = [[Server alloc] initWithName:@"Quasar" dnsName:@"quasar.szcloud.de"];
    [self.servers addObject:server];
    server = [[Server alloc] initWithName:@"DB2" dnsName:@"db2.szcloud.de"];
    [self.servers addObject:server];
    server = [[Server alloc] initWithName:@"Vijsboek" dnsName:@"facebuch.zeppelinium.de"];
    [self.servers addObject:server];
    server = [[Server alloc] initWithName:@"Office #1" dnsName:@"srv1.meine-wolke.net"];
    server.portNumber = 22000;
    [self.servers addObject:server];
    server = [[Server alloc] initWithName:@"Office #2" dnsName:@"srv2.meine-wolke.net"];
    server.portNumber = 22000;
    [self.servers addObject:server];
    server = [[Server alloc] initWithName:@"Incursus" dnsName:@"cloud.meine-werke.com"];
    server.portNumber = 22000;
    [self.servers addObject:server];
    server = [[Server alloc] initWithName:@"Mac mini" dnsName:@"192.168.1.42"];
    server.portNumber = 19180;
    [self.servers addObject:server];
    server = [[Server alloc] initWithName:@"RS/6000" dnsName:@"power.maxim-dyndns.net"];
    server.portNumber = 19180;
    [self.servers addObject:server];
#else
    [self loadServerList];
#endif
    
    return self;
}

#pragma mark Server list

- (void)saveServerList
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSInteger numberOfServers = [self.servers count];

    [defaults setInteger:numberOfServers forKey:@"NumberOfServers"];

    for (NSInteger serverId = 0; serverId < numberOfServers; serverId++)
    {
        Server *server = [self.servers objectAtIndex:serverId];
        NSString *serverKey = [NSString stringWithFormat:@"Server-%ld", (long)serverId];

        NSData *encodedServer = [NSKeyedArchiver archivedDataWithRootObject:server];
        [defaults setObject:encodedServer forKey:serverKey];
        [defaults synchronize];
    }
}

- (void)loadServerList
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSInteger numberOfServers = [defaults integerForKey:@"NumberOfServers"];
    
    for (NSInteger serverId = 0; serverId < numberOfServers; serverId++)
    {
        NSString *serverKey = [NSString stringWithFormat:@"Server-%ld", (long)serverId];
        NSData *encodedServer = [defaults objectForKey:serverKey];
        Server *server = [NSKeyedUnarchiver unarchiveObjectWithData:encodedServer];
        [self.servers addObject:server];
    }
}

#pragma mark Events

- (void)prepareForBackground
{
    for (Server *server in self.servers)
    {
        [server pauseMonitoring];
    }
}

- (void)serverSatusChanged:(NSObject *)server
{
    if (self.delegate != nil)
        [self.delegate serverSatusChanged:server];
}

@end
