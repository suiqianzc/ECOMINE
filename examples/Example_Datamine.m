%% Example processing input from Datamine:

%% Steps 
% o Click Run to start the example
% o Select "Single Rock Type"
% o Select input Block Model file "\examples\......\"
% o Select Computational Parameters file "\examples\...."
% o Input specific energy consumption of drilling to 370 MJ/m3
% o Select "Metal type", here "Gold"
% o Select "Measure Units", here "Feet"

%% 
clc; clear; close all

addpath(genpath('../functions'))
addpath(genpath('../libraries'))

[NBM, ECGWP] = BlockModel_Computation_Datamine;

