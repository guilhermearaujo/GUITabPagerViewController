//
//  GUITabScrollView.h
//  GUITabPagerViewController
//
//  Created by Guilherme Araújo on 26/02/15.
//  Copyright (c) 2015 Guilherme Araújo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GUITabScrollDelegate;

@interface GUITabScrollView : UIScrollView

@property (weak, nonatomic) id<GUITabScrollDelegate> tabScrollDelegate;

- (instancetype)initWithFrame:(CGRect)frame tabViews:(NSArray *)tabViews color:(UIColor *)color;
- (instancetype)initWithFrame:(CGRect)frame tabViews:(NSArray *)tabViews color:(UIColor *)color selectedTabIndex:(NSInteger)index;

- (void)selectTabAtIndex:(NSInteger)index;
- (void)selectTabAtIndex:(NSInteger)index animated:(BOOL)animated;

@end

@protocol GUITabScrollDelegate <NSObject>

- (void)tabScrollView:(GUITabScrollView *)tabScrollView didSelectTabAtIndex:(NSInteger)index;

@end
