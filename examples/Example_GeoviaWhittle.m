%% Example processing input from Geovia Whittle for:
% 1. Single Rock Type
% 2. Multiple Rock Types

%% 1. Steps for Single Rock Type
% o Click Run to start the example
% o Select "Single Rock Type"
% o Select input Block Model file "\examples\......\"
% o Select Computational Parameters file "\examples\...."
% o Input specific energy consumption of drilling to 370 MJ/m3
% o Select "Metal type", here "Gold"
% o Select "Measure Units", here "Feet"

%% 2. Steps for Multiple Rock Types
% xxx
% xxx
% xx

%% 
clc; clear; close all

addpath(genpath('../functions'))
addpath(genpath('../libraries'))

[NBM, ECGWP] = BlockModel_Computation_GeoviaWhittle;

