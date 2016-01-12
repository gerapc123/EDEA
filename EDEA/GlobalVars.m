//
//  GlobalVars.m
//  EDEA
//
//  Created by Vincent Villalta on 11/23/15.
//  Copyright © 2015 Vincent Villalta. All rights reserved.
//

#import "GlobalVars.h"

@implementation GlobalVars

@synthesize selectedAccount = _selectedAccount;
@synthesize consumosArray = _consumosArray;

+ (GlobalVars *)sharedInstance {
    static dispatch_once_t onceToken;
    static GlobalVars *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[GlobalVars alloc] init];
    });
    return instance;
}


- (id)init {
    self = [super init];
    if (self) {
        _selectedAccount = 0;
        _consumosArray = nil;
    }
    return self;
}

-(void)resetAndSelectUserAtIndex:(NSInteger)index{
    _selectedAccount = index;
    _consumosArray = nil;
    _consumos = nil;
    _facturas = nil;
}

-(void)initConsumosArrayWithUsers:(NSArray*)users{
    _consumosArray = [NSMutableArray new];
    for (NSDictionary * aUser in users) {
        [_consumosArray addObject:[NSString stringWithFormat:@"%@",[aUser objectForKey:@"nombre"]]];
    }
}

@end
