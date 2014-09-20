//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "BarGraph.h"

#import "SRVProcessorsRecorder.h"

@interface CpuDetailsBarGraph : BarGraph

- (id)initWithFrame:(CGRect)frame
           recorder:(SRVProcessorsRecorder *)recorder
          cpuNumber:(NSUInteger)cpuNumber
          userColor:(UIColor *)userColor
          niceColor:(UIColor *)niceColor
        systemColor:(UIColor *)systemColor
          idleColor:(UIColor *)idleColor;

- (void)refresh;

@end
