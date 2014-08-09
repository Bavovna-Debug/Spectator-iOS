//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HALServer.h"

@interface HALCpuGraph : UIView

typedef enum
{
    HALCpuGraphTypeTotal,
    HALCpuGraphTypeUser,
    HALCpuGraphTypeNice,
    HALCpuGraphTypeSystem
} HALCpuGraphType;

@property (weak, nonatomic) HALServer *server;
@property (assign, nonatomic) HALCpuGraphType graphType;

- (id)initWithFrame:(CGRect)frame
          graphType:(HALCpuGraphType)graphType;

@end
