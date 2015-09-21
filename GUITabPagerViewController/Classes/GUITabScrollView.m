//
//  GUITabScrollView.m
//  GUITabPagerViewController
//
//  Created by Guilherme Araújo on 26/02/15.
//  Copyright (c) 2015 Guilherme Araújo. All rights reserved.
//

#import "GUITabScrollView.h"

#define MAP(a, b, c) MIN(MAX(a, b), c)

@interface GUITabScrollView ()

@property (strong, nonatomic) NSArray *tabViews;
@property (strong, nonatomic) NSLayoutConstraint *tabIndicatorDisplacement;
@property (strong, nonatomic) NSLayoutConstraint *tabIndicatorWidth;

@end

@implementation GUITabScrollView

- (instancetype)initWithFrame:(CGRect)frame tabViews:(NSArray *)tabViews tabBarHeight:(CGFloat)height tabColor:(UIColor *)color backgroundColor:(UIColor *)backgroundColor {
  self = [super initWithFrame:frame];
  
  if (self) {
    [self setShowsHorizontalScrollIndicator:NO];
    [self setBounces:NO];
    
    [self setTabViews:tabViews];
    
    CGFloat width = 10;
    
    for (UIView *view in tabViews) {
      width += view.frame.size.width + 10;
    }
    
    [self setContentSize:CGSizeMake(MAX(width, self.frame.size.width), height)];
    
    CGFloat widthDifference = MAX(0, self.frame.size.width * 1.0f - width);
    
    UIView *contentView = [UIView new];
    [contentView setFrame:CGRectMake(0, 0, MAX(width, self.frame.size.width), height)];
    [contentView setBackgroundColor:backgroundColor];
    [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:contentView];
    
    NSMutableString *VFL = [NSMutableString stringWithString:@"H:|"];
    NSMutableDictionary *views = [NSMutableDictionary dictionary];
    int index = 0;
    
    
    for (UIView *tab in tabViews) {
      [contentView addSubview:tab];
      [tab setTranslatesAutoresizingMaskIntoConstraints:NO];
      [VFL appendFormat:@"-%f-[T%d(%f)]", index ? 10.0f : 10.0 + widthDifference / 2, index, tab.frame.size.width];
      [views setObject:tab forKey:[NSString stringWithFormat:@"T%d", index]];
      
      [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[T]-2-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:@{@"T": tab}]];
      [tab setTag:index];
      [tab setUserInteractionEnabled:YES];
      [tab addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tabTapHandler:)]];
      
      index++;
    }
    
    [VFL appendString:[NSString stringWithFormat:@"-%f-|", 10.0f + widthDifference / 2]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:VFL
                                                                        options:0
                                                                        metrics:nil
                                                                          views:views]];
    
    UIView *bottomLine = [UIView new];
    [bottomLine setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentView addSubview:bottomLine];
    [bottomLine setBackgroundColor:color];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[S]-0-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:@{@"S": bottomLine}]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-height-[S(2)]-0-|"
                                                                        options:0
                                                                        metrics:@{@"height": @(height - 2.0f)}
                                                                          views:@{@"S": bottomLine}]];
    UIView *tabIndicator = [UIView new];
    [tabIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentView addSubview:tabIndicator];
    [tabIndicator setBackgroundColor:color];
    
    [self setTabIndicatorDisplacement:[NSLayoutConstraint constraintWithItem:tabIndicator
                                                                   attribute:NSLayoutAttributeLeading
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:contentView
                                                                   attribute:NSLayoutAttributeLeading
                                                                  multiplier:1.0f
                                                                    constant:widthDifference / 2 + 5]];
    
    [self setTabIndicatorWidth:[NSLayoutConstraint constraintWithItem:tabIndicator
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:0
                                                           multiplier:1.0f
                                                             constant:[tabViews[0] frame].size.width + 10]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[S(5)]-0-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:@{@"S": tabIndicator}]];
    
    [contentView addConstraints:@[[self tabIndicatorDisplacement], [self tabIndicatorWidth]]];
  }
  
  return self;
}

- (void)animateToTabAtIndex:(NSInteger)index {
  CGFloat x = [[self tabViews][0] frame].origin.x - 5;
  
  for (int i = 0; i < index; i++) {
    x += [[self tabViews][i] frame].size.width + 10;
  }
  
  CGFloat w = [[self tabViews][index] frame].size.width + 10;
  [UIView animateWithDuration:0.4f
                   animations:^{
                     CGFloat p = x - (self.frame.size.width - w) / 2;
                     CGFloat min = 0;
                     CGFloat max = MAX(0, self.contentSize.width - self.frame.size.width);
                     
                     [self setContentOffset:CGPointMake(MAP(p, min, max), 0)];
                     [[self tabIndicatorDisplacement] setConstant:x];
                     [[self tabIndicatorWidth] setConstant:w];
                     [self layoutIfNeeded];
                   }];
}

- (void)tabTapHandler:(UITapGestureRecognizer *)gestureRecognizer {
  if ([[self tabScrollDelegate] respondsToSelector:@selector(tabScrollView:didSelectTabAtIndex:)]) {
    NSInteger index = [[gestureRecognizer view] tag];
    [[self tabScrollDelegate] tabScrollView:self didSelectTabAtIndex:index];
    [self animateToTabAtIndex:index];
  }
}

@end
