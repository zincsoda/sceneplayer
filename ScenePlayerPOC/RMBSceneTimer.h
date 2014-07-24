//
//  RMBSceneTimer.h
//  SecureBroadcast
//
//  Created by John Rowe on 01/07/2013.
//  Copyright (c) 2013 Secure Broadcast. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RMBSceneTimerDelegate <NSObject>
@required
- (void)timeUpdate:(NSTimeInterval)time;
@end

@interface RMBSceneTimer : NSObject

+(instancetype)sceneTimerWithDelegate:(id<RMBSceneTimerDelegate>)delegate;

@property (nonatomic, weak) id<RMBSceneTimerDelegate> delegate;
@property (nonatomic) NSTimeInterval sceneTime;


- (void)start;

- (void)stop;

- (void)pause;

- (void)resume;

@end
