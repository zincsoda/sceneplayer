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

#define kSBTZEROTIMEOFFSET 0.0

@interface SBTAppDelegate () <RMBSceneTimerDelegate>

@property (weak) IBOutlet NSView *sceneView;
@property (nonatomic) RMBSceneTimer *timer;
@property (weak) IBOutlet NSTextField *timeLabel;
@property (nonatomic) NSTimeInterval lastTimerTick;
@property (weak) IBOutlet NSSlider *slider;

@property (strong, nonatomic) NSView *greenBoxView;

@end

@implementation SBTAppDelegate



- (NSArray*)sceneElements {
  
  return @[
  @{
             @"name": @"Fade Up",
             @"keyPath": @"opacity",
             @"presentationTime" : @"1",
             @"fromValue": @"0.1",
             @"toValue": @"1.0",
             @"duration": @"4"
             },
           @{
             @"name": @"Rotate",
             @"keyPath": @"transform.rotation",
             @"presentationTime" : @"1",
             @"fromValue": @(-M_PI / 2.f),
             @"toValue": @(0.f),
             @"duration": @"4"
             }
           ,
           @{
             @"name": @"Fade Down",
             @"keyPath": @"opacity",
             @"presentationTime" : @"6",
             @"fromValue": @"1.0",
             @"toValue": @"0.1",
             @"duration": @"4"
             },
  @{
    @"name": @"Rotate",
    @"keyPath": @"transform.rotation",
    @"presentationTime" : @"6",
    @"toValue": @(-M_PI / 2.f),
    @"FromValue": @(0.f),
    @"duration": @"4"
    }
  
           ];
}

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
  [self.sceneView addSubview:self.greenBoxView];

  self.slider.minValue = 0;
  self.slider.maxValue = 10;
  
//  [self goToAnimationAtTime:3];

  for (NSDictionary *sceneElement in self.sceneElements) {

    float presentationTime = [sceneElement[@"presentationTime"] floatValue];

    [self presentGreenBox:presentationTime UsingSceneElementData:sceneElement WithTimeOffset:0 andScrubbing:NO];
//      NSLog(@"Animation : %@ setup at time : %f", sceneElement[@"name"], time);
    }
  self.greenBoxView.layer.speed = 0.0f;

}
- (IBAction)start:(id)sender {
  
  self.greenBoxView.layer.speed = 0.0f;
  
  [self presentGreenBox:0 UsingSceneElementData:
   @{
     @"name": @"Rotate",
     @"keyPath": @"transform.rotation",
     @"presentationTime" : @"1",
     @"fromValue": @(-M_PI / 2.f),
     @"toValue": @(0.f),
     @"duration": @"4"
     }
   
         WithTimeOffset:2 andScrubbing:YES];

}

- (void)timeUpdate:(NSTimeInterval)time {
  
  int64_t ms = (int64_t)(time * 1000);
  if ((ms % 1000) < 10) {
    NSLog(@"Time = %@", [NSString stringWithFormat:@"%f", time]);
    [self.timeLabel setStringValue:[NSString stringWithFormat:@"%d", (int)time]];
  }
  
  // Receiving ticks every 10 milliseconds
  // Check if any of the sceneElements are ready to play
  
  [self.slider setDoubleValue:time];
  

  // record time of last tick
  
  self.lastTimerTick = time;
}



- (void)presentGreenBox:(NSTimeInterval)time UsingSceneElementData:(NSDictionary *)animationInfo WithTimeOffset:(NSTimeInterval)timeOffset andScrubbing:(BOOL)isScrubbing {
  
//  
//  for (NSView *view in [self.sceneView subviews] ){
//    [view removeFromSuperview];
//  }
//  
//  [self.greenBoxView.layer removeAllAnimations];
  CABasicAnimation *ani = [CABasicAnimation animationFromDictionary:animationInfo];

  [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
    [self.greenBoxView.layer addAnimation:ani forKey:ani.keyPath];

  } completionHandler:^{
    NSLog(@"Animation : %@ over ", animationInfo[@"name"]);
    if ([ani.toValue isEqual:@0.0f] && [ani.keyPath isEqualToString:@"opacity"]) {
//      [self.greenBoxView removeFromSuperview];
    }
  }];

  [self.greenBoxView.layer setValue:ani.toValue forKey:ani.keyPath];


  if (time) {
    self.greenBoxView.layer.beginTime = time;

  }
  
}



- (void)goToAnimationAtTime:(NSTimeInterval)time {
  
  // parse the scene elements
  // work out which animation applies
  // present the animation at correct time offset
  

  // time is the time in the entire duration
  // need to convert animation times to project time
  
  // Suspect we will have to remove any currently playing animations that are OUTSIDE the current timeframe
  //[self.greenBoxView.layer removeAllAnimations];
  


  for (NSDictionary *sceneElement in self.sceneElements) {
    
    float presentationTime = [sceneElement[@"presentationTime"] floatValue];
    float endTime = presentationTime + [sceneElement[@"duration"] floatValue];
    if (time >= presentationTime && time <= endTime) {
      
      //We are somewhere in the middle of this animation
      
      //calculate the distance between The playhead and where we should be in the animation
      
      float timeOffset = time - presentationTime;
      
      
      // go get the layer we want to offset
//      self.greenBoxView.layer.timeOffset = timeOffset;
      
      [self presentGreenBox:time UsingSceneElementData:sceneElement WithTimeOffset:timeOffset andScrubbing:YES];
      
      NSLog(@"Animation : %@ scrubbed to time : %f using timeOffset : %f", sceneElement[@"name"], time, timeOffset);
    }
  }
  
  // record time of last tick
  
  
  
}

- (IBAction)sliderChanged:(id)sender {
  
  float position = [sender floatValue];
  self.greenBoxView.layer.timeOffset = position;
  /*
   
   for scrubbing:
   
   Need to pause timer and all animations
   
   need to change the timer to the point on the slider
   
   go to a point in time, work out what animations should be playing, animate to that time
   
   */
//  self.greenBoxView.layer.timeOffset = position;

  [self.timer pause];
//  self.greenBoxView.layer.speed = 0.0f;
//  [self.timer setSceneTime:position];
//  self.lastTimerTick = position;
// [self goToAnimationAtTime:position];
  
}

- (IBAction)pauseTimer:(id)sender {
  
  [self.timer pause];
  self.greenBoxView.layer.speed = 0.0f;
  //update animation to the given time
  
  
  
}

- (IBAction)resumeTimer:(id)sender {
  [self.timer resume];
  self.greenBoxView.layer.speed = 1.0f;
  
}


@end
