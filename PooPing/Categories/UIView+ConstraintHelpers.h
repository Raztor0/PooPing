#import <UIKit/UIKit.h>

@interface UIView (ConstraintHelpers)

- (NSArray *)constrainHorizontallyToFitSuperview:(UIView *)view;
- (NSArray *)constrainVerticallyToFitSuperview:(UIView *)view;
- (NSLayoutConstraint *)constrainTopOfView:(UIView *)bottomView toBottomOfView:(UIView *)topView;
- (NSLayoutConstraint *)constrainRightOfView:(UIView *)leftView toLeftOfView:(UIView *)rightView;
- (NSLayoutConstraint *)constrainTopOfViewToTopOfSuperview:(UIView *)view;
- (NSLayoutConstraint *)constrainView:(UIView *)view toSuperViewWithEqual:(NSLayoutAttribute)layoutAttribute;
- (NSLayoutConstraint *)constrainView:(UIView *)view toView:(UIView *)otherView withEqual:(NSLayoutAttribute)layoutAttribute;
- (NSLayoutConstraint *)constrainHeightOfView:(UIView *)view toHeight:(CGFloat)height;

@end
