//
//  KCLPCMPlayer.m
//  AudioUnitUsing
//
//  Created by Chentao on 2018/12/6.
//  Copyright © 2018 Chentao. All rights reserved.
//

#import "KCLPCMPlayer.h"
#import "KCLAudioUtilities.h"


@implementation KCLPCMPlayer{
    AudioUnit audioUnit;
    uint32_t numberSamples;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self initAudioComponent];
        [self setupAudioUnit];
        [self initAudioUnit];
    }
    return self;
}

- (NSTimeInterval)time {
    return (1000.0 / KCLSampleRate) * numberSamples;
}

- (NSUInteger)numberSample {
    return numberSamples;
}

- (void)initAudioComponent {
    AudioComponentDescription audioDesc;
    audioDesc.componentType = kAudioUnitType_Output;
    audioDesc.componentSubType = kAudioUnitSubType_RemoteIO;
    audioDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    audioDesc.componentFlags = 0;
    audioDesc.componentFlagsMask = 0;
    
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &audioDesc);
    AudioComponentInstanceNew(inputComponent, &audioUnit);
}

- (void)setupAudioUnit {
    UInt32 outputEnableFlag = 1;
    AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, 0, &outputEnableFlag, sizeof(outputEnableFlag));
    
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate = KCLSampleRate;
    audioFormat.mFormatID = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mChannelsPerFrame = KCLNumberChannels;
    audioFormat.mBitsPerChannel = KCLBitsPerChannels;
    audioFormat.mBytesPerPacket = KCLBytesPerFrame;
    audioFormat.mBytesPerFrame = KCLBytesPerFrame;
    
    AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &audioFormat, sizeof(audioFormat));
    
    AURenderCallbackStruct output;
    output.inputProc = OutputRenderTone;
    output.inputProcRefCon = (__bridge void *)self;
    AudioUnitSetProperty(audioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &output, sizeof(output));
}

- (void)initAudioUnit {
    AudioUnitInitialize(audioUnit);
}

OSStatus OutputRenderTone(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData) {
    memset(ioData->mBuffers[0].mData, 0, ioData->mBuffers[0].mDataByteSize);
    KCLPCMPlayer *pcmPlayer = (__bridge KCLPCMPlayer *)inRefCon;
    
    pcmPlayer->numberSamples += inNumberFrames;
    
    if (pcmPlayer.delegate) {
        [pcmPlayer.delegate pcmPlayer:pcmPlayer audioBuffer:ioData];
    }
    return noErr;
}


-(void)pause{
    AudioOutputUnitStop(audioUnit);
}

-(void)resume{
    numberSamples = 0;
    AudioOutputUnitStart(audioUnit);
}

- (void)dealloc {
    AudioComponentInstanceDispose(audioUnit);
}


@end
