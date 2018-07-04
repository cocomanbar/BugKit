//
//  BugAssistiveCrashViewController.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/17.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "BugAssistiveCrashViewController.h"
#import "BugAssistiveContentViewController.h"
#import "BugAssistiveCrashCell.h"
#import "BugAssistiveCrashHelper.h"
#import "BugAssistiveConstants.h"
#import "BugAssistiveTextInputViewController.h"

@interface BugAssistiveCrashViewController ()
<UITableViewDelegate,
UITableViewDataSource>

@property (nonatomic, strong)NSMutableArray *listData;
@property (nonatomic, strong)UITableView    *tableView;
@property (nonatomic, strong)UIView *tableBackgroundView;

@end

@implementation BugAssistiveCrashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self rightItemConfig];
    
    [self.view addSubview:self.tableView];
    self.tableView.frame = self.view.bounds;
    if (self.listData.count == 0 || !self.listData) {
        [self.tableView setBackgroundView:self.tableBackgroundView];
        self.tableBackgroundView.hidden = NO;
    }else{
        if (self.tableBackgroundView.superview) {
            [self.tableBackgroundView removeFromSuperview];
            self.tableBackgroundView.hidden = YES;
        }
    }
}

#pragma mark - tableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.listData.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == self.listData.count - 1) {
        return 5;
    }
    return 0.001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [BugAssistiveCrashCell rowHeight];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BugAssistiveCrashCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BugAssistiveCrashCell"];
    NSDictionary *dict = [self.listData objectAtIndex:indexPath.section];
    [cell loadDataWithDict:dict];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableDictionary *dict = [self.listData objectAtIndex:indexPath.section];
    NSDictionary *dicinfo = [dict objectForKey:@"info"];
    NSString *name = [dicinfo objectForKey:@"name"];
    NSString *reason = [dicinfo objectForKey:@"reason"];
    NSArray *callStack = [dicinfo objectForKey:@"callStack"];
    NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"%@\n\n%@\n\n",name,reason];
    for (NSString *item in callStack) {
        [str appendString:item];
        [str appendString:@"\n\n"];
    }
    
    /* 接上描述 */
    [str appendString:@"\n\n"];
    NSString *descip = [dict objectForKey:@"description"];
    descip = descip ? descip : @"描述：没有相关记录";
    [str appendString:descip];
    
    BugAssistiveContentViewController *viewController = [BugAssistiveContentViewController new];
    viewController.title = @"日志详情";
    viewController.content = str;
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
    
    if (![[dict objectForKey:@"read"] integerValue]) {
        [dict setValue:@1 forKey:@"read"];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        [[BugAssistiveCrashHelper sharedInstance] replaceCrashLogToFileByKey:[dict objectForKey:@"date"] withDict:dict];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
}

/* 删除/描述/困难度 */
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dict = [self.listData objectAtIndex:indexPath.section];
    NSString *key = [dict objectForKey:@"date"];
    if (!key) {
        return nil;
    }
    
    UITableViewRowAction *action_delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"移除\n记录" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您确定移除此条记录吗？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action_cacel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *action_sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            /* step1 */
            [[BugAssistiveCrashHelper sharedInstance] deleteCrashLogFromDateKey:key];
            /* step2 */
            [self.listData removeObjectAtIndex:indexPath.section];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            /* 暂位 */
            if (self.listData.count == 0 || !self.listData) {
                [self.tableView setBackgroundView:self.tableBackgroundView];
                self.tableBackgroundView.hidden = NO;
            }else{
                if (self.tableBackgroundView.superview) {
                    [self.tableBackgroundView removeFromSuperview];
                    self.tableBackgroundView.hidden = YES;
                }
            }
        }];
        [alert addAction:action_sure];
        [alert addAction:action_cacel];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
        });
        tableView.editing = NO;
    }];
    
    UITableViewRowAction *action_situation = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"评估\n等级" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择预估难易度" message:@"crash报告的首要目的是让程序员亲眼看到错误。如果您不能亲自做给他们看，给他们能使程序出错的详细的操作步骤" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *action_c = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *action_d = [UIAlertAction actionWithTitle:@"困难" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self updateCrashLogToFileByKey:key withDict:dict withStatus:BugAssistiveCrashSituationTypeDifficult withIndexPath:indexPath];
        }];
        UIAlertAction *action_m = [UIAlertAction actionWithTitle:@"中等" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self updateCrashLogToFileByKey:key withDict:dict withStatus:BugAssistiveCrashSituationTypeMedium withIndexPath:indexPath];
        }];
        UIAlertAction *action_s = [UIAlertAction actionWithTitle:@"简单" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self updateCrashLogToFileByKey:key withDict:dict withStatus:BugAssistiveCrashSituationTypeSimple withIndexPath:indexPath];
        }];
        [alert addAction:action_c];
        [alert addAction:action_d];
        [alert addAction:action_m];
        [alert addAction:action_s];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
        });
        tableView.editing = NO;
    }];
    
    BOOL ret = [[dict objectForKey:@"solution"] boolValue];
    NSString *title_text;
    if (!ret) {
        title_text = @"已经\n修复";
    }else{
        title_text = @"未能\n修复";
    }
    UITableViewRowAction *action_fix = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:title_text handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        if (ret) {
            [dict setValue:@0 forKey:@"solution"];
        }else{
            [dict setValue:@1 forKey:@"solution"];
        }
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        [[BugAssistiveCrashHelper sharedInstance] replaceCrashLogToFileByKey:key withDict:dict];
        
        tableView.editing = NO;
    }];
    
    UITableViewRowAction *action_desc = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"描述\n内容" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        BugAssistiveTextInputViewController *viewController = [[BugAssistiveTextInputViewController alloc]init];
        viewController.title = @"描述原因";
        viewController.dict = dict;
        viewController.hidesBottomBarWhenPushed = YES;
        __weak __typeof(&*self)weakSelf = self;
        viewController.refreshBlock = ^{
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        };
        [self.navigationController pushViewController:viewController animated:YES];
        tableView.editing = NO;
    }];
    
    action_delete.backgroundColor = [UIColor redColor];
    action_situation.backgroundColor = [UIColor purpleColor];
    action_fix.backgroundColor = [UIColor orangeColor];
    action_desc.backgroundColor = [UIColor darkGrayColor];
    
    return @[action_delete, action_situation, action_fix, action_desc];
}

- (void)updateCrashLogToFileByKey:(NSString *)key
                         withDict:(NSMutableDictionary *)dict
                       withStatus:(BugAssistiveCrashSituationType)status
                    withIndexPath:(NSIndexPath *)indexPath
{
    /* step1 */
    switch (status) {
        case BugAssistiveCrashSituationTypeSimple:
        {
            [dict setValue:@1 forKey:@"situation"];
        }
            break;
        case BugAssistiveCrashSituationTypeMedium:
        {
            [dict setValue:@2 forKey:@"situation"];
        }
            break;
        case BugAssistiveCrashSituationTypeDifficult:
        {
            [dict setValue:@3 forKey:@"situation"];
        }
            break;
            
        default:
            break;
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    /* step2 */
    [[BugAssistiveCrashHelper sharedInstance] replaceCrashLogToFileByKey:key withDict:dict];
}

#pragma mark - rightItemConfig

- (void)rightItemConfig{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"BugAssistiveBundle" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *close = [bundle pathForResource:@"source/selected@2x" ofType:@"png"];
    UIImage *image = [[UIImage imageWithContentsOfFile:close] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onRightItemClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)onRightItemClick{
    
}

#pragma mark - lazyLoad

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        
        [_tableView registerClass:[BugAssistiveCrashCell class] forCellReuseIdentifier:@"BugAssistiveCrashCell"];
    }
    return _tableView;
}

- (NSMutableArray *)listData{
    if (!_listData) {
        _listData = [NSMutableArray arrayWithArray:[[BugAssistiveCrashHelper sharedInstance] crashLogs]];
    }
    return _listData;
}

- (UIView *)tableBackgroundView{
    if (!_tableBackgroundView) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"BugAssistiveBundle" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        NSString *close = [bundle pathForResource:@"source/crash@2x" ofType:@"png"];
        UIImage *image = [[UIImage imageWithContentsOfFile:close] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.backgroundColor = [UIColor orangeColor];
        imageView.image = image;
        
        _tableBackgroundView = [[UIView alloc]initWithFrame:self.view.bounds];
        [_tableBackgroundView addSubview:imageView];
        _tableBackgroundView.backgroundColor = [UIColor clearColor];
    }
    return _tableBackgroundView;
}

#pragma mark - others

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
