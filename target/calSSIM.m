clc;clear;close all;
%addpath('.\nita');
 addpath('.\samplingRemoveBG');

% 原始目标
Originaltarget = 'target.png';

% 遍历目录下文件图像数据类型 '*.png' '*.jpg'
fileType = '*.png';
%dir_path = '.\nita';
 dir_path = '.\samplingRemoveBG';
file_list = dir(fullfile(dir_path, fileType));

ssim_Target = zeros(1,length(file_list));
% Read in the image
for i = 1:length(file_list)
    % 修改数据文件名
    targetComparedName = fullfile(dir_path, file_list(i).name);
    disp(targetComparedName);
    % Get a list of all the image files in the directory

    % 读入原始目标图像
    im_original = (imread(Originaltarget));
    %figure();imshow(im_original);
    % 读入重建目标图像
    im_resconst = (imread(targetComparedName));
    %figure();imshow(im_resconst);

    % 计算重建结果缩放比例
    scale = size(im_original, 1) / size(im_resconst, 1);
    %distanceR = 3000;
    % 对近距离红外图像进行缩放
    im_resconst_scale = imresize(im_resconst(:,:,1), scale);
    %figure();imshow(im_resconst_scale);
    % 进行距离补偿
    %im_far = im_far .*0.7;
    % 进行图像增强
    %im_far = adapthisteq(im_far);
    
    im_original       = im2double(im_original);
    im_resconst_scale = im2double(im_resconst_scale);


    % 计算结构相似度
    ssim_value = ssim(im_original,im_resconst_scale);

    % 显示结果
    % figure;
    % imshow(im_near);
    % title('近距离红外图像');
    % figure;
    % imshow(im_far);
    % title('一定远距离处的红外图像');
    % 显示结果
    disp(['结构相似度为：',num2str(ssim_value)]);
    ssim_Target(i) = ssim_value;
end

% 默认制表符分隔（.txt 常用）
fname = fullfile('cal_SSIM_result.txt');
writematrix(ssim_Target(:), fname);