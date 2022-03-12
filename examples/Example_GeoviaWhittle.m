%% Example processing input from Geovia Whittle for:
% 2022 © C. Zhang

% 1. Single Rock Type
% 2. Multiple Rock Types

%% 1. Steps for Single Rock Type
% o Click Run to start the example
% o Select "Single Rock Type"
% o Select input Block Model file "\examples\Example_GeoviaWhittle_SingleRock_OptimalProfile_BlockModel"
% o Select Computational Parameters file "\examples\Example_GeoviaWhittle_SingleRock_ComputationParameters"
% o Input specific energy consumption of drilling to 160 MJ/m3
% o Select "Metal type", here "Gold"
% o Select "Measure Units", here "Feet"

%% 2. Steps for Multiple Rock Types
% o Click Run to start the example
% o Select "Multiple Rock Types"
% o Select input Block Model file "\examples\Example_GeoviaWhittle_MultipleRock_OptimalProfile_BlockModel"
% o Select Computational Parameters file "\examples\Example_GeoviaWhittle_MultipleRock_ComputationParameters"
% o Input specific energy consumption of drilling for Rock1 and Rock2 to 148 MJ/m3 and 112 MJ/m3 respectively
% o Select "Metal type", here "Copper"
% o Select "Measure Units", here "Meters"

%% Running 
clc; clear; close all

addpath(genpath('../functions'))
addpath(genpath('../libraries'))

[NBM, ECGWP] = BlockModel_Computation_GeoviaWhittle;

