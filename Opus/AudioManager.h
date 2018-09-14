//
//  AudioManager.h
//  CCiAlexa
//
//  Created by Jonor on 2018/8/14.
//  Copyright © 2018年 SOUNDMAX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioManager : NSObject

+ (instancetype)shared;

// Recording
- (void)recordStartWithProcess:(void (^)(float peakPower))processHandler completed:(void (^)(NSData *data, NSError *error))completedHandler;
- (void)recordStop;
- (BOOL)isRecording;

// Playing
- (void)playAudioData:(NSData *)data completionHandler:(void (^)(BOOL successfully))handler;
- (BOOL)isPlaying;

@end

