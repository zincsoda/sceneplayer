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
  
  animation.fromValue = [NSNumber numberWithFloat:[settings[@"fromValue"] floatValue]];
  animation.toValue = [NSNumber numberWithFloat:[settings[@"toValue"] floatValue]];
  animation.duration = [settings[@"duration"] floatValue];
  
  return animation;
}

@end
