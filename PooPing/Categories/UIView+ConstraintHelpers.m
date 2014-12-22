#import "UIView+ConstraintHelpers.h"

@implementation UIView (ConstraintHelpers)

- (NSArray *)constrainHorizontallyToFitSuperview:(UIView *)view {
  NSMutableArray *constraints = [NSMutableArray array];
  
  [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f]];
  [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f]];
  
  [self addConstraints:constraints];
  return constraints;
}

- (NSArray *)constrainVerticallyToFitSuperview:(UIView *)view {
  NSMutableArray *constraints = [NSMutableArray array];
  
  [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f]];
  [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f]];
  
  [self addConstraints:constraints];
  return constraints;
}

- (NSLayoutConstraint *)constrainTopOfView:(UIView *)bottomView toBottomOfView:(UIView *)topView {
  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:topView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:bottomView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
  [self addConstraint:constraint];
  return constraint;
}

- (NSLayoutConstraint *)constrainRightOfView:(UIView *)leftView toLeftOfView:(UIView *)rightView {
  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:leftView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:rightView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0];
  [self addConstraint:constraint];
  return constraint;
}

- (NSLayoutConstraint *)constrainTopOfViewToTopOfSuperview:(UIView *)view {
  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
  [self addConstraint:constraint];
  return constraint;
}

- (NSLayoutConstraint *)constrainView:(UIView *)view toSuperViewWithEqual:(NSLayoutAttribute)layoutAttribute {
  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:layoutAttribute relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:layoutAttribute multiplier:1.0f constant:0];
  [self addConstraint:constraint];
  return constraint;
}

- (NSLayoutConstraint *)constrainView:(UIView *)view toView:(UIView *)otherView withEqual:(NSLayoutAttribute)layoutAttribute {
  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:layoutAttribute relatedBy:NSLayoutRelationEqual toItem:otherView attribute:layoutAttribute multiplier:1.0f constant:0];
  [self addConstraint:constraint];
  return constraint;
}

- (NSLayoutConstraint *)constrainHeightOfView:(UIView *)view toHeight:(CGFloat)height {
  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:height];
  [self addConstraint:constraint];
  return constraint;
}

@end
