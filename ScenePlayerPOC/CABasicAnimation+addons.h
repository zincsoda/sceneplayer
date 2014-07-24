//
//  CABasicAnimation+addons.h
//  ScenePlayerPOC
//
//  Created by Steve Walsh on 24/07/2014.
//  Copyright (c) 2014 Steve Walsh. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CABasicAnimation (addons)

+ (CABasicAnimation *)animationFromDictionary:(NSDictionary *)settings;

@end
