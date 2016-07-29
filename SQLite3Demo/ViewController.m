//
//  ViewController.m
//  SQLite3Demo
//
//  Created by Zorn on 16/7/29.
//  Copyright © 2016年 任大树. All rights reserved.
//

#import "ViewController.h"
#import "AddDataViewController.h"
#import "Database.h"
#import "User.h"
@interface ViewController ()<AddDataViewControllerDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic,strong)Database *db;
@property (nonatomic,strong)NSString *strRange;
@end

@implementation ViewController

#pragma mark -懒加载
-(NSMutableArray *)dataArr{
    if (_dataArr == nil) {
        _dataArr = (NSMutableArray *)[self.db selectTable];
        if (_dataArr == nil) {
            _dataArr = [NSMutableArray array];
        }
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    //打开数据库
    self.db = [[Database alloc]init];
    [self.db openDatabaseWithFilePath:@"zorn.sqlite" andTableName:@"t_zorn"];
    //添加按钮
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"增" style:UIBarButtonItemStylePlain target:self action:@selector(addAction)];
    //删除按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"删" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAction)];
    
    //设置搜索框
    UISearchBar *searchBar = [[UISearchBar alloc]init];
    [searchBar setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
    searchBar.placeholder = @"查询姓名或者电话";
    searchBar.showsCancelButton=YES;
    //修改SearchBar的Cancel Button 的Title
    UIButton *btn=[searchBar valueForKey:@"_cancelButton"];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    searchBar.delegate=self;
    self.navigationItem.titleView=searchBar;
    
    self.tableView.tableFooterView = [[UIView alloc]init];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //关闭数据库
    [self.db closeDatabase];
    [self.tableView setEditing:NO];
}

#pragma mark -实现AddDataViewController代理方法
-(void)changeValueName:(UITextField *)name andNumber:(UITextField *)number{
        //界面显示
    
    if (name.text.length > 0 || number.text.length > 0) {
        User *user = [[User alloc]init];
        user.name = name.text;
        user.number = number.text;
        [self.dataArr insertObject:user atIndex:self.dataArr.count];
        [self.tableView reloadData];
        
        //添加数据库
        [self.db insertName:name.text andNumber:number.text];
    }
    
    
}

#pragma mark -添加数据
-(void)addAction{
    AddDataViewController *vc = [[AddDataViewController alloc]init];
    vc.delegate = self;//设置自己为代理方
    vc.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"确认返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -删除数据
-(void)deleteAction{
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
}

#pragma mark -UITableView 代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
       static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    
 
    User *user = self.dataArr[indexPath.row];
        cell.textLabel.text = user.name;
        cell.detailTextLabel.text = user.number;
    
    
    return cell;
}
#pragma mark -删除的操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //界面删除
    User *user = self.dataArr[indexPath.row];
    
    NSMutableArray *dataArr = [NSMutableArray array];
    for (NSInteger i = indexPath.row; i < self.dataArr.count; i++) {
        [dataArr addObject:user];
    }
    
    [self.dataArr removeObjectsInArray:dataArr];
    [self.tableView reloadData];
    
   //数据库删除
    [self.db deleteT_ID:(int)user.userID];
}
#pragma mark -修改的操作
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改通讯录" message:@"号码请用数字表示" preferredStyle: UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入姓名";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入电话";
    }];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //界面显示
        User *user = self.dataArr[indexPath.row];
        user.name = alert.textFields[0].text;
        user.number = alert.textFields[1].text;
        
        [self.dataArr replaceObjectAtIndex:indexPath.row withObject:user];
        [self.tableView reloadData];
        NSLog(@"测试替换的数:%ld",indexPath.row);
        
        
        //添加到数据库
        [self.db updateTableWithName:user.name andNumber:user.number.intValue andUserID:(int)user.userID];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:action1];
    [alert addAction:action2];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark -UISearchBar 代理方法
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchBar.text.length <= 0 || [searchBar.text isEqualToString:@""]) {
        self.dataArr =(NSMutableArray *)[self.db selectTable];
        [self.tableView reloadData];
    }else{
        _strRange = searchText;
    self.dataArr = [self.db selectTableWithCondition:searchText];
        [self.tableView reloadData];
    
    }
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
        [self.tableView setEditing:NO animated:YES];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searchBar.text=nil;
    [searchBar resignFirstResponder];
    self.dataArr =(NSMutableArray *)[self.db selectTable];
    [self.tableView reloadData];
}


@end
