//
//  OpusCodec.m
//  Opus
//
//  Created by Jonor on 2018/9/11.
//  Copyright © 2018年 Jonor. All rights reserved.
//

#import "OpusCodec.h"
#import "opus.h"
#import "AudioDefine.h"


#define APPLICATION         OPUS_APPLICATION_VOIP
#define MAX_PACKET_BYTES    (FRAME_SIZE * CHANNELS * sizeof(opus_int16))
#define MAX_FRAME_SIZE      (FRAME_SIZE * CHANNELS * sizeof(opus_int16))

typedef opus_int16 OPUS_DATA_SIZE_T;


@implementation OpusCodec {
    OpusEncoder *_encoder;
    OpusDecoder *_decoder;
}

+ (instancetype)shared {
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone: NULL] init];
    });
    return _instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self shared];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    return [[self class] shared];
}

- (instancetype)init {
    self = [super init];
    if (self) {        
        _encoder = opus_encoder_create(SAMPLE_RATE, CHANNELS, APPLICATION, NULL);
        opus_encoder_ctl(_encoder, OPUS_SET_BITRATE(BITRATE));
        opus_encoder_ctl(_encoder, OPUS_SET_SIGNAL(OPUS_SIGNAL_VOICE));

        _decoder = opus_decoder_create(SAMPLE_RATE, CHANNELS, NULL);
    }
    return self;
}

#pragma mark - Public

- (NSData *)encode:(NSData *)PCM {
    opus_int16 *PCMPtr = (opus_int16 *)PCM.bytes;
    int PCMSize = (int)PCM.length / sizeof(opus_int16);
    opus_int16 *PCMEnd = PCMPtr + PCMSize;

    NSMutableData *mutData = [NSMutableData data];
    unsigned char encodedPacket[MAX_PACKET_BYTES];
    OPUS_DATA_SIZE_T encodedBytes = 0;

    while (PCMPtr + FRAME_SIZE < PCMEnd) {
        encodedBytes = opus_encode(_encoder, PCMPtr, FRAME_SIZE, encodedPacket, MAX_PACKET_BYTES);
        if (encodedBytes <= 0) {
            NSLog(@"ERROR: encodedBytes<=0");
            return nil;
        }
        NSLog(@"encodedBytes: %d",  encodedBytes);
        [mutData appendBytes:&encodedBytes length:sizeof(encodedBytes)];
        [mutData appendBytes:encodedPacket length:encodedBytes];
        
        PCMPtr += FRAME_SIZE;
    }
    
    return mutData.length > 0 ? mutData : nil;
}

- (NSData *)decode:(NSData *)opus {
    unsigned char *opusPtr = (unsigned char *)opus.bytes;
    int opusSize = (int)opus.length;
    unsigned char *opusEnd = opusPtr + opusSize;

    NSMutableData *mutData = [NSMutableData data];
    
    opus_int16 decodedPacket[MAX_FRAME_SIZE];
    OPUS_DATA_SIZE_T nBytes = 0;
    int decodedSamples = 0;
    
    while (opusPtr < opusEnd) {
        nBytes = *(OPUS_DATA_SIZE_T *)opusPtr;
        opusPtr += sizeof(nBytes);
        
        decodedSamples = opus_decode(_decoder, opusPtr, nBytes, decodedPacket, MAX_FRAME_SIZE, 0);
        if (decodedSamples <= 0) {
            NSLog(@"ERROR: decodedSamples<=0");
            return nil;
        }
        NSLog(@"decodedSamples:%d", decodedSamples);
        [mutData appendBytes:decodedPacket length:decodedSamples * sizeof(opus_int16)];
        
        opusPtr += nBytes;
    }

    return mutData.length > 0 ? mutData : nil;
}

@end




