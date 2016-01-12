//
//  GlobalVars.h
//  EDEA
//
//  Created by Vincent Villalta on 11/23/15.
//  Copyright © 2015 Vincent Villalta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalVars : NSObject
{
    int selectedAccount;
}

@property(nonatomic, readwrite) int selectedAccount;
@property(nonatomic, readwrite) NSArray *consumos;
@property(nonatomic, readwrite) NSArray *facturas;

@property(nonatomic, retain) NSMutableArray * consumosArray;

+(GlobalVars *)sharedInstance;
-(void)initConsumosArrayWithUsers:(NSArray*)users;
-(void)resetAndSelectUserAtIndex:(NSInteger)index;

@end