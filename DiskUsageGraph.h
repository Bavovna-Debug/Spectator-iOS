//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SRVMountRecord.h"

@interface DiskUsageGraph : UIView

@property (weak, nonatomic) SRVMountRecord *mount;

- (id)initWithFrame:(CGRect)frame
              mount:(SRVMountRecord *)mount;

- (void)updateGraph;

@end
