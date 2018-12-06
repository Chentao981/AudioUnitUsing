//
//  MainViewController.m
//  AudioUnitUsing
//
//  Created by Chentao on 2018/12/6.
//  Copyright © 2018 Chentao. All rights reserved.
//

#import "MainViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "KCLAudioRecorder.h"
#import "KCLPCMPlayer.h"

@interface MainViewController ()<KCLAudioRecorderDelegate,KCLPCMPlayerDelegate>

@property(nonatomic,strong)KCLAudioRecorder *audioRecorder;

@property(nonatomic,strong)NSFileHandle *outputFileHandler;


@property(nonatomic,strong)KCLPCMPlayer *pcmPlayer;

@property(nonatomic,strong)NSFileHandle *inputFileHandler;


@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    
    ///////////////////////////////////////////
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath=[docDir stringByAppendingPathComponent:@"test.pcm"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]) {
        [manager removeItemAtPath:filePath error:nil];
    }

    [manager createFileAtPath:filePath contents:nil attributes:nil];
    
    self.outputFileHandler = [NSFileHandle fileHandleForWritingAtPath:filePath];

    ///////////////////////////////////////////
    NSString *inputFilePath = [[NSBundle mainBundle]pathForResource:@"input" ofType:@"pcm"];
    self.inputFileHandler = [NSFileHandle fileHandleForReadingAtPath:inputFilePath];
    
    self.pcmPlayer = [[KCLPCMPlayer alloc]init];
    self.pcmPlayer.delegate = self;
    ///////////////////////////////////////////
    
    UIButton *startButton = [[UIButton alloc]initWithFrame:CGRectMake(30, 100, 100, 50)];
    [startButton addTarget:self action:@selector(startButtonTouchHandler:) forControlEvents:UIControlEventTouchUpInside];
    startButton.backgroundColor = [UIColor grayColor];
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    [self.view addSubview:startButton];
    
    UIButton *stopButton = [[UIButton alloc]initWithFrame:CGRectMake(190, 100, 100, 50)];
    [stopButton addTarget:self action:@selector(stopButtonTouchHandler:) forControlEvents:UIControlEventTouchUpInside];
    stopButton.backgroundColor = [UIColor grayColor];
    [stopButton setTitle:@"Stop" forState:UIControlStateNormal];
    [self.view addSubview:stopButton];
    
    self.audioRecorder = [[KCLAudioRecorder alloc]init];
    self.audioRecorder.delegate = self;
    
    
    ///////////////////////////////////////////////////////
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error;
    
    AVAudioSessionRouteDescription *currentRoute = [audioSession currentRoute];
    for (AVAudioSessionPortDescription *desc in [currentRoute outputs]) {
        if ([AVAudioSessionPortBluetoothA2DP isEqualToString:desc.portType]) {
            [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:&error];
            [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
        } else {
            [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
            [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        }
    }
    
    //[audioSession setPreferredSampleRate:48000 error:&error];
    //[audioSession setPreferredIOBufferDuration:0.001 error:&error];
    
    [audioSession setActive:YES error:&error];
    if (error) {
        NSLog(@"开始录音 设置AVAudioSession时发生错误:%@", error);
    }
    NSLog(@"在线播放 开始录音Current Category:%@", audioSession.category);
    AVAudioSessionCategoryOptions options = [audioSession categoryOptions];
    NSLog(@"在线播放 开始录音Category[%@] has %lu options", audioSession.category, options);
    ///////////////////////////////////////////////////////
    
}


-(void)startButtonTouchHandler:(UIButton *)button{
    [self.audioRecorder startRecorder];
    [self.pcmPlayer resume];
}

-(void)stopButtonTouchHandler:(UIButton *)button{
    [self.audioRecorder stopRecorder];
    [self.pcmPlayer pause];
}


#pragma mark-KCLAudioRecorderDelegate

-(void)recorder:(KCLAudioRecorder *)recorder receiveData:(NSData *)pcmData{
    //NSLog(@"pcmData.length:%lu",(unsigned long)pcmData.length );
    [self.outputFileHandler writeData:pcmData];
    NSLog(@"time:%f",self.pcmPlayer.time);
}
#pragma mark-KCLPCMPlayerDelegate
-(NSData *)pcmPlayer:(KCLPCMPlayer *)player audioBuffer:(AudioBufferList *)ioData{
    AudioBuffer buffer = ioData->mBuffers[0];
    @autoreleasepool {
        NSData *pcmData = [self.inputFileHandler readDataOfLength:buffer.mDataByteSize];
        memcpy(buffer.mData, pcmData.bytes, buffer.mDataByteSize);
    }
    return nil;
}

@end
