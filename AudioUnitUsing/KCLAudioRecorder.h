//
//  KCLAudioRecorder.h
//  AudioUnitUsing
//
//  Created by Chentao on 2018/12/6.
//  Copyright © 2018 Chentao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KCLAudioRecorder;

@protocol KCLAudioRecorderDelegate <NSObject>

- (void)recorder:(KCLAudioRecorder *)recorder receiveData:(NSData *)pcmData;

@end

@interface KCLAudioRecorder : NSObject

@property (nonatomic, weak) id<KCLAudioRecorderDelegate> delegate;

- (void)startRecorder;

- (void)stopRecorder;

@end
