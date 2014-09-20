//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "Panel.h"
#import "Server.h"

@interface ServerInformationPanel : Panel

@property (weak, nonatomic) Server *server;

- (id)initWithHeight:(CGFloat)height;

- (void)updateContent;

@end
