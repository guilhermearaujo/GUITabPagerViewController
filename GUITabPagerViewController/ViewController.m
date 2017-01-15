//
//  ViewController.m
//  GUITabPagerViewController
//
//  Created by Guilherme Araújo on 27/02/15.
//  Copyright (c) 2015 Guilherme Araújo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <GUITabPagerDataSource, GUITabPagerDelegate>

@end

@implementation ViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setDataSource:self];
  [self setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self reloadData];
}

#pragma mark - Tab Pager Data Source

- (NSInteger)numberOfViewControllers {
  return 10;
}

- (UIViewController *)viewControllerForIndex:(NSInteger)index {
  #pragma unused (index)

  UIViewController *pageVC = [UIViewController new];
  [[pageVC view] setBackgroundColor:[UIColor colorWithRed:arc4random_uniform(255) / 255.0f
                                                    green:arc4random_uniform(255) / 255.0f
                                                     blue:arc4random_uniform(255) / 255.0f
                                                    alpha:1]];
  return pageVC;
}

// Implement either viewForTabAtIndex: or titleForTabAtIndex:
//- (UIView *)viewForTabAtIndex:(NSInteger)index {
//  return <#UIView#>;
//}

- (NSString *)titleForTabAtIndex:(NSInteger)index {
  return [NSString stringWithFormat:@"Tab #%ld", (long) index + 1];
}

- (CGFloat)tabHeight {
  // Default: 44.0f
  return 50.0f;
}

- (UIColor *)tabColor {
  // Default: [UIColor orangeColor];
  return [UIColor purpleColor];
}

- (UIColor *)tabBackgroundColor {
  // Default: [UIColor colorWithWhite:0.95f alpha:1.0f];
  return [UIColor lightTextColor];
}

- (UIFont *)titleFont {
  // Default: [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f];
  return [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0f];
}

- (UIColor *)titleColor {
  // Default: [UIColor blackColor];
  return [UIColor colorWithRed:1.0f green:0.8f blue:0.0f alpha:1.0f];
}

#pragma mark - Tab Pager Delegate

- (void)tabPager:(GUITabPagerViewController *)tabPager willTransitionToTabAtIndex:(NSInteger)index {
  #pragma unused (tabPager)

  NSLog(@"Will transition from tab %ld to %ld", (long)[self selectedIndex], (long)index);
}

- (void)tabPager:(GUITabPagerViewController *)tabPager didTransitionToTabAtIndex:(NSInteger)index {
  #pragma unused (tabPager)

  NSLog(@"Did transition to tab %ld", (long)index);
}

@end
