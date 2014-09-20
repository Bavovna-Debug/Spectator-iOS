//
//  Spectator
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "Panel.h"

#import "SRVMountRecord.h"

@interface MountPanel : Panel

@property (strong, nonatomic) SRVMountRecord *mount;
@property (assign, nonatomic) Boolean showBytes;

- (id)initWithMount:(SRVMountRecord *)mount;

- (void)refresh;

@end
