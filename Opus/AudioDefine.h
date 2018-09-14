//
//  AudioDefine.h
//  Opus
//
//  Created by Jonor on 2018/9/13.
//  Copyright © 2018年 Jonor. All rights reserved.
//

#ifndef AUDIO_DEFINE_H
#define AUDIO_DEFINE_H

#ifdef __cplusplus
extern "C" {
#endif

/**
 * 采样率
 * 每秒钟采样次数，采样率越高越能表达高频信号的细节内容。
 * 一般有8K、16K、24K、44.1K、48K。
 */
#define SAMPLE_RATE     16000

    

/**
 * 通道数
 * 单通道为1， 双通道（立体声）为2
 */
#define CHANNELS        1


/**
 * 位深度
 * 每一个采样数据由多少位来表示，代表了幅度值丰富的变化程度。
 * 1字节 = 8bit, 2个字节 = 16bit, 3字节 = 24bit， 4字节 = 32bit
 */
#define PCM_BIT_DEPTH   16


/**
 * 比特率(码率)
 * 即音频每秒的传播的位数。这里是期望编码器压缩后的码率，而不是录音的码率。
 * BITRATE = SAMPLE_RATE * CHANNELS * PCM_BIT_DEPTH
 */
#define BITRATE         16000

/**
 * 音频帧大小
 * 以时间分割而得，在调用的时候必须使用的是恰好的一帧(2.5ms的倍数：2.5，5，10，20，40，60ms)的音频数据。
 * Fs/ms   2.5     5       10      20      40      60
 * 16kHz   40      80      160     320     640     960
 * 48kHz   120     240     480     960     1920    2880
 */
#define FRAME_SIZE      960 // 16000kHZ * 0.06s


#ifdef __cplusplus
} // extern "C"
#endif

#endif /* AUDIO_DEFINE_H */
