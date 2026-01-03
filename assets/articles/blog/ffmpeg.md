# ffmpeg 学习笔记

> Date: 2020-01-11
> Category: Blog

#### 1.ffmpeg常用命令
1. 视频录制命令
2. 多媒体文件的分解/复用命令
3. 裁剪与合并互转命令
4. 直播相关命令
5. 各种滤镜命令

```vim
1. 视频--H264编码/解码
2. 音频--ACC编码/解码
```

#### 2.应用场景

- 直播类：音视频会议、教育直播、娱乐/游戏
- 短视频：抖音、快手
- 网络视频：腾讯视频、优酷视频、爱奇艺
- 视频通话：微信、QQ
- 视频监控：幼儿园、停车场
- 人工智能：人脸视频、智能音箱


#### 3.基本流程
```
1. 解复用 ---  音视频解码（ffmpeg）--- 音频播放/视频渲染（SDL）
2. YUL数据 --- 渲染器渲染成纹理 --- 显卡计算交换 --- 窗口展示
```

#### 4.ffmpeg的历史

- 2000年，由法布里斯.贝拉创建
- 2004年，迈克尔接管
- 2011年，Libav从ffmpeg分离


#### 5.下载

```vim
git clone https://git.ffmpeg.org/ffmpeg.git

./configure --list-filters
./configure --helo | more

--disable-gpl
```

#### 6.ffmpeg命令分类

- 基本信息查询命令
- 录制命令
- 分解/复用命令
- 处理原始数据命令
- 裁剪与合并命令
- 图片/视频互转命令
- 直播相关命令
- 各种滤镜命令

#### 7.ffmpeg处理流程

输入文件 -- demuxer处理 --- 编码数据包 --- decoder处理 --- 解码后数据帧 --- encoder处理 --- 编码数据包 --- muxer处理 --- 输出文件

#### 8.ffmpeg命令之基本信息查询

命令 | 描述
---|---
-version | 显示版本
-demuxers | 显示可用的demuxers
-muxers | 显示可用的muxers
-devices | 显示可用的设备
-codecs | 显示所有编解码器
-decoders | 显示可用的解码器
-encoders | 显示所有的编码器
-bsfs | 显示比特流filter
-formats | 显示可用的格式
-protocols | 显示可用的协议
-filters | 显示可用的过滤器
-pix_fmts | 显示可用的像素格式
-sample_fmts | 显示可用过的采样格式
-layouts | 显示channel名称
-colors | 显示识别的颜色名称

#### 9.ffmpeg命令之录制

```
1. 录制屏幕：ffmpeg -f avfoundation -i1-r30 out.yuv
-f: 指定使用 avfoundation 采集数据
-i：指定从哪儿采集数据，它是一个文件的索引号
-r：指定帧率
.yuv：采集之后保存的数据 

2. 录制音频：ffmpeg -f avfoundation -i :0 out.wav
-f: 指定使用 avfoundation 采集数据
-i：指定从哪儿采集数据，它是一个文件的索引号（：0 是音频，冒号前是视频）
.yuv：采集之后保存的数据 
```


#### 10.ffmpeg命令之分解与复用

输入文件 -- demuxer -- 编码数据包 -- muxer 输出文件


```
1. 多媒体格式转换：ffmpeg -i out.mp4 -vcodec copy -acodec copy out.flv
-i：输入文件
-vcodec copy：视频编码处理方式
-acodec copy：音频编码处理方式 

2. 抽取视频：ffmpeg -i f35.mp4 -an -vcodec copy out.h264
3. 抽取音频：ffmpeg -i f35.mp4 -acodec -vn copy out.aac
```


#### 11.ffmpeg命令之处理原始数据

原始数据：ffmpeg解码在之后的数据，对于音频就是pcm数据，对于视频就是yuv数据。


```
1. 提取yuv数据：ffmpeg -i input.mp4 -an -c:v rawvideo -pix_fmt yuv420p out.yuv
-i：输入文件
-an：audio no 就是不需要音频
-c:v：对视频进行编码，使用rawvideo格式进行编码
-pix_fmt：指定像素格式

2. 提取pcm数据：ffmpeg -i out.mp4 -vn -ar 44100 -ac2 -f s16le out.pcm
-i：输入文件
-vn：video no 就是不需要视频
-ar：audio read：指定音频采样率
-ac2：audio channel 指定单声道、双声道、立体声、环绕立体声等等声道数
-f：指定抽取出来的数据存储方式


ffplay播放的时候原始数据需要指定一些参数以正确播放：
视频： -s 指定分辨率
音频:  -ar 指定采样率 -ar 指定声道数 -f 指定数据存储方式
```


#### 12.ffmpeg命令之滤镜

视频加水印、logo、画中画等等...处理解码后的数据帧
decoded frames --- filter处理 --- filtered frames --- encoder处理 ---  encoded data


```
1. 视频裁剪：ffmpeg -i in.mov -vf crop=in_w-200:in_h-200 -c:v libx264 -c:a copy out.mp4
-i：输入文件
-vf：video filter 指定视频滤镜且要=指定宽高w:h
-c:v：指定视频编码器
-c:a：指定音频编码器
```


#### 13.ffmpeg命令之裁剪与合并

```
1. 视频裁剪：ffmpeg -i in.mp4 -ss 00:00:00 -t 10 out.ts
-i：输入文件
-ss：指定裁剪的起始点
-t：指定裁剪的时长(持续时长)

2. 视频合并：ffmpeg -f concat -i inputs.txt out.flv
-f：file 指定文件处理方式
-i: 输入文件集合，inputs.txt内容为 'file filename' 格式
```


#### 14.ffmpeg命令之图片与视频互转

机器学习，视频裁切成一张张图片，然后使用图片识别技术识别图片上的内容。又或者多张图片合成一个视频等等。

```
1. 视频转图片：ffmpeg -i in.flv -r 1 -f image2 image-%3d.jpeg
-i：输入文件
-r：指定转换图片的帧率(每秒钟转出1张图片)
-f：指定文件转换格式

2. 图片转视频：ffmpeg -i image-%3d.jpeg out.mp4
-i：输入文件
```


#### 15.ffmpeg命令之直播推流与拉流

[一些直播流的rtmp地址](https://blog.csdn.net/github_30662571/article/details/72466091)

```
1. 直播推流：ffmpeg -re -i out.mp4 -c copy -f flv rtmp://server/live/streamName
-re：减慢帧率速度，保持帧率同步
-i：指定推流的文件
-c：音视频编解码 a是音频 v是视频 copy保持参数不变
-f：指定推流的文件格式

2. 直播拉流：ffmpeg -i rtmp://server/live/streamName -c copy dump.flv
-i：指定直播发布的rtmp服务地址
-c：指定音视频编码器
``` 


#### 16.vim编辑器

- 命令模式：拷贝/删除、粘贴 i/a 切换到编辑模式
- 编辑模式：esc退出编辑模式
- 创建文件：vim filename
- 保存：:w
- 退出：:q
- 保存并退出：:wq
- 拷贝：yy/yw  yy是拷贝一行   yw是拷贝一个单词
- 粘贴：p
- 删除：dd/dw  dd是删除一行   dw是删除一个单词
- 左下上右：h/j/k/l
- 跳到文件头：gg
- 跳到文件尾：GG
- 移动到行首：^
- 移动到行尾：$
- 按单词移动：向前 w/2w  向后 b/2b
- 查找关键字：/关键字   下一个n  上一个N
- 查找与替换：:%s/关键字/替换字/gc  c是表示要二次确认
- 分窗口：split/vsplit
- 窗口间跳转：ctrl + ww/w[hjkl]  ctrl + w + = 恢复等屏幕    ctrl + w shift + | 最大化当前窗口  ctrl + w shift + - 最大化当前窗口


#### 17.C语言基础

```c
#include <stdio.h>  // 导入头文件

int  main(int argc, char* argv[]) { // 入口函数
    int a = 100;
    float b = 7 .79;
    char c = 'today'
    printf("Hello Worl!\n");
    printf("a=%d\n", a);
    printf("b=%f\n", b);
    printf("c=%c\n", c);
    return 0;
}

//  clang -g -o helloworld helloworld.c    -g输出debug信息  -o是输出可执行程序
// ./helloworld
```


#### 18.C语言基础之常用基本类型

- short int long
- float double
- char
- void


#### 19.C语言基础之指针与数组

- 指针就是内存地址：void*  char*
- 数组： char c[2]   int arr[20]   连续的同一类型的内存空间
- 指针本身运算
- 指针所指内容的操作
- 操作系统如何管理内存？栈空间、堆空间、内存映射
- 分配内存：void* mem = malloc(size);
- 释放内存：free(mem);
- 申请的内存不用也不释放以引起内存泄漏
- 占用别人的内存成为野指针
- 函数指针：返回值类型(*指针变量名)([形参列表])

```
int func(int x); // 声明一个函数
int (*f) (int x); // 声明一个函数指针
f = func; // 将func函数的首地址赋给指针f 
```


```c
#include <studio.h>
#include <stdlib.h>

int sum(int a, int b) {
    return a + b;
}

int sub(int a, int b) {
    return a - b;
}

int main(int argc, char* argc[]) {
     int *a, *b; // 定义两个指针类型
     a = (int*)malloc(sizeof(int)); // 在堆里开辟空间
     b = (int*)malloc(sizeof(int));
     *a = 1;
     *b = 2;
     int c[3] = {0, 1, 2}; // 定义一个数组
     printf("addr of a:%p\n, %p, %d\n", &a, a, *a);
     printf("addr of b:%p\n, %p, %d\n", &b, a, *b);
     printf("addr of c:%p, %p, %d, %d, %d", &c, c, c[0], c[1], c[2]);
     
     int (*f)(int, int); // 定义一个函数指针
     int result;
     int r;
     f = sum;
     retsult = f(3, 5); // 通过函数指针调用函数
     
     f = sub;
     r = f(result, 5);
     printf("3+5=%d\n", result);
     printf("8-5=%d\n", r);
     return 0;
}
```


#### 20.C语言基础之结构体

原始类型，自定义的类型--结构体、枚举

```c
#include <studio.h>

struct st {
    int a;
    int b;
};

enum em {
    red = 10,
    green = 20,
    blue = 30
}

int main(int argc, char* argv[]) {
    struct st sst;
    sst.a = 10;
    sst.b = 20;
    printf("struct cpntent is:%d. %d\n", sst.a, sst.b);
    
    enum etype et;
    et = red;
    printf("the color is %d\n", et);
    
    et = blue;
    printf("the color is %d\n", et);
    return 0;
}
```


#### 20.C语言基础之算数运算符与比较运算符

- +、-、*、/、%
- <=、<、>、>=

```c
#include <studio.h>

int main(int argc, char* argv[]) {
    int a = 10;
    int b = 20;
    int c = a + b;
    printf("c=%d", c);
}
```


#### 21.C语言基础之循环

```c
#include <studio.h>

int main(int argc, char* argv[]) {
    for (int i = 0; i < 10; i++) {
        printf("i=%d\n", i);
    }
    
    int j = 0;
    while (j < 10) {
        printf('j=%d\n', j);
        j++;
    }
}
```


#### 22.C语言基础之函数

```c
#include <stdio.h>

int sum(int a, int b) {
    return  a + b;
}

void log() {
    printf("this is log info...");
}

int main(int argc, char* argv[]) {
    int result;
    result = sum(1, 2);
    printf("1 + 2 =%d\n", result);
    
    log();
    return 0;
}
```


#### 23.C语言基础之文件操作

- 问价类型：FILE* file;
- 打开文件 FILE* fopen(path, mode);
- 关闭文件 fclose(FILE*);

```c
#include <studio.h>

int main(int argc, char* argv[]) {
    FILE* file;
    char buf[1024] = {0,};
    file = fopen("1.txt", "a+"); // 打开一个文件，如果不存在就创建一个同名的文件
    fwrite("Hello World", 1, 11, file);
    rewind(file); // 手动将游标放到文件的开头
    fread(buf, 1, 11, file);
    fclose(file);
    printf("buf: %s\n", buf);
    return 0;
}
```


#### 24.C语言基础之编译器

- Mac上使用clang，Linux上使用gcc

```
1. gcc/clang -g -O2 -o test test.c -I... -L... -l
-g：输出文件中的调试信息
-O：对输出文件做指令优化
-o：输出文件
-I：指定头文件
-L：指定库文件位置
-l：指定使用哪个库
```

- 预编译：将头文件代码拷贝过来和项目代码合并
- 编译
- 链接、动态链接、静态链接
- clang -g -c add.c  ==>  add.o
- libtool -static -o libmylib.a add.o  生成静态库
- 静态库代码
```c
// add.h
#ifndef __MY_LIBRARY__
#define __MY_LIBRARY__

int add(int a, int b);

#endif
```
- 引用静态库

```c
#include <stdio.h>
#include "add.h"

int main(int argc, char* argv[]) {
    printf("add=%d\n", add(3, 3));
    return 0;
}
```
- 编译：clang -g -o testlib testlib.c -I . -L . -l -lmylib


#### 25.C语言基础之调试器

Mac下使用的是LLDB，Linux下使用Gdb

- 编译输出带调试信息的程序
- 调试信息包含：指令地址、对应源代码及行号
- 指令完成后，回调


命令 | gdb/lldb
---|---
设置断点 | b
运行程序 | r
单步执行 | n
跳入函数 | s
跳出函数 | finish
打印内容 | p

- lldb testlib

```
break list // 查看断点信息
p xxx // 打印变量信息
c // 一次执行完毕
n // 下一步
quit // 退出当前程序
xxx.dSYM // 带调试信息的编译后文件，使用dwarfdump xxx 即可查看对应的调试文件
```


#### 27.ffmpeg代码结构


文件夹 | 描述信息
---|---
libavcodec | 提供了一系列编码器的实现
libavformat | 实现在流协议，容器格式及基本IO访问
libavutil | 包括了hash器，解码器和各种工具函数
libavfilter | 提供了各种音视频过滤器
libavdevice | 提供了访问捕获设备和回访设备的接口
libswresample | 实现了混音和重采样
libswscale | 实现了色彩转换和缩放功能


#### 28.ffmpeg日志系统

- include <libavutil/log.h>  日志头文件
- av_log_set_level(AV_LOG_DEBUG)  设置debug样式界别
- av_log(NULL, AV_LOG_INFO, "..%s\n", op)  日志打印
- 常用日志级别
    -  AV_LOG_ERROR 
    -  AV_LOG_WARNING
    -  AV_LOG_INFO
    -  AV_:OG_DEBUG

```c
#include <stdio.h>
#include <libavutil/log.h>

int main(int argc, char* argv[]) {
    av_log_set_level(AV_LOG_DEBUG);
    av_log(NULL, AV_LOG_INFO, "Hello WOrld!:%s\n", "Hi~");
    return 0
}
```
- 执行命令：clang -g -o ffmpeg_log ffmpeg_log.c -lavutil


#### 29.ffmpeg文件的删除与重命名

- avpriv_io_delete()
- avpriv_io_move()

```c
#include <stdio.h>
#include <libavformat/avformat.h>

int main(int argc, char* argv[]) {
    int ret;
    ret = avpriv_io_move("111.txt", "222.txt"); // 重命名文件
    if (ret < 0) {
        av_log(NULL, AV_LOG_ERROR, "Failed to rename\n");
        return -1;
    }
    av_log(NULL, AV_LOG_INFO, "Success to rename\n");
    ret = avpriv_io_delete("./mytestfile.txt"); // 删除文件
    if (ret < 0) {
        av_log(NULL, AV_LOG_ERROR, "Failed to delete file mytestfile.txt\n");
        return -1;
    }
    av_log(NULL, AV_LOG_INFO, "Success to delete mytestfile.txt\n");
    return 0
}
```
- 执行程序：clang -g -o ffmpeg_del ffmpeg_file.c `pkg-config --libs libavformat`
 

#### 30.ffmpeg操作目录函数

- avio_open_dir()
- avio_read_dir()
- avio_close_dir()
    - AVIO_DirContext操作目录的上下文
    - AVIODirEntry目录想，用于存放文件名、文件属性等等

```c
#include <libavutil/log.h>
#include <libavformat/avformat.h>

int main(int argc, char* argv[]) {
    int ret;
    AVIODirEntry *entry = NULL;
    AVIODirCotext *ctx = NULL:
    av_log_set_level(AV_LOG_INFO);
    ret = avio_open_dir(&ctx, "./", NULL);
    if (ret < 0) {
        av_log(NULL, AV_LOG_ERROR, "Cant open dir:%s\n", av_err2str(ret));
        return -1;
    }
    while (1) {
        ret = avio_read_dir(ctx, &entry);
        if (ret < 0) {
            av_log(NULL, AV_LOG_ERROR, "Cant read dir:%s\n", av_err2str(ret));
            goto __fail;
        }
        if (!entry) {
            break;
        }
        av_log(NULL, AV_LOG_INFO, "%12"PRId64" %s \n", entry->size, entry->name);
        avio_free_directory_entry(&entry); // 释放内存
    }
    __fail;
    avio_close_dir(&ctx);
    return 0;
}
```


#### 31.多媒体文件

- 多媒体文件其实就是个容器
- 在容器里又很多流（Stream/Track）
- 每种流是由不同的编码器编码的
- 从流中读取的数据称为包
- 在一个包中包含着一个或多个帧
- AVFormatContext   读取多媒体文件的上下文
- AVStream
- AVPacket

```
解复用 -- 获取流 -- 读取数据包 -- 释放资源
```


#### 32.打印音视频信息

- av_register_all()
- avformat_open_input() / avformat_close_input()
- av_dump_format()

```c
#include <libavutil/log.h>
#include <libavformat/avformat.h>

int main(int argc, char* argv[]) {
    int ret;
    AVFormatContext *fmt_ctx = NULL: // 格式上下文
    av_log_set_level(AV_LOG_INFO);
    av_register_all(); // 注册各种解码器、协议等等
    ret = avformat_open_input(&fmt_ctx, "./test.mp4", NULL, NULL);
    if (ret < 0) {
        av_log(NULL, AV_LOG_ERROR, "Cant open file: %s\n", averr2str(ret));
        return -1;
    }
    av_dump_format(fmt_ctx, 0, "./test.mp4", 0); // 打印metadata
    avformat_close_input(&fmt_ctx);
    return 0;
}
```
- 执行程序：clang -g -o mediainfo mediainfo.c `pkg-config --libs libavutil libavformat`


#### 33.抽取音频数据

- av_init_packet()  初始化数据包结构体
- av_find_best_stream()   从对媒体文件中找到最好的一路流
- av_read_frame()/av_packet_unref()   读取流中的数据包/释放读取之后的引用计数-1，防止内存泄漏

```c
#include <stdio.h>
#include <libavutil/log.h>
#include <libavformat/avformat.h>

#define ADTS_HEADER_LEN 7;

void adts_header(char *szAdtsHeader, int dataLen) {
    int audio_object_type = 2;
    int sampling_frequency_index = 7;
    int channel_config = 2;
    int adtsLen = dataLen + 7;
    
    szAdtsHeader[0] = 0xff;
    szAdtsHeader[1] = 0xf0;
    szAdtsHeader[1] |= (0 << 3);
    szAdtsHeader[1] |= (0 << 1);
    szAdtsHeader[1] |= 1;
    szAdtsHeader[2] = (audio_object_type - 1) << 6;
    szAdtsHeader[2] |= (sampling_frequency_index & 0x0f) << 2;
    szAdtsHeader[2] |= (0 << 1);
    szAdtsHeader[2] |= (channel_config & 0x04) >> 2;
    szAdtsHeader[3] = (channel_config & 0x03) << 6;
    szAdtsHeader[3] |= (0 << 5);
    szAdtsHeader[3] |= (0 << 4);
    szAdtsHeader[3] |= (0 << 3);
    szAdtsHeader[3] |= (0 << 2);
    szAdtsHeader[3] |= ((adtsLen & 0x1800) >> 11);
    szAdtsHeader[4] = (uint8_t)((adtsLen & 0x7f8) >> 3);
    szAdtsHeader[5] = (uint8_t)((adtsLen & 0x7) << 5);
    szAdtsHeader[5] = 0x1f;
    szAdtsHeader[6] = 0xfc;
}

int main(int argc, char* argv[]) {
    int ret;
    int len;
    int audio_index;
    char* src = NULL;
    char* dst = NULL;
    AVPacket pkt;
    AVFormatContext *fmt_ctx = NULL;

    av_log_set_level(AV_LOG_INFO);
    // av_register_all(); // 注册各种解码器、协议等等，ffmpeg4.0之后不再需要手动注册
    
    // 第一步：从控制台读取两次参数
    if (argc < 3) {
        av_log(NULL, AV_LOG_ERROR, "the count of params should be more than three! \n");
        return -1;
    }
    src = argv[1];
    dst = argv[2];
    if (!src || !dst) {
        av_log(NULL, AV_LOG_ERROR, "src or dst is null! \n");
        return -1;
    }
    ret = avformat_open_input(&fmt_ctx, src, NULL, NULL); // 读取多媒体文件
    if (ret < 0) {
        av_log(NULL, AV_LOG_ERROR, "can not open file: %s\n", av_err2str(ret));
        return -1;
    }
    FILE* dst_fd = fopen(dst, "wb"); // 以只写的方式打开一个二进制文件，若无则创建这个文件
    if (!dst_fd) { // 判断输出文件是否存在
        av_log(NULL, AV_LOG_ERROR, "can not open out file! \n");
        avformat_close_input(&fmt_ctx);
        return -1;
    }
    av_dump_format(fmt_ctx, 0, src, 0); // 打印metadata
    // 2.第二步：获取流
    ret = av_find_best_stream(fmt_ctx, AVMEDIA_TYPE_AUDIO, -1, -1, NULL, 0); // 音频
    if (ret < 0) {
        av_log(NULL, AV_LOG_ERROR, "can not find the best stream!\n");
        avformat_close_input(&fmt_ctx);
        fclose(dst_fd);
        return -1;
    }
    audio_index = ret;
    av_init_packet(&pkt);
    while(av_read_frame(fmt_ctx, &pkt) >= 0) { // 读取流中的所有数据包
        if(pkt.stream_index == audio_index) {
            char adts_header_buf[7];
            adts_header(adts_header_buf, pkt.size);
            fwrite(adts_header_buf, 1, 7, dst_fd);
        // 第三步：读取流数据包
            len = fwrite(pkt.data, 1, pkt.size, dst_fd);
            if(len != pkt.size) {
                av_log(NULL, AV_LOG_WARNING, "warning length of data is not equal size of pkt! \n");
            }
        }
        av_packet_unref(&pkt);
    }
    avformat_close_input(&fmt_ctx);
    if (dst_fd) {
        fclose(dst_fd);
    }
    return 0;
}
```  



#### 34.抽取视频数据

- Start code  特征码
- SPS/PPS  去解码的视频参数  超级小，一般每一帧前面加
- codec -> extradata  获取SPS/PPS，在编码器的扩展数据空间里获取

```c
#include <libavutil/log.h>
#include <libavformat/avformat.h>

int main(int argc, char* argv[]) {
    return 0;
}
```


#### 35.将MP4转成FLV格式

- avformat_alloc_output_context2() / avformat_free_context()
- avformat_new_stream()
- avcodec_parameters_copy()
- avformat_write_header()
- av_write_frame() / av_interleaved_write_frame()
- av_write_trailer()

```c
#include <libavutil/timestamp.h>
#include <libavformat/avformat.h>

static void log_packet(const AVFormatContext *fmt_ctx, const AVPacket *pkt, const char *tag)
{
    AVRational *time_base = &fmt_ctx->streams[pkt->stream_index]->time_base;

    printf("%s: pts:%s pts_time:%s dts:%s dts_time:%s duration:%s duration_time:%s stream_index:%d\n",
           tag,
           av_ts2str(pkt->pts), av_ts2timestr(pkt->pts, time_base),
           av_ts2str(pkt->dts), av_ts2timestr(pkt->dts, time_base),
           av_ts2str(pkt->duration), av_ts2timestr(pkt->duration, time_base),
           pkt->stream_index);
}

int main(int argc, char **argv)
{
    AVOutputFormat *ofmt = NULL;
    AVFormatContext *ifmt_ctx = NULL, *ofmt_ctx = NULL;
    AVPacket pkt;
    const char *in_filename, *out_filename;
    int ret, i;
    int stream_index = 0;
    int *stream_mapping = NULL;
    int stream_mapping_size = 0;

    if (argc < 3) {
        printf("usage: %s input output\n"
               "API example program to remux a media file with libavformat and libavcodec.\n"
               "The output format is guessed according to the file extension.\n"
               "\n", argv[0]);
        return 1;
    }

    in_filename  = argv[1];
    out_filename = argv[2];

    av_register_all();

    if ((ret = avformat_open_input(&ifmt_ctx, in_filename, 0, 0)) < 0) {
        fprintf(stderr, "Could not open input file '%s'", in_filename);
        goto end;
    }

    if ((ret = avformat_find_stream_info(ifmt_ctx, 0)) < 0) {
        fprintf(stderr, "Failed to retrieve input stream information");
        goto end;
    }

    av_dump_format(ifmt_ctx, 0, in_filename, 0);

    avformat_alloc_output_context2(&ofmt_ctx, NULL, NULL, out_filename);
    if (!ofmt_ctx) {
        fprintf(stderr, "Could not create output context\n");
        ret = AVERROR_UNKNOWN;
        goto end;
    }

    stream_mapping_size = ifmt_ctx->nb_streams;
    stream_mapping = av_mallocz_array(stream_mapping_size, sizeof(*stream_mapping));
    if (!stream_mapping) {
        ret = AVERROR(ENOMEM);
        goto end;
    }

    ofmt = ofmt_ctx->oformat;

    for (i = 0; i < ifmt_ctx->nb_streams; i++) {
        AVStream *out_stream;
        AVStream *in_stream = ifmt_ctx->streams[i];
        AVCodecParameters *in_codecpar = in_stream->codecpar;

        if (in_codecpar->codec_type != AVMEDIA_TYPE_AUDIO &&
            in_codecpar->codec_type != AVMEDIA_TYPE_VIDEO &&
            in_codecpar->codec_type != AVMEDIA_TYPE_SUBTITLE) {
            stream_mapping[i] = -1;
            continue;
        }

        stream_mapping[i] = stream_index++;

        out_stream = avformat_new_stream(ofmt_ctx, NULL);
        if (!out_stream) {
            fprintf(stderr, "Failed allocating output stream\n");
            ret = AVERROR_UNKNOWN;
            goto end;
        }

        ret = avcodec_parameters_copy(out_stream->codecpar, in_codecpar);
        if (ret < 0) {
            fprintf(stderr, "Failed to copy codec parameters\n");
            goto end;
        }
        out_stream->codecpar->codec_tag = 0;
    }
    av_dump_format(ofmt_ctx, 0, out_filename, 1);

    if (!(ofmt->flags & AVFMT_NOFILE)) {
        ret = avio_open(&ofmt_ctx->pb, out_filename, AVIO_FLAG_WRITE);
        if (ret < 0) {
            fprintf(stderr, "Could not open output file '%s'", out_filename);
            goto end;
        }
    }

    ret = avformat_write_header(ofmt_ctx, NULL);
    if (ret < 0) {
        fprintf(stderr, "Error occurred when opening output file\n");
        goto end;
    }

    while (1) {
        AVStream *in_stream, *out_stream;

        ret = av_read_frame(ifmt_ctx, &pkt);
        if (ret < 0)
            break;

        in_stream  = ifmt_ctx->streams[pkt.stream_index];
        if (pkt.stream_index >= stream_mapping_size ||
            stream_mapping[pkt.stream_index] < 0) {
            av_packet_unref(&pkt);
            continue;
        }

        pkt.stream_index = stream_mapping[pkt.stream_index];
        out_stream = ofmt_ctx->streams[pkt.stream_index];
        log_packet(ifmt_ctx, &pkt, "in");

        /* copy packet */
        pkt.pts = av_rescale_q_rnd(pkt.pts, in_stream->time_base, out_stream->time_base, AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX);
        pkt.dts = av_rescale_q_rnd(pkt.dts, in_stream->time_base, out_stream->time_base, AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX);
        pkt.duration = av_rescale_q(pkt.duration, in_stream->time_base, out_stream->time_base);
        pkt.pos = -1;
        log_packet(ofmt_ctx, &pkt, "out");

        ret = av_interleaved_write_frame(ofmt_ctx, &pkt);
        if (ret < 0) {
            fprintf(stderr, "Error muxing packet\n");
            break;
        }
        av_packet_unref(&pkt);
    }

    av_write_trailer(ofmt_ctx);
end:

    avformat_close_input(&ifmt_ctx);

    /* close output */
    if (ofmt_ctx && !(ofmt->flags & AVFMT_NOFILE))
        avio_closep(&ofmt_ctx->pb);
    avformat_free_context(ofmt_ctx);

    av_freep(&stream_mapping);

    if (ret < 0 && ret != AVERROR_EOF) {
        fprintf(stderr, "Error occurred: %s\n", av_err2str(ret));
        return 1;
    }

    return 0;
}

```  


#### 36.cong从MP4截取一段视频

- av_seek_frame()

```c
#include <stdlib.h>
#include <libavutil/timestamp.h>
#include <libavformat/avformat.h>

static void log_packet(const AVFormatContext *fmt_ctx, const AVPacket *pkt, const char *tag)
{
    AVRational *time_base = &fmt_ctx->streams[pkt->stream_index]->time_base;

    printf("%s: pts:%s pts_time:%s dts:%s dts_time:%s duration:%s duration_time:%s stream_index:%d\n",
           tag,
           av_ts2str(pkt->pts), av_ts2timestr(pkt->pts, time_base),
           av_ts2str(pkt->dts), av_ts2timestr(pkt->dts, time_base),
           av_ts2str(pkt->duration), av_ts2timestr(pkt->duration, time_base),
           pkt->stream_index);
}

int cut_video(double from_seconds, double end_seconds, const char* in_filename, const char* out_filename) {
    AVOutputFormat *ofmt = NULL;
    AVFormatContext *ifmt_ctx = NULL, *ofmt_ctx = NULL;
    AVPacket pkt;
    int ret, i;

    av_register_all();

    if ((ret = avformat_open_input(&ifmt_ctx, in_filename, 0, 0)) < 0) {
        fprintf(stderr, "Could not open input file '%s'", in_filename);
        goto end;
    }

    if ((ret = avformat_find_stream_info(ifmt_ctx, 0)) < 0) {
        fprintf(stderr, "Failed to retrieve input stream information");
        goto end;
    }

    av_dump_format(ifmt_ctx, 0, in_filename, 0);

    avformat_alloc_output_context2(&ofmt_ctx, NULL, NULL, out_filename);
    if (!ofmt_ctx) {
        fprintf(stderr, "Could not create output context\n");
        ret = AVERROR_UNKNOWN;
        goto end;
    }

    ofmt = ofmt_ctx->oformat;

    for (i = 0; i < ifmt_ctx->nb_streams; i++) {
        AVStream *in_stream = ifmt_ctx->streams[i];
        AVStream *out_stream = avformat_new_stream(ofmt_ctx, in_stream->codec->codec);
        if (!out_stream) {
            fprintf(stderr, "Failed allocating output stream\n");
            ret = AVERROR_UNKNOWN;
            goto end;
        }

        ret = avcodec_copy_context(out_stream->codec, in_stream->codec);
        if (ret < 0) {
            fprintf(stderr, "Failed to copy context from input to output stream codec context\n");
            goto end;
        }
        out_stream->codec->codec_tag = 0;
        if (ofmt_ctx->oformat->flags & AVFMT_GLOBALHEADER)
            out_stream->codec->flags |= AV_CODEC_FLAG_GLOBAL_HEADER;
    }
    av_dump_format(ofmt_ctx, 0, out_filename, 1);

    if (!(ofmt->flags & AVFMT_NOFILE)) {
        ret = avio_open(&ofmt_ctx->pb, out_filename, AVIO_FLAG_WRITE);
        if (ret < 0) {
            fprintf(stderr, "Could not open output file '%s'", out_filename);
            goto end;
        }
    }

    ret = avformat_write_header(ofmt_ctx, NULL);
    if (ret < 0) {
        fprintf(stderr, "Error occurred when opening output file\n");
        goto end;
    }

    //    int indexs[8] = {0};


    //    int64_t start_from = 8*AV_TIME_BASE;
    ret = av_seek_frame(ifmt_ctx, -1, from_seconds*AV_TIME_BASE, AVSEEK_FLAG_ANY);
    if (ret < 0) {
        fprintf(stderr, "Error seek\n");
        goto end;
    }

    int64_t *dts_start_from = malloc(sizeof(int64_t) * ifmt_ctx->nb_streams);
    memset(dts_start_from, 0, sizeof(int64_t) * ifmt_ctx->nb_streams);
    int64_t *pts_start_from = malloc(sizeof(int64_t) * ifmt_ctx->nb_streams);
    memset(pts_start_from, 0, sizeof(int64_t) * ifmt_ctx->nb_streams);

    while (1) {
        AVStream *in_stream, *out_stream;

        ret = av_read_frame(ifmt_ctx, &pkt);
        if (ret < 0)
            break;

        in_stream  = ifmt_ctx->streams[pkt.stream_index];
        out_stream = ofmt_ctx->streams[pkt.stream_index];

        log_packet(ifmt_ctx, &pkt, "in");

        if (av_q2d(in_stream->time_base) * pkt.pts > end_seconds) {
            av_free_packet(&pkt);
            break;
        }

        if (dts_start_from[pkt.stream_index] == 0) {
            dts_start_from[pkt.stream_index] = pkt.dts;
            printf("dts_start_from: %s\n", av_ts2str(dts_start_from[pkt.stream_index]));
        }
        if (pts_start_from[pkt.stream_index] == 0) {
            pts_start_from[pkt.stream_index] = pkt.pts;
            printf("pts_start_from: %s\n", av_ts2str(pts_start_from[pkt.stream_index]));
        }

        /* copy packet */
        pkt.pts = av_rescale_q_rnd(pkt.pts - pts_start_from[pkt.stream_index], in_stream->time_base, out_stream->time_base, AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX);
        pkt.dts = av_rescale_q_rnd(pkt.dts - dts_start_from[pkt.stream_index], in_stream->time_base, out_stream->time_base, AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX);
        if (pkt.pts < 0) {
            pkt.pts = 0;
        }
        if (pkt.dts < 0) {
            pkt.dts = 0;
        }
        pkt.duration = (int)av_rescale_q((int64_t)pkt.duration, in_stream->time_base, out_stream->time_base);
        pkt.pos = -1;
        log_packet(ofmt_ctx, &pkt, "out");
        printf("\n");

        ret = av_interleaved_write_frame(ofmt_ctx, &pkt);
        if (ret < 0) {
            fprintf(stderr, "Error muxing packet\n");
            break;
        }
        av_free_packet(&pkt);
    }
    free(dts_start_from);
    free(pts_start_from);

    av_write_trailer(ofmt_ctx);
end:

    avformat_close_input(&ifmt_ctx);

    /* close output */
    if (ofmt_ctx && !(ofmt->flags & AVFMT_NOFILE))
        avio_closep(&ofmt_ctx->pb);
    avformat_free_context(ofmt_ctx);

    if (ret < 0 && ret != AVERROR_EOF) {
        fprintf(stderr, "Error occurred: %s\n", av_err2str(ret));
        return 1;
    }

    return 0;
}

int main(int argc, char *argv[]){
    if(argc < 5){
        fprintf(stderr, "Usage: \
                command startime, endtime, srcfile, outfile");
        return -1;
    }

    double startime = atoi(argv[1]);
    double endtime = atoi(argv[2]);
    cut_video(startime, endtime, argv[3], argv[4]);

    return 0;
}
```  


#### 37.h264解码

- 常用数据结构体
    - AVCodec 编码器结构体
    - AVCodecCotext 编码器上下文
    - AVFrame 解码后的帧
- av_frame_alloc() / av_frame_free()
- avcodec_alloc_context3()
- avcodec_free_context()
- 解码步骤
    1. 查找解码器（avcodec_find_decoder / avcodec_find_encoder_by_name）
    2. 打开解码器（avcodec_open2）
    3. 解码（avcodec_decode_video2）

- h264编码流程
    1. 查找编码器（avcodec_find_encoder_by_name）
    2. 设置编码参数，并打开编码器（avcodec_open2）
    3. 编码（avcodec_encode_video2）

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libswscale/swscale.h>

#define INBUF_SIZE 4096

#define WORD uint16_t
#define DWORD uint32_t
#define LONG int32_t

#pragma pack(2)
typedef struct tagBITMAPFILEHEADER {
  WORD  bfType;
  DWORD bfSize;
  WORD  bfReserved1;
  WORD  bfReserved2;
  DWORD bfOffBits;
} BITMAPFILEHEADER, *PBITMAPFILEHEADER;


typedef struct tagBITMAPINFOHEADER {
  DWORD biSize;
  LONG  biWidth;
  LONG  biHeight;
  WORD  biPlanes;
  WORD  biBitCount;
  DWORD biCompression;
  DWORD biSizeImage;
  LONG  biXPelsPerMeter;
  LONG  biYPelsPerMeter;
  DWORD biClrUsed;
  DWORD biClrImportant;
} BITMAPINFOHEADER, *PBITMAPINFOHEADER;

void saveBMP(struct SwsContext *img_convert_ctx, AVFrame *frame, char *filename)
{
    //1 先进行转换,  YUV420=>RGB24:
    int w = frame->width;
    int h = frame->height;


    int numBytes=avpicture_get_size(AV_PIX_FMT_BGR24, w, h);
    uint8_t *buffer=(uint8_t *)av_malloc(numBytes*sizeof(uint8_t));


    AVFrame *pFrameRGB = av_frame_alloc();
     /* buffer is going to be written to rawvideo file, no alignment */
    /*
    if (av_image_alloc(pFrameRGB->data, pFrameRGB->linesize,
                              w, h, AV_PIX_FMT_BGR24, pix_fmt, 1) < 0) {
        fprintf(stderr, "Could not allocate destination image\n");
        exit(1);
    }
    */
    avpicture_fill((AVPicture *)pFrameRGB, buffer, AV_PIX_FMT_BGR24, w, h);

    sws_scale(img_convert_ctx, frame->data, frame->linesize,
              0, h, pFrameRGB->data, pFrameRGB->linesize);

    //2 构造 BITMAPINFOHEADER
    BITMAPINFOHEADER header;
    header.biSize = sizeof(BITMAPINFOHEADER);


    header.biWidth = w;
    header.biHeight = h*(-1);
    header.biBitCount = 24;
    header.biCompression = 0;
    header.biSizeImage = 0;
    header.biClrImportant = 0;
    header.biClrUsed = 0;
    header.biXPelsPerMeter = 0;
    header.biYPelsPerMeter = 0;
    header.biPlanes = 1;

    //3 构造文件头
    BITMAPFILEHEADER bmpFileHeader = {0,};
    //HANDLE hFile = NULL;
    DWORD dwTotalWriten = 0;
    DWORD dwWriten;

    bmpFileHeader.bfType = 0x4d42; //'BM';
    bmpFileHeader.bfSize = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER)+ numBytes;
    bmpFileHeader.bfOffBits=sizeof(BITMAPFILEHEADER)+sizeof(BITMAPINFOHEADER);

    FILE* pf = fopen(filename, "wb");
    fwrite(&bmpFileHeader, sizeof(BITMAPFILEHEADER), 1, pf);
    fwrite(&header, sizeof(BITMAPINFOHEADER), 1, pf);
    fwrite(pFrameRGB->data[0], 1, numBytes, pf);
    fclose(pf);


    //释放资源
    //av_free(buffer);
    av_freep(&pFrameRGB[0]);
    av_free(pFrameRGB);
}

static void pgm_save(unsigned char *buf, int wrap, int xsize, int ysize,
                     char *filename)
{
    FILE *f;
    int i;

    f = fopen(filename,"w");
    fprintf(f, "P5\n%d %d\n%d\n", xsize, ysize, 255);
    for (i = 0; i < ysize; i++)
        fwrite(buf + i * wrap, 1, xsize, f);
    fclose(f);
}

static int decode_write_frame(const char *outfilename, AVCodecContext *avctx,
                              struct SwsContext *img_convert_ctx, AVFrame *frame, int *frame_count, AVPacket *pkt, int last)
{
    int len, got_frame;
    char buf[1024];

    len = avcodec_decode_video2(avctx, frame, &got_frame, pkt);
    if (len < 0) {
        fprintf(stderr, "Error while decoding frame %d\n", *frame_count);
        return len;
    }
    if (got_frame) {
        printf("Saving %sframe %3d\n", last ? "last " : "", *frame_count);
        fflush(stdout);

        /* the picture is allocated by the decoder, no need to free it */
        snprintf(buf, sizeof(buf), "%s-%d.bmp", outfilename, *frame_count);
        
        /*
        pgm_save(frame->data[0], frame->linesize[0],
                 frame->width, frame->height, buf);
        */
        
        saveBMP(img_convert_ctx, frame, buf);
        
        (*frame_count)++;
    }
    if (pkt->data) {
        pkt->size -= len;
        pkt->data += len;
    }
    return 0;
}

int main(int argc, char **argv)
{
    int ret;

    FILE *f;

    const char *filename, *outfilename;

    AVFormatContext *fmt_ctx = NULL;

    const AVCodec *codec;
    AVCodecContext *c= NULL;

    AVStream *st = NULL;
    int stream_index;

    int frame_count;
    AVFrame *frame;

    struct SwsContext *img_convert_ctx;

    //uint8_t inbuf[INBUF_SIZE + AV_INPUT_BUFFER_PADDING_SIZE];
    AVPacket avpkt;

    if (argc <= 2) {
        fprintf(stderr, "Usage: %s <input file> <output file>\n", argv[0]);
        exit(0);
    }
    filename    = argv[1];
    outfilename = argv[2];

    /* register all formats and codecs */
    av_register_all();

    /* open input file, and allocate format context */
    if (avformat_open_input(&fmt_ctx, filename, NULL, NULL) < 0) {
        fprintf(stderr, "Could not open source file %s\n", filename);
        exit(1);
    }

    /* retrieve stream information */
    if (avformat_find_stream_info(fmt_ctx, NULL) < 0) {
        fprintf(stderr, "Could not find stream information\n");
        exit(1);
    }

    /* dump input information to stderr */
    av_dump_format(fmt_ctx, 0, filename, 0);

    av_init_packet(&avpkt);

    /* set end of buffer to 0 (this ensures that no overreading happens for damaged MPEG streams) */
    //memset(inbuf + INBUF_SIZE, 0, AV_INPUT_BUFFER_PADDING_SIZE);
    //

    ret = av_find_best_stream(fmt_ctx, AVMEDIA_TYPE_VIDEO, -1, -1, NULL, 0);
    if (ret < 0) {
        fprintf(stderr, "Could not find %s stream in input file '%s'\n",
                av_get_media_type_string(AVMEDIA_TYPE_VIDEO), filename);
        return ret;
    }

    stream_index = ret;
    st = fmt_ctx->streams[stream_index];

    /* find decoder for the stream */
    codec = avcodec_find_decoder(st->codecpar->codec_id);
    if (!codec) {
        fprintf(stderr, "Failed to find %s codec\n",
                av_get_media_type_string(AVMEDIA_TYPE_VIDEO));
        return AVERROR(EINVAL);
    }


    /* find the MPEG-1 video decoder */
    /*
    codec = avcodec_find_decoder(AV_CODEC_ID_MPEG1VIDEO);
    if (!codec) {
        fprintf(stderr, "Codec not found\n");
        exit(1);
    }
    */

    c = avcodec_alloc_context3(NULL);
    if (!c) {
        fprintf(stderr, "Could not allocate video codec context\n");
        exit(1);
    }

    /* Copy codec parameters from input stream to output codec context */
    if ((ret = avcodec_parameters_to_context(c, st->codecpar)) < 0) {
        fprintf(stderr, "Failed to copy %s codec parameters to decoder context\n",
                av_get_media_type_string(AVMEDIA_TYPE_VIDEO));
        return ret;
    }


    /*
    if (codec->capabilities & AV_CODEC_CAP_TRUNCATED)
        c->flags |= AV_CODEC_FLAG_TRUNCATED; // we do not send complete frames
    */

    /* For some codecs, such as msmpeg4 and mpeg4, width and height
       MUST be initialized there because this information is not
       available in the bitstream. */

    /* open it */
    if (avcodec_open2(c, codec, NULL) < 0) {
        fprintf(stderr, "Could not open codec\n");
        exit(1);
    }

    /*
    f = fopen(filename, "rb");
    if (!f) {
        fprintf(stderr, "Could not open %s\n", filename);
        exit(1);
    }
    */

    img_convert_ctx = sws_getContext(c->width, c->height,
                                     c->pix_fmt,
                                     c->width, c->height,
                                     AV_PIX_FMT_RGB24,
                                     SWS_BICUBIC, NULL, NULL, NULL);

    if (img_convert_ctx == NULL)
    {
        fprintf(stderr, "Cannot initialize the conversion context\n");
        exit(1);
    }

    frame = av_frame_alloc();
    if (!frame) {
        fprintf(stderr, "Could not allocate video frame\n");
        exit(1);
    }

    frame_count = 0;
    while (av_read_frame(fmt_ctx, &avpkt) >= 0) {
        /*
        avpkt.size = fread(inbuf, 1, INBUF_SIZE, f);
        if (avpkt.size == 0)
            break;
        */

        /* NOTE1: some codecs are stream based (mpegvideo, mpegaudio)
           and this is the only method to use them because you cannot
           know the compressed data size before analysing it.

           BUT some other codecs (msmpeg4, mpeg4) are inherently frame
           based, so you must call them with all the data for one
           frame exactly. You must also initialize 'width' and
           'height' before initializing them. */

        /* NOTE2: some codecs allow the raw parameters (frame size,
           sample rate) to be changed at any frame. We handle this, so
           you should also take care of it */

        /* here, we use a stream based decoder (mpeg1video), so we
           feed decoder and see if it could decode a frame */
        //avpkt.data = inbuf;
        //while (avpkt.size > 0)
        if(avpkt.stream_index == stream_index){
            if (decode_write_frame(outfilename, c, img_convert_ctx, frame, &frame_count, &avpkt, 0) < 0)
                exit(1);
        }

        av_packet_unref(&avpkt);
    }

    /* Some codecs, such as MPEG, transmit the I- and P-frame with a
       latency of one frame. You must do the following to have a
       chance to get the last frame of the video. */
    avpkt.data = NULL;
    avpkt.size = 0;
    decode_write_frame(outfilename, c, img_convert_ctx, frame, &frame_count, &avpkt, 1);

    fclose(f);

    avformat_close_input(&fmt_ctx);

    sws_freeContext(img_convert_ctx);
    avcodec_free_context(&c);
    av_frame_free(&frame);

    return 0;
}
```  
- 执行程序：clang -g -o encode_video encode_video.c `pkg-config --libs libavcodec`


#### 38.视频转图片

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libswscale/swscale.h>

#define INBUF_SIZE 4096

#define WORD uint16_t
#define DWORD uint32_t
#define LONG int32_t

#pragma pack(2)
typedef struct tagBITMAPFILEHEADER {
  WORD  bfType;
  DWORD bfSize;
  WORD  bfReserved1;
  WORD  bfReserved2;
  DWORD bfOffBits;
} BITMAPFILEHEADER, *PBITMAPFILEHEADER;


typedef struct tagBITMAPINFOHEADER {
  DWORD biSize;
  LONG  biWidth;
  LONG  biHeight;
  WORD  biPlanes;
  WORD  biBitCount;
  DWORD biCompression;
  DWORD biSizeImage;
  LONG  biXPelsPerMeter;
  LONG  biYPelsPerMeter;
  DWORD biClrUsed;
  DWORD biClrImportant;
} BITMAPINFOHEADER, *PBITMAPINFOHEADER;

void saveBMP(struct SwsContext *img_convert_ctx, AVFrame *frame, char *filename)
{
    //1 先进行转换,  YUV420=>RGB24:
    int w = frame->width;
    int h = frame->height;


    int numBytes=avpicture_get_size(AV_PIX_FMT_BGR24, w, h);
    uint8_t *buffer=(uint8_t *)av_malloc(numBytes*sizeof(uint8_t));


    AVFrame *pFrameRGB = av_frame_alloc();
     /* buffer is going to be written to rawvideo file, no alignment */
    /*
    if (av_image_alloc(pFrameRGB->data, pFrameRGB->linesize,
                              w, h, AV_PIX_FMT_BGR24, pix_fmt, 1) < 0) {
        fprintf(stderr, "Could not allocate destination image\n");
        exit(1);
    }
    */
    avpicture_fill((AVPicture *)pFrameRGB, buffer, AV_PIX_FMT_BGR24, w, h);

    sws_scale(img_convert_ctx, frame->data, frame->linesize,
              0, h, pFrameRGB->data, pFrameRGB->linesize);

    //2 构造 BITMAPINFOHEADER
    BITMAPINFOHEADER header;
    header.biSize = sizeof(BITMAPINFOHEADER);


    header.biWidth = w;
    header.biHeight = h*(-1);
    header.biBitCount = 24;
    header.biCompression = 0;
    header.biSizeImage = 0;
    header.biClrImportant = 0;
    header.biClrUsed = 0;
    header.biXPelsPerMeter = 0;
    header.biYPelsPerMeter = 0;
    header.biPlanes = 1;

    //3 构造文件头
    BITMAPFILEHEADER bmpFileHeader = {0,};
    //HANDLE hFile = NULL;
    DWORD dwTotalWriten = 0;
    DWORD dwWriten;

    bmpFileHeader.bfType = 0x4d42; //'BM';
    bmpFileHeader.bfSize = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER)+ numBytes;
    bmpFileHeader.bfOffBits=sizeof(BITMAPFILEHEADER)+sizeof(BITMAPINFOHEADER);

    FILE* pf = fopen(filename, "wb");
    fwrite(&bmpFileHeader, sizeof(BITMAPFILEHEADER), 1, pf);
    fwrite(&header, sizeof(BITMAPINFOHEADER), 1, pf);
    fwrite(pFrameRGB->data[0], 1, numBytes, pf);
    fclose(pf);


    //释放资源
    //av_free(buffer);
    av_freep(&pFrameRGB[0]);
    av_free(pFrameRGB);
}

static void pgm_save(unsigned char *buf, int wrap, int xsize, int ysize,
                     char *filename)
{
    FILE *f;
    int i;

    f = fopen(filename,"w");
    fprintf(f, "P5\n%d %d\n%d\n", xsize, ysize, 255);
    for (i = 0; i < ysize; i++)
        fwrite(buf + i * wrap, 1, xsize, f);
    fclose(f);
}

static int decode_write_frame(const char *outfilename, AVCodecContext *avctx,
                              struct SwsContext *img_convert_ctx, AVFrame *frame, int *frame_count, AVPacket *pkt, int last)
{
    int len, got_frame;
    char buf[1024];

    len = avcodec_decode_video2(avctx, frame, &got_frame, pkt);
    if (len < 0) {
        fprintf(stderr, "Error while decoding frame %d\n", *frame_count);
        return len;
    }
    if (got_frame) {
        printf("Saving %sframe %3d\n", last ? "last " : "", *frame_count);
        fflush(stdout);

        /* the picture is allocated by the decoder, no need to free it */
        snprintf(buf, sizeof(buf), "%s-%d.bmp", outfilename, *frame_count);
        
        /*
        pgm_save(frame->data[0], frame->linesize[0],
                 frame->width, frame->height, buf);
        */
        
        saveBMP(img_convert_ctx, frame, buf);
        
        (*frame_count)++;
    }
    if (pkt->data) {
        pkt->size -= len;
        pkt->data += len;
    }
    return 0;
}

int main(int argc, char **argv)
{
    int ret;

    FILE *f;

    const char *filename, *outfilename;

    AVFormatContext *fmt_ctx = NULL;

    const AVCodec *codec;
    AVCodecContext *c= NULL;

    AVStream *st = NULL;
    int stream_index;

    int frame_count;
    AVFrame *frame;

    struct SwsContext *img_convert_ctx;

    //uint8_t inbuf[INBUF_SIZE + AV_INPUT_BUFFER_PADDING_SIZE];
    AVPacket avpkt;

    if (argc <= 2) {
        fprintf(stderr, "Usage: %s <input file> <output file>\n", argv[0]);
        exit(0);
    }
    filename    = argv[1];
    outfilename = argv[2];

    /* register all formats and codecs */
    av_register_all();

    /* open input file, and allocate format context */
    if (avformat_open_input(&fmt_ctx, filename, NULL, NULL) < 0) {
        fprintf(stderr, "Could not open source file %s\n", filename);
        exit(1);
    }

    /* retrieve stream information */
    if (avformat_find_stream_info(fmt_ctx, NULL) < 0) {
        fprintf(stderr, "Could not find stream information\n");
        exit(1);
    }

    /* dump input information to stderr */
    av_dump_format(fmt_ctx, 0, filename, 0);

    av_init_packet(&avpkt);

    /* set end of buffer to 0 (this ensures that no overreading happens for damaged MPEG streams) */
    //memset(inbuf + INBUF_SIZE, 0, AV_INPUT_BUFFER_PADDING_SIZE);
    //

    ret = av_find_best_stream(fmt_ctx, AVMEDIA_TYPE_VIDEO, -1, -1, NULL, 0);
    if (ret < 0) {
        fprintf(stderr, "Could not find %s stream in input file '%s'\n",
                av_get_media_type_string(AVMEDIA_TYPE_VIDEO), filename);
        return ret;
    }

    stream_index = ret;
    st = fmt_ctx->streams[stream_index];

    /* find decoder for the stream */
    codec = avcodec_find_decoder(st->codecpar->codec_id);
    if (!codec) {
        fprintf(stderr, "Failed to find %s codec\n",
                av_get_media_type_string(AVMEDIA_TYPE_VIDEO));
        return AVERROR(EINVAL);
    }


    /* find the MPEG-1 video decoder */
    /*
    codec = avcodec_find_decoder(AV_CODEC_ID_MPEG1VIDEO);
    if (!codec) {
        fprintf(stderr, "Codec not found\n");
        exit(1);
    }
    */

    c = avcodec_alloc_context3(NULL);
    if (!c) {
        fprintf(stderr, "Could not allocate video codec context\n");
        exit(1);
    }

    /* Copy codec parameters from input stream to output codec context */
    if ((ret = avcodec_parameters_to_context(c, st->codecpar)) < 0) {
        fprintf(stderr, "Failed to copy %s codec parameters to decoder context\n",
                av_get_media_type_string(AVMEDIA_TYPE_VIDEO));
        return ret;
    }


    /*
    if (codec->capabilities & AV_CODEC_CAP_TRUNCATED)
        c->flags |= AV_CODEC_FLAG_TRUNCATED; // we do not send complete frames
    */

    /* For some codecs, such as msmpeg4 and mpeg4, width and height
       MUST be initialized there because this information is not
       available in the bitstream. */

    /* open it */
    if (avcodec_open2(c, codec, NULL) < 0) {
        fprintf(stderr, "Could not open codec\n");
        exit(1);
    }

    /*
    f = fopen(filename, "rb");
    if (!f) {
        fprintf(stderr, "Could not open %s\n", filename);
        exit(1);
    }
    */

    img_convert_ctx = sws_getContext(c->width, c->height,
                                     c->pix_fmt,
                                     c->width, c->height,
                                     AV_PIX_FMT_RGB24,
                                     SWS_BICUBIC, NULL, NULL, NULL);

    if (img_convert_ctx == NULL)
    {
        fprintf(stderr, "Cannot initialize the conversion context\n");
        exit(1);
    }

    frame = av_frame_alloc();
    if (!frame) {
        fprintf(stderr, "Could not allocate video frame\n");
        exit(1);
    }

    frame_count = 0;
    while (av_read_frame(fmt_ctx, &avpkt) >= 0) {
        /*
        avpkt.size = fread(inbuf, 1, INBUF_SIZE, f);
        if (avpkt.size == 0)
            break;
        */

        /* NOTE1: some codecs are stream based (mpegvideo, mpegaudio)
           and this is the only method to use them because you cannot
           know the compressed data size before analysing it.

           BUT some other codecs (msmpeg4, mpeg4) are inherently frame
           based, so you must call them with all the data for one
           frame exactly. You must also initialize 'width' and
           'height' before initializing them. */

        /* NOTE2: some codecs allow the raw parameters (frame size,
           sample rate) to be changed at any frame. We handle this, so
           you should also take care of it */

        /* here, we use a stream based decoder (mpeg1video), so we
           feed decoder and see if it could decode a frame */
        //avpkt.data = inbuf;
        //while (avpkt.size > 0)
        if(avpkt.stream_index == stream_index){
            if (decode_write_frame(outfilename, c, img_convert_ctx, frame, &frame_count, &avpkt, 0) < 0)
                exit(1);
        }

        av_packet_unref(&avpkt);
    }

    /* Some codecs, such as MPEG, transmit the I- and P-frame with a
       latency of one frame. You must do the following to have a
       chance to get the last frame of the video. */
    avpkt.data = NULL;
    avpkt.size = 0;
    decode_write_frame(outfilename, c, img_convert_ctx, frame, &frame_count, &avpkt, 1);

    fclose(f);

    avformat_close_input(&fmt_ctx);

    sws_freeContext(img_convert_ctx);
    avcodec_free_context(&c);
    av_frame_free(&frame);

    return 0;
}
``` 


#### 39.AAC编码

- 编码流程与视频相同
- 编码函数 avcodec_encodec_audio2
    - 1. 添加头文件
    - 2. 注册编解码器
    - 3. 通过名字去找到编码器
    - 4. 设置参数，打开编码器
    - 5. 获取数据包，进行编码

```c
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include <libavcodec/avcodec.h>

#include <libavutil/channel_layout.h>
#include <libavutil/common.h>
#include <libavutil/frame.h>
#include <libavutil/samplefmt.h>

/* check that a given sample format is supported by the encoder */
static int check_sample_fmt(const AVCodec *codec, enum AVSampleFormat sample_fmt)
{
    const enum AVSampleFormat *p = codec->sample_fmts;

    while (*p != AV_SAMPLE_FMT_NONE) {
        if (*p == sample_fmt)
            return 1;
        p++;
    }
    return 0;
}

/* just pick the highest supported samplerate */
static int select_sample_rate(const AVCodec *codec)
{
    const int *p;
    int best_samplerate = 0;

    if (!codec->supported_samplerates)
        return 44100;

    p = codec->supported_samplerates;
    while (*p) {
        if (!best_samplerate || abs(44100 - *p) < abs(44100 - best_samplerate))
            best_samplerate = *p;
        p++;
    }
    return best_samplerate;
}

/* select layout with the highest channel count */
static int select_channel_layout(const AVCodec *codec)
{
    const uint64_t *p;
    uint64_t best_ch_layout = 0;
    int best_nb_channels   = 0;

    if (!codec->channel_layouts)
        return AV_CH_LAYOUT_STEREO;

    p = codec->channel_layouts;
    while (*p) {
        int nb_channels = av_get_channel_layout_nb_channels(*p);

        if (nb_channels > best_nb_channels) {
            best_ch_layout    = *p;
            best_nb_channels = nb_channels;
        }
        p++;
    }
    return best_ch_layout;
}

int main(int argc, char **argv)
{
    const char *filename;
    const AVCodec *codec;
    AVCodecContext *c= NULL;
    AVFrame *frame;
    AVPacket pkt;
    int i, j, k, ret, got_output;
    FILE *f;
    uint16_t *samples;
    float t, tincr;

    if (argc <= 1) {
        fprintf(stderr, "Usage: %s <output file>\n", argv[0]);
        return 0;
    }
    filename = argv[1];

    /* register all the codecs */
    avcodec_register_all();

    /* find the MP2 encoder */
    codec = avcodec_find_encoder(AV_CODEC_ID_MP2);
    if (!codec) {
        fprintf(stderr, "Codec not found\n");
        exit(1);
    }

    c = avcodec_alloc_context3(codec);
    if (!c) {
        fprintf(stderr, "Could not allocate audio codec context\n");
        exit(1);
    }

    /* put sample parameters */
    c->bit_rate = 64000;

    /* check that the encoder supports s16 pcm input */
    c->sample_fmt = AV_SAMPLE_FMT_S16;
    if (!check_sample_fmt(codec, c->sample_fmt)) {
        fprintf(stderr, "Encoder does not support sample format %s",
                av_get_sample_fmt_name(c->sample_fmt));
        exit(1);
    }

    /* select other audio parameters supported by the encoder */
    c->sample_rate    = select_sample_rate(codec);
    c->channel_layout = select_channel_layout(codec);
    c->channels       = av_get_channel_layout_nb_channels(c->channel_layout);

    /* open it */
    if (avcodec_open2(c, codec, NULL) < 0) {
        fprintf(stderr, "Could not open codec\n");
        exit(1);
    }

    f = fopen(filename, "wb");
    if (!f) {
        fprintf(stderr, "Could not open %s\n", filename);
        exit(1);
    }

    /* frame containing input raw audio */
    frame = av_frame_alloc();
    if (!frame) {
        fprintf(stderr, "Could not allocate audio frame\n");
        exit(1);
    }

    frame->nb_samples     = c->frame_size;
    frame->format         = c->sample_fmt;
    frame->channel_layout = c->channel_layout;

    /* allocate the data buffers */
    ret = av_frame_get_buffer(frame, 0);
    if (ret < 0) {
        fprintf(stderr, "Could not allocate audio data buffers\n");
        exit(1);
    }

    /* encode a single tone sound */
    t = 0;
    tincr = 2 * M_PI * 440.0 / c->sample_rate;
    for (i = 0; i < 200; i++) {
        av_init_packet(&pkt);
        pkt.data = NULL; // packet data will be allocated by the encoder
        pkt.size = 0;

        /* make sure the frame is writable -- makes a copy if the encoder
         * kept a reference internally */
        ret = av_frame_make_writable(frame);
        if (ret < 0)
            exit(1);
        samples = (uint16_t*)frame->data[0];

        for (j = 0; j < c->frame_size; j++) {
            samples[2*j] = (int)(sin(t) * 10000);

            for (k = 1; k < c->channels; k++)
                samples[2*j + k] = samples[2*j];
            t += tincr;
        }
        /* encode the samples */
        ret = avcodec_encode_audio2(c, &pkt, frame, &got_output);
        if (ret < 0) {
            fprintf(stderr, "Error encoding audio frame\n");
            exit(1);
        }
        if (got_output) {
            fwrite(pkt.data, 1, pkt.size, f);
            av_packet_unref(&pkt);
        }
    }

    /* get the delayed frames */
    for (got_output = 1; got_output; i++) {
        ret = avcodec_encode_audio2(c, &pkt, NULL, &got_output);
        if (ret < 0) {
            fprintf(stderr, "Error encoding frame\n");
            exit(1);
        }

        if (got_output) {
            fwrite(pkt.data, 1, pkt.size, f);
            av_packet_unref(&pkt);
        }
    }
    fclose(f);

    av_frame_free(&frame);
    avcodec_free_context(&c);

    return 0;
}
```  


#### 40.SDL简介、编译与安装

- SDL，全称：Simple DirectMedia Layer
- 由C语言实现的跨平台的媒体开源库
- 多用于开发游戏、模拟器、媒体播放器等多媒体应用领域
- 官网：https://www.libsdl.org
- 安装编译：
    - 1. 下载SDL源码
    - 2. 生成Makefile configure --prefix=/usr/local  （--prefix即为安装目录在哪儿）
    - 3. 安装 sudo make -j 8 && make install (-j 8 的是意思是开8个线程同时进行操作，即内核*2)


#### 41.SDL的使用步骤

- 添加头文件 #include<SDL.h>
- 初始化SDL
- 退出SDL
- SDL主要用来渲染窗口
    - SDL_Init() / SDL——Quit()
    - SDL_CreateWindow() / SDL_DestroyWindow()
    - SDL_CreateRender() 创建渲染器，将图片渲染帧渲染到上边

```c
#include <SDL.h>
#include <stdio.h>

int main(int argc, char* argv[]) {
    SDL_Window *window = NULL:];
    // 初始化
    SDL_Init(SDL_INIT_VIDEO);
    // 创建窗口
    window = SDL_CreateWindow("SDL2 Window", 200, 200, 640, 480, SDL_WINDOW_SHOWN); // name,x,y,height,width,option
    if (!window) {
        printf("Failed to Create Window!");
        goto __EXIT;
    }
    SDL_DestroyWindow(window);
    __EXIT;
    // 退出
    SDL_Quit();
    return 0;
}
// 创建的窗口实际上是在内存上分配的空间，要显示的话需要将内容推动到显卡驱动上
```  
- 执行：clang -g -o firstsdl firstsdl.c `pkg-config --cflags --libs sdl2`


#### 42.SDL渲染窗口
- SDL_CreateRenderer / SDL_DestroyRenderer
- SDL_RenderClear
- SDL_RenderPresent 推送数据包

```c
#include <SDL.h>
#include <stdio.h>

int main(int argc, char* argv[]) {
    SDL_Window *window = NULL;
    SDL_Renderer *render = NULL;
    // 初始化
    SDL_Init(SDL_INIT_VIDEO);
    // 创建窗口
    window = SDL_CreateWindow("SDL2 Window", 200, 200, 640, 480, SDL_WINDOW_SHOWN); // name,x,y,height,width,option
    if (!window) {
        printf("Failed to Create Window!");
        goto __EXIT;
    }
    // 创建渲染器
    render = SDL_CreateRenderer(window, -1, 0);
    if (!render) {
        SDL_Log("Faild to Create Render!");
        goto __DWINDOW;
    }
    SDL_SetRenderDrawColor(render, 255, 0, 0, 255); // rgba
    // 清屏缓存
    SDL_RenderClear(render);
    // 推送到显卡
    SDL_RenderPresent(render);
    // 这里是延迟，为了看到效果
    SDL_Delay(30000);
    // 销毁窗口
__DWINDOW:
    SDL_DestroyWindow(window);
    // 退出
__EXIT:
    SDL_Quit();
    return 0;
}
```  
- 执行：clang -g -o firstsdl firstsdl.c `pkg-config --cflags --libs sdl2`


#### 43.SDL处理事件基本原理
- SDL将所有的事件都存放到一个队列中
- 所有对事件的操作，其实就是对队列的操作
- SDL事件分类
    - SDL_WIndowEvent: 窗口事件
    - SDL_KeyboardEvent: 键盘事件
    - SDL_MouseMotionEvent: 鼠标事件
- SDL事件处理
    - SDL_PollEvent 轮循队列处理事件
    - SDL_WaitEvent 事件触发机制

```c
#include <SDL.h>
#include <stdio.h>

int main(int argc, char* argv[]) {
    int quit = 1;
    SDL_Event event;
    SDL_Window *window = NULL;
    SDL_Renderer *render = NULL;
    // 初始化
    SDL_Init(SDL_INIT_VIDEO);
    // 创建窗口
    window = SDL_CreateWindow("SDL2 Window", 200, 200, 640, 480, SDL_WINDOW_SHOWN); // name,x,y,height,width,option
    if (!window) {
        printf("Failed to Create Window!");
        goto __EXIT;
    }
    // 创建渲染器
    render = SDL_CreateRenderer(window, -1, 0);
    if (!render) {
        SDL_Log("Faild to Create Render!");
        goto __DWINDOW;
    }
    SDL_SetRenderDrawColor(render, 255, 0, 0, 255); // rgba
    // 清屏缓存
    SDL_RenderClear(render);
    // 推送到显卡
    SDL_RenderPresent(render);
    do {
        SDL_WaitEvent(&event);
        switch(event.type) {
            case SDL_QUIT:
                quit = 0;
                break;
            default:
                SDL_Log("event type is %d", event.type);
        }
    } while(quit);
    // 销毁窗口
__DWINDOW:
    SDL_DestroyWindow(window);
    // 退出
__EXIT:
    SDL_Quit();
    return 0;
}
```
- 执行：clang -g -o eventsdl eventsdl.c `pkg-config --cflags --libs sdl2`


#### 44.纹理渲染

- 内存图像 --（渲染器）-- 纹理 --（交换：显卡计算）-- 窗口展示
- 纹理相关的API
    - SDL_CreateTexture()
        - format: YUV,GRB
        - access: Texture类型、Target，Stream
    - SDL_DestroyTexture()
- 渲染相关的API
    - SDL_SetRenderTarget()  // 设置渲染目标
    - SDL_RenderClear()
    - SDL_RenderCopy()
    - SDL_RenderPresent() // 控制渲染

```c
#include <SDL.h>
#include <stdio.h>

int main(int argc, char* argv[]) {
    int quit = 1;
    SDL_Rect rect;
    rect.w = 30;
    rect.h = 30;
    SDL_Event event;
    SDL_Texture *texture = NULL;
    SDL_Window *window = NULL;
    SDL_Renderer *render = NULL;
    // 初始化
    SDL_Init(SDL_INIT_VIDEO);
    // 创建窗口
    window = SDL_CreateWindow("SDL2 Window", 200, 200, 640, 480, SDL_WINDOW_SHOWN); // name,x,y,height,width,option
    if (!window) {
        printf("Failed to Create Window!");
        goto __EXIT;
    }
    // 创建渲染器
    render = SDL_CreateRenderer(window, -1, 0);
    if (!render) {
        SDL_Log("Faild to Create Render!");
        goto __DWINDOW;
    }
    // 创建纹理
    texture = SDL_CreateTexture(render, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, 640, 480);
    if (!texture) {
        SDL_Log("Failed to Create Texture!");
        goto __RENDER;
    }
    do {
        SDL_PollEvent(&event);
        switch(event.type) {
            case SDL_QUIT:
                quit = 0;
                break;
            default:
                SDL_Log("event type is %d", event.type);
        }
        // 创建方块
        rect.x = rand() % 600;
        rect.y = rand() % 450;
        SDL_SetRenderTarget(render, texture);
        SDL_SetRenderDrawColor(render, 0, 0, 0, 0);
        SDL_RenderClear(render);
        // 绘制方块
        SDL_RenderDrawRect(render, &rect);
        SDL_SetRenderDrawColor(render, 255, 0, 0, 0);
        SDL_RenderFillRect(render, &rect);
        // 推送到显卡
        SDL_SetRenderTarget(render, NULL);
        SDL_RenderCopy(render, texture, NULL, NULL); // 拷贝描述文件到显卡驱动
        SDL_RenderPresent(render); // 告诉显卡让其显示她已经按照描述文件绘制好的图像显示到屏幕上
    } while(quit);
    // 销毁纹理
__RENDER:
    SDL_DestroyTexture(texture);
    // 销毁窗口
__DWINDOW:
    SDL_DestroyWindow(window);
    // 退出
__EXIT:
    SDL_Quit();
    return 0;
}
```
- 执行：clang -g -o texturesdl texturesdl.c `pkg-config --cflags --libs sdl2`


#### 45.YUV播放器
- 创建线程
    - SDL_CreateThread
        - fn: 线程执行函数
        - name: 线程名
        - data: 执行函数参数
- 更新纹理
    - SDL_UpdateTexture()
    - SDL_UpdateYUVTexture()  // 需要每一个分量的数据
```c
#include <stdio.h>
#include <string.h>

#include <SDL.h>

const int bpp=12;

int screen_w=500,screen_h=500;

#define BLOCK_SIZE 4096000

//event message
#define REFRESH_EVENT  (SDL_USEREVENT + 1)
#define QUIT_EVENT  (SDL_USEREVENT + 2)

int thread_exit=0;

int refresh_video_timer(void *udata){

    thread_exit=0;

    while (!thread_exit) {
        SDL_Event event;
        event.type = REFRESH_EVENT;
        SDL_PushEvent(&event);
        SDL_Delay(40);
    }

    thread_exit=0;

    //push quit event
    SDL_Event event;
    event.type = QUIT_EVENT;
    SDL_PushEvent(&event);

    return 0;
}

int main(int argc, char* argv[])
{

    FILE *video_fd = NULL;

    SDL_Event event;
    SDL_Rect rect;

    Uint32 pixformat = 0;

    SDL_Window *win = NULL;
    SDL_Renderer *renderer = NULL;
    SDL_Texture *texture = NULL;

    SDL_Thread *timer_thread = NULL;

    int w_width = 640; w_height = 480;
    const int video_width = 320, video_height = 180;

    Uint8 *video_pos = NULL;
    Uint8 *video_end = NULL;

    unsigned int remain_len = 0;
    unsigned int video_buff_len = 0;
    unsigned int blank space_len = 0;
    Uint8 *video_buf[BLOCK_SIZE];

    const char *path = "test_yuv420p_320x180.yuv";

    const unsigned int yuv_frame_len = video_width * video_height * 12 / 8;

    //initialize SDL
    if(SDL_Init(SDL_INIT_VIDEO)) {
        fprintf( stderr, "Could not initialize SDL - %s\n", SDL_GetError());
        return -1;
    }

    //creat window from SDL
    win = SDL_CreateWindow("YUV Player",
                           SDL_WINDOWPOS_UNDEFINED,
                           SDL_WINDOWPOS_UNDEFINED,
                           w_width, w_height,
                           SDL_WINDOW_OPENGL|SDL_WINDOW_RESIZABLE);
    if(!win) {
        fprintf(stderr, "Failed to create window, %s\n",SDL_GetError());
        goto __FAIL;
    }

    renderer = SDL_CreateRenderer(screen, -1, 0);

    //IYUV: Y + U + V  (3 planes)
    //YV12: Y + V + U  (3 planes)
    pixformat= SDL_PIXELFORMAT_IYUV;

    //create texture for render
    texture = SDL_CreateTexture(renderer,
                                pixformat,
                                SDL_TEXTUREACCESS_STREAMING,
                                video_width,
                                video_height);

    //open yuv file
    video_fd = fopen(path, "r");
    if( !video_fd ){
        fprintf(stderr, "Failed to open yuv file\n");
        goto __FAIL;
    }

    //read block data
    if(video_buff_len = fread(video_buf, 1, BLOCK_SIZE, video_fd) <= 0){
        fprintf(stderr, "Failed to read data from yuv file!\n");
        goto __FAIL;
    }

    //set video positon
    video_pos = video_buf;
    video_end = video_buf + video_buff_len;
    blank_space_len = BLOCK_SIZE - video_buff_len;

    timer_thread = SDL_CreateThread(refresh_video_timer,
                                    NULL,
                                    NULL);

    do {
        //Wait
        SDL_WaitEvent(&event);
        if(event.type==REFRESH_EVENT){
            //not enought data to render
            if((video_pos + yuv_frame_len) > video_end){

                //have remain data, but there isn't space
                remain_len = video_end - video_pos;
                if(remain_len && !black_space_len) {
                    //copy data to header of buffer
                    memcpy(video_buf, video_pos, remain_len);

                    blank_space_len = BLOCK_SIZE - remain_len;
                    video_pos = video_buf;
                    video_end = video_buf + remain_len;
                }

                //at the end of buffer, so rotate to header of buffer
                if(video_end == (video_buf + BLOCK_SIZE)){
                    video_pos = video_buf;
                    video_end = video_buf;
                    blank_space_len = BLOCK_SIZE;
                }

                //read data from yuv file to buffer
                if(video_buff_len = fread(video_end, 1, blank_space_len, video_fd) <= 0){
                    fprintf(stderr, "eof, exit thread!");
                    thread_exit = 1;
                    continue;// to wait event for exiting
                }

                //reset video_end
                video_end += video_buff_len;
            }

            SDL_UpdateTexture( texture, NULL, video_pos, video_width);

            //FIX: If window is resize
            rect.x = 0;
            rect.y = 0;
            rect.w = w_width;
            rect.h = w_height;

            SDL_RenderClear( renderer );
            SDL_RenderCopy( renderer, texture, NULL, &rect);
            SDL_RenderPresent( renderer );

        }else if(event.type==SDL_WINDOWEVENT){
            //If Resize
            SDL_GetWindowSize(win, &w_width, &w_height);
        }else if(event.type==SDL_QUIT){
            thread_exit=1;
        }else if(event.type==QUIT_EVENT){
            break;
        }
    }while ( 1 );

__FAIL:

    //close file
    if(video_fd){
        fclose(video_fd);
    }

    SDL_Quit();

    return 0;
}
```  


#### 46.SDL播放音频

- 将多媒体文件分解成音频轨、视频轨、字幕轨等等（解复用）
- 视频轨解码成yuv数据
    - 将yuv数据输送给SDL
    - SDL将yuv数据输送到显卡
    - 显卡显示到屏幕
- 音频轨解码成pcm数据
    - 将pcm数据输送给SDL
    - SDL驱动声卡将声音播放出来
- 播放音频基本流程
    - 1. 打开音频设备
    - 2. 设置音频参数 // 通道数、采样率、采样大小
    - 3. 向声卡喂数据
    - 4. 播放音频
    - 5. 关闭设备
- 播放音频的基本原则
    - 声卡向你要数据而不是你主动推给声卡
    - 数据的多少是由音频参数决定的
- SDL音频API
    - SDL_OpenAudio / SDL_CloseAudio
    - SDL_PauseAudio 暂停播放
    - SDL_MixAudio  混音
```c
#include <libavutil/log.h>
#include <libavformat/avformat.h>

int main(int argc, char* argv[]) {
    return 0;
}
```  


#### 47.PCM音频播放器

```c
#include <SDL.h>
#define BLOCK_SIZE 4096000
static size_t buffer_len = 0;
static Uint8 *audio_buf = NULL;
static Uint8 *audio_pos = NULL:

// 声卡主动读取数据的回调函数
void read_audio_data(void *udata, Uint8 *stream, int len) {
    // 判断当前文件数据是否读区完
    if (buffer_len == 0) {
        return;
    }
    // 清空声卡SDL缓存数据，防止音质变差
    SDL_memset(stream, 0, len);
    // 判断读取数据，如果需要的数据小于缓存数据，则取读取数据大小，反之取我们定义的缓冲大小
    len = (len < buffer_len) ? len : buffer_len;
    // 混音拷贝
    SDL_MixAudio(stream, audio_pos, len, SDL_MIX_MAXVOLUME);
    // 修改读取之后的缓冲区的位置信息
    audio_pos += len;
    buffer_len -= len;
}

int main(int argc, char* argv[]) {
    int ret = -1;
    char *path = "./1.pcm";
    FILE* audio_fd = NULL:

    // 初始化SDL
    if (SDL_Init(SDL_INIT_AUDIO | SDL_INIT_TIMER)) {
        SDL_Log("Failed to initial!");
        return ret;
    };

    // 打开pcm文件
    audio_fd = fopen(path, "r");
    if (!audio_fd) {
        SDL_Log("Failed to open audio file!");
        goto __FAIL;
    }
    
    // 分配空间
    audio_buf = (Uint8*)malloc(BLOCK_SIZE);
    if (!audio_buf) {
        SDL_Log("Failed to alloc memory!");
        goto __FAIL;
    }
    
    // 打开音频设备
    SDL_AudioSpec spec;
    spec.freq = 44100; // 采样率
    spec.channels = 2; // 通道数
    spec.format = AUDIO_S16SYS; // 采样大小
    spec.silence = 0;
    spec.callback = read_audio_data; // 声卡要数据的回调函数
    spec.userdata = NULL; // 声卡回调参数
    if(SDL_OpenAudio(&spec, NULL)) {
        SDL_Log("Failed to open audio device!");
        goto __FAIL;
    }
    
    // 启动播放
    SDL_PauseAudio(0); // 0是播放，1是暂停
    
    // 循环读取文件数据到缓冲区
    do {
        buffer_len = fread(audio_buf, 1, BLOCK_SIZE, audio_fd);
        audio_pos = audio_buf;
        while (audio_pos < (audio_buf + buffer_len)) { // 判断buffer里是否还有数据
            SDL_Delay(1);
        }
    } while (buffer_len != 0);
    
    // 关闭音频设备
    SDL_CloseAudio();
    ret = 0;

    // 关闭SDL和pcm文件、释放空间
__FAIL:
    if (audio_buf) {
        free(audio_buf);
    }
    if (audio_fd) {
        fclose(audio_fd);
    }
    SDL_Quit();
    return ret;
}
```  
- 执行：clang -g -o pcmplay pcmplay.c `pkg-config --cflags --libs sdl2`


#### 48.实现一个最简单的播放器

- 只实现播放
- 将ffmpeg与SDL结合
- 通过ffmpeg解码视频数据
- 通过SDL进行渲染

```c
#include <stdio.h>
#include <SDL.h>

#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>

// compatibility with newer API
#if LIBAVCODEC_VERSION_INT < AV_VERSION_INT(55,28,1)
#define av_frame_alloc avcodec_alloc_frame
#define av_frame_free avcodec_free_frame
#endif

int main(int argc, char *argv[]) {

  int ret = -1;

  AVFormatContext *pFormatCtx = NULL; //for opening multi-media file

  int             i, videoStream;

  AVCodecContext  *pCodecCtxOrig = NULL; //codec context
  AVCodecContext  *pCodecCtx = NULL;

  struct SwsContext *sws_ctx = NULL;

  AVCodec         *pCodec = NULL; // the codecer
  AVFrame         *pFrame = NULL;
  AVPacket        packet;

  int             frameFinished;
  float           aspect_ratio;

  AVPicture  	  *pict  = NULL;

  SDL_Rect        rect;
  Uint32 	  pixformat; 

  //for render
  SDL_Window 	  *win = NULL;
  SDL_Renderer    *renderer = NULL;
  SDL_Texture     *texture = NULL;

  //set defualt size of window 
  int w_width = 640;
  int w_height = 480;

  if(argc < 2) {
    //fprintf(stderr, "Usage: command <file>\n");
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Usage: command <file>");
    return ret;
  }

  if(SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_TIMER)) {
    //fprintf(stderr, "Could not initialize SDL - %s\n", SDL_GetError());
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Could not initialize SDL - %s\n", SDL_GetError());
    return ret;
  }

  //Register all formats and codecs
  av_register_all();

  // Open video file
  if(avformat_open_input(&pFormatCtx, argv[1], NULL, NULL)!=0){
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Failed to open video file!");
    goto __FAIL; // Couldn't open file
  }
  
  // Retrieve stream information
  if(avformat_find_stream_info(pFormatCtx, NULL)<0){
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Failed to find stream infomation!");
    goto __FAIL; // Couldn't find stream information
  }
  
  // Dump information about file onto standard error
  av_dump_format(pFormatCtx, 0, argv[1], 0);
  
  // Find the first video stream
  videoStream=-1;
  for(i=0; i<pFormatCtx->nb_streams; i++) {
    if(pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO) {
      videoStream=i;
      break;
    }
  }

  if(videoStream==-1){
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Din't find a video stream!");
    goto __FAIL;// Didn't find a video stream
  }
  
  // Get a pointer to the codec context for the video stream
  pCodecCtxOrig=pFormatCtx->streams[videoStream]->codec;

  // Find the decoder for the video stream
  pCodec=avcodec_find_decoder(pCodecCtxOrig->codec_id);
  if(pCodec==NULL) {
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Unsupported codec!\n");
    goto __FAIL; // Codec not found
  }

  // Copy context
  pCodecCtx = avcodec_alloc_context3(pCodec);
  if(avcodec_copy_context(pCodecCtx, pCodecCtxOrig) != 0) {
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION,  "Couldn't copy codec context");
    goto __FAIL;// Error copying codec context
  }

  // Open codec
  if(avcodec_open2(pCodecCtx, pCodec, NULL)<0) {
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Failed to open decoder!\n");
    goto __FAIL; // Could not open codec
  }
  
  // Allocate video frame
  pFrame=av_frame_alloc();

  w_width = pCodecCtx->width;
  w_height = pCodecCtx->height;

  win = SDL_CreateWindow( "Media Player",
		          SDL_WINDOWPOS_UNDEFINED,
		  	  SDL_WINDOWPOS_UNDEFINED,
			  w_width, w_height,
			  SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE);	  
  if(!win){
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Failed to create window by SDL");  
    goto __FAIL;
  }

  renderer = SDL_CreateRenderer(win, -1, 0);
  if(!renderer){
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Failed to create Renderer by SDL");  
    goto __FAIL;
  }

  pixformat = SDL_PIXELFORMAT_IYUV;
  texture = SDL_CreateTexture(renderer,
		    pixformat, 
		    SDL_TEXTUREACCESS_STREAMING,
		    w_width, 
		    w_height);

  // initialize SWS context for software scaling
  sws_ctx = sws_getContext(pCodecCtx->width,
			   pCodecCtx->height,
			   pCodecCtx->pix_fmt,
			   pCodecCtx->width,
			   pCodecCtx->height,
			   AV_PIX_FMT_YUV420P,
			   SWS_BILINEAR,
			   NULL,
			   NULL,
			   NULL
			   );

  pict = (AVPicture*)malloc(sizeof(AVPicture));
  avpicture_alloc(pict, 
		  AV_PIX_FMT_YUV420P, 
		  pCodecCtx->width, 
		  pCodecCtx->height);


  // Read frames and save first five frames to disk
  while(av_read_frame(pFormatCtx, &packet)>=0) {
    // Is this a packet from the video stream?
    if(packet.stream_index==videoStream) {
      // Decode video frame
      avcodec_decode_video2(pCodecCtx, pFrame, &frameFinished, &packet);
      
      // Did we get a video frame?
      if(frameFinished) {

	// Convert the image into YUV format that SDL uses
	sws_scale(sws_ctx, (uint8_t const * const *)pFrame->data,
		  pFrame->linesize, 0, pCodecCtx->height,
		  pict->data, pict->linesize);

	SDL_UpdateYUVTexture(texture, NULL, 
			     pict->data[0], pict->linesize[0],
			     pict->data[1], pict->linesize[1],
			     pict->data[2], pict->linesize[2]);
	
	// Set Size of Window
	rect.x = 0;
	rect.y = 0;
	rect.w = pCodecCtx->width;
	rect.h = pCodecCtx->height;

	SDL_RenderClear(renderer);
	SDL_RenderCopy(renderer, texture, NULL, &rect);
	SDL_RenderPresent(renderer);

      }
    }
    
    // Free the packet that was allocated by av_read_frame
    av_free_packet(&packet);

    /*
    SDL_Event event;
    SDL_PollEvent(&event);
    switch(event.type) {
    case SDL_QUIT:
      goto __QUIT;
      break;
    default:
      break;
    }
    */

  }

__QUIT:
  ret = 0;
  
__FAIL:
  // Free the YUV frame
  if(pFrame){
    av_frame_free(&pFrame);
  }
  
  // Close the codec
  if(pCodecCtx){
    avcodec_close(pCodecCtx);
  }

  if(pCodecCtxOrig){
    avcodec_close(pCodecCtxOrig);
  }
  
  // Close the video file
  if(pFormatCtx){
    avformat_close_input(&pFormatCtx);
  }

  if(pict){
    avpicture_free(pict);
    free(pict);
  }

  if(win){
    SDL_DestroyWindow(win);
  }

  if(renderer){
    SDL_DestroyRenderer(renderer);
  }

  if(texture){
    SDL_DestroyTexture(texture);
  }

  SDL_Quit();
  
  return ret;
}
```
- 执行：clang -g -o player2va player2va.c `pkg-config --cflags --libs sdl2 libavutil libavformat libavcodec libswscale`


#### 49.实现一个最简单的播放器（支持视频和音频）

```c
#include <stdio.h>
#include <assert.h>

#include <SDL.h>

#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#include <libswresample/swresample.h>

// compatibility with newer API
#if LIBAVCODEC_VERSION_INT < AV_VERSION_INT(55,28,1)
#define av_frame_alloc avcodec_alloc_frame
#define av_frame_free avcodec_free_frame
#endif

#define SDL_AUDIO_BUFFER_SIZE 1024
#define MAX_AUDIO_FRAME_SIZE 192000

struct SwrContext *audio_convert_ctx = NULL;

typedef struct PacketQueue {
  AVPacketList *first_pkt, *last_pkt;
  int nb_packets;
  int size;
  SDL_mutex *mutex;
  SDL_cond *cond;
} PacketQueue;

PacketQueue audioq;

int quit = 0;

void packet_queue_init(PacketQueue *q) {
  memset(q, 0, sizeof(PacketQueue));
  q->mutex = SDL_CreateMutex();
  q->cond = SDL_CreateCond();
}

int packet_queue_put(PacketQueue *q, AVPacket *pkt) {

  AVPacketList *pkt1;
  if(av_dup_packet(pkt) < 0) {
    return -1;
  }
  pkt1 = av_malloc(sizeof(AVPacketList));
  if (!pkt1)
    return -1;
  pkt1->pkt = *pkt;
  pkt1->next = NULL;
  
  SDL_LockMutex(q->mutex);
  
  if (!q->last_pkt) {
    q->first_pkt = pkt1;
  }else{
    q->last_pkt->next = pkt1;
  }

  q->last_pkt = pkt1;
  q->nb_packets++;
  q->size += pkt1->pkt.size;
  SDL_CondSignal(q->cond);
  
  SDL_UnlockMutex(q->mutex);
  return 0;
}

int packet_queue_get(PacketQueue *q, AVPacket *pkt, int block)
{
  AVPacketList *pkt1;
  int ret;
  
  SDL_LockMutex(q->mutex);
  
  for(;;) {
    
    if(quit) {
      ret = -1;
      break;
    }

    pkt1 = q->first_pkt;
    if (pkt1) {
      q->first_pkt = pkt1->next;
      if (!q->first_pkt)
	q->last_pkt = NULL;
      q->nb_packets--;
      q->size -= pkt1->pkt.size;
      *pkt = pkt1->pkt;
      av_free(pkt1);
      ret = 1;
      break;
    } else if (!block) {
      ret = 0;
      break;
    } else {
      SDL_CondWait(q->cond, q->mutex);
    }
  }
  SDL_UnlockMutex(q->mutex);
  return ret;
}

int audio_decode_frame(AVCodecContext *aCodecCtx, uint8_t *audio_buf, int buf_size) {

  static AVPacket pkt;
  static uint8_t *audio_pkt_data = NULL;
  static int audio_pkt_size = 0;
  static AVFrame frame;

  int len1, data_size = 0;

  for(;;) {
    while(audio_pkt_size > 0) {
      int got_frame = 0;
      len1 = avcodec_decode_audio4(aCodecCtx, &frame, &got_frame, &pkt);
      if(len1 < 0) {
	/* if error, skip frame */
	audio_pkt_size = 0;
	break;
      }
      audio_pkt_data += len1;
      audio_pkt_size -= len1;
      data_size = 0;
      if(got_frame) {
        //fprintf(stderr, "channels:%d, nb_samples:%d, sample_fmt:%d \n", aCodecCtx->channels, frame.nb_samples, aCodecCtx->sample_fmt);
        /*
	data_size = av_samples_get_buffer_size(NULL, 
					       aCodecCtx->channels,
					       frame.nb_samples,
					       aCodecCtx->sample_fmt,
					       1);
        */
	data_size = 2 * 2 * frame.nb_samples;
 
	assert(data_size <= buf_size);
	swr_convert(audio_convert_ctx,
		    &audio_buf,
		    MAX_AUDIO_FRAME_SIZE*3/2,
		    (const uint8_t **)frame.data,
		    frame.nb_samples);

	//memcpy(audio_buf, frame.data[0], data_size);
      }
      if(data_size <= 0) {
	/* No data yet, get more frames */
	continue;
      }
      /* We have data, return it and come back for more later */
      return data_size;
    }
    if(pkt.data)
      av_free_packet(&pkt);

    if(quit) {
      return -1;
    }

    if(packet_queue_get(&audioq, &pkt, 1) < 0) {
      return -1;
    }
    audio_pkt_data = pkt.data;
    audio_pkt_size = pkt.size;
  }
}

void audio_callback(void *userdata, Uint8 *stream, int len) {

  AVCodecContext *aCodecCtx = (AVCodecContext *)userdata;
  int len1, audio_size;

  static uint8_t audio_buf[(MAX_AUDIO_FRAME_SIZE * 3) / 2];
  static unsigned int audio_buf_size = 0;
  static unsigned int audio_buf_index = 0;

  while(len > 0) {
    if(audio_buf_index >= audio_buf_size) {
      /* We have already sent all our data; get more */
      audio_size = audio_decode_frame(aCodecCtx, audio_buf, sizeof(audio_buf));
      if(audio_size < 0) {
	/* If error, output silence */
	audio_buf_size = 1024; // arbitrary?
	memset(audio_buf, 0, audio_buf_size);
      } else {
	audio_buf_size = audio_size;
      }
      audio_buf_index = 0;
    }
    len1 = audio_buf_size - audio_buf_index;
    if(len1 > len)
      len1 = len;
    fprintf(stderr, "index=%d, len1=%d, len=%d\n",
		    audio_buf_index,
		    len,
                    len1);
    memcpy(stream, (uint8_t *)audio_buf + audio_buf_index, len1);
    len -= len1;
    stream += len1;
    audio_buf_index += len1;
  }
}

int main(int argc, char *argv[]) {

  int  		  ret = -1;
  int             i, videoStream, audioStream;

  AVFormatContext *pFormatCtx = NULL;

  //for video decode
  AVCodecContext  *pCodecCtxOrig = NULL;
  AVCodecContext  *pCodecCtx = NULL;
  AVCodec         *pCodec = NULL;

  struct SwsContext *sws_ctx = NULL;
  
  AVPicture	  *pict = NULL;
  AVFrame         *pFrame = NULL;
  AVPacket        packet;
  int             frameFinished;

  //for audio decode
  AVCodecContext  *aCodecCtxOrig = NULL;
  AVCodecContext  *aCodecCtx = NULL;
  AVCodec         *aCodec = NULL;
 

  int64_t in_channel_layout;
  int64_t out_channel_layout;

  //for video render
  int		  w_width = 640;
  int 		  w_height = 480;

  int             pixformat;
  SDL_Rect        rect;

  SDL_Window      *win;
  SDL_Renderer    *renderer;
  SDL_Texture     *texture;

  //for event
  SDL_Event       event;

  //for audio
  SDL_AudioSpec   wanted_spec, spec;

  if(argc < 2) {
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Usage: command <file>");
    return ret;
  }

  // Register all formats and codecs
  av_register_all();
  
  if(SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_TIMER)) {
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Could not initialize SDL - %s\n", SDL_GetError());
    return ret;
  }

  // Open video file
  if(avformat_open_input(&pFormatCtx, argv[1], NULL, NULL)!=0) {
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Failed to open multi-media file");
    goto __FAIL; // Couldn't open file
  }
  
  // Retrieve stream information
  if(avformat_find_stream_info(pFormatCtx, NULL)<0) {
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Couldn't find stream information ");
    goto __FAIL;  
  }
  
  // Dump information about file onto standard error
  av_dump_format(pFormatCtx, 0, argv[1], 0);
    
  // Find the first video stream
  videoStream=-1;
  audioStream=-1;

  for(i=0; i<pFormatCtx->nb_streams; i++) {
    if(pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO &&
       videoStream < 0) {
      videoStream=i;
    }
    if(pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_AUDIO &&
       audioStream < 0) {
      audioStream=i;
    }
  }

  if(videoStream==-1) {
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, " Didn't find a video stream ");
    goto __FAIL; // Didn't find a video stream
  }

  if(audioStream==-1) {
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, " Didn't find a audio stream ");
    goto __FAIL; // Didn't find a video stream
  }
   
  aCodecCtxOrig=pFormatCtx->streams[audioStream]->codec;
  aCodec = avcodec_find_decoder(aCodecCtxOrig->codec_id);
  if(!aCodec) {
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Unsupported codec! ");
    goto __FAIL; // Didn't find a video stream
  }

  // Copy context
  aCodecCtx = avcodec_alloc_context3(aCodec);
  if(avcodec_copy_context(aCodecCtx, aCodecCtxOrig) != 0) {
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Couldn't copy codec context! ");
    goto __FAIL; // Didn't find a video stream
  }

  // Set audio settings from codec info
  wanted_spec.freq = aCodecCtx->sample_rate;
  wanted_spec.format = AUDIO_S16SYS;
  wanted_spec.channels = aCodecCtx->channels;
  wanted_spec.silence = 0;
  wanted_spec.samples = SDL_AUDIO_BUFFER_SIZE;
  wanted_spec.callback = audio_callback;
  wanted_spec.userdata = aCodecCtx;
  
  if(SDL_OpenAudio(&wanted_spec, &spec) < 0) {
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Failed to open audio device - %s!", SDL_GetError());
    goto __FAIL;
  }

  avcodec_open2(aCodecCtx, aCodec, NULL);

  packet_queue_init(&audioq);

  in_channel_layout = av_get_default_channel_layout(aCodecCtx->channels);
  out_channel_layout = in_channel_layout; //AV_CH_LAYOUT_STEREO;
  fprintf(stderr, "in layout:%lld, out layout:%lld \n", in_channel_layout, out_channel_layout);

  audio_convert_ctx = swr_alloc();
  if(audio_convert_ctx){
    swr_alloc_set_opts(audio_convert_ctx,
		       out_channel_layout,
		       AV_SAMPLE_FMT_S16,
		       aCodecCtx->sample_rate,
		       in_channel_layout,
		       aCodecCtx->sample_fmt,
		       aCodecCtx->sample_rate,
		       0,
		       NULL);
  }
  swr_init(audio_convert_ctx);

  SDL_PauseAudio(0);

  // Get a pointer to the codec context for the video stream
  pCodecCtxOrig=pFormatCtx->streams[videoStream]->codec;
  
  // Find the decoder for the video stream
  pCodec=avcodec_find_decoder(pCodecCtxOrig->codec_id);
  if(pCodec==NULL) {
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Unsupported codec!");
    goto __FAIL;
  }

  // Copy context
  pCodecCtx = avcodec_alloc_context3(pCodec);
  if(avcodec_copy_context(pCodecCtx, pCodecCtxOrig) != 0) {
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Failed to copy context of codec!");
    goto __FAIL;
  }

  // Open codec
  if(avcodec_open2(pCodecCtx, pCodec, NULL)<0) {
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Failed to open audio decoder!");
    goto __FAIL;
  }
  
  // Allocate video frame
  pFrame=av_frame_alloc();

  w_width = pCodecCtx->width;
  w_height = pCodecCtx->height;

  fprintf(stderr, "width:%d, height:%d\n", w_width, w_height);

  win = SDL_CreateWindow("Media Player",
			 SDL_WINDOWPOS_UNDEFINED,
			 SDL_WINDOWPOS_UNDEFINED,
			 w_width, w_height,
			 SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE);
  if(!win){
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Failed to create window!");
    goto __FAIL;
  }

  renderer = SDL_CreateRenderer(win, -1, 0);
  if(!renderer){
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Failed to create renderer!");
    goto __FAIL;
  }

  pixformat = SDL_PIXELFORMAT_IYUV;
  texture = SDL_CreateTexture(renderer, 
                              pixformat,
  			      SDL_TEXTUREACCESS_STREAMING,
			      w_width,
			      w_height);
  if(!texture){
    SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Failed to create Texture!");
    goto __FAIL;
  }
  
  // initialize SWS context for software scaling
  sws_ctx = sws_getContext(pCodecCtx->width,
			   pCodecCtx->height,
			   pCodecCtx->pix_fmt,
			   pCodecCtx->width,
			   pCodecCtx->height,
			   AV_PIX_FMT_YUV420P,
			   SWS_BILINEAR,
			   NULL,
			   NULL,
			   NULL);

  pict = (AVPicture*)malloc(sizeof(AVPicture));
  avpicture_alloc(pict,
                  AV_PIX_FMT_YUV420P,
                  pCodecCtx->width,
                  pCodecCtx->height);

  // Read frames and save first five frames to disk
  while(av_read_frame(pFormatCtx, &packet)>=0) {
    // Is this a packet from the video stream?
    if(packet.stream_index==videoStream) {
      // Decode video frame
      avcodec_decode_video2(pCodecCtx, pFrame, &frameFinished, &packet);
      
      // Did we get a video frame?
      if(frameFinished) {

	// Convert the image into YUV format that SDL uses	
	sws_scale(sws_ctx, (uint8_t const * const *)pFrame->data,
		  pFrame->linesize, 0, pCodecCtx->height,
		  pict->data, pict->linesize);
	
	SDL_UpdateYUVTexture(texture, NULL,
                             pict->data[0], pict->linesize[0],
			     pict->data[1], pict->linesize[1],
			     pict->data[2], pict->linesize[2]);

	rect.x = 0;
	rect.y = 0;
	rect.w = pCodecCtx->width;
	rect.h = pCodecCtx->height;

	SDL_RenderClear(renderer);
	SDL_RenderCopy(renderer, texture, NULL, &rect);
	SDL_RenderPresent(renderer);

	av_free_packet(&packet);
      }
    } else if(packet.stream_index==audioStream) { //for audio
      packet_queue_put(&audioq, &packet);
    } else {
      av_free_packet(&packet);
    }

    // Free the packet that was allocated by av_read_frame
    SDL_PollEvent(&event);
    switch(event.type) {
    case SDL_QUIT:
      quit = 1;
      goto __QUIT; 
      break;
    default:
      break;
    }

  }

__QUIT:
  ret = 0;

__FAIL:
  // Free the YUV frame
  if(pFrame){
    av_frame_free(&pFrame);
  }
  
  // Close the codecs
  if(pCodecCtxOrig){
    avcodec_close(pCodecCtxOrig);
  }

  if(pCodecCtx){
    avcodec_close(pCodecCtx);
  }
 
  if(aCodecCtxOrig) {
    avcodec_close(aCodecCtxOrig);
  }

  if(aCodecCtx) {
    avcodec_close(aCodecCtx);
  }

  // Close the video file
  if(pFormatCtx){
    avformat_close_input(&pFormatCtx);
  }

  if(pict){
    avpicture_free(pict);
    free(pict);
  }
  
  if(win){
    SDL_DestroyWindow(win);
  }
 
  if(renderer){
    SDL_DestroyRenderer(renderer);
  }

  if(texture){
    SDL_DestroyTexture(texture);
  }

  SDL_Quit();
  
  return ret;
}
``` 
- 执行：clang -g -o player2va player2va.c `pkg-config --cflags --libs sdl2 libavutil libavformat libavcodec libswscale libswrsample`




#### 50.多线程与锁

- 多线程的好处
    - 充分利用CPU资源【管理】 
- 线程的互斥与同步
    - 互斥（抢锁的钥匙）
    - 同步（信号机制）
- 锁与信号量
    - 锁的种类
        - 1. 读写锁
        - 2. 自旋锁（等待，要短时间）
        - 3. 可重入锁
    - 通过信号进行同步
- SDL创建/等待线程
    - 1. SDL_CreateThread
    - 2. SDL_WaitThread
- SDL锁
    - 1. SDL_CreateMutex / SDL_DestroyMutex
    - 2. SDL_LockMutex / SDL_UnlockMutex
- SDL条件变量（信号量）
    - 1. SDL_CreateCond / SDL_DestroyCond
    - 2. SDL_CondWait / SDL_CondSignal



#### 51.锁与条件变量的使用

```c
#define FF_REFRESH_EVENT (SDL_USEREVENT)
#define FF_QUIT_EVENT (SDL_USEREVENT + 1)

#define VIDEO_PICTURE_QUEUE_SIZE 1

// 队列的结构体
typedef struct PacketQueue {
  AVPacketList *first_pkt, *last_pkt; // 队列的头和尾,ffmpeg提供的
  int nb_packets; // 有多少个包
  int size; // 存储空间
  SDL_mutex *mutex; // 互斥
  SDL_cond *cond; // 同步，信号量
} PacketQueue;

void packet_queue_init(PacketQueue *q) {
  memset(q, 0, sizeof(PacketQueue));
  q->mutex = SDL_CreateMutex();
  q->cond = SDL_CreateCond();
}

// 入队函数
int packet_queue_put(PacketQueue *q, AVPacket *pkt) {

  AVPacketList *pkt1; // 引用计数
  if(av_dup_packet(pkt) < 0) {
    return -1;
  }
  // 分配内存空间，构造队列中的一个元素，然后将我们的元素插入
  pkt1 = av_malloc(sizeof(AVPacketList));
  if (!pkt1)
    return -1;
  pkt1->pkt = *pkt;
  pkt1->next = NULL;
  
  // 加锁
  SDL_LockMutex(q->mutex);

  // 判读是不是第一个元素
  if (!q->last_pkt)
    q->first_pkt = pkt1;
  else
    q->last_pkt->next = pkt1;
  q->last_pkt = pkt1; // 移动队尾指针
  q->nb_packets++;
  q->size += pkt1->pkt.size; // 统计包大小
  SDL_CondSignal(q->cond); // 发送信号，让等待的线程唤醒
  
  SDL_UnlockMutex(q->mutex); // 解锁
  return 0;
}

// 出队函数
int packet_queue_get(PacketQueue *q, AVPacket *pkt, int block)
{
  AVPacketList *pkt1;
  int ret;

  SDL_LockMutex(q->mutex); // 加锁
  
  for(;;) { // 死循环等待
    
    if(global_video_state->quit) {
      ret = -1;
      break;
    }

    pkt1 = q->first_pkt; // 拿到队列头中取元素
    if (pkt1) {
      q->first_pkt = pkt1->next; // 往后移动
      if (!q->first_pkt) // 队列为空
	q->last_pkt = NULL;
      q->nb_packets--;
      q->size -= pkt1->pkt.size;
      *pkt = pkt1->pkt; // 取数据
      av_free(pkt1); // 释放资源
      ret = 1;
      break;
    } else if (!block) {
      ret = 0;
      break;
    } else {
      SDL_CondWait(q->cond, q->mutex);
    }
  }
  SDL_UnlockMutex(q->mutex); // 解锁
  return ret;
}
``` 


#### 52.播放器线程模型

- 主线程（对输入参数处理，对事件处理，对视频渲染），一般不做复杂逻辑

```text
                              --------->视频流队列<----------
                              ^                             |
                              |                             |
输入文件 --- [创建线程] --- 解复用 --- [创建线程] --- 视频解码线程
                              |                             |
                              V                             |
                          音频流队列 --------------------------------------音频渲染(SDL)
                                                            |
                                                            V
视频渲染 -------------------------------------------->解码视频队列
```  

```c
// tutorial04.c
// A pedagogical video player that will stream through every video frame as fast as it can,
// and play audio (out of sync).
//
// Code based on FFplay, Copyright (c) 2003 Fabrice Bellard, 
// and a tutorial by Martin Bohme (boehme@inb.uni-luebeckREMOVETHIS.de)
// Tested on Gentoo, CVS version 5/01/07 compiled with GCC 4.1.1
// With updates from https://github.com/chelyaev/ffmpeg-tutorial
// Updates tested on:
// LAVC 54.59.100, LAVF 54.29.104, LSWS 2.1.101, SDL 1.2.15
// on GCC 4.7.2 in Debian February 2015
// Use
//
// gcc -o tutorial04 tutorial04.c -lavformat -lavcodec -lswscale -lz -lm `sdl-config --cflags --libs`
// to build (assuming libavformat and libavcodec are correctly installed, 
// and assuming you have sdl-config. Please refer to SDL docs for your installation.)
//
// Run using
// tutorial04 myvideofile.mpg
//
// to play the video stream on your screen.

#include <stdio.h>
#include <assert.h>
#include <math.h>

#include <SDL.h>

#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#include <libswresample/swresample.h>

// compatibility with newer API
#if LIBAVCODEC_VERSION_INT < AV_VERSION_INT(55,28,1)
#define av_frame_alloc avcodec_alloc_frame
#define av_frame_free avcodec_free_frame
#endif

#define SDL_AUDIO_BUFFER_SIZE 1024
#define MAX_AUDIO_FRAME_SIZE 192000

#define MAX_AUDIOQ_SIZE (5 * 16 * 1024)
#define MAX_VIDEOQ_SIZE (5 * 256 * 1024)

#define FF_REFRESH_EVENT (SDL_USEREVENT)
#define FF_QUIT_EVENT (SDL_USEREVENT + 1)

#define VIDEO_PICTURE_QUEUE_SIZE 1

typedef struct PacketQueue {
  AVPacketList *first_pkt, *last_pkt;
  int nb_packets;
  int size;
  SDL_mutex *mutex;
  SDL_cond *cond;
} PacketQueue;


typedef struct VideoPicture {
  AVPicture *pict;
  int width, height; /* source height & width */
  int allocated;
} VideoPicture;

typedef struct VideoState {

  //for multi-media file
  char            filename[1024];
  AVFormatContext *pFormatCtx;

  int             videoStream, audioStream;

  //for audio
  AVStream        *audio_st;
  AVCodecContext  *audio_ctx;
  PacketQueue     audioq;
  uint8_t         audio_buf[(MAX_AUDIO_FRAME_SIZE * 3) / 2];
  unsigned int    audio_buf_size;
  unsigned int    audio_buf_index;
  AVFrame         audio_frame;
  AVPacket        audio_pkt;
  uint8_t         *audio_pkt_data;
  int             audio_pkt_size;
  struct SwrContext *audio_swr_ctx;

  //for video
  AVStream        *video_st;
  AVCodecContext  *video_ctx;
  PacketQueue     videoq;
  struct SwsContext *sws_ctx;

  VideoPicture    pictq[VIDEO_PICTURE_QUEUE_SIZE];
  int             pictq_size, pictq_rindex, pictq_windex;

  //for thread
  SDL_mutex       *pictq_mutex;
  SDL_cond        *pictq_cond;
  
  SDL_Thread      *parse_tid;
  SDL_Thread      *video_tid;

  int             quit;

} VideoState;

SDL_mutex       *texture_mutex;
SDL_Window      *win;
SDL_Renderer    *renderer;
SDL_Texture     *texture;

FILE            *audiofd = NULL;
FILE            *audiofd1 = NULL;

/* Since we only have one decoding thread, the Big Struct
   can be global in case we need it. */
VideoState *global_video_state;

void packet_queue_init(PacketQueue *q) {
  memset(q, 0, sizeof(PacketQueue));
  q->mutex = SDL_CreateMutex();
  q->cond = SDL_CreateCond();
}

int packet_queue_put(PacketQueue *q, AVPacket *pkt) {

  AVPacketList *pkt1;
  if(av_dup_packet(pkt) < 0) {
    return -1;
  }
  pkt1 = av_malloc(sizeof(AVPacketList));
  if (!pkt1)
    return -1;
  pkt1->pkt = *pkt;
  pkt1->next = NULL;
  
  SDL_LockMutex(q->mutex);

  if (!q->last_pkt)
    q->first_pkt = pkt1;
  else
    q->last_pkt->next = pkt1;
  q->last_pkt = pkt1;
  q->nb_packets++;
  q->size += pkt1->pkt.size;
  //fprintf(stderr, "enqueue, packets:%d, send cond signal\n", q->nb_packets);
  SDL_CondSignal(q->cond);
  
  SDL_UnlockMutex(q->mutex);
  return 0;
}

int packet_queue_get(PacketQueue *q, AVPacket *pkt, int block)
{
  AVPacketList *pkt1;
  int ret;

  SDL_LockMutex(q->mutex);
  
  for(;;) {
    
    if(global_video_state->quit) {
      fprintf(stderr, "quit from queue_get\n");
      ret = -1;
      break;
    }

    pkt1 = q->first_pkt;
    if (pkt1) {
      q->first_pkt = pkt1->next;
      if (!q->first_pkt)
	q->last_pkt = NULL;
      q->nb_packets--;
      q->size -= pkt1->pkt.size;
      *pkt = pkt1->pkt;
      av_free(pkt1);
      ret = 1;
      break;
    } else if (!block) {
      ret = 0;
      break;
    } else {
      fprintf(stderr, "queue is empty, so wait a moment and wait a cond signal\n");
      SDL_CondWait(q->cond, q->mutex);
    }
  }
  SDL_UnlockMutex(q->mutex);
  return ret;
}

int audio_decode_frame(VideoState *is, uint8_t *audio_buf, int buf_size) {

  int len1, data_size = 0;
  AVPacket *pkt = &is->audio_pkt;

  for(;;) {
    while(is->audio_pkt_size > 0) {

      int got_frame = 0;
      len1 = avcodec_decode_audio4(is->audio_ctx, &is->audio_frame, &got_frame, pkt);
      if(len1 < 0) {
	/* if error, skip frame */
	fprintf(stderr, "Failed to decode audio ......\n");
	is->audio_pkt_size = 0;
	break;
      }

      data_size = 0;
      if(got_frame) {
	/*
	fprintf(stderr, "auido: channels:%d, nb_samples:%d, sample_fmt:%d\n",
			is->audio_ctx->channels,
			is->audio_frame.nb_samples,
			is->audio_ctx->sample_fmt);

	data_size = av_samples_get_buffer_size(NULL, 
					       is->audio_ctx->channels,
					       is->audio_frame.nb_samples,
					       is->audio_ctx->sample_fmt,
					       1);
	*/
	data_size = 2 * is->audio_frame.nb_samples * 2;
	assert(data_size <= buf_size);
	//memcpy(audio_buf, is->audio_frame.data[0], data_size);
	
	swr_convert(is->audio_swr_ctx,
                        &audio_buf,
                        MAX_AUDIO_FRAME_SIZE*3/2,
                        (const uint8_t **)is->audio_frame.data,
                        is->audio_frame.nb_samples);
	
	
	fwrite(audio_buf, 1, data_size, audiofd);
        fflush(audiofd);
      }

      is->audio_pkt_data += len1;
      is->audio_pkt_size -= len1;
      if(data_size <= 0) {
	/* No data yet, get more frames */
	continue;
      }
      /* We have data, return it and come back for more later */
      return data_size;
    }

    if(pkt->data)
      av_free_packet(pkt);

    if(is->quit) {
      fprintf(stderr, "will quit program......\n");
      return -1;
    }

    /* next packet */
    if(packet_queue_get(&is->audioq, pkt, 1) < 0) {
      return -1;
    }

    is->audio_pkt_data = pkt->data;
    is->audio_pkt_size = pkt->size;
  }
}

void audio_callback(void *userdata, Uint8 *stream, int len) {

  VideoState *is = (VideoState *)userdata;
  int len1, audio_size;

  SDL_memset(stream, 0, len);

  while(len > 0) {
    if(is->audio_buf_index >= is->audio_buf_size) {
      /* We have already sent all our data; get more */
      audio_size = audio_decode_frame(is, is->audio_buf, sizeof(is->audio_buf));
      if(audio_size < 0) {
	/* If error, output silence */
	is->audio_buf_size = 1024*2*2;
	memset(is->audio_buf, 0, is->audio_buf_size);
      } else {
	is->audio_buf_size = audio_size;
      }
      is->audio_buf_index = 0;
    }
    len1 = is->audio_buf_size - is->audio_buf_index;
    fprintf(stderr, "stream addr:%p, audio_buf_index:%d, len1:%d, len:%d\n",
		    stream,
	  	    is->audio_buf_index, 
		    len1, 
		    len);
    if(len1 > len)
      len1 = len;
    //memcpy(stream, (uint8_t *)is->audio_buf + is->audio_buf_index, len1);
    fwrite(is->audio_buf, 1, len1, audiofd1);
    fflush(audiofd1);
    SDL_MixAudio(stream,(uint8_t *)is->audio_buf, len1, SDL_MIX_MAXVOLUME);
    len -= len1;
    stream += len1;
    is->audio_buf_index += len1;
  }
}

static Uint32 sdl_refresh_timer_cb(Uint32 interval, void *opaque) {
  SDL_Event event;
  event.type = FF_REFRESH_EVENT;
  event.user.data1 = opaque;
  SDL_PushEvent(&event);
  return 0; /* 0 means stop timer */
}

/* schedule a video refresh in 'delay' ms */
static void schedule_refresh(VideoState *is, int delay) {
  SDL_AddTimer(delay, sdl_refresh_timer_cb, is);
}

void video_display(VideoState *is) {

  SDL_Rect rect;
  VideoPicture *vp;
  float aspect_ratio;
  int w, h, x, y;
  int i;

  vp = &is->pictq[is->pictq_rindex];
  if(vp->pict) {

    if(is->video_ctx->sample_aspect_ratio.num == 0) {
      aspect_ratio = 0;
    } else {
      aspect_ratio = av_q2d(is->video_ctx->sample_aspect_ratio) *
	is->video_ctx->width / is->video_ctx->height;
    }

    if(aspect_ratio <= 0.0) {
      aspect_ratio = (float)is->video_ctx->width /
	(float)is->video_ctx->height;
    }

    /*
    h = screen->h;
    w = ((int)rint(h * aspect_ratio)) & -3;
    if(w > screen->w) {
      w = screen->w;
      h = ((int)rint(w / aspect_ratio)) & -3;
    }
    x = (screen->w - w) / 2;
    y = (screen->h - h) / 2;
    */

    SDL_UpdateYUVTexture( texture, NULL,
                          vp->pict->data[0], vp->pict->linesize[0],
                          vp->pict->data[1], vp->pict->linesize[1],
                          vp->pict->data[2], vp->pict->linesize[2]);
    
    rect.x = 0;
    rect.y = 0;
    rect.w = is->video_ctx->width;
    rect.h = is->video_ctx->height;

    SDL_LockMutex(texture_mutex);
    SDL_RenderClear(renderer);
    SDL_RenderCopy(renderer, texture, NULL, &rect);
    SDL_RenderPresent(renderer);
    SDL_UnlockMutex(texture_mutex);

  }
}

void video_refresh_timer(void *userdata) {

  VideoState *is = (VideoState *)userdata;
  VideoPicture *vp;
  
  if(is->video_st) {
    if(is->pictq_size == 0) {
      schedule_refresh(is, 1); //if the queue is empty, so we shoud be as fast as checking queue of picture
    } else {
      vp = &is->pictq[is->pictq_rindex];
      /* Now, normally here goes a ton of code
	 about timing, etc. we're just going to
	 guess at a delay for now. You can
	 increase and decrease this value and hard code
	 the timing - but I don't suggest that ;)
	 We'll learn how to do it for real later.
      */
      schedule_refresh(is, 40);
      
      /* show the picture! */
      video_display(is);
      
      /* update queue for next picture! */
      if(++is->pictq_rindex == VIDEO_PICTURE_QUEUE_SIZE) {
	is->pictq_rindex = 0;
      }
      SDL_LockMutex(is->pictq_mutex);
      is->pictq_size--;
      SDL_CondSignal(is->pictq_cond);
      SDL_UnlockMutex(is->pictq_mutex);
    }
  } else {
    schedule_refresh(is, 100);
  }
}
      
void alloc_picture(void *userdata) {

  VideoState *is = (VideoState *)userdata;
  VideoPicture *vp;

  vp = &is->pictq[is->pictq_windex];
  if(vp->pict) {//free space if vp->pict is not NULL
    avpicture_free(vp->pict);
    free(vp->pict);
  }

  // Allocate a place to put our YUV image on that screen
  SDL_LockMutex(texture_mutex);
  vp->pict = (AVPicture*)malloc(sizeof(AVPicture));
  if(vp->pict){
    avpicture_alloc(vp->pict,
		    AV_PIX_FMT_YUV420P, 
		    is->video_ctx->width,
		    is->video_ctx->height);
  }
  SDL_UnlockMutex(texture_mutex);

  vp->width = is->video_ctx->width;
  vp->height = is->video_ctx->height;
  vp->allocated = 1;

}

int queue_picture(VideoState *is, AVFrame *pFrame) {

  VideoPicture *vp;
  int dst_pix_fmt;
  AVPicture pict;

  /* wait until we have space for a new pic */
  SDL_LockMutex(is->pictq_mutex);
  while(is->pictq_size >= VIDEO_PICTURE_QUEUE_SIZE &&
	!is->quit) {
    SDL_CondWait(is->pictq_cond, is->pictq_mutex);
  }
  SDL_UnlockMutex(is->pictq_mutex);

  if(is->quit){
    fprintf(stderr, "quit from queue_picture....\n");
    return -1;
  }

  // windex is set to 0 initially
  vp = &is->pictq[is->pictq_windex];

  /*
  fprintf(stderr, "vp.width=%d, vp.height=%d, video_ctx.width=%d, video_ctx.height=%d\n", 
		  vp->width, 
		  vp->height, 
		  is->video_ctx->width,
		  is->video_ctx->height);
  */

  /* allocate or resize the buffer! */
  if(!vp->pict ||
     vp->width != is->video_ctx->width ||
     vp->height != is->video_ctx->height) {

    vp->allocated = 0;
    alloc_picture(is);
    if(is->quit) {
      fprintf(stderr, "quit from queue_picture2....\n");
      return -1;
    }
  }

  /* We have a place to put our picture on the queue */

  if(vp->pict) {

    // Convert the image into YUV format that SDL uses
    sws_scale(is->sws_ctx, (uint8_t const * const *)pFrame->data,
	      pFrame->linesize, 0, is->video_ctx->height,
	      vp->pict->data, vp->pict->linesize);
    
    /* now we inform our display thread that we have a pic ready */
    if(++is->pictq_windex == VIDEO_PICTURE_QUEUE_SIZE) {
      is->pictq_windex = 0;
    }
    SDL_LockMutex(is->pictq_mutex);
    is->pictq_size++;
    SDL_UnlockMutex(is->pictq_mutex);
  }
  return 0;
}

int video_thread(void *arg) {
  VideoState *is = (VideoState *)arg;
  AVPacket pkt1, *packet = &pkt1;
  int frameFinished;
  AVFrame *pFrame;

  pFrame = av_frame_alloc();

  for(;;) {
    if(packet_queue_get(&is->videoq, packet, 1) < 0) {
      // means we quit getting packets
      break;
    }

    // Decode video frame
    avcodec_decode_video2(is->video_ctx, pFrame, &frameFinished, packet);

    // Did we get a video frame?
    if(frameFinished) {
      if(queue_picture(is, pFrame) < 0) {
	break;
      }      
    }

    av_free_packet(packet);
  }
  av_frame_free(&pFrame);
  return 0;
}

int stream_component_open(VideoState *is, int stream_index) {

  int64_t in_channel_layout, out_channel_layout;

  AVFormatContext *pFormatCtx = is->pFormatCtx;
  AVCodecContext *codecCtx = NULL;
  AVCodec *codec = NULL;
  SDL_AudioSpec wanted_spec, spec;

  if(stream_index < 0 || stream_index >= pFormatCtx->nb_streams) {
    return -1;
  }

  codec = avcodec_find_decoder(pFormatCtx->streams[stream_index]->codec->codec_id);
  if(!codec) {
    fprintf(stderr, "Unsupported codec!\n");
    return -1;
  }

  codecCtx = avcodec_alloc_context3(codec);
  if(avcodec_copy_context(codecCtx, pFormatCtx->streams[stream_index]->codec) != 0) {
    fprintf(stderr, "Couldn't copy codec context");
    return -1; // Error copying codec context
  }


  if(codecCtx->codec_type == AVMEDIA_TYPE_AUDIO) {
    // Set audio settings from codec info
    wanted_spec.freq = codecCtx->sample_rate;
    wanted_spec.format = AUDIO_S16SYS;
    wanted_spec.channels = codecCtx->channels;
    wanted_spec.silence = 0;
    wanted_spec.samples = SDL_AUDIO_BUFFER_SIZE;
    wanted_spec.callback = audio_callback;
    wanted_spec.userdata = is;
    
    if(SDL_OpenAudio(&wanted_spec, &spec) < 0) {
      fprintf(stderr, "SDL_OpenAudio: %s\n", SDL_GetError());
      return -1;
    }
  }

  if(avcodec_open2(codecCtx, codec, NULL) < 0) {
    fprintf(stderr, "Unsupported codec!\n");
    return -1;
  }

  switch(codecCtx->codec_type) {
  case AVMEDIA_TYPE_AUDIO:
    is->audioStream = stream_index;
    is->audio_st = pFormatCtx->streams[stream_index];
    is->audio_ctx = codecCtx;
    is->audio_buf_size = 0;
    is->audio_buf_index = 0;
    memset(&is->audio_pkt, 0, sizeof(is->audio_pkt));
    packet_queue_init(&is->audioq);
    SDL_PauseAudio(0);

    in_channel_layout=av_get_default_channel_layout(is->audio_ctx->channels);
    out_channel_layout = in_channel_layout;

    is->audio_swr_ctx = swr_alloc();
    swr_alloc_set_opts(is->audio_swr_ctx,
                       out_channel_layout,
                       AV_SAMPLE_FMT_S16,
                       is->audio_ctx->sample_rate,
                       in_channel_layout,
                       is->audio_ctx->sample_fmt,
                       is->audio_ctx->sample_rate,
                       0,
                       NULL);

    fprintf(stderr, "swr opts: out_channel_layout:%lld, out_sample_fmt:%d, out_sample_rate:%d, in_channel_layout:%lld, in_sample_fmt:%d, in_sample_rate:%d",
                    out_channel_layout, 
		    AV_SAMPLE_FMT_S16, 
		    is->audio_ctx->sample_rate, 
		    in_channel_layout, 
		    is->audio_ctx->sample_fmt, 
		    is->audio_ctx->sample_rate);

    swr_init(is->audio_swr_ctx);

    break;

  case AVMEDIA_TYPE_VIDEO:
    is->videoStream = stream_index;
    is->video_st = pFormatCtx->streams[stream_index];
    is->video_ctx = codecCtx;
    packet_queue_init(&is->videoq);
    is->video_tid = SDL_CreateThread(video_thread, "video_thread", is);
    is->sws_ctx = sws_getContext(is->video_ctx->width, 
				 is->video_ctx->height,
				 is->video_ctx->pix_fmt, 
				 is->video_ctx->width,
				 is->video_ctx->height, 
				 AV_PIX_FMT_YUV420P,
				 SWS_BILINEAR, 
				 NULL, NULL, NULL);
    break;
  default:
    break;
  }

  return 0;
}

int decode_thread(void *arg) {

  Uint32 pixformat;

  VideoState *is = (VideoState *)arg;
  AVFormatContext *pFormatCtx;
  AVPacket pkt1, *packet = &pkt1;

  int i;
  int video_index = -1;
  int audio_index = -1;

  is->videoStream = -1;
  is->audioStream = -1;

  global_video_state = is;

  // Open video file
  if(avformat_open_input(&pFormatCtx, is->filename, NULL, NULL)!=0)
    return -1; // Couldn't open file

  is->pFormatCtx = pFormatCtx;
  
  // Retrieve stream information
  if(avformat_find_stream_info(pFormatCtx, NULL)<0)
    return -1; // Couldn't find stream information
  
  // Dump information about file onto standard error
  av_dump_format(pFormatCtx, 0, is->filename, 0);
  
  // Find the first video stream
  for(i=0; i<pFormatCtx->nb_streams; i++) {
    if(pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO &&
       video_index < 0) {
      video_index=i;
    }
    if(pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_AUDIO &&
       audio_index < 0) {
      audio_index=i;
    }
  }

  if(audio_index >= 0) {
    stream_component_open(is, audio_index);
  }
  if(video_index >= 0) {
    stream_component_open(is, video_index);
  }   

  if(is->videoStream < 0 || is->audioStream < 0) {
    fprintf(stderr, "%s: could not open codecs\n", is->filename);
    goto fail;
  }

  fprintf(stderr, "video context: width=%d, height=%d\n", is->video_ctx->width, is->video_ctx->height);
  win = SDL_CreateWindow("Media Player",
     		   SDL_WINDOWPOS_UNDEFINED,
		   SDL_WINDOWPOS_UNDEFINED,
		   is->video_ctx->width, is->video_ctx->height,
		   SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE);
  
  renderer = SDL_CreateRenderer(win, -1, 0);

  pixformat = SDL_PIXELFORMAT_IYUV;
  texture = SDL_CreateTexture(renderer,
			      pixformat, 
			      SDL_TEXTUREACCESS_STREAMING,
			      is->video_ctx->width,
			      is->video_ctx->height);

  // main decode loop
  for(;;) {

    if(is->quit) {
      SDL_CondSignal(is->videoq.cond);
      SDL_CondSignal(is->audioq.cond);
      break;
    }

    // seek stuff goes here
    if(is->audioq.size > MAX_AUDIOQ_SIZE ||
       is->videoq.size > MAX_VIDEOQ_SIZE) {
      SDL_Delay(10);
      continue;
    }

    if(av_read_frame(is->pFormatCtx, packet) < 0) {
      if(is->pFormatCtx->pb->error == 0) {
	SDL_Delay(100); /* no error; wait for user input */
	continue;
      } else {
	break;
      }
    }

    // Is this a packet from the video stream?
    if(packet->stream_index == is->videoStream) {
      packet_queue_put(&is->videoq, packet);
      fprintf(stderr, "put video queue, size :%d\n", is->videoq.nb_packets);
    } else if(packet->stream_index == is->audioStream) {
      packet_queue_put(&is->audioq, packet);
      fprintf(stderr, "put audio queue, size :%d\n", is->audioq.nb_packets);
    } else {
      av_free_packet(packet);
    }

  }

  /* all done - wait for it */
  while(!is->quit) {
    SDL_Delay(100);
  }

 fail:
  if(1){
    SDL_Event event;
    event.type = FF_QUIT_EVENT;
    event.user.data1 = is;
    SDL_PushEvent(&event);
  }

  return 0;
}

int main(int argc, char *argv[]) {

  int 		  ret = -1;

  SDL_Event       event;

  VideoState      *is;

  if(argc < 2) {
    fprintf(stderr, "Usage: test <file>\n");
    exit(1);
  }

  audiofd = fopen("testout.pcm", "wb+");
  audiofd1 = fopen("testout1.pcm", "wb+");

  //big struct, it's core
  is = av_mallocz(sizeof(VideoState));

  // Register all formats and codecs
  av_register_all();
  
  if(SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_TIMER)) {
    fprintf(stderr, "Could not initialize SDL - %s\n", SDL_GetError());
    exit(1);
  }

  texture_mutex = SDL_CreateMutex();

  av_strlcpy(is->filename, argv[1], sizeof(is->filename));

  is->pictq_mutex = SDL_CreateMutex();
  is->pictq_cond = SDL_CreateCond();

  //set timer
  schedule_refresh(is, 40);

  is->parse_tid = SDL_CreateThread(decode_thread, "decode_thread", is);
  if(!is->parse_tid) {
    av_free(is);
    goto __FAIL;
  }

  for(;;) {

    SDL_WaitEvent(&event);
    switch(event.type) {
    case FF_QUIT_EVENT:
    case SDL_QUIT:
      fprintf(stderr, "receive a QUIT event: %d\n", event.type);
      is->quit = 1;
      //SDL_Quit();
      //return 0;
      goto __QUIT;
      break;
    case FF_REFRESH_EVENT:
      //fprintf(stderr, "receive a refresh event: %d\n", event.type);
      video_refresh_timer(event.user.data1);
      break;
    default:
      break;
    }
  }

__QUIT:
  ret = 0;
  

__FAIL:
  SDL_Quit();
  if(audiofd){
    fclose(audiofd);
  }
  if(audiofd1){
    fclose(audiofd1);
  }
  return ret;

}
```  


#### 53.线程的退出机制

- 主线程接收到退出事件
- 解复用线程在循环分流时对quit进行判断
- 视频解码线程从视频流队列中取包时对quit进行判断
- 音频解码从音频流队列中取包时对quit进行判断
- 音视频循环解码时对quit进行判断
- 在收到信号变量消息时对quit进行判断


#### 54.音视频同步

- 时间戳
    - PTS: Presentation timestamp 用于最终渲染用的
    - DTS: Decoding timestamp 用于视频解码
    - I(intra) / B(bidirectional) / P(predicted) 帧
        - I 关键帧，帧内压缩
        - B 向前向后参考3帧，可多帧
        - P 向前参考帧，1帧
- 时间戳顺序
    - 实际帧顺序：I B B P
    - 存放帧顺序：I P B B
    - 解码时间戳：1 4 2 3
    - 展示时间戳：1 2 3 4
- 从哪儿获取PTS
    - AVPacket中的PTS【解复用的数据包里】
    - AvFrame中的PTS【解码数据帧里】
    - av_frame_get_best_effort_timestamp()
- 时间基
    - 不同的时间的基数
    - tbr: 帧率 【1/25】
    - tbn: time base of stream
    - tbc: time base of codec
- 计算当前帧的PTS
    - PTS = PTS * av_q2d(video_stream->time_base) 
    - av_q2d(AVRotional a) { return a.num / (double)a.den; }
- 计算下一帧的PTS
    - video_clock: 预测的下一帧视频的PTS
    - frame_delay: 1/tbr
    - audio_clokc: 音频当前播放的时间戳
- 音视频同步的方式
    - 视频同步到音频（易）
    - 音频同步到视频（难）
    - 音频和视频都同步到系统时钟
- 视频播放的基本思路
    - 一般的做法，展示第一帧视频帧后，获得要显示的下一个帧视频的PTS，然后设置一个定时器，当定时器超时后，刷新新的视频帧，如此反复操作。 

```c
#include <stdio.h>
#include <assert.h>
#include <math.h>

#include <SDL.h>

#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#include <libswresample/swresample.h>

// compatibility with newer API
#if LIBAVCODEC_VERSION_INT < AV_VERSION_INT(55,28,1)
#define av_frame_alloc avcodec_alloc_frame
#define av_frame_free avcodec_free_frame
#endif

#define SDL_AUDIO_BUFFER_SIZE 1024
#define MAX_AUDIO_FRAME_SIZE 192000

#define MAX_AUDIOQ_SIZE (5 * 16 * 1024)
#define MAX_VIDEOQ_SIZE (5 * 256 * 1024)

#define AV_SYNC_THRESHOLD 0.01
#define AV_NOSYNC_THRESHOLD 10.0

#define FF_REFRESH_EVENT (SDL_USEREVENT)
#define FF_QUIT_EVENT (SDL_USEREVENT + 1)

#define VIDEO_PICTURE_QUEUE_SIZE 1

typedef struct PacketQueue {
  AVPacketList *first_pkt, *last_pkt;
  int nb_packets;
  int size;
  SDL_mutex *mutex;
  SDL_cond *cond;
} PacketQueue;


typedef struct VideoPicture {
  AVPicture *bmp;
  int width, height; /* source height & width */
  int allocated;
  double pts;
} VideoPicture;

typedef struct VideoState {

  AVFormatContext *pFormatCtx;
  int             videoStream, audioStream;

  AVStream        *audio_st;
  AVCodecContext  *audio_ctx;
  PacketQueue     audioq;
  uint8_t         audio_buf[(MAX_AUDIO_FRAME_SIZE * 3) / 2];
  unsigned int    audio_buf_size;
  unsigned int    audio_buf_index;
  AVFrame         audio_frame;
  AVPacket        audio_pkt;
  uint8_t         *audio_pkt_data;
  int             audio_pkt_size;
  int             audio_hw_buf_size;  
  struct SwrContext *audio_swr_ctx;

  double          audio_clock;
  double          video_clock; ///<pts of last decoded frame / predicted pts of next decoded frame

  double          frame_timer;
  double          frame_last_pts;
  double          frame_last_delay;

  AVStream        *video_st;
  AVCodecContext  *video_ctx;
  PacketQueue     videoq;
  struct SwsContext *video_sws_ctx;

  VideoPicture    pictq[VIDEO_PICTURE_QUEUE_SIZE];
  int             pictq_size, pictq_rindex, pictq_windex;
  SDL_mutex       *pictq_mutex;
  SDL_cond        *pictq_cond;
  
  SDL_Thread      *parse_tid;
  SDL_Thread      *video_tid;

  char            filename[1024];
  int             quit;
} VideoState;

SDL_mutex       *text_mutex;
SDL_Window	*win;
SDL_Renderer 	*renderer;
SDL_Texture  	*texture;

/* Since we only have one decoding thread, the Big Struct
   can be global in case we need it. */
VideoState *global_video_state;

void packet_queue_init(PacketQueue *q) {
  memset(q, 0, sizeof(PacketQueue));
  q->mutex = SDL_CreateMutex();
  q->cond = SDL_CreateCond();
}
int packet_queue_put(PacketQueue *q, AVPacket *pkt) {

  AVPacketList *pkt1;
  if(av_dup_packet(pkt) < 0) {
    return -1;
  }
  pkt1 = av_malloc(sizeof(AVPacketList));
  if (!pkt1)
    return -1;
  pkt1->pkt = *pkt;
  pkt1->next = NULL;
  
  SDL_LockMutex(q->mutex);

  if (!q->last_pkt)
    q->first_pkt = pkt1;
  else
    q->last_pkt->next = pkt1;
  q->last_pkt = pkt1;
  q->nb_packets++;
  q->size += pkt1->pkt.size;
  SDL_CondSignal(q->cond);
  
  SDL_UnlockMutex(q->mutex);
  return 0;
}

int packet_queue_get(PacketQueue *q, AVPacket *pkt, int block)
{
  AVPacketList *pkt1;
  int ret;

  SDL_LockMutex(q->mutex);
  
  for(;;) {
    
    if(global_video_state->quit) {
      ret = -1;
      break;
    }

    pkt1 = q->first_pkt;
    if (pkt1) {
      q->first_pkt = pkt1->next;
      if (!q->first_pkt)
	q->last_pkt = NULL;
      q->nb_packets--;
      q->size -= pkt1->pkt.size;
      *pkt = pkt1->pkt;
      av_free(pkt1);
      ret = 1;
      break;
    } else if (!block) {
      ret = 0;
      break;
    } else {
      SDL_CondWait(q->cond, q->mutex);
    }
  }
  SDL_UnlockMutex(q->mutex);
  return ret;
}

double get_audio_clock(VideoState *is) {
  double pts;
  int hw_buf_size, bytes_per_sec, n;
  
  pts = is->audio_clock; /* maintained in the audio thread */
  hw_buf_size = is->audio_buf_size - is->audio_buf_index;
  bytes_per_sec = 0;
  n = is->audio_ctx->channels * 2;
  if(is->audio_st) {
    bytes_per_sec = is->audio_ctx->sample_rate * n;
  }
  if(bytes_per_sec) {
    pts -= (double)hw_buf_size / bytes_per_sec;
  }
  return pts;
}

int audio_decode_frame(VideoState *is, uint8_t *audio_buf, int buf_size, double *pts_ptr) {

  int len1, data_size = 0;
  AVPacket *pkt = &is->audio_pkt;
  double pts;
  int n;

  for(;;) {
    while(is->audio_pkt_size > 0) {
      int got_frame = 0;
      len1 = avcodec_decode_audio4(is->audio_ctx, &is->audio_frame, &got_frame, pkt);
      if(len1 < 0) {
	/* if error, skip frame */
	is->audio_pkt_size = 0;
	break;
      }
      data_size = 0;
      if(got_frame) {
	/*
	data_size = av_samples_get_buffer_size(NULL, 
					       is->audio_ctx->channels,
					       is->audio_frame.nb_samples,
					       is->audio_ctx->sample_fmt,
					       1);
	*/
	data_size = 2 * is->audio_frame.nb_samples * 2;
	assert(data_size <= buf_size);

        swr_convert(is->audio_swr_ctx,
                        &audio_buf,
                        MAX_AUDIO_FRAME_SIZE*3/2,
                        (const uint8_t **)is->audio_frame.data,
                        is->audio_frame.nb_samples);

	//memcpy(audio_buf, is->audio_frame.data[0], data_size);
      }
      is->audio_pkt_data += len1;
      is->audio_pkt_size -= len1;
      if(data_size <= 0) {
	/* No data yet, get more frames */
	continue;
      }
      pts = is->audio_clock;
      *pts_ptr = pts;
      n = 2 * is->audio_ctx->channels;
      is->audio_clock += (double)data_size /
	(double)(n * is->audio_ctx->sample_rate);
      /* We have data, return it and come back for more later */
      return data_size;
    }
    if(pkt->data)
      av_free_packet(pkt);

    if(is->quit) {
      return -1;
    }
    /* next packet */
    if(packet_queue_get(&is->audioq, pkt, 1) < 0) {
      return -1;
    }
    is->audio_pkt_data = pkt->data;
    is->audio_pkt_size = pkt->size;
    /* if update, update the audio clock w/pts */
    if(pkt->pts != AV_NOPTS_VALUE) {
      is->audio_clock = av_q2d(is->audio_st->time_base)*pkt->pts;
    }
  }
}

void audio_callback(void *userdata, Uint8 *stream, int len) {

  VideoState *is = (VideoState *)userdata;
  int len1, audio_size;
  double pts;

  SDL_memset(stream, 0, len);

  while(len > 0) {
    if(is->audio_buf_index >= is->audio_buf_size) {
      /* We have already sent all our data; get more */
      audio_size = audio_decode_frame(is, is->audio_buf, sizeof(is->audio_buf), &pts);
      if(audio_size < 0) {
	/* If error, output silence */
	is->audio_buf_size = 1024 * 2 * 2;
	memset(is->audio_buf, 0, is->audio_buf_size);
      } else {
	is->audio_buf_size = audio_size;
      }
      is->audio_buf_index = 0;
    }
    len1 = is->audio_buf_size - is->audio_buf_index;
    if(len1 > len)
      len1 = len;
    SDL_MixAudio(stream,(uint8_t *)is->audio_buf + is->audio_buf_index, len1, SDL_MIX_MAXVOLUME);
    //memcpy(stream, (uint8_t *)is->audio_buf + is->audio_buf_index, len1);
    len -= len1;
    stream += len1;
    is->audio_buf_index += len1;
  }
}

static Uint32 sdl_refresh_timer_cb(Uint32 interval, void *opaque) {
  SDL_Event event;
  event.type = FF_REFRESH_EVENT;
  event.user.data1 = opaque;
  SDL_PushEvent(&event);
  return 0; /* 0 means stop timer */
}

/* schedule a video refresh in 'delay' ms */
static void schedule_refresh(VideoState *is, int delay) {
  SDL_AddTimer(delay, sdl_refresh_timer_cb, is);
}

void video_display(VideoState *is) {

  SDL_Rect rect;
  VideoPicture *vp;
  float aspect_ratio;
  int w, h, x, y;
  int i;

  vp = &is->pictq[is->pictq_rindex];
  if(vp->bmp) {

    SDL_UpdateYUVTexture( texture, NULL,
                          vp->bmp->data[0], vp->bmp->linesize[0],
                          vp->bmp->data[1], vp->bmp->linesize[1],
                          vp->bmp->data[2], vp->bmp->linesize[2]);

    rect.x = 0;
    rect.y = 0;
    rect.w = is->video_ctx->width;
    rect.h = is->video_ctx->height;
    SDL_LockMutex(text_mutex);
    SDL_RenderClear( renderer );
    SDL_RenderCopy( renderer, texture, NULL, &rect);
    SDL_RenderPresent( renderer );
    SDL_UnlockMutex(text_mutex);

  }
}

void video_refresh_timer(void *userdata) {

  VideoState *is = (VideoState *)userdata;
  VideoPicture *vp;
  double actual_delay, delay, sync_threshold, ref_clock, diff;
  
  if(is->video_st) {
    if(is->pictq_size == 0) {
      schedule_refresh(is, 1);
    } else {
      vp = &is->pictq[is->pictq_rindex];

      delay = vp->pts - is->frame_last_pts; /* the pts from last time */
      if(delay <= 0 || delay >= 1.0) {
	/* if incorrect delay, use previous one */
	delay = is->frame_last_delay;
      }
      /* save for next time */
      is->frame_last_delay = delay;
      is->frame_last_pts = vp->pts;

      /* update delay to sync to audio */
      ref_clock = get_audio_clock(is);
      diff = vp->pts - ref_clock;

      /* Skip or repeat the frame. Take delay into account
	 FFPlay still doesn't "know if this is the best guess." */
      sync_threshold = (delay > AV_SYNC_THRESHOLD) ? delay : AV_SYNC_THRESHOLD;
      if(fabs(diff) < AV_NOSYNC_THRESHOLD) {
	if(diff <= -sync_threshold) {
	  delay = 0;
	} else if(diff >= sync_threshold) {
	  delay = 2 * delay;
	}
      }
      is->frame_timer += delay;
      /* computer the REAL delay */
      actual_delay = is->frame_timer - (av_gettime() / 1000000.0);
      if(actual_delay < 0.010) {
	/* Really it should skip the picture instead */
	actual_delay = 0.010;
      }
      schedule_refresh(is, (int)(actual_delay * 1000 + 0.5));
      
      /* show the picture! */
      video_display(is);
      
      /* update queue for next picture! */
      if(++is->pictq_rindex == VIDEO_PICTURE_QUEUE_SIZE) {
	is->pictq_rindex = 0;
      }
      SDL_LockMutex(is->pictq_mutex);
      is->pictq_size--;
      SDL_CondSignal(is->pictq_cond);
      SDL_UnlockMutex(is->pictq_mutex);
    }
  } else {
    schedule_refresh(is, 100);
  }
}
      
void alloc_picture(void *userdata) {

  int ret = -1;

  VideoState *is = (VideoState *)userdata;
  VideoPicture *vp;

  vp = &is->pictq[is->pictq_windex];
  if(vp->bmp) {

    // we already have one make another, bigger/smaller
    avpicture_free(vp->bmp);
    free(vp->bmp);

    vp->bmp = NULL;
  }

  // Allocate a place to put our YUV image on that screen
  SDL_LockMutex(text_mutex);
  vp->bmp = (AVPicture*)malloc(sizeof(AVPicture));
  ret = avpicture_alloc(vp->bmp, AV_PIX_FMT_YUV420P, is->video_ctx->width, is->video_ctx->height);
  if (ret < 0) {
      fprintf(stderr, "Could not allocate temporary picture: %s\n", av_err2str(ret));
  }

  SDL_UnlockMutex(text_mutex);

  vp->width = is->video_ctx->width;
  vp->height = is->video_ctx->height;
  vp->allocated = 1;

}

int queue_picture(VideoState *is, AVFrame *pFrame, double pts) {

  VideoPicture *vp;

  /* wait until we have space for a new pic */
  SDL_LockMutex(is->pictq_mutex);
  while(is->pictq_size >= VIDEO_PICTURE_QUEUE_SIZE &&
	!is->quit) {
    SDL_CondWait(is->pictq_cond, is->pictq_mutex);
  }
  SDL_UnlockMutex(is->pictq_mutex);

  if(is->quit)
    return -1;

  // windex is set to 0 initially
  vp = &is->pictq[is->pictq_windex];

  /* allocate or resize the buffer! */
  if(!vp->bmp ||
     vp->width != is->video_ctx->width ||
     vp->height != is->video_ctx->height) {

    vp->allocated = 0;
    alloc_picture(is);
    if(is->quit) {
      return -1;
    }
  }

  /* We have a place to put our picture on the queue */
  if(vp->bmp) {

    vp->pts = pts;
    
    // Convert the image into YUV format that SDL uses
    sws_scale(is->video_sws_ctx, (uint8_t const * const *)pFrame->data,
	      pFrame->linesize, 0, is->video_ctx->height,
	      vp->bmp->data, vp->bmp->linesize);
    
    /* now we inform our display thread that we have a pic ready */
    if(++is->pictq_windex == VIDEO_PICTURE_QUEUE_SIZE) {
      is->pictq_windex = 0;
    }
    SDL_LockMutex(is->pictq_mutex);
    is->pictq_size++;
    SDL_UnlockMutex(is->pictq_mutex);
  }
  return 0;
}

double synchronize_video(VideoState *is, AVFrame *src_frame, double pts) {

  double frame_delay;

  if(pts != 0) {
    /* if we have pts, set video clock to it */
    is->video_clock = pts;
  } else {
    /* if we aren't given a pts, set it to the clock */
    pts = is->video_clock;
  }
  /* update the video clock */
  frame_delay = av_q2d(is->video_ctx->time_base);
  /* if we are repeating a frame, adjust clock accordingly */
  frame_delay += src_frame->repeat_pict * (frame_delay * 0.5);
  is->video_clock += frame_delay;
  return pts;
}

int decode_video_thread(void *arg) {
  VideoState *is = (VideoState *)arg;
  AVPacket pkt1, *packet = &pkt1;
  int frameFinished;
  AVFrame *pFrame;
  double pts;

  pFrame = av_frame_alloc();

  for(;;) {
    if(packet_queue_get(&is->videoq, packet, 1) < 0) {
      // means we quit getting packets
      break;
    }
    pts = 0;

    // Decode video frame
    avcodec_decode_video2(is->video_ctx, pFrame, &frameFinished, packet);

    if((pts = av_frame_get_best_effort_timestamp(pFrame)) == AV_NOPTS_VALUE) {
      pts = 0;
    }
    pts *= av_q2d(is->video_st->time_base);

    // Did we get a video frame?
    if(frameFinished) {
      pts = synchronize_video(is, pFrame, pts);
      if(queue_picture(is, pFrame, pts) < 0) {
	break;
      }
    }
    av_free_packet(packet);
  }
  av_frame_free(&pFrame);
  return 0;
}

int stream_component_open(VideoState *is, int stream_index) {

  AVFormatContext *pFormatCtx = is->pFormatCtx;
  AVCodecContext *codecCtx = NULL;
  AVCodec *codec = NULL;
  SDL_AudioSpec wanted_spec, spec;

  if(stream_index < 0 || stream_index >= pFormatCtx->nb_streams) {
    return -1;
  }

  codecCtx = avcodec_alloc_context3(NULL);

  int ret = avcodec_parameters_to_context(codecCtx, pFormatCtx->streams[stream_index]->codecpar);
  if (ret < 0)
    return -1;

  codec = avcodec_find_decoder(codecCtx->codec_id);
  if(!codec) {
    fprintf(stderr, "Unsupported codec!\n");
    return -1;
  }


  if(codecCtx->codec_type == AVMEDIA_TYPE_AUDIO) {

    // Set audio settings from codec info
    wanted_spec.freq = codecCtx->sample_rate;
    wanted_spec.format = AUDIO_S16SYS;
    wanted_spec.channels = 2;//codecCtx->channels;
    wanted_spec.silence = 0;
    wanted_spec.samples = SDL_AUDIO_BUFFER_SIZE;
    wanted_spec.callback = audio_callback;
    wanted_spec.userdata = is;
    
    if(SDL_OpenAudio(&wanted_spec, &spec) < 0) {
      fprintf(stderr, "SDL_OpenAudio: %s\n", SDL_GetError());
      return -1;
    }
    is->audio_hw_buf_size = spec.size;
  }
  if(avcodec_open2(codecCtx, codec, NULL) < 0) {
    fprintf(stderr, "Unsupported codec!\n");
    return -1;
  }

  switch(codecCtx->codec_type) {
  case AVMEDIA_TYPE_AUDIO:
    is->audioStream = stream_index;
    is->audio_st = pFormatCtx->streams[stream_index];
    is->audio_ctx = codecCtx;
    is->audio_buf_size = 0;
    is->audio_buf_index = 0;
    memset(&is->audio_pkt, 0, sizeof(is->audio_pkt));
    packet_queue_init(&is->audioq);

    //Out Audio Param
    uint64_t out_channel_layout=AV_CH_LAYOUT_STEREO;

    //AAC:1024  MP3:1152
    int out_nb_samples= is->audio_ctx->frame_size;
    //AVSampleFormat out_sample_fmt = AV_SAMPLE_FMT_S16;

    int out_sample_rate=is->audio_ctx->sample_rate;
    int out_channels=av_get_channel_layout_nb_channels(out_channel_layout);
    //Out Buffer Size
    /*
    int out_buffer_size=av_samples_get_buffer_size(NULL,
                                                   out_channels,
                                                   out_nb_samples,
                                                   AV_SAMPLE_FMT_S16,
                                                   1);
                                                   */

    //uint8_t *out_buffer=(uint8_t *)av_malloc(MAX_AUDIO_FRAME_SIZE*2);
    int64_t in_channel_layout=av_get_default_channel_layout(is->audio_ctx->channels);

    struct SwrContext *audio_convert_ctx;
    audio_convert_ctx = swr_alloc();
    swr_alloc_set_opts(audio_convert_ctx,
                       out_channel_layout,
                       AV_SAMPLE_FMT_S16,
                       out_sample_rate,
                       in_channel_layout,
                       is->audio_ctx->sample_fmt,
                       is->audio_ctx->sample_rate,
                       0,
                       NULL);
    fprintf(stderr, "swr opts: out_channel_layout:%lld, out_sample_fmt:%d, out_sample_rate:%d, in_channel_layout:%lld, in_sample_fmt:%d, in_sample_rate:%d",
            out_channel_layout, AV_SAMPLE_FMT_S16, out_sample_rate, in_channel_layout, is->audio_ctx->sample_fmt, is->audio_ctx->sample_rate);
    swr_init(audio_convert_ctx);

    is->audio_swr_ctx = audio_convert_ctx;

    SDL_PauseAudio(0);
    break;
  case AVMEDIA_TYPE_VIDEO:
    is->videoStream = stream_index;
    is->video_st = pFormatCtx->streams[stream_index];
    is->video_ctx = codecCtx;

    is->frame_timer = (double)av_gettime() / 1000000.0;
    is->frame_last_delay = 40e-3;
    
    packet_queue_init(&is->videoq);
    is->video_sws_ctx = sws_getContext(is->video_ctx->width, is->video_ctx->height,
				 is->video_ctx->pix_fmt, is->video_ctx->width,
				 is->video_ctx->height, AV_PIX_FMT_YUV420P,
				 SWS_BILINEAR, NULL, NULL, NULL
				 );
    is->video_tid = SDL_CreateThread(decode_video_thread, "decode_video_thread", is);
    break;
  default:
    break;
  }
}

int demux_thread(void *arg) {

  Uint32 pixformat;

  VideoState *is = (VideoState *)arg;
  AVFormatContext *pFormatCtx;
  AVPacket pkt1, *packet = &pkt1;

  int video_index = -1;
  int audio_index = -1;
  int i;

  is->videoStream=-1;
  is->audioStream=-1;

  global_video_state = is;

  // Open video file
  if(avformat_open_input(&pFormatCtx, is->filename, NULL, NULL)!=0)
    return -1; // Couldn't open file

  is->pFormatCtx = pFormatCtx;
  
  // Retrieve stream information
  if(avformat_find_stream_info(pFormatCtx, NULL)<0)
    return -1; // Couldn't find stream information
  
  // Dump information about file onto standard error
  av_dump_format(pFormatCtx, 0, is->filename, 0);
  
  // Find the first video stream
  for(i=0; i<pFormatCtx->nb_streams; i++) {
    if(pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO &&
       video_index < 0) {
      video_index=i;
    }
    if(pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_AUDIO &&
       audio_index < 0) {
      audio_index=i;
    }
  }

  if(audio_index >= 0) {
    stream_component_open(is, audio_index);
  }
  if(video_index >= 0) {
    stream_component_open(is, video_index);
  }   

  if(is->videoStream < 0 || is->audioStream < 0) {
    fprintf(stderr, "%s: could not open codecs\n", is->filename);
    goto fail;
  }

  win = SDL_CreateWindow("Media Player",
     		   SDL_WINDOWPOS_UNDEFINED,
		   SDL_WINDOWPOS_UNDEFINED,
		   is->video_ctx->width, is->video_ctx->height,
		   SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE);
  
  renderer = SDL_CreateRenderer(win, -1, 0);

  pixformat = SDL_PIXELFORMAT_IYUV;
  texture = SDL_CreateTexture(renderer,
			      pixformat, 
			      SDL_TEXTUREACCESS_STREAMING,
			      is->video_ctx->width,
			      is->video_ctx->height);

  // main decode loop

  for(;;) {

    if(is->quit) {
      SDL_CondSignal(is->videoq.cond);
      SDL_CondSignal(is->audioq.cond);
      break;
    }
    // seek stuff goes here
    if(is->audioq.size > MAX_AUDIOQ_SIZE ||
       is->videoq.size > MAX_VIDEOQ_SIZE) {
      SDL_Delay(10);
      continue;
    }
    if(av_read_frame(is->pFormatCtx, packet) < 0) {
      if(is->pFormatCtx->pb->error == 0) {
	SDL_Delay(100); /* no error; wait for user input */
	continue;
      } else {
	break;
      }
    }
    // Is this a packet from the video stream?
    if(packet->stream_index == is->videoStream) {
      packet_queue_put(&is->videoq, packet);
    } else if(packet->stream_index == is->audioStream) {
      packet_queue_put(&is->audioq, packet);
    } else {
      av_free_packet(packet);
    }
  }
  /* all done - wait for it */
  while(!is->quit) {
    SDL_Delay(100);
  }

 fail:
  if(1){
    SDL_Event event;
    event.type = FF_QUIT_EVENT;
    event.user.data1 = is;
    SDL_PushEvent(&event);
  }
  return 0;
}

int main(int argc, char *argv[]) {

  int             ret = -1;

  SDL_Event       event;

  VideoState      *is;

  is = av_mallocz(sizeof(VideoState));

  if(argc < 2) {
    fprintf(stderr, "Usage: test <file>\n");
    exit(1);
  }
  // Register all formats and codecs
  av_register_all();
  
  if(SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_TIMER)) {
    fprintf(stderr, "Could not initialize SDL - %s\n", SDL_GetError());
    exit(1);
  }

  text_mutex = SDL_CreateMutex();

  av_strlcpy(is->filename, argv[1], sizeof(is->filename));

  is->pictq_mutex = SDL_CreateMutex();
  is->pictq_cond = SDL_CreateCond();

  schedule_refresh(is, 40);

  is->parse_tid = SDL_CreateThread(demux_thread, "demux_thread", is);
  if(!is->parse_tid) {
    av_free(is);
    goto __FAIL;
  }
  for(;;) {

    SDL_WaitEvent(&event);
    switch(event.type) {
    case FF_QUIT_EVENT:
    case SDL_QUIT:
      is->quit = 1;
      //SDL_Quit();
      //return 0;
      goto __QUIT;
      break;
    case FF_REFRESH_EVENT:
      video_refresh_timer(event.user.data1);
      break;
    default:
      break;
    }
  }

__QUIT:
  ret = 0;

__FAIL:

  SDL_Quit();
  /*
  if(audiofd){
    fclose(audiofd);
  }
  if(audiofd1){
    fclose(audiofd1);
  }
  */
  return ret;

}
``` 


#### 55.Android中使用FFmpeg

- Java与C之间的相互调用
- Android下FFmpeg的编译
- Android下如何使用FFmpeg
- JNI基本概念
    - JNIEnv Java本地化环境，C/C++要访问Java相关的代码都需要它
    - JavaVM  一个进程对于一个JavaVM，用于获取JNIEnv，一个JavaVM里边很多线程，一个线程对应一个JNIEnv
    - 线程
- [Java调用C/C++方法一](#Java调用C/C++)
    - 在Java层定义native关键字函数
    - 在C/C++层创建`Java_packname_classname_methodname`函数
- [Java调用C/C++方法二](#Java调用C/C++)
    - 在Java层定义native关键字函数
    - [RegisterNative](#方法二的定义)
        - Jnit JNI_OnLoad(JavaVM *vm, void* reserved)
        - Jint JNI_OnUnload(JavaVM *vm, void* reserved)
- 什么是Signature
    - Java与C/C++相互调用时，用于描述函数参数的描述符【可以理解为映射表的key】
    - 输入参数放在()内，输出参数放在()外
    - 多个参数之间顺序存放，且用`;`分割
- 原始类型的Signature

Java类型 | 符号
---|---
boolean | Z
byte    | B
char    | C
short   | S
int     | I
long    | L
float   | F
double  | D
void    | V

- 类的Signature
    - Java对象参数`L包路径/类名`
    - Java数组`[`
        -  ([Student;)[LStudent]  ==> Student[] Xxx(Student[])
        -  ([java/lang/String;)[Ljava/lang/Object  ==> Object[] Xxx(String[] s)

- [C/C++调Java方法](#C/C++调Java方法)
    - 1. FindClass 获取Java中的类
    - 2. GetMethodID / GetFieldID  获取Java类中所有的方法/属性
    - 3. NewObject  获取Java中的内存对象
    - 4. Call<TYPE>Method / [G/S]et<Type>Field
        

 ###### 方法二的定义

```c
typedef struct {
    const char* name; // 与Java定义的name同名
    const char* signature; // 标注输入输出参数
    void* fnPtr; // 具体API
}JNINativeMethod;
```

 ###### Java调用C/C++
 
- C++端代码
```c++
#include <jni.h>
#include <string>

#define JNI_CLASS_PATH "com/muziyu/apple/firstjni/MainActivity"

extern "C" JNIEXPORT jstring JNICALL
Java_com_muziyu_apple_firstjni_MainActivity_stringFromJNI(
        JNIEnv *env,
        jobject /* this */) {
    std::string hello = "Hello from C++";
    return env->NewStringUTF(hello.c_str());
}

/// 方法一
extern "C"
JNIEXPORT jstring JNICALL
Java_com_muziyu_apple_firstjni_MainActivity_mStringFromJNI(JNIEnv *env, jobject thiz, jstring str) {
    // TODO: implement mStringFromJNI()
    const char *mStr = env->GetStringUTFChars(str, 0);
    env->ReleaseStringUTFChars(str, mStr);
    return env->NewStringUTF(mStr);
}

/// 方法二
extern "C"
JNIEXPORT jstring JNICALL
my_test_register(JNIEnv *env, jobject thiz) { /// 实现一个Native对应的函数
    return env->NewStringUTF("This is a test of register!");
}

static JNINativeMethod g_methods[] = { /// 定义了一个静态方法，第一个参数是Java端定义的Native的方法名，第二个参数是一个输入输出参数
    { "_test","()Ljava/lang/String;", (void*)my_test_register },
};

jint JNI_OnLoad(JavaVM *vm, void *reserved) {
    JNIEnv *env = NULL;
    vm->GetEnv((void**)&env, JNI_VERSION_1_6); /// 获取Java虚拟机环境
    jclass clazz = env->FindClass(JNI_CLASS_PATH); /// 根据Java端的类路径在C/C++层创建这个类
    env->RegisterNatives(clazz, g_methods, sizeof(g_methods)/sizeof(g_methods[0])); /// 在Java虚拟机里建立C/C++到Java的映射关系
    return JNI_VERSION_1_6;
}
```

- Java端代码
```java
package com.muziyu.apple.firstjni;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {

    // Used to load the 'native-lib' library on application startup.
    static {
        System.loadLibrary("native-lib");
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Example of a call to a native method
        TextView tv = findViewById(R.id.sample_text);
        String hello = stringFromJNI() + mStringFromJNI("ABC") + ' ' + _test();
        tv.setText(hello);
    }

    /**
     * A native method that is implemented by the 'native-lib' native library,
     * which is packaged with this application.
     */
    public native String stringFromJNI();

    // 方法一
    public native String mStringFromJNI(String str);

    // 方法二
    public native String _test();
}
```

 C/C++调Java方法
 
- Java主入口
 
```java
package com.muziyu/apple.firstjni;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {

    // Used to load the 'native-lib' library on application startup.
    static {
        System.loadLibrary("native-lib");
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Example of a call to a native method
        TextView tv = findViewById(R.id.sample_text);
        String hello = mTest();
        tv.setText(hello);
    }

    /**
     * A native method that is implemented by the 'native-lib' native library,
     * which is packaged with this application.
     */
    // C/C++调用Java
    public native String mTest();

}

```

- Java外部类

```java
package com.muziyu/apple.firstjni;

public class Student {
    private int year;

    public int getYear() {
        return year;
    }

    public void setYear(int year) {
        this.year = year;
    }

}

```


- C/C++代码
```c
#include <jni.h>
#include <string>

#define JNI_CLAZZ_PATH "com/muziyu/apple/firstjni/Student"

// C/C++调用Java
extern "C"
JNIEXPORT jstring JNICALL
Java_com_muziyu_apple_firstjni_MainActivity_mTest(JNIEnv *env, jobject thiz) {
    /// 第一步：获取Java类
    jclass clazz = env->FindClass(JNI_CLAZZ_PATH);
    /// 第二步：获取Java类中的方法和属性
    jmethodID method_init_id = env->GetMethodID(clazz, "<init>", "()V");
    jmethodID method_set_id = env->GetMethodID(clazz, "setYear", "(I)V");
    jmethodID method_get_id = env->GetMethodID(clazz, "getYear", "()I");
    /// 第三步：生成一个新的对象
    jobject obj = env->NewObject(clazz, method_init_id);
    /// 第四步：调用Java中的方法
    env->CallVoidMethod(obj, method_set_id, 18);
    int year = env->CallIntMethod(obj, method_get_id);

    char tmp [50];
    sprintf(tmp, "%d", year);
    std::string hello = "Hello from C++, year=";
    hello.append(tmp);
    return env->NewStringUTF(hello.c_str());
}
```


#### 56.Android下的播放器

```
# 设置CMake版本
cmake_minimum_required(VERSION 3.4.1)

# 新增的Lib库：第一个参数是自己定义的名字，第二参数是指定是动态库(.so)还是静态库(.a)，第三个参数是Lib的路径
add_library(
        native-lib
        SHARED
        native-lib.cpp)

# 指定ffmpeg编译好之后的Lib库目录
set(JNI_LIBS_DIR ${CMAKE_SOURCE_DIR}/src/main/jniLibs)

# 在系统下找对应的Lib库
find_library(
        log-lib
        log)
find_library(
        android-lib
        android)

# 引入FFmpeg中的libavutil
add_library(
        avutil
        SHARED
        native-lib.cpp)

set_target_properties(
                avutil
                PROPERTIES IMPORTED_LOCATION
                ${JNI_LIBS_DIR}/${ANDROID_ABI}/libavutil.so)

# 引入FFmpeg中的libswresample            
add_library(
        swresample
        SHARED
        native-lib.cpp)

set_target_properties(
                avutil
                PROPERTIES IMPORTED_LOCATION
                ${JNI_LIBS_DIR}/${ANDROID_ABI}/libswresample.so)

# 引入FFmpeg中的libswscale
add_library(
        swscale
        SHARED
        native-lib.cpp)

set_target_properties(
                avutil
                PROPERTIES IMPORTED_LOCATION
                ${JNI_LIBS_DIR}/${ANDROID_ABI}/libswscale.so)

# 引入FFmpeg中的libavcodec            
add_library(
        avcodec
        SHARED
        native-lib.cpp)

set_target_properties(
                avutil
                PROPERTIES IMPORTED_LOCATION
                ${JNI_LIBS_DIR}/${ANDROID_ABI}/libavcodec.so)

# 引入FFmpeg中的libavformat
add_library(
        avformat
        SHARED
        native-lib.cpp)

set_target_properties(
                avutil
                PROPERTIES IMPORTED_LOCATION
                ${JNI_LIBS_DIR}/${ANDROID_ABI}/libavformat.so)

# 引入FFmpeg中的libavfilter
add_library(
        avfilter
        SHARED
        native-lib.cpp)

set_target_properties(
                avutil
                PROPERTIES IMPORTED_LOCATION
                ${JNI_LIBS_DIR}/${ANDROID_ABI}/libavfilter.so)
                
# 引入FFmpeg中的libavdevice
add_library(
        avdevice
        SHARED
        native-lib.cpp)

set_target_properties(
                avutil
                PROPERTIES IMPORTED_LOCATION
                ${JNI_LIBS_DIR}/${ANDROID_ABI}/libavdevice.so)
      
# 设置第三方lib库的头文件路径          
include_directories(${JNI_LIBS_DIR}/includes)

# 链接所有Lib库
target_link_libraries(
            native-lib
            avutil swresample swscale avcodec avformat avfilter avdevice
            ${log-lib} ${android-lib})
```


#### 57.IOS下使用FFmpeg

- build-ffmpeg.sh

```bash
#!/bin/sh

# directories
FF_VERSION="4.2"
#FF_VERSION="snapshot-git"
if [[ $FFMPEG_VERSION != "" ]]; then
  FF_VERSION=$FFMPEG_VERSION
fi
SOURCE="ffmpeg-$FF_VERSION"
FAT="FFmpeg-iOS"

SCRATCH="scratch"
# must be an absolute path
THIN=`pwd`/"thin"

# absolute path to x264 library
#X264=`pwd`/fat-x264

#FDK_AAC=`pwd`/../fdk-aac-build-script-for-iOS/fdk-aac-ios

CONFIGURE_FLAGS="--enable-cross-compile --disable-debug --disable-programs \
                 --disable-doc --enable-pic"

if [ "$X264" ]
then
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-gpl --enable-libx264"
fi

if [ "$FDK_AAC" ]
then
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-libfdk-aac --enable-nonfree"
fi

# avresample
#CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-avresample"

ARCHS="arm64 armv7 x86_64 i386"

COMPILE="y"
LIPO="y"

DEPLOYMENT_TARGET="8.0"

if [ "$*" ]
then
	if [ "$*" = "lipo" ]
	then
		# skip compile
		COMPILE=
	else
		ARCHS="$*"
		if [ $# -eq 1 ]
		then
			# skip lipo
			LIPO=
		fi
	fi
fi

if [ "$COMPILE" ]
then
	if [ ! `which yasm` ]
	then
		echo 'Yasm not found'
		if [ ! `which brew` ]
		then
			echo 'Homebrew not found. Trying to install...'
                        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" \
				|| exit 1
		fi
		echo 'Trying to install Yasm...'
		brew install yasm || exit 1
	fi
	if [ ! `which gas-preprocessor.pl` ]
	then
		echo 'gas-preprocessor.pl not found. Trying to install...'
		(curl -L https://github.com/libav/gas-preprocessor/raw/master/gas-preprocessor.pl \
			-o /usr/local/bin/gas-preprocessor.pl \
			&& chmod +x /usr/local/bin/gas-preprocessor.pl) \
			|| exit 1
	fi

	if [ ! -r $SOURCE ]
	then
		echo 'FFmpeg source not found. Trying to download...'
		curl http://www.ffmpeg.org/releases/$SOURCE.tar.bz2 | tar xj \
			|| exit 1
	fi

	CWD=`pwd`
	for ARCH in $ARCHS
	do
		echo "building $ARCH..."
		mkdir -p "$SCRATCH/$ARCH"
		cd "$SCRATCH/$ARCH"

		CFLAGS="-arch $ARCH"
		if [ "$ARCH" = "i386" -o "$ARCH" = "x86_64" ]
		then
		    PLATFORM="iPhoneSimulator"
		    CFLAGS="$CFLAGS -mios-simulator-version-min=$DEPLOYMENT_TARGET"
		else
		    PLATFORM="iPhoneOS"
		    CFLAGS="$CFLAGS -mios-version-min=$DEPLOYMENT_TARGET -fembed-bitcode"
		    if [ "$ARCH" = "arm64" ]
		    then
		        EXPORT="GASPP_FIX_XCODE5=1"
		    fi
		fi

		XCRUN_SDK=`echo $PLATFORM | tr '[:upper:]' '[:lower:]'`
		CC="xcrun -sdk $XCRUN_SDK clang"

		# force "configure" to use "gas-preprocessor.pl" (FFmpeg 3.3)
		if [ "$ARCH" = "arm64" ]
		then
		    AS="gas-preprocessor.pl -arch aarch64 -- $CC"
		else
		    AS="gas-preprocessor.pl -- $CC"
		fi

		CXXFLAGS="$CFLAGS"
		LDFLAGS="$CFLAGS"
		if [ "$X264" ]
		then
			CFLAGS="$CFLAGS -I$X264/include"
			LDFLAGS="$LDFLAGS -L$X264/lib"
		fi
		if [ "$FDK_AAC" ]
		then
			CFLAGS="$CFLAGS -I$FDK_AAC/include"
			LDFLAGS="$LDFLAGS -L$FDK_AAC/lib"
		fi

		TMPDIR=${TMPDIR/%\/} $CWD/$SOURCE/configure \
		    --target-os=darwin \
		    --arch=$ARCH \
		    --cc="$CC" \
		    --as="$AS" \
		    $CONFIGURE_FLAGS \
		    --extra-cflags="$CFLAGS" \
		    --extra-ldflags="$LDFLAGS" \
		    --prefix="$THIN/$ARCH" \
		|| exit 1

		make -j3 install $EXPORT || exit 1
		cd $CWD
	done
fi

if [ "$LIPO" ]
then
	echo "building fat binaries..."
	mkdir -p $FAT/lib
	set - $ARCHS
	CWD=`pwd`
	cd $THIN/$1/lib
	for LIB in *.a
	do
		cd $CWD
		echo lipo -create `find $THIN -name $LIB` -output $FAT/lib/$LIB 1>&2
		lipo -create `find $THIN -name $LIB` -output $FAT/lib/$LIB || exit 1
	done

	cd $CWD
	cp -rf $THIN/$1/include $FAT
fi

echo Done
``` 


#### 58.音视频进阶

- FFmpeg Filter的使用与开发
- FFmpeg裁剪与优化
- 视频渲染(OpenGL / Metal)
- 声音特效
- 网络传输
- WebRTC 在浏览器之间进行P2P的传输，视频会议
- AR技术
- OpenCV 
- 回音消除
- 降噪
- 视频秒开
- 多人多视频实时互动

