//
//  RMBSceneTimer.m
//  SecureBroadcast
//
//  Created by John Rowe on 01/07/2013.
//  Copyright (c) 2013 Secure Broadcast. All rights reserved.
//

#import "RMBSceneTimer.h"

@interface RMBSceneTimer()

@property (nonatomic) NSTimer *timer;
@property BOOL paused;

@end

@implementation RMBSceneTimer

+(instancetype)sceneTimer
{
  return [[self alloc] init];
}

+(instancetype)sceneTimerWithDelegate:(id<RMBSceneTimerDelegate>)delegate
{
  RMBSceneTimer *sceneTimer = [self sceneTimer];
  sceneTimer.delegate = delegate;
  return sceneTimer;
}

- (void)start
{
  self.sceneTime = 0.0f;
  self.paused = NO;
  self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
}

- (void)tick:(NSTimer *)timer
{
  if (self.paused == NO) {
    self.sceneTime += self.timer.timeInterval;
    [self.delegate timeUpdate:self.sceneTime];
  }
}

- (void)stop
{
  [self.timer invalidate];
  self.timer = nil;
}

- (void)pause {
  self.paused = YES;
}

- (void)resume {
  self.paused = NO;
}

@end
