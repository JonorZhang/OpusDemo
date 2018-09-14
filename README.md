# OpusDemo


## 编译opus静态库

- 从GitHub[下载Opus-iOS编译工程](git@github.com:JonorZhang/Opus-iOS.git)
- 在Opus-iOS编译工程根目录下创建`Opus-iOS/build/src`目录。
- 下载[opus稳定版](http://opus-codec.org/downloads/)，得到opus-xx.tar文件。
- 将opus-xx.tar放到`Opus-iOS/build/src`目录下。
- 如果你下载的opus版本和`build-libopus.sh`中的opus版本信息不一样，你要修改以下版本信息。

```bash
VERSION="1.2"       #这是opus版本
SDKVERSION="11.4"   #这是SDK版本
MINIOSVERSION="9.0" #这是最低iOS版本
```

- 在命令行中执行编译:

```bash
$ ./build-libopus.sh
```

- 编译完成后在`Opus-iOS/dependencies`中会看到`include`和`lib`


- 关于编译`Static Library` 和 `Framework` 的详细步骤请看`Opus-iOS/README.md`


## 集成opus到Xcode工程

用Xcode新建OpusDemo，将`include` 和 `lib`一同拷贝到工程中即可。
这一步就不细说了，新手请自行搜索`Xcode集成静态库`的方法。
不想往下看的话请直接看示例[OpusDemo](https://github.com/JonorZhang/OpusDemo)

## opus主要接口

- opus的接口声明在`include/opus.h`中，下面是四个主要的函数：

```c
// 创建编码器
OpusEncoder *opus_encoder_create(
    opus_int32 Fs,
    int channels,
    int application,
    int *error
)

// 修改编码器参数
int opus_encoder_ctl(
    OpusEncoder *st, 
    int request, ...
)

// 创建解码器
OpusDecoder *opus_decoder_create(
    opus_int32 Fs,
    int channels,
    int *error
)

// 将PCM编码成opus
opus_int32 opus_encode(
    OpusEncoder *st,
    const opus_int16 *pcm,
    int frame_size,
    unsigned char *data,
    opus_int32 max_data_bytes
) 

// 从opus中译码出PCM
int opus_decode(
    OpusDecoder *st,
    const unsigned char *data,
    opus_int32 len,
    opus_int16 *pcm,
    int frame_size,
    int decode_fec
) 

```

## Tips

- 使用动态码率？

编码器默认使用动态码率，因此需要记录每一个帧编码之后的大小。我的demo使用2字节的头来记录每一块opus数据的大小，具体请看我的demo。

静态码率需要设置编码器的初始化参数如下，编码后产生固定的大小的opus块。

```c
opus_encoder_ctl(_encoder, OPUS_SET_VBR(0));  // 0固定码率，1动态码率
``` 

- 指定码率？

你可以指定opus编码的码率大小，比特率从 6kb/s 到 510 kb/s，想要压缩比大一些就设置码率小一点，但是相应的也会使声音失真多一些。

```c
#define BITRATE 16000 
opus_encoder_ctl(_encoder, OPUS_SET_BITRATE(BITRATE));
```

- 语音信号优化？

如果你用于语音而不是音乐，那你完全可以设置如下，以使编码器针对语音模式做优化处理。

```c
opus_encoder_ctl(_encoder, 
OPUS_SET_APPLICATION(OPUS_APPLICATION_VOIP));

opus_encoder_ctl(_encoder, OPUS_SET_SIGNAL(OPUS_SIGNAL_VOICE));
```
