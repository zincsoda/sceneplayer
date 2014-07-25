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
#define kSBTDuration 10.0


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
             @"name": @"Rotate",
             @"keyPath": @"transform.rotation",
             @"presentationTime" : @"1",
             @"toValue": @(-M_PI / 2.f),
             @"fromValue": @(0.f),
             @"duration": @"5"
             },
           // If there is a gap between timings the animation will jump back to the 'fromValue'
           @{
             @"name": @"Rotate",
             @"keyPath": @"transform.rotation",
             @"presentationTime" : @"6",
             @"fromValue": @(-M_PI / 2.f),
             @"toValue": @(0.f),
             @"duration": @"3"
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
  self.slider.maxValue = kSBTDuration;
  
  // set up group of animations
  
  CAAnimationGroup *group = [CAAnimationGroup animation];
  [group setDuration:kSBTDuration];
  
  NSMutableArray *animations = [NSMutableArray arrayWithCapacity:1];
  
  for (NSDictionary *sceneElement in self.sceneElements) {
    
    float presentationTime = [sceneElement[@"presentationTime"] floatValue];
    CABasicAnimation *ani = [CABasicAnimation animationFromDictionary:sceneElement];
    ani.beginTime = presentationTime;
    [animations addObject:ani];
    
  }
  
  [group setAnimations:animations];
  [self.greenBoxView.layer addAnimation:group forKey:nil];
  self.greenBoxView.layer.speed = 0.0f;
  
  
}

- (void)timeUpdate:(NSTimeInterval)time {
  
  int64_t ms = (int64_t)(time * 1000);
  if ((ms % 1000) < 10) {
    NSLog(@"Time = %@", [NSString stringWithFormat:@"%f", time]);
    [self.timeLabel setStringValue:[NSString stringWithFormat:@"%d", (int)time]];
  }
  
  // Receiving ticks every 10 milliseconds
  
  [self.slider setDoubleValue:time];
  self.greenBoxView.layer.timeOffset = time;
  
  // record time of last tick
  
  self.lastTimerTick = time;
  
  
  if (time >= kSBTDuration) {
    [self.timer stop];
  }
  
}


- (IBAction)sliderChanged:(id)sender {
  
  [self.timer pause];
  float position = [sender floatValue];
  self.greenBoxView.layer.timeOffset = position;
  [self.timeLabel setStringValue:[NSString stringWithFormat:@"%d", (int)position]];
  [self.timer setSceneTime:position];

}

- (IBAction)pauseTimer:(id)sender {
  
  [self.timer pause];

}

- (IBAction)resumeTimer:(id)sender {

  [self.timer resume];
  
}


@end
