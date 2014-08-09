//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALMount.h"
#import "HALPanel.h"

@interface HALMountPanel : HALPanel

@property (strong, nonatomic) HALMount *mount;
@property (assign, nonatomic) Boolean showBytes;

- (id)initWithMount:(HALMount *)mount;

- (void)refresh;

@end
