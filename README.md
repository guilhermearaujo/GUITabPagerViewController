# GUITabPagerViewController

<img src="preview.gif" alt="Animated gif">

## Installation
**CocoaPods** (recommended)  
Add the following line to your `Podfile`:  
`pod 'GUITabPagerViewController', '~> 0.0.3'`  
And then add `#import <GUITabPagerViewController.h>` to your view controller.

**Manual**  
Copy the folders `Classes` to your project, then add `#import "GUITabPagerViewController.h"` to your view controller.

## Usage
To use it, you should create a view controller that extends `GUITabPagerViewController`. Write your `viewDidLoad` as follows:

```obj-c
- (void)viewDidLoad {
  [super viewDidLoad];
  [self setDataSource:self];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self reloadData];
}
```

Then, implement the `GUITabPagerDataSource` to populate the view.
The data source has a couple of required methods, and a few more optional.

### Required Methods
```obj-c
- (NSInteger)numberOfViewControllers;
- (UIViewController *)viewControllerForIndex:(NSInteger)index;
```

### Optional Methods
**Note that despite being optional, the tab setup will require you to return either a `UIView` or an `NSString` to work.**

```obj-c
- (UIView *)viewForTabAtIndex:(NSInteger)index;
- (NSString *)titleForTabAtIndex:(NSInteger)index;
- (CGFloat)tabHeight;  // Default value: 44.0f
- (UIColor *)tabColor; // Default value: [UIColor orangeColor]
```
