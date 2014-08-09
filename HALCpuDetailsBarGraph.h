//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "HALBarGraph.h"
#import "HALProcessorsRecorder.h"

@interface HALCpuDetailsBarGraph : HALBarGraph

- (id)initWithFrame:(CGRect)frame
           recorder:(HALProcessorsRecorder *)recorder
          cpuNumber:(NSUInteger)cpuNumber
          userColor:(UIColor *)userColor
          niceColor:(UIColor *)niceColor
        systemColor:(UIColor *)systemColor
          idleColor:(UIColor *)idleColor;

- (void)refresh;

@end
