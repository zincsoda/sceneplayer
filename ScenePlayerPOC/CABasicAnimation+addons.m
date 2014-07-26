//
//  CABasicAnimation+addons.m
//  SecureBroadcast
//
//  Created by John Rowe on 07/06/2013.
//  Copyright (c) 2013 Secure Broadcast. All rights reserved.
//

#import "CABasicAnimation+addons.h"

@implementation CABasicAnimation (addons)

+ (CABasicAnimation *)animationFromDictionary:(NSDictionary *)settings
{
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:settings[@"keyPath"]];
  
  if ([settings[@"keyPath"] isEqualToString:@"position"]) {
    
    
    #if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    
    CGPoint fromPoint = CGPointFromString(settings[@"fromValue"]);
    animation.fromValue  =  [NSValue valueWithCGPoint:fromPoint];
    CGPoint toPoint = CGPointFromString(settings[@"toValue"]);
    animation.toValue  =  [NSValue valueWithCGPoint:toPoint];
#else
    
    NSPoint fromPoint = NSPointFromString(settings[@"fromValue"]);
    animation.fromValue  =  [NSValue valueWithPoint:fromPoint];
    NSPoint toPoint = NSPointFromString(settings[@"toValue"]);
    animation.toValue  =  [NSValue valueWithPoint:toPoint];
#endif

  
  
  }
  else
  {
  animation.fromValue = [NSNumber numberWithFloat:[settings[@"fromValue"] floatValue]];
  animation.toValue = [NSNumber numberWithFloat:[settings[@"toValue"] floatValue]];
  }
  animation.duration = [settings[@"duration"] floatValue];
  
  return animation;
}

@end
