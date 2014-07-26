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

@property (weak) IBOutlet UIView *sceneView;
@property (nonatomic) RMBSceneTimer *timer;
@property (weak) IBOutlet NSTextField *timeLabel;
@property (nonatomic) NSTimeInterval lastTimerTick;
@property (weak) IBOutlet NSSlider *slider;
@property (weak) IBOutlet NSScrollView *textView;
@property (unsafe_unretained) IBOutlet NSTextView *jsonTextView;

@property (strong, nonatomic) UIView *greenBoxView;

@end

@implementation SBTAppDelegate



- (NSArray*)sceneElements {
  
  return @[
           @{
             @"keyPath": @"transform.rotation",
             @"presentationTime" : @"1",
             @"toValue": @(-M_PI / 2.f),
             @"fromValue": @(0.f),
             @"duration": @"4"
             },
           @{
             @"keyPath": @"transform.rotation",
             @"presentationTime" : @"6",
             @"fromValue": @(-M_PI / 2.f),
             @"toValue": @(0.f),
             @"duration": @"3"
             }
           ];
}
- (IBAction)resetFromJson:(id)sender {
  
  NSString *text = [[self.jsonTextView textStorage] string];
  NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
  NSError *error;
  NSArray *elements = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

  [self.greenBoxView removeFromSuperview];
  [self createAnimationView];
  [self.greenBoxView.layer addAnimation:[self makeAnimationGroupFromArrayOfElements:elements] forKey:nil];
  self.greenBoxView.layer.speed = 0.0f;

  [self.timer stop];
  [self resumeTimer:nil];

}


- (void)createAnimationView{
  
  self.greenBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
  CALayer *greenViewLayer = [CALayer layer];
  greenViewLayer.backgroundColor = [NSColor greenColor].CGColor;
  greenViewLayer.anchorPoint = CGPointMake(0,0);
  [self.greenBoxView setLayer:greenViewLayer];
  [self.sceneView addSubview:self.greenBoxView];
  
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
  self.timer = [RMBSceneTimer sceneTimerWithDelegate:self];
  [self.timer start];
  
  [self.sceneView setWantsLayer:YES];
  CALayer *viewLayer = [CALayer layer];
  viewLayer.backgroundColor = [NSColor orangeColor].CGColor;
  [self.sceneView setLayer:viewLayer];
  [self.jsonTextView setAutomaticQuoteSubstitutionEnabled:NO];

  [self createAnimationView];
  
  // Set up our green box view
  
  self.slider.minValue = 0;
  self.slider.maxValue = kSBTDuration;
  
  //populate the textview with default scene json
  
  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"scene" ofType:@"json"];
  NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
  
  [self.jsonTextView setString:fileContents];
  
  NSData *data = [fileContents dataUsingEncoding:NSUTF8StringEncoding];
  NSError *error;
  NSArray *elements = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

  
  // set up group of animations
  [self.greenBoxView.layer addAnimation:[self makeAnimationGroupFromArrayOfElements:elements] forKey:nil];
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


- (CAAnimationGroup *)makeAnimationGroupFromArrayOfElements:(NSArray *)elements {
  
  CAAnimationGroup *group = [CAAnimationGroup animation];
  [group setDuration:kSBTDuration];
  
  NSMutableArray *animations = [NSMutableArray arrayWithCapacity:1];
  
  for (NSDictionary *sceneElement in elements) {
    
    float presentationTime = [sceneElement[@"presentationTime"] floatValue];
    CABasicAnimation *ani = [CABasicAnimation animationFromDictionary:sceneElement];
    ani.beginTime = presentationTime;
    [ani setFillMode:kCAFillModeForwards];
    [ani setRemovedOnCompletion:NO];
    [animations addObject:ani];
    
  }
  
  [group setAnimations:animations];
  
  return group;
  
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
