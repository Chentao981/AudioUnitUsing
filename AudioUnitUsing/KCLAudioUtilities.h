//
//  KCLAudioUtilities.h
//  AudioUnitUsing
//
//  Created by Chentao on 2018/12/6.
//  Copyright © 2018 Chentao. All rights reserved.
//

#ifndef KCLAudioUtilities_h
#define KCLAudioUtilities_h

#define t_sample SInt16

#define KCLSampleRate 48000
#define KCLNumberChannels 1
#define KCLBitsPerChannels (sizeof(t_sample) * 8)
#define KCLBytesPerFrame (KCLNumberChannels * sizeof(t_sample))


#endif /* KCLAudioUtilities_h */
