# 基于MIT-kemar数据集的虚拟声场
能够实现简单的环绕空间声，使用正常耳廓，1通道的hrir

过程性文档：
1. 在matlab中使用websave从[Index of /data/database/mit (sofacoustics.org)](https://sofacoustics.org/data/database/mit/)下载数据集
2. 下载SOFA工具箱，SOFA为AES协会标准化的一种空间定向声学 数据文件格式，包含有众多HRTFs和双耳或 空间房间脉冲响应（BRIRs, SRIRs）数据库。
	[SOFA download | SourceForge.net](https://sourceforge.net/projects/sofacoustics/)
3. 使用audioread方法读取音频，接受.wav格式和.mp3格式
4. 使用SOFAload方法加载HRIR数据
5. 校准，如果音频的采样率与hrir不一致，使用resample方法重采样，统一采样率
6. 使用buffer对信号进行分帧，设定50%帧移，为防止频谱泄露，加窗，这里使用了汉明窗
7. 将信号帧与对应角度的hrir进行卷积，重叠相加
8. 保存
