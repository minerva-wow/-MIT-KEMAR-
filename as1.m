%基于 Matlab 完成虚拟环绕声的算法实现。 要求:基于 MIT的人工头 HRIR 数据生成一段360度虚拟环绕声。
% 虚拟声源为单声源，频谱动态的声源信号(语音或音乐)，声源按顺时针/逆时针以正常速度绕聆听者为中心转
% 动(声源转动无停顿，旋转一圈以上)。
clc;
% 添加路径
addpath(genpath(pwd));
% 读取声源音频文件
[x, signal_fs] = audioread('1.mp3'); % 替换为你的音频文件名


%% 加载 HRIR 数据
hrirObj = SOFAload('.\mit_kemar_normal_pinna.sofa');
hrirs = double(hrirObj.Data.IR(:,:,1:256));%此矩阵中包含球面上710个采样位置下的HRIR数据,出于计算效率，需求，取前一半主要部分。
hrir_fs=hrirObj.Data.SamplingRate;%脉冲响应采样率
ir_len=size(hrirs,3);%脉冲响应长度

%% 校准
%调整采样率
if signal_fs~= hrir_fs
    fsgcd = gcd(signal_fs,hrir_fs);%fsgcd为两个采样率的最大公约数
    x_res = resample(x(:,1), hrir_fs/fsgcd, signal_fs/fsgcd);%重采样
else
   x_res=x(:,1);
end

% 音频的点数
x_len = length(x_res);

% 旋转角度
angle = 720;
% 每帧旋转的角度
angle_per_frame = 5;
% 旋转的帧数
frame_num = angle / angle_per_frame;
% 计算合适的帧长，50%的帧移
frame_len = round(2*x_len/frame_num); 
% 对信号进行分帧
frames = buffer(x_res, frame_len, round(frame_len/2), 'nodelay');
% 为了避免频谱泄露，加窗,这里使用汉明窗
win = hamming(frame_len);
frames = frames .* win;

%% 生成对应角度的HRIR矩阵索引，刚好在0-360度的方位角之间间隔5度采样，共72个点，暂时不考虑大小耳廓的影响
index=261:1:332; 
% 方向，1 为顺时针，0 为逆时针
direction = 0;


%% 生成虚拟环绕声
y = zeros((x_len+frame_len),2); % 初始化输出
for i = 1:frame_num
    hrir_index = mod(i-1,72)+1; % 72个方位角
    if direction == 1
        hrir_index = 73 - hrir_index;
    end
    % 每一帧和对应的HRIR数据进行卷积
    y_frame = zeros(frame_len,2);
    y_frame(:,1) = conv(frames(:,i), reshape(hrirs(index(hrir_index),1,:),ir_len,1),"same");
    y_frame(:,2) = conv(frames(:,i), reshape(hrirs(index(73-hrir_index),1,:),ir_len,1),"same");
    % 重叠相加
    y((i-1)*round(frame_len/2)+1:(i-1)*round(frame_len/2)+frame_len,:) = y((i-1)*round(frame_len/2)+1:(i-1)*round(frame_len/2)+frame_len,:) + y_frame; 
end

%% 保存结果
audiowrite(['output_', num2str(direction), '.wav'], y, hrir_fs);



