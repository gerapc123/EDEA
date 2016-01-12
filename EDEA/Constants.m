//
//  Constants.m
//  Wisetrack
//
//  Created by Vincent Villalta on 4/27/15.
//  Copyright (c) 2015 Vincent Villalta. All rights reserved.
//

#import "Constants.h"
#import "AFSQLManager.h"

@implementation Constants

-(id)performQuery: (NSString *)query {
    _array = [NSMutableArray array];
    [[AFSQLManager sharedManager]performQuery:query withBlock:^(NSArray *row, NSError *error, BOOL finished) {
        if (!error) {
            if (!finished) {
                [_array addObject:row];
            }
        } else {
            NSLog(@"Error with query %@ -> %@", query, error.localizedDescription);
        }
    }];
    return _array;
}

- (BOOL) perfomrQueryWithoutReturnType: (NSString *)query{
    BOOL completedTask = false;
    [[AFSQLManager sharedManager]performQuery:query withBlock:^(NSArray *row, NSError *error, BOOL finished) {
        if (!error) {
            if (!finished) {
               __block completedTask = finished;
            }
        } else {
            NSLog(@"Error with query %@ -> %@", query, error.localizedDescription);
        }
    }];
    return completedTask;
}

@end
