//
//  User.m
//  SQLite3Demo
//
//  Created by Zorn on 16/7/29.
//  Copyright © 2016年 任大树. All rights reserved.
//

#import "User.h"

@implementation User
-(instancetype)initWithName:(NSString *)name andNumber:(NSString *)number andUserID:(int)userID{
    if (self = [super init]) {
        _name=name;
        _number=number;
        _userID=userID;
    }
    return self;
}
@end
