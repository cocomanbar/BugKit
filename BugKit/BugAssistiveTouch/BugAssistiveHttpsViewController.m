//
//  BugAssistiveHttpsViewController.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/17.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "BugAssistiveHttpsViewController.h"
#import "BugAssistiveHttpCell.h"
#import "BugAssistiveHttpDataSource.h"
#import "BugAssistiveConstants.h"
#import "BugAssistiveHttpHelper.h"
#import "BugAssistiveHttpsDetailViewController.h"

@interface BugAssistiveHttpsViewController ()
<UITableViewDataSource,
UITableViewDelegate>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSArray *listData;
@property (nonatomic, strong)UIView *tableBackgroundView;

@end

@implementation BugAssistiveHttpsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    /* rightItemConfig */
    [self rightItemConfig];
    
    /* tableView */
    [self.view addSubview:self.tableView];
    self.tableView.frame = self.view.bounds;
    
    /* reload list */
    [self reloadHttp];
    
    /* listen reload */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadHttp)
                                                 name:kNotifyKeyReloadHttp
                                               object:nil];
}

- (void)reloadHttp{
    self.listData = [[[BugAssistiveHttpDataSource shareInstance] httpArray] copy];
    [self.tableView reloadData];
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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.listData.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [BugAssistiveHttpCell rowHeight];
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BugAssistiveHttpCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BugAssistiveHttpCell"];
    BugAssistiveHttpModel *model = [self.listData objectAtIndex:indexPath.section];
    cell.titleText = model.url.host;
    cell.detailText = model.url.path;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BugAssistiveHttpModel *model = [self.listData objectAtIndex:indexPath.section];
    
    BugAssistiveHttpsDetailViewController *viewController = [[BugAssistiveHttpsDetailViewController alloc]init];
    viewController.model = model;
    viewController.hidesBottomBarWhenPushed = YES;
    viewController.title = @"详情";
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - lazyLoad

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        
        [_tableView registerClass:[BugAssistiveHttpCell class] forCellReuseIdentifier:@"BugAssistiveHttpCell"];
    }
    return _tableView;
}

- (UIView *)tableBackgroundView{
    if (!_tableBackgroundView) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"BugAssistiveBundle" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        NSString *close = [bundle pathForResource:@"source/space@2x" ofType:@"png"];
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

#pragma mark - rightItemConfig

- (void)rightItemConfig{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"BugAssistiveBundle" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *close = [bundle pathForResource:@"source/clean@2x" ofType:@"png"];
    UIImage *image = [[UIImage imageWithContentsOfFile:close] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onRightItemClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)onRightItemClick{
    [[BugAssistiveHttpDataSource shareInstance] clear];
    self.listData = @[];
    [self.tableView reloadData];
    if (!self.tableBackgroundView.superview) {
        [self.tableView setBackgroundView:self.tableBackgroundView];
        self.tableBackgroundView.hidden = NO;
    }
}

#pragma mark - others

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
