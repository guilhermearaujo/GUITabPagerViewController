//
//  GUITabPagerViewController.m
//  GUITabPagerViewController
//
//  Created by Guilherme Araújo on 26/02/15.
//  Copyright (c) 2015 Guilherme Araújo. All rights reserved.
//

#import "GUITabPagerViewController.h"
#import "GUITabScrollView.h"

@interface GUITabPagerViewController () <GUITabScrollDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) GUITabScrollView *header;
@property (assign, nonatomic) NSInteger currentIndex;

@property (strong, nonatomic) NSMutableArray *viewControllers;
@property (strong, nonatomic) NSMutableArray *tabTitles;
@property (strong, nonatomic) UIColor *headerColor;
@property (assign, nonatomic) CGFloat headerHeight;

@end

@implementation GUITabPagerViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self setPageViewController:[[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil]];
  
  for (UIView *view in [[[self pageViewController] view] subviews]) {
    if ([view isKindOfClass:[UIScrollView class]]) {
      [(UIScrollView *)view setCanCancelContentTouches:YES];
      [(UIScrollView *)view setDelaysContentTouches:NO];
    }
  }

  [[self pageViewController] setDataSource:self];
  [[self pageViewController] setDelegate:self];

  [self addChildViewController:self.pageViewController];
  [self.view addSubview:self.pageViewController.view];
  [self.pageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Page View Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
  NSUInteger pageIndex = [[self viewControllers] indexOfObject:viewController];
  return pageIndex > 0 ? [self viewControllers][pageIndex - 1]: nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
  NSUInteger pageIndex = [[self viewControllers] indexOfObject:viewController];
  return pageIndex < [[self viewControllers] count] - 1 ? [self viewControllers][pageIndex + 1]: nil;
}

#pragma mark - Page View Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
  NSInteger index = [[self viewControllers] indexOfObject:pendingViewControllers[0]];
  [[self header] animateToTabAtIndex:index];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
  [self setCurrentIndex:[[self viewControllers] indexOfObject:[[self pageViewController] viewControllers][0]]];
  [[self header] animateToTabAtIndex:[self currentIndex]];
}

#pragma mark - Tab Scroll View Delegate

- (void)tabScrollView:(GUITabScrollView *)tabScrollView didSelectTabAtIndex:(NSInteger)index {
  if (index != [self currentIndex]) {
    [[self pageViewController]  setViewControllers:@[[self viewControllers][index]]
                                         direction:(index > [self currentIndex]) ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse
                                          animated:YES
                                        completion:nil];
    [self setCurrentIndex:index];
  }
}

- (void)reloadData {
  [self setViewControllers:[NSMutableArray array]];
  [self setTabTitles:[NSMutableArray array]];
  
  NSInteger number = [[self dataSource] numberOfViewControllers];
  if (number == 0)
    return;
  
  for (int i = 0; i < number; i++) {
    [[self viewControllers] addObject:[[self dataSource] viewControllerForIndex:i]];
    if ([[self dataSource] respondsToSelector:@selector(titleForTabAtIndex:)]) {
      [[self tabTitles] addObject:[[self dataSource] titleForTabAtIndex:i]];
     }
  }
  
  if ([[self dataSource] respondsToSelector:@selector(tabHeight)]) {
    [self setHeaderHeight:[[self dataSource] tabHeight]];
  } else {
    [self setHeaderHeight:44.0f];
  }
  
  if ([[self dataSource] respondsToSelector:@selector(tabColor)]) {
    [self setHeaderColor:[[self dataSource] tabColor]];
  } else {
    [self setHeaderColor:[UIColor orangeColor]];
  }

  CGRect frame = [[self view] frame];
  frame.origin.y += [self headerHeight];
  frame.size.height -= [self headerHeight];
  
  [[[self pageViewController] view] setFrame:frame];
  
  [self.pageViewController setViewControllers:@[[self viewControllers][0]]
                                    direction:UIPageViewControllerNavigationDirectionReverse
                                     animated:NO
                                   completion:nil];
  [self setCurrentIndex:0];
  
  NSMutableArray *tabViews = [NSMutableArray array];
  
  if ([[self dataSource] respondsToSelector:@selector(viewForTabAtIndex:)]) {
    for (int i = 0; i < [[self viewControllers] count]; i++) {
      [tabViews addObject:[[self dataSource] viewForTabAtIndex:i]];
     }
  } else {
    for (NSString *title in [self tabTitles]) {
      UILabel *label = [UILabel new];
      [label setText:title];
      [label setTextAlignment:NSTextAlignmentCenter];
      [label setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f]];
      [label sizeToFit];
      
      CGRect frame = [label frame];
      frame.size.width = MAX(frame.size.width + 20, 85);
      [label setFrame:frame];
      [tabViews addObject:label];
    }
  }
  
  if ([self header]) {
    [[self header] removeFromSuperview];
  }
  
  [self setHeader:[[GUITabScrollView alloc] initWithTabViews:tabViews tabBarHeight:[self headerHeight] tabColor:[self headerColor]]];
  [[self header] setTabScrollDelegate:self];
  
  frame = [[self view] frame];
  frame.size.height = [self headerHeight];
  [[self header] setFrame:frame];
  [[self view] addSubview:[self header]];
}

@end

