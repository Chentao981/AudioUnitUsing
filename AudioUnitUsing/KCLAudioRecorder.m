

//
//  KCLAudioRecorder.m
//  AudioUnitUsing
//
//  Created by Chentao on 2017/8/28.
//  Copyright © 2017年 Chentao. All rights reserved.
//

#import "KCLAudioRecorder.h"
#import <AudioToolbox/AudioToolbox.h>
#import "KCLAudioUtilities.h"

@interface KCLAudioRecorder ()

@end

@implementation KCLAudioRecorder {
    AudioUnit audioUnit;
}

#pragma mark - init

- (instancetype)init {
    self = [super init];
    if (self) {        
        [self initAudioComponent];
        
        [self setupAudioUnit];
        
        [self initAudioUnit];
    }
    return self;
}

- (void)initAudioComponent {
    AudioComponentDescription audioDesc;
    audioDesc.componentType = kAudioUnitType_Output;
    audioDesc.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
    audioDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    audioDesc.componentFlags = 0;
    audioDesc.componentFlagsMask = 0;
    
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &audioDesc);
    AudioComponentInstanceNew(inputComponent, &audioUnit);
}

- (void)setupAudioUnit {
    UInt32 inputEnableFlag = 1;
    AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &inputEnableFlag, sizeof(inputEnableFlag));
    
    UInt32 outputEnableFlag = 0;
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
    
    AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &audioFormat, sizeof(audioFormat));
    
    AURenderCallbackStruct recordCallback;
    recordCallback.inputProc = RecordCallback;
    recordCallback.inputProcRefCon = (__bridge void *)self;
    AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Output, 1, &recordCallback, sizeof(recordCallback));
}

- (void)initAudioUnit {
    AudioUnitInitialize(audioUnit);
}

#pragma mark - callback function

static OSStatus RecordCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData) {

    KCLAudioRecorder *recorder = (__bridge KCLAudioRecorder *)inRefCon;
    
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0].mData = NULL;
    bufferList.mBuffers[0].mDataByteSize = 0;
    
    AudioUnitRender(recorder->audioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, &bufferList);
    
    NSData *pcmData = [NSData dataWithBytes:bufferList.mBuffers[0].mData length:bufferList.mBuffers[0].mDataByteSize];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (recorder.delegate && [recorder.delegate respondsToSelector:@selector(recorder:receiveData:)]) {
            [recorder.delegate recorder:recorder receiveData:pcmData];
        }
    });

    return noErr;
}

#pragma mark - public methods

- (void)startRecorder {
    AudioOutputUnitStart(audioUnit);
}

- (void)stopRecorder {
    AudioOutputUnitStop(audioUnit);
}

- (void)dealloc {
    AudioComponentInstanceDispose(audioUnit);
}

@end
