//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HALServer.h"

/*
typedef enum {
    HALVersionFull,
    HALVersionLite
} HALVersion;
*/

@interface HALApplicationDelegate : UIResponder <UIApplicationDelegate>

//@property (assign, nonatomic) HALVersion version;
@property (strong, nonatomic) UIWindow *window;

- (void)switchToMainPage;

- (void)switchToIntroduction;

- (void)switchToEditForm:(HALServer *)server;

- (void)switchToServer:(HALServer *)server;

@end