clc;
clear;
close all;

scanNum =10;
autoRun = true;      % 告诉 demoBase 自动执行，不等按钮
demoBase
close(mainFig);      % 跑完关闭本次界面，避免窗口堆积

clc;
clear;
close all;

scanNum =20;
autoRun = true;      % 告诉 demoBase 自动执行，不等按钮
demoBase
close(mainFig);      % 跑完关闭本次界面，避免窗口堆积

clc;
clear;
close all;

scanNum =40;
autoRun = true;      % 告诉 demoBase 自动执行，不等按钮
demoBase
%close(mainFig);      % 跑完关闭本次界面，避免窗口堆积

%剔除背景
removebg
%计算重建结构相似度
calSSIM

