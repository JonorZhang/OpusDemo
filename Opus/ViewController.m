//
//  ViewController.m
//  Opus
//
//  Created by Jonor on 2018/9/10.
//  Copyright © 2018年 Jonor. All rights reserved.
//

#import "ViewController.h"
#import "AudioManager.h"
#import "OpusCodec.h"
#import "PlotView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet PlotView *wavPlotView;
@property (weak, nonatomic) IBOutlet PlotView *opusPlotView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)wav2opus2wav:(NSData *)data {
    // seeking ‘data’ flag.
    NSRange dataFlagRange = [data rangeOfData:[@"data" dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions range:NSMakeRange(0, data.length)];
    if (dataFlagRange.length == 0) {
        NSLog(@"ERROR: not found 'data' flag.");
        return;
    }
    
    // WAV => PCM
    NSUInteger pcmLenIdx = NSMaxRange(dataFlagRange);
    uint32_t pcmDataLen = *((uint32_t *)((char *)data.bytes + pcmLenIdx));
    NSUInteger pcmDataIdx = pcmLenIdx + sizeof(uint32_t);
    NSData *pcmData = [data subdataWithRange:(NSMakeRange(pcmDataIdx, pcmDataLen))];
    // 绘制原PCM波形
    [self.wavPlotView setPoints:pcmData];
    NSLog(@"WAV => PCM: %zd", pcmData.length);

    // PCM => OPUS
    NSData *opus = [OpusCodec.shared encode:pcmData];
    NSLog(@"PCM => OPUS: %zd", opus.length);
    
    // OPUS => PCM
    NSData *newpcm = [OpusCodec.shared decode:opus];
    // 绘制后PCM波形
    [self.opusPlotView setPoints:newpcm];
    NSLog(@"OPUS => PCM: %zd", newpcm.length);
    
    // PCM => WAV
    NSMutableData *wavHeader = [[data subdataWithRange:NSMakeRange(0, pcmDataIdx)] mutableCopy];
    *((uint32_t *)((char *)wavHeader.bytes + pcmLenIdx)) = (uint32_t)newpcm.length;
    [wavHeader appendData:newpcm]; //新pcm添加wav头
    NSData *newWav = wavHeader;
    NSLog(@"PCM => WAV: %zd", newWav.length);

    // 更新 info label
    self.infoLabel.text = [NSString stringWithFormat:@"原PCM: %zd 字节 \nOPUS: %zd 字节 \n后PCM: %zd 字节  \n压缩倍数:%.2f", pcmData.length, opus.length, newpcm.length, 1.0*pcmData.length/opus.length];
    
    // 播放解码出来的wav
    [AudioManager.shared playAudioData:newWav completionHandler:^(BOOL successfully) {
        NSLog(@"SUCCESS: wav -> pcm -> opus -> pcm -> wav : %.2f", 1.0*pcmData.length/opus.length);
    }];
}

- (IBAction)recordDidClicked:(UIButton *)sender {
    if ([AudioManager.shared isRecording]) {
        [sender setTitle:@"开始录音" forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [AudioManager.shared recordStop];
    } else {
        [sender setTitle:@"停止" forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];

        [AudioManager.shared recordStartWithProcess:^(float peakPower) {
//            NSLog(@"%.2f", peakPower);
        } completed:^(NSData *data, NSError *error) {
            if (error) {
                NSLog(@"record err:%@", error);
            } else {
                NSLog(@"record completed:%zd", data.length);
                [self wav2opus2wav:data];
            }
        }];
    }
}

@end
