//
//  SBTViewController.m
//  iPadScenePlayer
//
//  Created by Richard Johnston on 25/07/2014.
//  Copyright (c) 2014 Steve Walsh. All rights reserved.
//

#import "SBTViewController.h"
#import "RMBSceneTimer.h"
#import "CABasicAnimation+addons.h"

#define kSBTZEROTIMEOFFSET 0.0
#define kSBTDuration 10.0

@interface SBTViewController () <RMBSceneTimerDelegate>

@property (weak) IBOutlet UIView *sceneView;
@property (nonatomic) RMBSceneTimer *timer;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic) NSTimeInterval lastTimerTick;
@property (weak) IBOutlet UISlider *slider;
@property (weak) IBOutlet UITextView *jsonTextView;
@property (strong, nonatomic) UIView *greenBoxView;


@end

@implementation SBTViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  self.timer = [RMBSceneTimer sceneTimerWithDelegate:self];
  [self.timer start];
  
//  [self.sceneView setWantsLayer:YES];

  [self createAnimationView];
  
  // Set up our green box view
  
  self.slider.minimumValue = 0;
  self.slider.maximumValue = kSBTDuration;
  
  //populate the textview with default scene json
  
  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"scene" ofType:@"json"];
  NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
  
  [self.jsonTextView setText:fileContents];
  
  NSData *data = [fileContents dataUsingEncoding:NSUTF8StringEncoding];
  NSError *error;
  NSArray *elements = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
  
  
  // set up group of animations
  
  [self.greenBoxView.layer addAnimation:[self makeAnimationGroupFromArrayOfElements:elements] forKey:nil];
  self.greenBoxView.layer.speed = 0.0f;


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)timeUpdate:(NSTimeInterval)time {
  
  int64_t ms = (int64_t)(time * 1000);
  if ((ms % 1000) < 10) {
    NSLog(@"Time = %@", [NSString stringWithFormat:@"%f", time]);
    [self.timeLabel setText:[NSString stringWithFormat:@"%d", (int)time]];
  }
  
  // Receiving ticks every 10 milliseconds
  
  [self.slider setValue:time];
  self.greenBoxView.layer.timeOffset = time;
  
  // record time of last tick
  
  self.lastTimerTick = time;
  
  
  if (time >= kSBTDuration) {
    [self.timer stop];
  }
  
}



- (IBAction)resetFromJson:(id)sender {
  
  NSString *text = [[self.jsonTextView textStorage] string];
  NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
  NSError *error;
  NSArray *elements = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
  
  [self createAnimationView];
  [self.greenBoxView.layer addAnimation:[self makeAnimationGroupFromArrayOfElements:elements] forKey:nil];
  self.greenBoxView.layer.speed = 0.0f;
  
  [self.timer stop];
  [self resumeTimer:nil];
  
}
- (void)createAnimationView{
  
  [self.greenBoxView removeFromSuperview];
  self.greenBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
  self.greenBoxView.layer.anchorPoint = CGPointMake(0,0);
  self.greenBoxView.backgroundColor = [UIColor greenColor];
  [self.sceneView addSubview:self.greenBoxView];
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
  float position = [(UISlider *)sender value];
  self.greenBoxView.layer.timeOffset = position;
  [self.timeLabel setText:[NSString stringWithFormat:@"%d", (int)position]];

  [self.timer setSceneTime:position];
  
}

- (IBAction)pauseTimer:(id)sender {
  
  [self.timer pause];
  
}

- (IBAction)resumeTimer:(id)sender {
  
  [self.timer resume];
  
}





@end
