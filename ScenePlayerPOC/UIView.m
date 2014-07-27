//
//  SBTFlippedView.m
//  ScenePlayerPOC
//
//  Created by Richard Johnston on 26/07/2014.
//  Copyright (c) 2014 Steve Walsh. All rights reserved.
//

#import "UIView.h"

@implementation UIView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (BOOL)isFlipped {
  
  return YES;
  
}


@end
