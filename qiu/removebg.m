clc;clear;close all;

 addpath('.\sampling');
% 遍历目录下文件图像数据类型 '*.png' '*.jpg'
fileType = '*.png';
%dir_path = '.\nita';
 dir_path = '.\sampling';
file_list = dir(fullfile(dir_path, fileType));

ssim_Target = zeros(1,length(file_list));
% Read in the image
for i = 1:length(file_list)
    % 修改数据文件名
    targetComparedName = fullfile(dir_path, file_list(i).name);
    disp(targetComparedName);
    % Get a list of all the image files in the directory

    % 读入重建目标图像
    im_original = (imread(targetComparedName));

% 如果图像是彩色的，转换为灰度图像
if size(im_original, 3) == 3
    im_original = rgb2gray(im_original);
end

% 使用Otsu方法自动找到合适的阈值
level = 0.3*graythresh(im_original);
%level = 0.095;
%level = 0.17;
%level = 0.30;

%% 去除背景
im_original(im_original<level*255) = 0;
figure();imshow(im_original);

% 修改数据文件名
targetComparedName1 = fullfile('.\samplingRemoveBG', file_list(i).name);
imwrite(im_original,targetComparedName1);

% 使用找到的阈值将图像二值化
BW = imbinarize(im_original, level);

% 此时BW是一个二值图像，其中目标区域是白色(值为1)，背景是黑色(值为0)
% 如果目标比背景暗，则需要反转BW
% if mean(BW(:)) > 0.5 % 说明图像中白色区域较多，可能是背景
%     BW = ~BW;
% end

% 显示原图和二值化结果
figure();
imshowpair(im_original, BW, 'montage');

% 可选：提取目标区域的像素位置或属性
stats = regionprops(BW, 'BoundingBox', 'Area', 'PixelIdxList');

% 例如，显示最大区域的目标
[~, largestIdx] = max([stats.Area]);
rectangle('Position', stats(largestIdx).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 2);

% 如果需要提取原图中的目标区

end