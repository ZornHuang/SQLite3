//
//  User.h
//  SQLite3Demo
//
//  Created by Zorn on 16/7/29.
//  Copyright © 2016年 任大树. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
/**	
 姓名
 */
@property (nonatomic,copy) NSString *name;

/**	
 电话
 */
@property (nonatomic,copy) NSString *number;

/**	
 userID
 */
@property (nonatomic,assign)NSInteger userID;

//自定义初始化方法
-(instancetype)initWithName:(NSString *)name andNumber:(NSString *)number andUserID:(int)userID;



@end
