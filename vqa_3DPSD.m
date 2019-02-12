function score = vqa_3DPSD(yuv_org, yuv_dst, fheight, fwidth, nframes, nframes_per_tensor, yuv_fmt)
%%
%  Author:              Gukyeong Kwon
%  Version:             1.0
%  Publication title:   Power of tempospatially unified spectral density for perceptual video quality assessment
%  Publication details  2017 IEEE International Conference on Multimedia and Expo (ICME), Hong Kong, 2017, pp. 1476-1481.
%% 
% Args:
%     yuv_org: Path of original yuv video. 
%     yuv_dst: Path of distorted yuv video.
%     fheight: Frame height
%     fwidth: Frame width
%     nframes: Total number of frames in the video
%     nframes_per_tensor: Number of frames in each tensor
%     yuv_fmt: YUV sampling format
% Return:
%     score: Estimated object video quality score
%%

    if strcmp(yuv_fmt,'400')
        fw = 0;
        fh= 0;
    elseif strcmp(yuv_fmt,'411')
        fw = 0.25;
        fh= 1;
    elseif strcmp(yuv_fmt,'420')
        fw = 0.5;
        fh= 0.5;
    elseif strcmp(yuv_fmt,'422')
        fw = 0.5;
        fh= 1;
    elseif strcmp(yuv_fmt,'444')
        fw = 1;
        fh= 1;
    else
        display('Error: wrong format');
    end


    tensor_frame_idx = 1 : nframes_per_tensor : nframes;
    if rem(nframes, nframes_per_tensor) ~= 0
        tensor_frame_idx = tensor_frame_idx(1 : end - 1);
    end

    tensor_org = zeros(fheight, fwidth, nframes_per_tensor);
    tensor_dst = zeros(fheight, fwidth, nframes_per_tensor);

    PSD_org_sum = zeros(length(tensor_frame_idx), fheight, fwidth); % Anchor 2D TPSD planes
    PSD_dst_sum = zeros(length(tensor_frame_idx), fheight, fwidth); % Distorted 2D TPSD planes

    ST_PSD = zeros(length(tensor_frame_idx), 1); % tensor-level video quality score

    for tensorID = 1 : length(tensor_frame_idx)

        fprintf('3D PSD calculation (tensor %d / %d)... \n', tensorID, length(tensor_frame_idx));

        % Loading a tensor
        for i =1 : nframes_per_tensor

            tmp_frame_org = double(loadFileYUV(fwidth, fheight, tensor_frame_idx(tensorID) + i - 1, yuv_org, fh, fw));
            tensor_org (:,:,i) = tmp_frame_org(:,:,1);

            tmp_frame_dst = double(loadFileYUV(fwidth, fheight, tensor_frame_idx(tensorID) + i - 1, yuv_dst, fh, fw));
            tensor_dst(:,:,i) = tmp_frame_dst(:,:,1);

        end

        % Calculate 2D TPSD plane
        PSD_org = log(fftshift(abs(fftn(tensor_org)).^2)+eps); 
        PSD_org_sum(tensorID, :, :) = sum(PSD_org,3); 

        PSD_dst = log(fftshift(abs(fftn(tensor_dst)).^2)+eps);         
        PSD_dst_sum(tensorID, :, :) = sum(PSD_dst,3);

        % Calculate tensor-level video quality scores using the local cross-correlation
        ST_PSD(tensorID) = CrossCorre(squeeze(PSD_org_sum(tensorID,:,:)), squeeze(PSD_dst_sum(tensorID,:,:)));        

    end
    % An overall video quality score
    score = mean(ST_PSD);

end

