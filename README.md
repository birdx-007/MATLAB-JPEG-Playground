# MATLAB JPEG Playground

本仓库展示了基于JPEG有损压缩算法开发的一些有趣小玩意儿，有灵感了就更新。

环境：MATLAB R2021A

## 文件目录清单

| 文件/目录名称  | 功能                                         |
| -------------- | -------------------------------------------- |
| ./data/        | 存放输入/输出数据                            |
| ./deprecated/  | 存放已弃用的性能较差的代码                   |
| ./lib/jpeg/    | 存放JPEG算法函数，基础库（目前只支持灰度图） |
| ./jpeg2music.m | 将JPEG图像文件解码为音频文件                 |
| ./music2jpeg.m | 将音频文件压缩编码为JPEG图像文件             |
| ./test.mlx     | 测试用                                       |

## JPEG基础库函数接口文档-API doc

### zigzag8

针对8*8矩阵的之字形扫描。

```matlab
y=zigzag8(x)
```

y	之字形扫描结果，8*8矩阵

x	之字形扫描输入，64*1列向量

### izigzag8

针对8*8矩阵的逆之字形扫描。

```matlab
x=izigzag8(y)
```

x	逆之字形扫描结果，64*1列向量

y	逆之字形扫描输入，8*8矩阵

### encodeHuffmanTable

将Huffman码表编码为JPEG文件DHT块中使用的码流（数据段）。

```matlab
code=encodeHuffmanTable(type,table)
```

code	编码结果，与JPEG文件中的码流格式一致

type	码表类型，只有0（DC）和1（AC）两个值

table	码表，格式如下：

DC码表的每一行：Category | 码长L  | 长度为L的码+占位用的0

AC码表的每一行：Run | Size | 码长L  | 长度为L的码+占位用的0

此外，需保证码长L从上到下不严格递增

### decodeHuffmanTable

将JPEG文件DHT块中使用的码流解码为Huffman码表。

```matlab
table=decodeHuffmanTable(type,bitscnt,vals)
```

table	码表，格式见**encodeHuffmanTable**的说明

type	码表类型，只有0（DC）和1（AC）两个值

bitscnt	码长为L的码的数量，为DHT块数据段的前16个字节

vals	编码内容，对应DC码表的Category或AC码表中的Run*16+Size，为DHT块数据段的剩余部分

### jpegPreEncode

对灰度图像的2D灰度值矩阵进行分块、DCT、量化、之字形扫描，为熵编码做准备。

```matlab
[qResult,H,W]=jpegPreEncode(matrix2D,QT)
```

qResult	量化结果，64*(块数) 矩阵，可直接用于熵编码

H	图像原始高度

W	图像原始宽度

matrix2D	图像灰度值矩阵，H*W矩阵

QT	量化表，8*8矩阵

### jpegPostDecode

对熵解码结果进行逆之字形扫描、反量化、IDCT、拼接，得到JPEG图像2D灰度值矩阵。

```matlab
matrix2D=jpegPostDecode(dResult,H,W,QT)
```

matrix2D	JPEG图像灰度值矩阵，H*W矩阵

dResult	熵解码结果，64*(块数) 矩阵

H	图像原始高度

W	图像原始宽度

QT	量化表，8*8矩阵

### jpegEntropyEncode

将**jpegPreEncode**结果熵编码为JPEG文件中使用的码流。

```matlab
code=jpegEntropyEncode(qResult,DCHT,ACHT)
```

code	码流，与JPEG文件中使用码流格式一致

qResult	量化结果，64*(块数) 矩阵

DCHT	DC系数的Huffman码表

ACHT	AC系数的Huffman码表

### jpegEntropyDecode

将JPEG文件中使用的码流熵解码为 64*(块数) 系数矩阵。

```matlab
dResult=jpegEntropyDecode(code,DCHT,ACHT)
```

dResult	熵解码结果，64*(块数) 矩阵

code	码流，与JPEG文件中使用码流格式一致

DCHT	DC系数的Huffman码表

ACHT	AC系数的Huffman码表

### jpegFileEncode

将 64*(块数) 系数矩阵压缩编码为JPEG文件。

```matlab
jpegFileEncode(filename,qResult,info)
```

filename	输出JPEG文件的目录-文件名

qResult	量化结果，64*(块数) 矩阵

info	图像信息，结构体，格式可参考./lib/jpeg/info_template.mat

### jpegFileDecode

将JPEG文件解码为 64*(块数) 系数矩阵和图像信息结构体。

```matlab
[dResult,info]=jpegFileDecode(filename)
```

dResult	64*(块数) 系数矩阵

info	图像信息，结构体，格式可参考./lib/jpeg/info_template.mat

filename	输入JPEG文件的目录-文件名

### mat2jpeg

将2D灰度值矩阵压缩编码为JPEG文件。

```matlab
mat2jpeg(matrix2D,filename)
```

matrix2D	图像灰度值矩阵

filename	输出JPEG文件的目录-文件名

### jpeg2mat

将JPEG文件解码为2D灰度值矩阵。

```matlab
matrix2D=jpeg2mat(filename)
```

matrix2D	图像灰度值矩阵

filename	输入JPEG文件的目录-文件名
