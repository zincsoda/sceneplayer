//
//  SBTAppDelegate.m
//  ScenePlayerPOC
//
//  Created by Steve Walsh on 23/07/2014.
//  Copyright (c) 2014 Steve Walsh. All rights reserved.
//

#import "SBTAppDelegate.h"
#import "RMBSceneTimer.h"
#import "CABasicAnimation+addons.h"

@interface SBTAppDelegate () <RMBSceneTimerDelegate>

@property (weak) IBOutlet NSView *sceneView;
@property (nonatomic) RMBSceneTimer *timer;
@property (weak) IBOutlet NSTextField *timeLabel;
@property (nonatomic) NSTimeInterval lastTimerTick;

@property (strong, nonatomic) NSView *greenBoxView;

@end

@implementation SBTAppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
  self.timer = [RMBSceneTimer sceneTimerWithDelegate:self];
  [self.timer start];
  
  [self.sceneView setWantsLayer:YES];
  CALayer *viewLayer = [CALayer layer];
  viewLayer.backgroundColor = [NSColor orangeColor].CGColor;
  [self.sceneView setLayer:viewLayer];
  
  // Set up our green box view
  self.greenBoxView = [[NSView alloc] initWithFrame:NSMakeRect(10, 10, 100, 100)];
  CALayer *greenViewLayer = [CALayer layer];
  greenViewLayer.backgroundColor = [NSColor greenColor].CGColor;
  [self.greenBoxView setLayer:greenViewLayer];
}

- (void)timeUpdate:(NSTimeInterval)time {
  
  int64_t ms = (int64_t)(time * 1000);
  if ((ms % 1000) < 10) {
    NSLog(@"Time = %@", [NSString stringWithFormat:@"%f", time]);
   [self.timeLabel setStringValue:[NSString stringWithFormat:@"%d", (int)time]];
  }
  
  NSTimeInterval greenBoxPresentationTime = 1.5;
  if (greenBoxPresentationTime >= self.lastTimerTick && greenBoxPresentationTime <= time) {
    [self presentGreenBox:time];
  }
  
  NSTimeInterval greenBoxDeathTime = 4.0;
  if (greenBoxDeathTime >= self.lastTimerTick && greenBoxDeathTime <= time) {
    [self killThatDamnedBox:time];
  }
  
  self.lastTimerTick = time;
}

- (void)presentGreenBox:(NSTimeInterval)time {
    NSLog(@"Presenting green box at %@", [NSString stringWithFormat:@"%f", time]);
  NSDictionary *animationInfo = @{
                                  @"keyPath": @"opacity",
                                  @"fromValue": @"0.0",
                                  @"toValue": @"0.7",
                                  @"duration": @"1.5"
                                  };

  [self.sceneView addSubview:self.greenBoxView];

  CABasicAnimation *ani = [CABasicAnimation animationFromDictionary:animationInfo];
  
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
    [self.greenBoxView.layer addAnimation:ani forKey:ani.keyPath];
  } completionHandler:^{
    if ([ani.toValue isEqual:@0.0f] && [ani.keyPath isEqualToString:@"opacity"]) {
      [self.greenBoxView removeFromSuperview];
    }
  }];
  [self.greenBoxView.layer setValue:ani.toValue forKey:ani.keyPath];

}

- (void)killThatDamnedBox:(NSTimeInterval)time {
  NSDictionary *animationInfo = @{
                                  @"keyPath": @"opacity",
                                  @"fromValue": @"0.7",
                                  @"toValue": @"0.0",
                                  @"duration": @"1.5"
                                  };
  
 
  CABasicAnimation *ani = [CABasicAnimation animationFromDictionary:animationInfo];
 [self.greenBoxView.layer setValue:ani.toValue forKey:ani.keyPath];
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
    [self.greenBoxView.layer addAnimation:ani forKey:ani.keyPath];
  } completionHandler:^{
    if ([ani.toValue isEqual:@0.0f] && [ani.keyPath isEqualToString:@"opacity"]) {
      [self.greenBoxView removeFromSuperview];
    }
  }];

}

- (IBAction)goToX:(id)sender {
  
  NSTimeInterval x = 2;
  
  
  
}

@end
