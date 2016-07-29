//
//  User.h
//  SQLite3Demo
//
//  Created by Zorn on 16/7/29.
//  Copyright © 2016年 任大树. All rights reserved.
//


#import "Database.h"
#import "User.h"
#import <sqlite3.h>


@implementation Database

static Database *databace = nil;

#pragma mark -单例-
+(instancetype)shareDatabase{
     //加锁
    @synchronized (self) {
        if (!databace) {
            databace = [[Database alloc]init];
        }
    }
    return databace;
}

#pragma mark -创建数据库对象-
static sqlite3 *db = nil;

#pragma mark -打开数据库-
-(void)openDatabaseWithFilePath:(NSString *)filePath andTableName:(NSString *)tableName{
    _filePath = filePath;
    _tableName = tableName;
     //如果数据库已经打开，则不需要执行后面的操作
    if (db) {
        return;
    }
    
    //创建保存数据库的路径
    NSString *fileName = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:_filePath];
    //转化为C语言
    const char *cfileName = fileName.UTF8String;
    //确认语句
    int result = sqlite3_open(cfileName,&db);
    //打开数据（如果该数据库存在则直接打开，否则，自动创建一个再打开）
    if (result == SQLITE_OK) {
        NSLog(@"数据库打开成功了");

            //建表
            //1.准备sql语句
            NSString *sql =[NSString stringWithFormat:@"CREATE TABLE %@ (userID INTEGER PRIMARY KEY NOT NULL UNIQUE, name TEXT NOT NULL,number INTEGER NOT NULL)",_tableName];
            //2.调试使用
//            char *errmsg = NULL;
            //3.执行sql语句
            sqlite3_exec(db, sql.UTF8String, NULL, NULL, NULL);
//            if (!errmsg) {
//                NSLog(@"创表成功了");
//            }else{
//                NSLog(@"创表失败了：%s",errmsg);
//            }

        
        
    }else{
        NSLog(@"数据库打开失败！！！");
    }
    
    NSLog(@"获取数据库路径：%@",fileName);
}

#pragma mark -关闭数据库-
-(void)closeDatabase{
    int result = sqlite3_close(db);
    if (result == SQLITE_OK) {
        //关闭数据库的时候将db置为空，是因为打开数据库的时候，我们需要用nil做判断
        db = nil;
    }else{
        NSLog(@"关闭数据库失败");
    }
}

#pragma mark -添加-
-(void)insertName:(NSString *)name andNumber:(NSString*)number{
    
        //1.打开数据库
        [self openDatabaseWithFilePath:_filePath andTableName:_tableName];
        //2.创建跟随指针
        sqlite3_stmt *stmt = nil;
        //3.准备sql语句
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (name,number) VALUES(?,?)",_tableName];
        //4.验证SQL语句的正确性
        int resulte = sqlite3_prepare_v2(db, sql.UTF8String, -1, &stmt, NULL);
        if (resulte == SQLITE_OK) {
            NSLog(@"添加数据成功");
            //5.绑定
            sqlite3_bind_text(stmt, 1, name.UTF8String, -1, NULL);
            sqlite3_bind_int(stmt, 2, number.intValue);
            //6.执行单步
            sqlite3_step(stmt);
            
        }else{
            NSLog(@"添加数据失败");
        }
        //7.释放跟随指针占用的内存
        sqlite3_finalize(stmt);
    
    
}

#pragma mark -删除所有-
-(void)deleteTable{
    //1.打开数据库
    [self openDatabaseWithFilePath:_filePath andTableName:_tableName];
    //2.创建一个跟随指针
    sqlite3_stmt *stmt = nil;
    //3.准备sql语句
    NSString *sql =[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@",_tableName];
    //4.验证sql语句的正确性
    int result = sqlite3_prepare_v2(db,sql.UTF8String,-1,&stmt,NULL);
    if (result == SQLITE_OK) {
        NSLog(@"删除成功了");
        //5.绑定 (第三个参数，代表第几列。因为id是主键，所以删除它也就删除了所有了)
        sqlite3_bind_int(stmt, 1, 1);
        //6.执行单步
        sqlite3_step(stmt);
    }else{
        NSLog(@"删除失败");
    }
    //7.释放跟随指针占用的内存
    sqlite3_finalize(stmt);
    
}

#pragma mark -删除指定位置-
-(void)deleteT_ID:(int)t_id{
    //1.打开数据库
    [self openDatabaseWithFilePath:_filePath andTableName:_tableName];
    //2.创建一个跟随指针
    sqlite3_stmt *stmt = nil;
    //3.准备sql语句
    NSString *sql =[NSString stringWithFormat:@"DELETE FROM %@ WHERE userID = ?",_tableName];
    //4.验证sql语句的正确性
    int result = sqlite3_prepare_v2(db, sql.UTF8String, -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        NSLog(@"删除成功了");
        //5.绑定
        sqlite3_bind_int(stmt, 1, t_id);
        //6.执行单步
        sqlite3_step(stmt);
    }else{
        NSLog(@"删除失败");
    }
    //7.释放跟随指针占用的内存
    sqlite3_finalize(stmt);
    
}



#pragma mark -查询此表-
-(NSMutableArray *)selectTable{
     //1.打开数据库
   [self openDatabaseWithFilePath:_filePath andTableName:_tableName];
    //2.创建一个跟随指针
    sqlite3_stmt *stmt = nil;
    //3.准备SQL语句
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@",_tableName];
    //4.验证sql语句
    int result = sqlite3_prepare_v2(db, sql.UTF8String, -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        NSLog(@"查询成功");
        //5.创建可变数组，用来存储查询到的数据
        NSMutableArray *array = [NSMutableArray array];
        
        //6.每调用一次sqlite3_step函数，stmt就会指向下一条记录
        while (sqlite3_step(stmt) == SQLITE_ROW) {//找到一条记录
            //7.取出数据
            //7.1.列出第0列字段的值(int 类型的值)
            int userID = sqlite3_column_int(stmt, 0);
            //7.2.取出第1列字段的值(text 类型的值)
             NSString *name = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 1)];
            //7.3.取出第2列字段的值(int 类型的值)
             NSString *number = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 2)];

            //封装name age t_ID,然后将对象添加到数组，并返回
            User *user = [[User alloc]initWithName:name andNumber:number andUserID:userID];
            [array addObject:user];
        }
        //9.释放跟随指针
        sqlite3_finalize(stmt);
        return array;
    }else{
        NSLog(@"查询失败:%d",result);
    }
    
    //释放跟随指针
    sqlite3_finalize(stmt);
    return nil;
}

#pragma mark -指定查询纪录-
-(NSMutableArray *)selectTableWithCondition:(NSString *)condition{
    
    //创建数组，用来存放数据
    NSMutableArray *dataArr = nil;
    //1.打开数据库
    [self openDatabaseWithFilePath:_filePath andTableName:_tableName];
    //2.创建跟随指针
    sqlite3_stmt *stmt = nil;
    //3.准备sql语句
    NSString *sql = [NSString stringWithFormat:@"SELECT  *FROM  %@ WHERE name LIKE '%%%@%%' or number LIKE '%%%@%%'",_tableName,condition,condition];
    
    //4.验证SQL语句的正确性
    int result = sqlite3_prepare_v2(db, sql.UTF8String, -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        //每调用一次sqlite3_stmp函数，stmt就会指向下一条记录
        while (sqlite3_step(stmt)==SQLITE_ROW) {//找到一条记录
            //取出数据
            //1.列出第0列字段的值(int 类型的值)
            int userID = sqlite3_column_int(stmt,0);
            //2.取出第1列字段的值(text类型的值)
            NSString *name = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)];
            
            //3.取出第2列字段的值(int类型的值)
             NSString *number = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, 2)];
            
            dataArr = [NSMutableArray array];
            User *user = [[User alloc]initWithName:name andNumber:number andUserID:userID];
   
            [dataArr addObject:user];
        }
        
    }else{
        NSLog(@"查询ID失败");
    }
    
    //6.释放跟随指针
    sqlite3_finalize(stmt);
    return dataArr;
}

#pragma mark -修改数据-
-(void)updateTableWithName:(NSString *)name andNumber:(int)number andUserID:(int)userID{
   
    //1.打开数据库
    [self openDatabaseWithFilePath:_filePath andTableName:_tableName];
    //2.创建一个跟随指针
    sqlite3_stmt *stmt = nil;
    //3.准备一个跟随指针
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET name = ? , number = ? WHERE userID = ? ",_tableName];
    //4.验证sql语句
    int result = sqlite3_prepare_v2(db, sql.UTF8String, -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        NSLog(@"修改成功");
        //5.绑定
        sqlite3_bind_text(stmt, 1, name.UTF8String, -1, NULL);
        sqlite3_bind_int(stmt, 2, number);
        sqlite3_bind_int(stmt, 3, userID);
        //6.单步执行
        sqlite3_step(stmt);
    }else{
        NSLog(@"修改失败");
    }
    
    //7.释放跟随指针占用的内存
    sqlite3_finalize(stmt);
}



#pragma mark -获取Document文件路径-
+(NSString *)documentWithFilePath:(NSString *)filePath{
    //获取文件路径
    NSString *fileName = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",filePath]];
    return fileName;
}

#pragma mark -获取Library文件路径-
+(NSString *)libraryWithFilePath:(NSString *)filePath{
    //获取文件路径
    NSString *fileName = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",filePath]];
    return fileName;

}

#pragma mark -获取Caches文件路径-
+(NSString *)cachesWithFilePath:(NSString *)filePath{
    //获取文件路径
    NSString *fileName = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",filePath]];
    return fileName;

}

#pragma mark -获取Tmp文件路径-
+(NSString *)tmpWithFilePath:(NSString *)filePath{
    //获取文件路径
    NSString *fileName = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",filePath]];
    return fileName;
}

#pragma mark -删除数据库-
-(void)deleteDatabaseWithFilePath:(NSString *)filePath{
    
    //创建文件管理者
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //判断文件是否存在
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:nil];
        NSLog(@"从Document删除数据库成功了");
    }else{
        NSLog(@"删除数据库失败了");
    }
    
}


#pragma mark -修改数据库名-
-(void)updateDatabaseWithFilePath:(NSString *)filePath andOtherFilePath:(NSString *)otherFilePath{

    //创建文件管理者
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //判断文件是否存在
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager copyItemAtPath:filePath toPath:otherFilePath error:nil];
        [fileManager removeItemAtPath:filePath error:nil];
        NSLog(@"修改数据库名成功了");
    }else{
        NSLog(@"修改数据库名失败了");
    }
    
    
}

#pragma mark -移动数据库-
-(void)moveDatabaseWithFilePath:(NSString *)filePath toOtherFilePath:(NSString *)otherFilePath{

    //创建文件管理者
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //判断文件是否存在
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager moveItemAtPath:filePath toPath:otherFilePath error:nil];
        NSLog(@"移动数据库到Library成功了");
    }else{
        NSLog(@"移动数据库到Library失败了");
    }
    
}



@end
