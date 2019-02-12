% This code is written for video inputs in a YUV format.

yuv_org = './hc_org.yuv'; % original video path
yuv_dst = './hc_r1.yuv'; % distorted video path

fwidth = 1280; % Frame width
fheight = 720; % Frame height
nframes = 450; % Total number of frames
nframes_per_tensor = 30; % Number of frames in each tensor
yuv_fmt = '420'; % YUV format

% Objective quality score calculation
score = vqa_3DPSD(yuv_org, yuv_dst, fheight, fwidth, nframes, nframes_per_tensor, yuv_fmt);
fprintf('Video quality score: %.3f\n', score);
