//
//  UIViewController+Items.h
//  LPMultiViewControllerDemo
//
//  Created by XuYafei on 15/11/9.
//  Copyright © 2015年 loopeer. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LPHPageBarItem.h"
#import "LPHPageBar.h"
#import "LPHPageController.h"
#import "LPVPageController.h"

@interface UIViewController (Items)

@property (nonatomic, strong) LPHPageBarItem *pageBarItem;
@property (nonatomic, assign) LPHPageController *hPageController;
@property (nonatomic, assign) LPVPageController *vPageController;

- (void)lp_viewWillAppear:(BOOL)animated;
- (void)lp_viewDidAppear:(BOOL)animated;
- (void)lp_viewWillDisappear:(BOOL)animated;
- (void)lp_viewDidDisappear:(BOOL)animated;

@end
