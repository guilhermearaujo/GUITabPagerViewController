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
@property (strong, nonatomic) UIView *tabIndicator;

@property (strong, nonatomic) NSLayoutConstraint *tabsLeadingConstraint;
@property (strong, nonatomic) NSLayoutConstraint *tabsTrailingConstraint;
@property (strong, nonatomic) NSLayoutConstraint *indicatorWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *indicatorCenterConstraint;

@end

@implementation GUITabScrollView

#pragma mark - Initialize Methods

- (instancetype)initWithFrame:(CGRect)frame tabViews:(NSArray *)tabViews color:(UIColor *)color selectedTabIndex:(NSInteger)index {
  self = [self initWithFrame:frame tabViews:tabViews color:color];

  if (!self) {
    return nil;
  }

  [self selectTabAtIndex:(index ?: 0) animated:NO];

  return self;

}

- (instancetype)initWithFrame:(CGRect)frame tabViews:(NSArray *)tabViews color:(UIColor *)color {
    self = [super initWithFrame:frame];

    if (!self) {
        return nil;
    }

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

    CGFloat bottomLineHeight = 2.0;
    NSDictionary *views = NSDictionaryOfVariableBindings(contentView, bottomLine);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[bottomLine]-0-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[contentView]-0-[bottomLine(bottomLineHeight)]-0-|" options:0 metrics:@{@"bottomLineHeight":@(bottomLineHeight)} views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-bottomLineHeight]];

    self.tabsLeadingConstraint = [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    self.tabsTrailingConstraint = [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    [self addConstraints:@[self.tabsLeadingConstraint, self.tabsTrailingConstraint]];

    // Tabs
    NSMutableString *VFL = [NSMutableString stringWithString:@"H:|"];
    NSMutableDictionary *tabViewsDict = [NSMutableDictionary dictionary];
    for (int index=0; index<tabViews.count; index++) {
        UIView *tab = tabViews[index];
        [tab setTranslatesAutoresizingMaskIntoConstraints:NO];
        [contentView addSubview:tab];

        [VFL appendFormat:@"-10-[T%d]", index];
        [tabViewsDict setObject:tab forKey:[NSString stringWithFormat:@"T%d", index]];

        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[T]-0-|" options:0 metrics:nil views:@{@"T": tab}]];
        [tab setUserInteractionEnabled:YES];
        [tab addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tabTapHandler:)]];
    }

    [VFL appendString:@"-10-|"];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:VFL options:0 metrics:nil views:tabViewsDict]];

    // Indicator
    UIView *tabIndicator = [UIView new];
    [tabIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
    tabIndicator.backgroundColor = color;
    [contentView addSubview:tabIndicator];
    self.tabIndicator = tabIndicator;

    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[tabIndicator(3)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tabIndicator)]];
    self.indicatorWidthConstraint = [NSLayoutConstraint constraintWithItem:tabIndicator attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.tabViews[0] attribute:NSLayoutAttributeWidth multiplier:1.0 constant:10.0];
    self.indicatorCenterConstraint = [NSLayoutConstraint constraintWithItem:tabIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.tabViews[0] attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    [contentView addConstraints:@[self.indicatorCenterConstraint, self.indicatorWidthConstraint]];

    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];

    [self setNeedsUpdateConstraints];
    [self scrollToSelectedTab];
}

- (void)updateConstraints {
    CGFloat offset = 0.0;
    if (self.bounds.size.width > self.tabsView.frame.size.width) {
        offset = (self.bounds.size.width - self.tabsView.frame.size.width) / 2.0;
    }
    self.tabsLeadingConstraint.constant = offset;
    self.tabsTrailingConstraint.constant = -offset;

    [super updateConstraints];
}

#pragma mark - Public Methods

- (void)selectTabAtIndex:(NSInteger)index {
    [self selectTabAtIndex:index animated:YES];
}

- (void)selectTabAtIndex:(NSInteger)index animated:(BOOL)animated {
    //    self.currentIndex = index;
        CGFloat animatedDuration = 0.4f;
        if (!animated) {
            animatedDuration = 0.0f;
        }

    self.indicatorWidthConstraint = [self replaceConstraint:self.indicatorWidthConstraint withNewToItem:self.tabViews[index]];
    self.indicatorCenterConstraint = [self replaceConstraint:self.indicatorCenterConstraint withNewToItem:self.tabViews[index]];

    [UIView animateWithDuration:animatedDuration animations:^{
        [self layoutIfNeeded];
        [self scrollToSelectedTab];
    }];
}

- (void)tabTapHandler:(UITapGestureRecognizer *)gestureRecognizer {
    if ([[self tabScrollDelegate] respondsToSelector:@selector(tabScrollView:didSelectTabAtIndex:)]) {
        NSInteger index = [self.tabViews indexOfObject:[gestureRecognizer view]];
        [[self tabScrollDelegate] tabScrollView:self didSelectTabAtIndex:index];
        [self selectTabAtIndex:index];
    }
}

#pragma mark - Private Methods

- (void)scrollToSelectedTab {
    CGRect indicatorRect = [self.tabIndicator convertRect:self.tabIndicator.bounds toView:self.superview];
    CGFloat diff = 0.0;
    if (indicatorRect.origin.x < 0) {
        diff = indicatorRect.origin.x - 5.0;
    } else if (CGRectGetMaxX(indicatorRect) > self.frame.size.width) {
        diff = CGRectGetMaxX(indicatorRect) - self.frame.size.width + 5.0;
    } else {
        diff = 0.0;
    }

    if (diff != 0.0) {
        CGFloat xOffset = self.contentOffset.x + diff;
        self.contentOffset = CGPointMake(xOffset, self.contentOffset.y);
    }
}

- (NSLayoutConstraint *)replaceConstraint:(NSLayoutConstraint *)oldConstraint withNewToItem:(UIView *)toItem {
    NSLayoutConstraint *newConstraint = [NSLayoutConstraint constraintWithItem:oldConstraint.firstItem attribute:oldConstraint.firstAttribute relatedBy:oldConstraint.relation toItem:toItem attribute:oldConstraint.secondAttribute multiplier:oldConstraint.multiplier constant:oldConstraint.constant];
    [newConstraint setPriority:oldConstraint.priority];
    newConstraint.shouldBeArchived = oldConstraint.shouldBeArchived;
    newConstraint.identifier = oldConstraint.identifier;

    [NSLayoutConstraint deactivateConstraints:@[oldConstraint]];
    [NSLayoutConstraint activateConstraints:@[newConstraint]];

    return newConstraint;
}

@end
