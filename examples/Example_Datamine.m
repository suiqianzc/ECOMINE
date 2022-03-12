%% Example processing input from Datamine:
% 2022 © C. Zhang

%% Steps 
% o Click Run to start the example
% o Select input Block Model file "\examples\Example_Datamine_MultipleRock_OptimalProfile_BlockModel"
% o Select Computational Parameters file "\examples\Example_Datamine_MultipleRock_ComputationParameters"
% o Input specific energy consumption of drilling for each RockCode: RC0=0,RC44=132,RC50=96,RC51=92,RC52=80,RC53=64,RC82=0,RC91=0,RC92=0 (MJ/m3) 
% o Select "Metal type", here "Gold"
% o Select "Measure Units", here "Feet"

%% Running 
clc; clear; close all

addpath(genpath('../functions'))
addpath(genpath('../libraries'))

[NBM, ECGWP] = BlockModel_Computation_Datamine;

