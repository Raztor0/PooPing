#import "UIDevice+DeviceType.h"

@implementation UIDevice (DeviceType)

+ (BOOL)isIpad {
  return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

+ (BOOL)isIphone {
  return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
}

@end
