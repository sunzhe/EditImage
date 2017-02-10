//
//  EditViewController.m
//  TKImageViewDemo
//
//  Created by admin on 2016/12/21.
//  Copyright © 2016年 yinyu. All rights reserved.
//

#import "EditViewController.h"
#import "ShowImageView.h"
@interface EditViewController ()

@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame));
    //CGSize maskSize = CGSizeMake(rect.size.width*.7, rect.size.width*.7);
    ShowImageView *_editView = [[ShowImageView alloc] initWithFrame:rect];
    _editView.image = [UIImage imageNamed:@"test.jpg"];
    [_editView addCycleWithMaskSize:CGSizeMake(rect.size.width-30, rect.size.width-30)];
    _editView.limitCycle = YES;
    [_editView fillShadowWithColor:[UIColor colorWithWhite:0 alpha:.5] image:nil];
    [self.view addSubview:_editView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
