//
//  KCLPCMPlayer.h
//  AudioUnitUsing
//
//  Created by Chentao on 2018/12/6.
//  Copyright © 2018 Chentao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@class KCLPCMPlayer;

@protocol KCLPCMPlayerDelegate <NSObject>

@required
- (NSData *)pcmPlayer:(KCLPCMPlayer *)player audioBuffer:(AudioBufferList *)ioData;

@end

@interface KCLPCMPlayer : NSObject

@property (nonatomic, weak) id<KCLPCMPlayerDelegate> delegate;

@property (nonatomic, readonly) NSUInteger numberSample;

@property (nonatomic, readonly) NSTimeInterval time; //单位：毫秒

- (void)pause;

- (void)resume;

@end

NS_ASSUME_NONNULL_END
