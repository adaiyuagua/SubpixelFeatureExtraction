

%% ===================== 固定内部参数，不放到界面 =====================

% workDir = "C:\Users\ZC\Desktop\万星呈论文\毕业设计\弱小目标\微扫";
% cd(workDir);

%picname = strcat('.\不同模糊程度\不同波段\7.7-9.5\F_0.5.png');
%picname = strcat('.\不同模糊程度\不同波段\7.7-9.5\球\F_0.5.png');
picname = strcat('.\tar.png');

% 一个低分辨率像素对应 mScale × mScale 个精细网格
mScale = 40;

% 原始目标所在低分辨率像素位置
targetPositionRow = 64;
targetPositionCol = 64;

% 希望观测的低分辨率像素位置
MoveToRow = 61;
MoveToCol = 61;

% 目标运动方向
% MATLAB 图像坐标中，行号向下增加
% -1 表示目标向上运动
% +1 表示目标向下运动
targetMotionSignY = -1;

% 平台水平扫描方向
% +1 表示图像相对像素网格向右移动
% -1 表示图像相对像素网格向左移动
platformScanSignX = 1;

%% ===================== 创建界面 =====================

mainFig = uifigure( ...
    'Name', '目标运动等效微扫描差分重建', ...
    'Position', [100 80 1250 720]);

mainGrid = uigridlayout(mainFig, [2, 2]);
mainGrid.ColumnWidth = {330, '1x'};
mainGrid.RowHeight = {'1x', 70};
mainGrid.Padding = [10 10 10 10];
mainGrid.ColumnSpacing = 10;
mainGrid.RowSpacing = 10;

%% ===================== 左侧参数区 =====================

paramPanel = uipanel(mainGrid, 'Title', '参数');
paramPanel.Layout.Row = 1;
paramPanel.Layout.Column = 1;

paramGrid = uigridlayout(paramPanel, [24, 2]);
paramGrid.ColumnWidth = {150, '1x'};
paramGrid.RowHeight = { ...
    26, ...
    24,24,24,24,24,24, ...
    26, ...
    24,24,24, ...
    26, ...
    24,24,24,24, ...
    35, ...
    '1x','1x','1x','1x','1x','1x','1x'};
paramGrid.Padding = [10 10 10 10];
paramGrid.RowSpacing = 5;
paramGrid.ColumnSpacing = 8;

%% ---------- 固定参数 ----------

labelFixed = uilabel(paramGrid, ...
    'Text', '固定参数', ...
    'FontWeight', 'bold');
labelFixed.Layout.Column = [1 2];

uilabel(paramGrid, 'Text', 'F');
FField = uieditfield(paramGrid, 'numeric', 'Value', 0.5);
FField.Editable = 'off';

uilabel(paramGrid, 'Text', '焦距 / mm');
fField = uieditfield(paramGrid, 'numeric', 'Value', 300);
fField.Editable = 'off';

uilabel(paramGrid, 'Text', '像元尺寸 / μm');
pixelSizeField = uieditfield(paramGrid, 'numeric', 'Value', 15);
pixelSizeField.Editable = 'off';

uilabel(paramGrid, 'Text', '分辨率');
resolutionField = uieditfield(paramGrid, 'text', 'Value', '128 × 128');
resolutionField.Editable = 'off';

uilabel(paramGrid, 'Text', '波段 / μm');
wavebandField = uieditfield(paramGrid, 'text', 'Value', '10 - 14');
wavebandField.Editable = 'off';

uilabel(paramGrid, 'Text', '瞬时视场角 / μrad');
IFOVField = uieditfield(paramGrid, 'numeric', 'Value', 50);
IFOVField.Editable = 'off';

%% ---------- 可调参数 ----------

labelAdjust = uilabel(paramGrid, ...
    'Text', '可调参数', ...
    'FontWeight', 'bold');
labelAdjust.Layout.Column = [1 2];

uilabel(paramGrid, 'Text', '横向每行扫的位置数');
horizontalSampleNumField = uieditfield(paramGrid, 'numeric', 'Value', scanNum);

uilabel(paramGrid, 'Text', '纵向扫的位置数');
verticalSampleNumField = uieditfield(paramGrid, 'numeric', 'Value', scanNum);

uilabel(paramGrid, 'Text', '积分时间 / ms');
integrationTimeField = uieditfield(paramGrid, 'numeric', 'Value', 20);

%% ---------- 计算参数 ----------

labelCalc = uilabel(paramGrid, ...
    'Text', '计算参数', ...
    'FontWeight', 'bold');
labelCalc.Layout.Column = [1 2];

uilabel(paramGrid, 'Text', '总采样数（含参考帧）');
totalFrameNumField = uieditfield(paramGrid, 'numeric', 'Value', 400);
totalFrameNumField.Editable = 'off';

uilabel(paramGrid, 'Text', '完整微扫描时间 / s');
microScanTimeField = uieditfield(paramGrid, 'numeric', 'Value', 4);
microScanTimeField.Editable = 'off';

uilabel(paramGrid, 'Text', '目标像面速度 / pixel/s');
targetVelocityField = uieditfield(paramGrid, 'numeric', 'Value', 0.25);
targetVelocityField.Editable = 'off';

uilabel(paramGrid, 'Text', '每次积分位移 / pixel');
targetMovePerIntegrationField = uieditfield(paramGrid, 'numeric', 'Value', 0.0025);
targetMovePerIntegrationField.Editable = 'off';

%% ---------- 启动按钮 ----------

startButton = uibutton(paramGrid, ...
    'push', ...
    'Text', '启动重建', ...
    'FontWeight', 'bold');

startButton.Layout.Column = [1 2];

statusText = uitextarea(paramGrid, ...
    'Value', {'等待启动重建。'}, ...
    'Editable', 'off');
statusText.Layout.Column = [1 2];
statusText.Layout.Row = [18 24];

%% ===================== 右侧图像显示区 =====================

imagePanel = uipanel(mainGrid, 'Title', '图像显示');
imagePanel.Layout.Row = 1;
imagePanel.Layout.Column = 2;

imageGrid = uigridlayout(imagePanel, [1, 2]);
imageGrid.ColumnWidth = {'1x', '1x'};
imageGrid.Padding = [10 10 10 10];
imageGrid.ColumnSpacing = 10;

axTarget = uiaxes(imageGrid);
axTarget.Layout.Row = 1;
axTarget.Layout.Column = 1;
title(axTarget, '原始目标图像 targetData');
axis(axTarget, 'image');
axTarget.XTick = [];
axTarget.YTick = [];
colormap(axTarget, 'gray');

axRecon = uiaxes(imageGrid);
axRecon.Layout.Row = 1;
axRecon.Layout.Column = 2;
title(axRecon, '微扫描差分重构 calTargetDataW');
axis(axRecon, 'image');
axRecon.XTick = [];
axRecon.YTick = [];
colormap(axRecon, 'gray');

%% ===================== 底部进度条 =====================

progressPanel = uipanel(mainGrid, 'Title', '微扫描进度');
progressPanel.Layout.Row = 2;
progressPanel.Layout.Column = [1 2];

progressGrid = uigridlayout(progressPanel, [2, 1]);
progressGrid.RowHeight = {22, '1x'};
progressGrid.Padding = [15 2 15 8];

progressLabel = uilabel(progressGrid, 'Text', '进度：0.0%');

progressAxes = uiaxes(progressGrid);
progressAxes.XLim = [0 1];
progressAxes.YLim = [0 1];
progressAxes.XTick = [];
progressAxes.YTick = [];
progressAxes.Box = 'on';
progressAxes.Toolbar.Visible = 'off';

progressPatch = patch(progressAxes, ...
    [0 0 0 0], ...
    [0 1 1 0], ...
    [0.2 0.55 0.95], ...
    'EdgeColor', 'none');

%% ===================== 点击按钮后开始运行 =====================

startButton.ButtonPushedFcn = @(src, event) uiresume(mainFig);
% 自动运行开关：外部脚本设 autoRun = true 时跳过等待，直接执行重建
if ~exist('autoRun', 'var') || isempty(autoRun) || ~autoRun
    uiwait(mainFig);
end

if ~isvalid(mainFig)
    return;
end

startButton.Enable = 'off';
statusText.Value = {'正在读取参数...'};

%% ===================== 读取界面参数 =====================

F_number = FField.Value;
f = fField.Value * 1e-3;
pixel_size = pixelSizeField.Value * 1e-6;

horizontalSampleNum = round(horizontalSampleNumField.Value);
verticalSampleNum = round(verticalSampleNumField.Value);

integrationTime = integrationTimeField.Value * 1e-3;

%% ===================== 根据参数计算目标像面移动速度 =====================
%
% 为了让每一个输出像素都能用完整的二维二阶差分
%   D(i,j) = S(i,j) - S(i-1,j) - S(i,j-1) + S(i-1,j-1)
% 来重建，水平、垂直方向都需要比"输出分辨率"多采一个参考位置，
% 即实际采样网格是 (horizontalSampleNum+1) x (verticalSampleNum+1)，
% 而不是 horizontalSampleNum x verticalSampleNum。
% 这样差分重建时就不再需要对第一行/第一列做特殊处理，
% 原先由此产生的边缘"条纹"也就消失了。

% 总采样数（含参考行、参考列）
totalFrameNum = (horizontalSampleNum + 1) * (verticalSampleNum + 1);

% 完整一次微扫描所需时间
microScanTime = totalFrameNum * integrationTime;

% 定义：完整一次微扫描，目标在像面移动一个像素
targetVelocityYPixelPerSecond = 1 / microScanTime;

% 每次积分期间目标移动的像素数
targetMovePixelPerIntegration = targetVelocityYPixelPerSecond * integrationTime;

% 每次积分期间目标移动的精细网格数
targetVelocityYFinePerFrame = targetMovePixelPerIntegration * mScale;

% 瞬时视场角
IFOV = pixel_size / f;
IFOV_urad = IFOV * 1e6;

% 更新计算参数显示
IFOVField.Value = IFOV_urad;
totalFrameNumField.Value = totalFrameNum;
microScanTimeField.Value = microScanTime;
targetVelocityField.Value = targetVelocityYPixelPerSecond;
targetMovePerIntegrationField.Value = targetMovePixelPerIntegration;

statusText.Value = { ...
    '参数计算完成。', ...
    ['总采样数（含参考帧） = ', num2str(totalFrameNum)], ...
    ['完整微扫描时间 = ', num2str(microScanTime), ' s'], ...
    ['目标像面速度 = ', num2str(targetVelocityYPixelPerSecond), ' pixel/s'], ...
    ['每次积分位移 = ', num2str(targetMovePixelPerIntegration), ' pixel']};

drawnow;

%% ===================== 读入数据 =====================

imageR = imread(picname);

if ndims(imageR) == 3
    image = rgb2gray(imageR);
else
    image = imageR;
end

image = im2double(image);

%% ===================== 基本图像参数 =====================

[imgy0, imgx0] = size(image);

lowRows = floor(imgy0 / mScale);
lowCols = floor(imgx0 / mScale);

image = image(1:lowRows*mScale, 1:lowCols*mScale);

[imgy, imgx] = size(image);

%% ===================== 原始低分辨率采样 =====================

statusText.Value = {'正在进行原始低分辨率采样...'};
drawnow;

sampleResult = zeros(lowRows, lowCols);

for i = 1:imgy
    for j = 1:imgx

        rowIndex = ceil(i / mScale);
        colIndex = ceil(j / mScale);

        sampleResult(rowIndex, colIndex) = ...
            sampleResult(rowIndex, colIndex) + image(i, j);

    end
end

sampleResult = sampleResult ./ double(mScale * mScale);

%% ===================== 提取目标所在像素内部精细图像 =====================

targetData = zeros(mScale, mScale);

rowStart = (targetPositionRow - 1) * mScale + 1;
rowEnd = targetPositionRow * mScale;

colStart = (targetPositionCol - 1) * mScale + 1;
colEnd = targetPositionCol * mScale;

targetData(:, :) = image(rowStart:rowEnd, colStart:colEnd);

imagesc(axTarget, targetData);
axis(axTarget, 'image');
axTarget.XTick = [];
axTarget.YTick = [];
colormap(axTarget, 'gray');
title(axTarget, '原始目标图像 targetData');

%% ===================== 预生成插值坐标 =====================

[Xgrid, Ygrid] = meshgrid(1:imgx, 1:imgy);

%% ===================== 初始粗偏移 =====================

coarseShiftRowFine = (MoveToRow - targetPositionRow) * mScale;
coarseShiftColFine = (MoveToCol - targetPositionCol) * mScale;

%% ===================== 步长参数 =====================

horizontalStepPixel = 1 / horizontalSampleNum;
horizontalStepFine = horizontalStepPixel * mScale;

verticalStepPixel = 1 / verticalSampleNum;
verticalStepFine = verticalStepPixel * mScale; %#ok<NASGU> % 目前未直接使用，纵向偏移由目标连续运动给出

%% ===================== 目标运动 + 平台水平微扫描 =====================
%
% yIndex、xIndex 都从 0 开始，分别扫到 verticalSampleNum、
% horizontalSampleNum（含），即 (verticalSampleNum+1) x (horizontalSampleNum+1)
% 个采样位置。多出来的 "0" 这一行/一列就是差分重建需要的参考帧，
% 不再需要在重建时对边界做特殊处理。

OffsetData = zeros(verticalSampleNum + 1, horizontalSampleNum + 1);

trajectory = zeros(totalFrameNum, 4);

progressPatch.XData = [0 0 0 0];
progressPatch.YData = [0 0 1 1];
progressLabel.Text = '进度：0.0%';
drawnow;

statusText.Value = {'正在进行目标运动等效微扫描...'};

sampleCounter = 0;

for yIndex = 0:verticalSampleNum

    for xIndex = 0:horizontalSampleNum

        sampleCounter = sampleCounter + 1;

        %% ---------- 平台水平微扫描 ----------

        platformShiftColFine = platformScanSignX * xIndex * horizontalStepFine;

        %% ---------- 目标垂直运动提供纵向微扫描 ----------
        % 沿用原设计：目标在整个采样过程中连续运动，
        % 因此纵向偏移用累计采样序号 sampleCounter，而不是单独的行号。

        targetShiftRowFine = targetMotionSignY * ...
            (sampleCounter - 1) * targetVelocityYFinePerFrame;

        %% ---------- 总相对偏移 ----------

        totalShiftRowFine = coarseShiftRowFine + targetShiftRowFine;

        totalShiftColFine = coarseShiftColFine + platformShiftColFine;

        %% ---------- 对高分辨率图像做亚像素平移 ----------

        subPixelOffset = interp2( ...
            Xgrid, ...
            Ygrid, ...
            image, ...
            Xgrid - totalShiftColFine, ...
            Ygrid - totalShiftRowFine, ...
            'linear', ...
            0);

        %% ---------- 低分辨率探测器积分采样 ----------

        subPixelTargetData = zeros(lowRows, lowCols);

        for i = 1:imgy
            for j = 1:imgx

                rowIndex = ceil(i / mScale);
                colIndex = ceil(j / mScale);

                subPixelTargetData(rowIndex, colIndex) = ...
                    subPixelTargetData(rowIndex, colIndex) + subPixelOffset(i, j);

            end
        end

        subPixelTargetData = subPixelTargetData ./ double(mScale * mScale);

        %% ---------- 记录当前偏移下观测像素响应 ----------
        % 修正：读取真正希望观测的像素 (MoveToRow, MoveToCol)。
        % 原代码写成 subPixelTargetData(MoveToRow-1, MoveToCol+1)，
        % 这是导致重建目标位置和输入位置对不上的直接原因。

        OffsetData(yIndex + 1, xIndex + 1) = subPixelTargetData(MoveToRow, MoveToCol);

        trajectory(sampleCounter, 1) = sampleCounter;
        trajectory(sampleCounter, 2) = platformShiftColFine / mScale;
        trajectory(sampleCounter, 3) = targetShiftRowFine / mScale;
        trajectory(sampleCounter, 4) = OffsetData(yIndex + 1, xIndex + 1);

        %% ---------- 更新进度条 ----------

        progressValue = sampleCounter / totalFrameNum;

        progressPatch.XData = [0 progressValue progressValue 0];
        progressPatch.YData = [0 0 1 1];

        progressLabel.Text = [ ...
            '进度：', num2str(progressValue * 100, '%.1f'), ...
            '%    当前：', num2str(sampleCounter), ...
            ' / ', num2str(totalFrameNum)];

        if mod(sampleCounter, 5) == 0 || sampleCounter == totalFrameNum
            statusText.Value = { ...
                '正在进行目标运动等效微扫描...', ...
                ['当前采样 = ', num2str(sampleCounter), ' / ', num2str(totalFrameNum)], ...
                ['yIndex = ', num2str(yIndex), ', xIndex = ', num2str(xIndex)], ...
                ['目标纵向偏移 = ', num2str(targetShiftRowFine / mScale), ' pixel'], ...
                ['平台横向偏移 = ', num2str(platformShiftColFine / mScale), ' pixel']};
            drawnow limitrate;
        end

    end
end

%% ===================== 差分重建 =====================
%
% 现在 OffsetData 是 (verticalSampleNum+1) x (horizontalSampleNum+1)，
% 每个输出像素都可以用统一的完整二维二阶差分公式，不再需要区分
% 第一行/第一列/角点这些特殊情况，边缘的"条纹"伪影随之消失。

statusText.Value = {'微扫描完成，正在进行差分重建...'};
drawnow;

calTargetData = zeros(verticalSampleNum, horizontalSampleNum);

for yIndex = 1:verticalSampleNum

    for xIndex = 1:horizontalSampleNum

        calTargetData(yIndex, xIndex) = ...
            OffsetData(yIndex + 1, xIndex + 1) ...
            - OffsetData(yIndex,     xIndex + 1) ...
            - OffsetData(yIndex + 1, xIndex) ...
            + OffsetData(yIndex,     xIndex);

    end
end

%% ===================== 归一化显示 =====================

calTargetDataW = calTargetData;

% 提醒：这一步左右镜像是否仍然需要，请在确认上面两处修正后
% 重新核对一次方向（可以先注释掉这一行做对比）。
calTargetDataW = fliplr(calTargetDataW);

calTargetDataW = calTargetDataW - min(calTargetDataW(:));

if max(calTargetDataW(:)) > 0
    calTargetDataW = calTargetDataW ./ max(calTargetDataW(:));
end

imagesc(axRecon, calTargetDataW);
axis(axRecon, 'image');
axRecon.XTick = [];
axRecon.YTick = [];
colormap(axRecon, 'gray');
title(axRecon, '微扫描差分重构 calTargetDataW');

progressPatch.XData = [0 1 1 0];
progressPatch.YData = [0 0 1 1];
progressLabel.Text = ['进度：100.0%    当前：', num2str(totalFrameNum), ' / ', num2str(totalFrameNum)];

statusText.Value = { ...
    '目标运动等效微扫描完成。', ...
    ['横向每行扫的位置数 = ', num2str(horizontalSampleNum)], ...
    ['纵向扫的位置数 = ', num2str(verticalSampleNum)], ...
    ['积分时间 = ', num2str(integrationTime * 1e3), ' ms'], ...
    ['完整微扫描时间 = ', num2str(microScanTime), ' s'], ...
    ['目标像面速度 = ', num2str(targetVelocityYPixelPerSecond), ' pixel/s'], ...
    ['每次积分位移 = ', num2str(targetMovePixelPerIntegration), ' pixel']};

startButton.Enable = 'on';

drawnow;

% 方式二：保留前缀，方便区分（推荐）
outDir = fullfile(pwd, 'sampling');
if ~exist(outDir, 'dir'); mkdir(outDir); end
fname = fullfile(outDir, sprintf('cal_result_%d.png', scanNum));
imwrite(calTargetDataW, fname);