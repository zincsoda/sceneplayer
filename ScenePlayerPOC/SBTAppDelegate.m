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
@import AVFoundation;


#define kSBTZEROTIMEOFFSET 0.0
#define kSBTDuration 20.0


@interface SBTAppDelegate () <RMBSceneTimerDelegate>

@property (weak) IBOutlet NSView *sceneView;
@property (nonatomic) RMBSceneTimer *timer;
@property (weak) IBOutlet NSTextField *timeLabel;
@property (nonatomic) NSTimeInterval lastTimerTick;
@property (weak) IBOutlet NSSlider *slider;
@property (weak) IBOutlet NSScrollView *textView;
@property (unsafe_unretained) IBOutlet NSTextView *jsonTextView;
@property (strong, nonatomic) NSView *greenBoxView;
@property (strong, nonatomic) NSArray *sceneArray;

//video setup

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;


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
  [self.jsonTextView setAutomaticQuoteSubstitutionEnabled:NO];
  
//  [self createAnimationView];
  
  // Set up our green box view
  
  self.slider.minValue = 0;
  self.slider.maxValue = kSBTDuration;
  
  //populate the textview with default scene json
  
  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"scene_ver2" ofType:@"json"];
  NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
  
  [self.jsonTextView setString:fileContents];
  
  NSData *data = [fileContents dataUsingEncoding:NSUTF8StringEncoding];
  NSError *error;
  NSArray *elements = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
  
  // the elements are views of two different types (lower third and video)
  [self setUpSceneObjectsForElements:elements];
  
  // set up group of animations

  
  
  
  
  
}

-(void)loadVideosFromAsset:(AVAsset*)video {
  
  [video loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                     NSError *error;
                     AVKeyValueStatus status = [video statusOfValueForKey:@"tracks" error:&error];
                     if (status == AVKeyValueStatusLoaded) {
//                       AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:video];
//                       self.player = [AVPlayer playerWithPlayerItem:playerItem];
//                       self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
//                       [self.sceneView setLayer:self.playerLayer];
//                       [self.player play];
                       NSLog(@"The asset's tracks were  loaded");

                     } else {
                       NSLog(@"The asset's tracks were not loaded:\n%@", [error localizedDescription]);
                     }
                   });
  }];

  
}


-(void)setUpSceneObjectsForElements:(NSArray *)elements {
  
  // first the views
  self.sceneArray = nil;

  NSMutableArray *sceneArraySetup = [NSMutableArray arrayWithCapacity:1];
  
  for (id element in elements) {
    
    // first copy element data into the dictionary
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObject:element forKey:@"data"];
    NSRect ourRect = [self returnRectFromData:element];
    NSView *itemView = [[NSView alloc] initWithFrame:ourRect];
    
    // add a layer, green for lower third, red for video
    
    CALayer *itemLayer = [CALayer layer];
    if ([element[@"type"] isEqualToString:@"lowerThird"]) {
      itemLayer.backgroundColor = [NSColor greenColor].CGColor;
      itemLayer.speed = 0.0f;
      
    }
    else {
      
      // get the asset url
      
      NSString *filename = element[@"file"];
      NSString *fileExtension = element[@"filetype"];
      NSURL *videoURL = [[NSBundle mainBundle]
                         URLForResource:filename withExtension:fileExtension];
      
      
      AVURLAsset *video = [AVURLAsset URLAssetWithURL:videoURL options:nil];
      
      [self loadVideosFromAsset:video];
      
      [item setObject:video forKey:@"video"];
      
      itemLayer.backgroundColor = [NSColor blueColor].CGColor;
//      itemLayer.speed = 0.0f;

    }
    itemLayer.anchorPoint = CGPointMake(0,0);
    [itemLayer addAnimation:[self makeAnimationGroupFromArrayOfElements:element[@"animations"]] forKey:nil];
    
    [itemView setLayer:itemLayer];
    
    // now add animations to this view
    [item setObject:itemView forKey:@"view"];
    
    [self.sceneView addSubview:itemView];
    [itemView.layer setOpacity:0.0];
    [sceneArraySetup addObject:item];
  }
  
  
  self.sceneArray = sceneArraySetup;
  
  
}



- (NSRect)returnRectFromData:(NSDictionary *)data {
  
  NSPoint origin = NSPointFromString(data[@"origin"]);
  NSPoint size = NSPointFromString(data[@"size"]);
  NSRect theRect = NSMakeRect(origin.x, origin.y, size.x, size.y);
  
  return theRect ;
}


- (void)createAnimationView{
  
  self.greenBoxView = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
  CALayer *greenViewLayer = [CALayer layer];
  greenViewLayer.backgroundColor = [NSColor greenColor].CGColor;
  greenViewLayer.anchorPoint = CGPointMake(0,0);
  [self.greenBoxView setLayer:greenViewLayer];
  [self.sceneView addSubview:self.greenBoxView];
  
}


- (IBAction)resetFromJson:(id)sender {
  
  NSString *text = [[self.jsonTextView textStorage] string];
  NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
  NSError *error;
  NSArray *elements = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
  
  for (id item in self.sceneArray) {
    
    NSView *theView = (NSView *)item[@"view"];
    [theView removeFromSuperview];
  }
  
  
  [self setUpSceneObjectsForElements:elements];

  [self.timer stop];
  [self resumeTimer:nil];
  
}



- (void)timeUpdate:(NSTimeInterval)time {
  
  int64_t ms = (int64_t)(time * 1000);
  if ((ms % 1000) < 10) {
    NSLog(@"Time = %@", [NSString stringWithFormat:@"%f", time]);
    [self.timeLabel setStringValue:[NSString stringWithFormat:@"%d", (int)time]];
  }
  
  // Receiving ticks every 10 milliseconds
  
  [self.slider setDoubleValue:time];
  [self updateSceneToTime:time];
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
  
  // update all the time offsets where appropriate
  
  [self updateSceneToTime:position];
  
//  self.greenBoxView.layer.timeOffset = position;
  [self.timeLabel setStringValue:[NSString stringWithFormat:@"%d", (int)position]];
  [self.timer setSceneTime:position];
  
}

- (void)updateSceneToTime:(float)time {
  
  for (id item in self.sceneArray) {
    
    NSView *theView = (NSView *)item[@"view"];
    
    
    // is this animation in view?  is time > presentationtime && < (presentation + duration)
    NSDictionary *itemData = item[@"data"];
    float presentationTime = [itemData[@"presentationTime"] floatValue];
    float duration = [itemData[@"duration"] floatValue];


    
    if (time >= presentationTime && time <= (presentationTime+duration)) {
      
      // animation should be in view, now calculate how far along
      
      if ([itemData[@"type"] isEqualToString:@"lowerThird"]) {
        float offset = time-presentationTime;
        theView.layer.timeOffset = offset;
        [theView.layer setOpacity:1.0];
        [theView.layer setNeedsDisplay];
      }
      
      else {
        AVURLAsset *video = (AVURLAsset *)item[@"video"];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:video];
        self.player = [AVPlayer playerWithPlayerItem:playerItem];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        [theView setLayer:self.playerLayer];
        [self.player play];

      }


      
    }
    
    else {
//      [theView.layer setHidden:YES];
      [theView.layer setOpacity:0.0];
      [theView.layer setNeedsDisplay];
      
    }
    if (time < presentationTime) {
      
      
      
      [theView.layer setOpacity:0.0];
      [theView.layer setNeedsDisplay];

    }
    if (time > presentationTime+duration) {
      [theView.layer setOpacity:0.0];
      [theView.layer setNeedsDisplay];
    }
    
    // calculate the offset
    
  }
  
}


- (IBAction)pauseTimer:(id)sender {
  
  [self.timer pause];
  
}

- (IBAction)resumeTimer:(id)sender {
  
  [self.timer resume];
  
}


@end
