//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALPanel.h"
#import "HALServer.h"

@interface HALServerInformationPanel : HALPanel

@property (weak, nonatomic) HALServer *server;

- (id)initWithHeight:(CGFloat)height;

- (void)updateContent;

@end
