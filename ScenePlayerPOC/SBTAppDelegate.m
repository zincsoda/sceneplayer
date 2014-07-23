//
//  SBTAppDelegate.m
//  ScenePlayerPOC
//
//  Created by Steve Walsh on 23/07/2014.
//  Copyright (c) 2014 Steve Walsh. All rights reserved.
//

#import "SBTAppDelegate.h"
//@import AVFoundation.AVSynchronizedLayer;
@import AVFoundation;


@interface SBTAppDelegate ()

//@property (nonatomic, strong) AVAsset *assetForPlayback;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (weak) IBOutlet NSView *sceneView;

@end

@implementation SBTAppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
  [self.sceneView setWantsLayer:YES];

  NSURL *videoURL = [[NSBundle mainBundle]
                    URLForResource:@"burj" withExtension:@"mp4"];
  AVURLAsset *video = [AVURLAsset URLAssetWithURL:videoURL options:nil];
  
  [video loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
   dispatch_async(dispatch_get_main_queue(),
   ^{
     NSError *error;
     AVKeyValueStatus status = [video statusOfValueForKey:@"tracks" error:&error];
     if (status == AVKeyValueStatusLoaded) {
       AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:video];
       self.player = [AVPlayer playerWithPlayerItem:playerItem];
       self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
       
       

       [self.sceneView setLayer:self.playerLayer];
       
       [self.player play];
     } else {
       NSLog(@"The asset's tracks were not loaded:\n%@", [error localizedDescription]);
     }
   });
  }];
  

}

@end
