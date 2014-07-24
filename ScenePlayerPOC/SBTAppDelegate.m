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
  self.greenBoxView = [[NSView alloc] initWithFrame:NSMakeRect(150, 150, 100, 100)];
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
  
  NSTimeInterval greenBoxPresentationTime = 0.5;
  if (greenBoxPresentationTime >= self.lastTimerTick && greenBoxPresentationTime <= time) {
    [self presentGreenBox:time];
  }
  
  NSTimeInterval greenBoxDeathTime = 7.0;
  if (greenBoxDeathTime >= self.lastTimerTick && greenBoxDeathTime <= time) {
//    [self killThatDamnedBox:time];
  }
  
  self.lastTimerTick = time;
}

- (void)presentGreenBox:(NSTimeInterval)time {
  
//  self.greenBoxView.layer.speed = 0.0f;
//  self.greenBoxView.layer.timeOffset = 2;
  
  
    NSLog(@"Presenting green box at %@", [NSString stringWithFormat:@"%f", time]);
  NSDictionary *animationInfo = @{
                                  @"keyPath": @"opacity",
                                  @"fromValue": @"0.5",
                                  @"toValue": @"1.0",
                                  @"duration": @"15.5"
                                  };

  [self.sceneView addSubview:self.greenBoxView];

  CABasicAnimation* theAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
  theAnim.fromValue = @(-M_PI / 2.f);
  theAnim.toValue = @(0.f);
  theAnim.duration = 15.5;
  [self.greenBoxView.layer addAnimation:theAnim forKey:@"transform.rotation"];

  
  CABasicAnimation *ani = [CABasicAnimation animationFromDictionary:animationInfo];
  
  [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
    [self.greenBoxView.layer addAnimation:ani forKey:ani.keyPath];
  } completionHandler:^{
    NSLog(@"*** Animation OVER ***");
    if ([ani.toValue isEqual:@0.0f] && [ani.keyPath isEqualToString:@"opacity"]) {
      [self.greenBoxView removeFromSuperview];
    }
  }];
  [self.greenBoxView.layer setValue:ani.toValue forKey:ani.keyPath];
  self.greenBoxView.layer.speed = 0.0f;

}
- (IBAction)sliderChanged:(id)sender {
  
  float s = [sender floatValue];
  
  float position = 15.5*s;

  self.greenBoxView.layer.timeOffset = position;
  
  
}

- (void)killThatDamnedBox:(NSTimeInterval)time {
  NSDictionary *animationInfo = @{
                                  @"keyPath": @"opacity",
                                  @"fromValue": @"0.7",
                                  @"toValue": @"0.0",
                                  @"duration": @"5.5"
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
- (IBAction)goToTime:(id)sender {
  
  [self pauseLayer:self.greenBoxView.layer];
  [self playLayer:self.greenBoxView.layer AtTime:4];
  
  
  
}



-(void)playLayer:(CALayer*)layer AtTime:(NSTimeInterval)time {
  
  
//  layer.speed = 0.0;

  CFTimeInterval pausedTime = [layer timeOffset];  /// 12:30:05
  NSLog(@"Paused Time : %f",pausedTime);
  NSLog(@"Layer Time Begin Time: %f",layer.beginTime);
  
  layer.timeOffset = time;
  layer.beginTime = 0.0;
  CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime ;
  NSLog(@"Time since Pause :%f",timeSincePause);
  
  layer.timeOffset = timeSincePause +time;
  NSLog(@"Layer Time Begin Time + added seconds: %f",layer.beginTime);
  
}


- (IBAction)resume:(id)sender {
  
  self.greenBoxView.layer.speed = 1.0f;
}
- (IBAction)pauseAnimation:(id)sender {
  
  [self pauseLayer:self.greenBoxView.layer];

}


-(void)pauseLayer:(CALayer*)layer {
  NSLog(@"Layer Time Offset: %f",layer.timeOffset);
  
  //Specifies an additional time offset in active local time. (required)
  


  
  CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
  layer.speed = 0.0;
  layer.timeOffset = pausedTime;
  NSLog(@"Layer Time Offset: %f",layer.timeOffset);

}

-(void)resumeLayer:(CALayer*)layer {
  
  
  CFTimeInterval pausedTime = [layer timeOffset];  /// 12:30:05
  NSLog(@"Paused Time : %f",pausedTime);
  NSLog(@"Layer Time Begin Time: %f",layer.beginTime);

  layer.speed = 1.0;
  layer.timeOffset = 0.0;
  layer.beginTime = 0.0;
  CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
  NSLog(@"Time since Pause :%f",timeSincePause);

  layer.beginTime = timeSincePause;
  NSLog(@"Layer Time Begin Time: %f",layer.beginTime);

}





@end
