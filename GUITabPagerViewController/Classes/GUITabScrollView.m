//
//  GUITabScrollView.m
//  GUITabPagerViewController
//
//  Created by Guilherme Araújo on 26/02/15.
//  Copyright (c) 2015 Guilherme Araújo. All rights reserved.
//

#import "GUITabScrollView.h"

@interface GUITabScrollView ()

@property (strong, nonatomic) NSArray *tabViews;

@property (strong, nonatomic) UIView *tabsView;
@property (assign, nonatomic) TabPosition tabPosition;
@property (strong, nonatomic) UIView *tabIndicator;

@property (strong, nonatomic) NSLayoutConstraint *tabsLeadingConstraint;
@property (strong, nonatomic) NSLayoutConstraint *tabsTrailingConstraint;
@property (strong, nonatomic) NSLayoutConstraint *indicatorWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *indicatorCenterConstraint;

@end

@implementation GUITabScrollView

#pragma mark - Initialize Methods

- (instancetype)initWithFrame:(CGRect)frame tabViews:(NSArray *)tabViews tabPosition:(TabPosition)tabPosition
                        color:(UIColor *)color bottomLineHeight:(CGFloat)bottomLineHeight
             selectedTabIndex:(NSInteger)index {
  self = [super initWithFrame:frame];

  if (!self) {
    return nil;
  }

  [self setTabPosition:tabPosition];

  [self setShowsHorizontalScrollIndicator:NO];
  [self setBounces:NO];

  self.tabViews = tabViews;

  UIView *contentView = [UIView new];
  [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
  [self addSubview:contentView];
  self.tabsView = contentView;

  UIView *bottomLine = [[UIView alloc] initWithFrame:self.bounds];
  [bottomLine setTranslatesAutoresizingMaskIntoConstraints:NO];
  bottomLine.backgroundColor = color;
  [self addSubview:bottomLine];

  [self addConstraintsToContentView:contentView bottomLine:bottomLine bottomLineHeight:bottomLineHeight];

  [self addTabsFrom:tabViews toContentView:contentView];
  [self addIndicatorsToContentView:contentView withColor:color];

  [self selectTabAtIndex:(index ?: 0) animated:NO];

  return self;
}

- (instancetype)initWithFrame:(CGRect)frame tabViews:(NSArray *)tabViews color:(UIColor *)color
             bottomLineHeight:(CGFloat)bottomLineHeight selectedTabIndex:(NSInteger)index {
  return [self initWithFrame:frame tabViews:tabViews tabPosition:TabPositionCenter color:color
            bottomLineHeight:bottomLineHeight selectedTabIndex:index];
}

- (instancetype)initWithFrame:(CGRect)frame tabViews:(NSArray *)tabViews color:(UIColor *)color
             bottomLineHeight:(CGFloat)bottomLineHeight {
  return [self initWithFrame:frame tabViews:tabViews tabPosition:TabPositionCenter color:color
            bottomLineHeight:bottomLineHeight selectedTabIndex:0];
}

- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];

  [self setNeedsUpdateConstraints];
  [self scrollToSelectedTab];
}

- (void)layoutSubviews {
  [super layoutSubviews];

  UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.contentSize.width, self.contentSize.height)];
  self.layer.shadowPath = shadowPath.CGPath;
  self.layer.shadowColor = [[UIColor blackColor] CGColor];
  self.layer.shadowRadius = 5;
  self.layer.shadowOpacity = 0.6;
  self.layer.masksToBounds = NO;
}

- (void)updateConstraints {
  CGFloat offset = self.bounds.size.width - self.tabsView.frame.size.width;

  switch (self.tabPosition) {
    case TabPositionLeft:
      self.tabsLeadingConstraint.constant = 0;
      self.tabsTrailingConstraint.constant = offset;
      break;

    case TabPositionRight:
      self.tabsLeadingConstraint.constant = offset;
      self.tabsTrailingConstraint.constant = 0;
      break;

    case TabPositionCenter: {
      if (self.bounds.size.width > self.tabsView.frame.size.width) {
        offset /= 2.0f;
      }

      self.tabsLeadingConstraint.constant = offset;
      self.tabsTrailingConstraint.constant = offset;
      break;
    }
  }

  [super updateConstraints];
}

#pragma mark - Public Methods

- (void)selectTabAtIndex:(NSInteger)index {
  [self selectTabAtIndex:index animated:YES];
}

- (void)selectTabAtIndex:(NSInteger)index animated:(BOOL)animated {
  CGFloat animatedDuration = 0.4f;

  if (!animated) {
    animatedDuration = 0.0f;
  }

  self.indicatorWidthConstraint = [self replaceConstraint:self.indicatorWidthConstraint
                                            withNewToItem:self.tabViews[index]];

  self.indicatorCenterConstraint = [self replaceConstraint:self.indicatorCenterConstraint
                                             withNewToItem:self.tabViews[index]];

  [UIView animateWithDuration:animatedDuration animations:^{
    [self layoutIfNeeded];
    [self scrollToSelectedTab];
  }];
}

- (void)tabTapHandler:(UITapGestureRecognizer *)gestureRecognizer {
  SEL selector = @selector(tabScrollView:didSelectTabAtIndex:);

  if ([[self tabScrollDelegate] respondsToSelector:selector]) {
    NSInteger index = [self.tabViews indexOfObject:[gestureRecognizer view]];
    [[self tabScrollDelegate] tabScrollView:self didSelectTabAtIndex:index];
    [self selectTabAtIndex:index];
  }
}

#pragma mark - Private Methods

- (void)addConstraintsToContentView:(UIView *)contentView bottomLine:(UIView *)bottomLine bottomLineHeight:(CGFloat)bottomLineHeight {
  NSDictionary *views = NSDictionaryOfVariableBindings(contentView, bottomLine);

  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[bottomLine]-0-|"
                                                               options:0
                                                               metrics:nil
                                                                 views:views]];

  NSString *format = @"V:|-0-[contentView]-0-[bottomLine(bottomLineHeight)]-0-|";
  NSDictionary *metrics = @{@"bottomLineHeight":@(bottomLineHeight)};
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                               options:0
                                                               metrics:metrics
                                                                 views:views]];

  [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView
                                                   attribute:NSLayoutAttributeHeight
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self
                                                   attribute:NSLayoutAttributeHeight
                                                  multiplier:1.0f
                                                    constant:-bottomLineHeight]];

  self.tabsLeadingConstraint =
  [NSLayoutConstraint constraintWithItem:contentView
                               attribute:NSLayoutAttributeLeading
                               relatedBy:NSLayoutRelationEqual
                                  toItem:self
                               attribute:NSLayoutAttributeLeading
                              multiplier:1.0f
                                constant:0];

  self.tabsTrailingConstraint =
  [NSLayoutConstraint constraintWithItem:self
                               attribute:NSLayoutAttributeTrailing
                               relatedBy:NSLayoutRelationEqual
                                  toItem:contentView
                               attribute:NSLayoutAttributeTrailing
                              multiplier:1.0f
                                constant:0];

  [self addConstraints:@[self.tabsLeadingConstraint, self.tabsTrailingConstraint]];
}

- (void)addTabsFrom:(NSArray *)tabViews toContentView:(UIView *)contentView {
  NSMutableString *VFL = [NSMutableString stringWithString:@"H:|"];
  NSMutableDictionary *tabViewsDict = [NSMutableDictionary dictionary];
  int totalTabsWidth = 0;

  for (int index = 0; index < tabViews.count; index++) {
    UIView *tab = tabViews[index];
    [tab setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentView addSubview:tab];

    totalTabsWidth += (int)(tab.frame.size.width);
    [VFL appendFormat:@"-0-[T%d(%d)]", index, (int)(tab.frame.size.width)];
    tabViewsDict[[NSString stringWithFormat:@"T%d", index]] = tab;

    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[T]-0-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:@{@"T": tab}]];
    [tab setUserInteractionEnabled:YES];
    [tab addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tabTapHandler:)]];
  }

  [VFL appendString:@"-0-|"];
  [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:VFL
                                                                      options:0
                                                                      metrics:nil
                                                                        views:tabViewsDict]];
}

- (void)addIndicatorsToContentView:(UIView *)contentView withColor:(UIColor *)color {
  UIView *tabIndicator = [UIView new];
  [tabIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
  tabIndicator.backgroundColor = color;
  [contentView addSubview:tabIndicator];
  self.tabIndicator = tabIndicator;

  NSString *format = @"V:[tabIndicator(3)]-0-|";
  NSDictionary *views = NSDictionaryOfVariableBindings(tabIndicator);

  [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];

  self.indicatorWidthConstraint =
    [NSLayoutConstraint constraintWithItem:tabIndicator
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.tabViews[0]
                                 attribute:NSLayoutAttributeWidth
                                multiplier:1.0f
                                  constant:0.0f];

  self.indicatorCenterConstraint =
    [NSLayoutConstraint constraintWithItem:tabIndicator
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.tabViews[0]
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1.0f
                                  constant:0.0f];

  [contentView addConstraints:@[self.indicatorCenterConstraint, self.indicatorWidthConstraint]];
}

- (void)scrollToSelectedTab {
  CGRect indicatorRect = [self.tabIndicator convertRect:self.tabIndicator.bounds
                                                 toView:self.superview];
  CGFloat diff = 0.0f;

  if (indicatorRect.origin.x < 0) {
    diff = indicatorRect.origin.x;
  } else if (CGRectGetMaxX(indicatorRect) > self.frame.size.width) {
    diff = CGRectGetMaxX(indicatorRect) - self.frame.size.width;
  } else {
    diff = 0.0f;
  }

  if (diff != 0.0f) {
    CGFloat xOffset = self.contentOffset.x + diff;
    self.contentOffset = CGPointMake(xOffset, self.contentOffset.y);
  }
}

- (NSLayoutConstraint *)replaceConstraint:(NSLayoutConstraint *)oldConstraint
                            withNewToItem:(UIView *)toItem {

  NSLayoutConstraint *newConstraint =
    [NSLayoutConstraint constraintWithItem:oldConstraint.firstItem
                                 attribute:oldConstraint.firstAttribute
                                 relatedBy:oldConstraint.relation
                                    toItem:toItem
                                 attribute:oldConstraint.secondAttribute
                                multiplier:oldConstraint.multiplier
                                  constant:oldConstraint.constant];

  [newConstraint setPriority:oldConstraint.priority];
  newConstraint.shouldBeArchived = oldConstraint.shouldBeArchived;
  newConstraint.identifier = oldConstraint.identifier;

  [NSLayoutConstraint deactivateConstraints:@[oldConstraint]];
  [NSLayoutConstraint activateConstraints:@[newConstraint]];
  
  return newConstraint;
}
  
@end
