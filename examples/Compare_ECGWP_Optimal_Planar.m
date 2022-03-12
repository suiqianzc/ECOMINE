%% Example comparing the energy consumption and global warming potential for:
% 2022 © C. Zhang

% 1. Optimal pitwalls design method
% 2. Planar pitwalls design method

%% Running
clc; clear; close all

addpath(genpath('../functions'))
addpath(genpath('../libraries'))

% Geovia Whittle
Optimal = load('ECGWP_Optimal_GeoviaWhittle');
Planar  = load('ECGWP_Planar_GeoviaWhittle');

% Datamine
% Optimal = load('ECGWP_Optimal_Datamine');
% Planar  = load('ECGWP_Planar_Datamine');

Plot_Compare_Optimal_Planar(Optimal, Planar)
