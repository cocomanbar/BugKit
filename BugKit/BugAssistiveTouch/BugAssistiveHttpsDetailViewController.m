//
//  BugAssistiveHttpsDetailViewController.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/25.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "BugAssistiveHttpsDetailViewController.h"
#import "BugAssistiveHttpCell.h"
#import "BugAssistiveHttpDataSource.h"
#import "BugAssistiveConstants.h"
#import "BugAssistiveContentViewController.h"
#import "BugAssistiveResponseViewController.h"

#define detailTitles   @[@"Request Url",@"Method",@"Status Code",@"Mime Type",@"Start Time",@"Total Duration",@"Request Body",@"Response Body"]

@interface BugAssistiveHttpsDetailViewController ()
<UITableViewDelegate,
UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSDateFormatter *formatter;

@end

@implementation BugAssistiveHttpsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    /* tableView */
    [self.view addSubview:self.tableView];
    self.tableView.frame = self.view.bounds;
}

- (void)setModel:(BugAssistiveHttpModel *)model{
    _model = model;
    [self.tableView reloadData];
}

#pragma mark - tableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return detailTitles.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [BugAssistiveHttpCell rowHeight];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BugAssistiveHttpCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BugAssistiveHttpCell"];
    cell.titleText = [detailTitles objectAtIndex:indexPath.row];
    NSInteger index =  indexPath.row;
    NSString *value = @"";
    if (index == 0) {
        value = self.model.url.absoluteString;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (index == 1){
        value = self.model.method;
    }
    else if (index == 2){
        value = self.model.statusCode;
    }
    else if (index == 3){
        value = self.model.mineType;
    }
    else if (index == 4){
        value = [self.formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.model.startTime.doubleValue]];
    }
    else if (index == 5){
        value = self.model.totalDuration;
    }
    else if (index == 6){
        if (self.model.requestBody.length > 0) {
            value = @"Tap to view";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            value = @"Empty";
        }
    }
    else if (index == 7){
        NSInteger lenght = self.model.responseData.length;
        if (lenght > 0) {
            if (lenght < 1024) {
                value = [NSString stringWithFormat:@"(%zdB) Tap to view",lenght];
            }
            else {
                value = [NSString stringWithFormat:@"(%.2fKB) Tap to view",1.0 * lenght / 1024];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            value = @"Empty";
        }
    }
    cell.detailText = value;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *viewController_out;
    if (indexPath.row == 0) {
        BugAssistiveContentViewController *viewController = [[BugAssistiveContentViewController alloc] init];
        viewController.content = self.model.url.absoluteString;
        viewController.title = @"接口地址";
        viewController_out = viewController;
    }
    else if (indexPath.row == 6 && self.model.requestBody.length > 0) {
        BugAssistiveContentViewController *viewController = [[BugAssistiveContentViewController alloc] init];
        viewController.content = self.model.requestBody;
        viewController.title = @"请求数据";
        viewController_out = viewController;
    }else if (indexPath.row == 7 && self.model.responseData.length > 0){
        BugAssistiveResponseViewController *viewController = [[BugAssistiveResponseViewController alloc] init];
        viewController.isImage = self.model.isImage;
        viewController.data = self.model.responseData;
        viewController.title = @"返回数据";
        viewController_out = viewController;
    }
    if (viewController_out) {
        viewController_out.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:viewController_out animated:YES];
    }
}


#pragma mark - lazyLoad

- (NSDateFormatter *)formatter{
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return _formatter;
}

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
        _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        
        [_tableView registerClass:[BugAssistiveHttpCell class] forCellReuseIdentifier:@"BugAssistiveHttpCell"];
    }
    return _tableView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
