%% This function is used to select the suitable interface to carry out next computation
%  There are 3 types of interfaces: 1.rock types selection; 2.unit measure selection; 3.metal types selection.
%  ATTENTION: This framework is guaranteed to work only for files that block attributes as required.
%  Warning: Please ensure the variable names of the block atributes in the imported file are consistent with the example.
%  2021 © C. Zhang

function [rk, dc, str, dmg, dmt, gmg, gmt, grg, grt] = Interface_Selection(Module, option, var, num)

% Input
%  Module : The different option of interfaces
%  option : Single/Multiple version for GeoviaWhittle computation module
%  var    : The varibale block attributes of imported block model
%  num    : The number of rock types

% Output
%  rk  : The indexes of different selected rock types
%  dc  : The selection of unit measure for distance computation
%  str : The structure to store column indexes for block attributes
%  dmg : The column index of metal grade block attribute(Datamine)
%  dmt : The column index of metal mass block attribute(Datamine)
%  gmg : The column index of metal mill grade block attribute(GeoviaWhittle)
%  gmt : The column index of metal mill mass block attribute(GeoviaWhittle)
%  grg : The column index of metal rejected grade block attribute(GeoviaWhittle)
%  grt : The column index of metal rejected mass block attribute(GeoviaWhittle)

if Module == 1 %Rock Type Option
    %Display the interface of rock type selection
    RockType = {'Single Rock Type', 'Multiple Rock Type'};
    [rk,~] = listdlg('PromptString',{'Please select the number of rock type option for the block model.',''},...
        'SelectionMode','single','ListString',RockType);
    %Empty output
    dc = []; str = []; dmg = []; dmt = []; gmg = []; gmt = []; grg = []; grt = [];
end

if Module == 2 %Unit Measure Option
    %Display the interface for unit measure selection of distance
    UnitMeasure = {'Feet', 'Meters'};
    [dc,~] = listdlg('PromptString',{'Please select the appropriate unit measure for distance.',''},...
        'SelectionMode','single','ListString',UnitMeasure);
    %Empty output
    rk = []; str = []; dmg = []; dmt = []; gmg = []; gmt = []; grg = []; grt = [];
end

if Module == 3 %Datamine Option
    %Find the column indexes for fixed variable names of block attributes
    ind_X   = find(string(var.Properties.VariableNames) == "X");
    ind_Y   = find(string(var.Properties.VariableNames) == "Y");
    ind_Z   = find(string(var.Properties.VariableNames) == "Z");
    ind_xs  = find(string(var.Properties.VariableNames) == "X_size");
    ind_ys  = find(string(var.Properties.VariableNames) == "Y_size");
    ind_zs  = find(string(var.Properties.VariableNames) == "Z_size");
    ind_op  = find(string(var.Properties.VariableNames) == "Ore_per");
    ind_rk  = find(string(var.Properties.VariableNames) == "Rock_code");
    ind_den = find(string(var.Properties.VariableNames) == "Density");
    ind_ton = find(string(var.Properties.VariableNames) == "Block_ton");
    % Build struct1
    str     = struct;
    str.X   = ind_X;
    str.Y   = ind_Y;
    str.Z   = ind_Z;
    str.XS  = ind_xs;
    str.YS  = ind_ys;
    str.ZS  = ind_zs;
    str.Den = ind_den;
    str.Per = ind_op;
    str.BT  = ind_ton;
    str.RC  = ind_rk;
    %Create interface
    Metal = {'Gold','Copper','Iron','Silver','Zinc','Aluminium','Uranium'};
    [Type,~] = listdlg('PromptString',{'Select metal type for the block model.',''},'SelectionMode','single','ListString',Metal);
    switch Type
        case 1 %gold
            dmg = find(string(var.Properties.VariableNames) == "Au_grade");
            dmt = find(string(var.Properties.VariableNames) == "Au_mass");
        case 2 %copper
            dmg = find(string(var.Properties.VariableNames) == "Cu_grade");
            dmt = find(string(var.Properties.VariableNames) == "Cu_mass");
        case 3 %iron
            dmg = find(string(var.Properties.VariableNames) == "Fe_grade");
            dmt = find(string(var.Properties.VariableNames) == "Fe_mass");
        case 4 %silver
            dmg = find(string(var.Properties.VariableNames) == "Ag_grade");
            dmt = find(string(var.Properties.VariableNames) == "Ag_mass");
        case 5 %zinc
            dmg = find(string(var.Properties.VariableNames) == "Zn_grade");
            dmt = find(string(var.Properties.VariableNames) == "Zn_mass");
        case 6 %aluminium
            dmg = find(string(var.Properties.VariableNames) == "Al_grade");
            dmt = find(string(var.Properties.VariableNames) == "Al_mass");
        case 7 %uranium
            dmg = find(string(var.Properties.VariableNames) == "Ur_grade");
            dmt = find(string(var.Properties.VariableNames) == "Ur_mass");
        otherwise
            error('Wrong metal type!')
    end
    %Empty output
    rk = []; dc = []; gmg = []; gmt = []; grg = []; grt = [];
end

if Module == 4 %GeoviaWhittle Option
    switch option
        case ('Single')
            %Find the column indexes for fixed variable names of block attributes
            ind_X   = find(string(var.Properties.VariableNames) == "X");
            ind_Y   = find(string(var.Properties.VariableNames) == "Y");
            ind_Z   = find(string(var.Properties.VariableNames) == "Z");
            ind_xs  = find(string(var.Properties.VariableNames) == "X_size");
            ind_ys  = find(string(var.Properties.VariableNames) == "Y_size");
            ind_zs  = find(string(var.Properties.VariableNames) == "Z_size");
            ind_vol = find(string(var.Properties.VariableNames) == "volume");
            ind_bt  = find(string(var.Properties.VariableNames) == "block_tonnage");
            ind_rmt = find(string(var.Properties.VariableNames) == "rk_mill_tonnage");
            ind_rrt = find(string(var.Properties.VariableNames) == "rk_rejected_tonnage");
            ind_sg  = find(string(var.Properties.VariableNames) == "sg");
            ind_vf  = find(string(var.Properties.VariableNames) == "volume_factor");
            ind_mp  = find(string(var.Properties.VariableNames) == 'mined_period_a_value');
            ind_ou  = find(string(var.Properties.VariableNames) == 'ore_unmineralised');
            ind_wu  = find(string(var.Properties.VariableNames) == 'waste_unmineralised');
            %Build struct1
            str      = struct;
            str.X    = ind_X;
            str.Y    = ind_Y;
            str.Z    = ind_Z;
            str.XS   = ind_xs;
            str.YS   = ind_ys;
            str.ZS   = ind_zs;
            str.Vol  = ind_vol;
            str.BT   = ind_bt;
            str.SG   = ind_sg;
            str.VF   = ind_vf;
            str.RMT  = ind_rmt;
            str.RRT  = ind_rrt;
            str.Year = ind_mp;
            str.OU   = ind_ou;
            str.WU   = ind_wu;
            %Create interface
            Metal = {'Gold','Copper','Iron','Silver','Zinc','Aluminium','Uranium'};
            [Type,~] = listdlg('PromptString',{'Select metal type for the block model.',''},'SelectionMode','single','ListString',Metal);
            switch Type
                case 1 %gold
                    gmg = find(string(var.Properties.VariableNames) == "Au_mill_grade");
                    gmt = find(string(var.Properties.VariableNames) == "Au_mill_mass");
                    grg = find(string(var.Properties.VariableNames) == "Au_rejected_grade");
                    grt = find(string(var.Properties.VariableNames) == "Au_rejected_mass");
                case 2 %copper
                    gmg = find(string(var.Properties.VariableNames) == "Cu_mill_grade");
                    gmt = find(string(var.Properties.VariableNames) == "Cu_mill_mass");
                    grg = find(string(var.Properties.VariableNames) == "Cu_rejected_grade");
                    grt = find(string(var.Properties.VariableNames) == "Cu_rejected_mass");
                case 3 %iron
                    gmg = find(string(var.Properties.VariableNames) == "Fe_mill_grade");
                    gmt = find(string(var.Properties.VariableNames) == "Fe_mill_mass");
                    grg = find(string(var.Properties.VariableNames) == "Fe_rejected_grade");
                    grt = find(string(var.Properties.VariableNames) == "Fe_rejected_mass");
                case 4 %silver
                    gmg = find(string(var.Properties.VariableNames) == "Ag_mill_grade");
                    gmt = find(string(var.Properties.VariableNames) == "Ag_mill_mass");
                    grg = find(string(var.Properties.VariableNames) == "Ag_rejected_grade");
                    grt = find(string(var.Properties.VariableNames) == "Ag_rejected_mass");
                case 5 %zinc
                    gmg = find(string(var.Properties.VariableNames) == "Zn_mill_grade");
                    gmt = find(string(var.Properties.VariableNames) == "Zn_mill_mass");
                    grg = find(string(var.Properties.VariableNames) == "Zn_rejected_grade");
                    grt = find(string(var.Properties.VariableNames) == "Zn_rejected_mass");
                case 6 %aluminium
                    gmg = find(string(var.Properties.VariableNames) == "Al_mill_grade");
                    gmt = find(string(var.Properties.VariableNames) == "Al_mill_mass");
                    grg = find(string(var.Properties.VariableNames) == "Al_rejected_grade");
                    grt = find(string(var.Properties.VariableNames) == "Al_rejected_mass");
                case 7 %uranium
                    gmg = find(string(var.Properties.VariableNames) == "Ur_mill_grade");
                    gmt = find(string(var.Properties.VariableNames) == "Ur_mill_mass");
                    grg = find(string(var.Properties.VariableNames) == "Ur_rejected_grade");
                    grt = find(string(var.Properties.VariableNames) == "Ur_rejected_mass");
                otherwise
                    error('Wrong metal type!')
            end
            %Empty output
            rk = []; dc = []; dmg = []; dmt = [];
            
        case ('Multiple')
            %Find the column indexes for fixed variable names of block attributes
            ind_X   = find(string(var.Properties.VariableNames) == "X");
            ind_Y   = find(string(var.Properties.VariableNames) == "Y");
            ind_Z   = find(string(var.Properties.VariableNames) == "Z");
            ind_xs  = find(string(var.Properties.VariableNames) == "X_size");
            ind_ys  = find(string(var.Properties.VariableNames) == "Y_size");
            ind_zs  = find(string(var.Properties.VariableNames) == "Z_size");
            ind_vol = find(string(var.Properties.VariableNames) == "volume");
            ind_bt  = find(string(var.Properties.VariableNames) == "block_tonnage");
            ind_sg  = find(string(var.Properties.VariableNames) == "sg");
            ind_vf  = find(string(var.Properties.VariableNames) == "volume_factor");
            ind_mp  = find(string(var.Properties.VariableNames) == 'mined_period_a_value');
            %Determine the column index for variable names rk_mill_tonnage/rk_rejected_tonnage
            ind_rmt = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_mill_tonnage$)','once','match')) <= num);
            ind_rrt = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_rejected_tonnage$)','once','match')) <= num);
            %Build struct1
            str      = struct;
            str.X    = ind_X;
            str.Y    = ind_Y;
            str.Z    = ind_Z;
            str.XS   = ind_xs;
            str.YS   = ind_ys;
            str.ZS   = ind_zs;
            str.Vol  = ind_vol;
            str.BT   = ind_bt;
            str.SG   = ind_sg;
            str.VF   = ind_vf;
            str.RMT  = ind_rmt;
            str.RRT  = ind_rrt;
            str.Year = ind_mp;
            %Create interface
            Metal = {'Gold','Copper','Iron','Silver','Zinc','Aluminium','Uranium'};
            [Type,~] = listdlg('PromptString',{'Select metal type for the block model.',''},'SelectionMode','single','ListString',Metal);
            switch Type
                case 1 %gold
                    gmg = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Au_mill_grade$)','once','match')) <= num);
                    gmt = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Au_mill_mass$)','once','match')) <= num);
                    grg = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Au_rejected_grade$)','once','match')) <= num);
                    grt = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Au_rejected_mass$)','once','match')) <= num);
                case 2 %copper
                    gmg = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Cu_mill_grade$)','once','match')) <= num);
                    gmt = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Cu_mill_mass$)','once','match')) <= num);
                    grg = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Cu_rejected_grade$)','once','match')) <= num);
                    grt = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Cu_rejected_mass$)','once','match')) <= num);
                case 3 %iron
                    gmg = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Fe_mill_grade$)','once','match')) <= num);
                    gmt = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Fe_mill_mass$)','once','match')) <= num);
                    grg = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Fe_rejected_grade$)','once','match')) <= num);
                    grt = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Fe_rejected_mass$)','once','match')) <= num);
                case 4 %silver
                    gmg = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Ag_mill_grade$)','once','match')) <= num);
                    gmt = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Ag_mill_mass$)','once','match')) <= num);
                    grg = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Ag_rejected_grade$)','once','match')) <= num);
                    grt = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Ag_rejected_mass$)','once','match')) <= num);
                case 5 %zinc
                    gmg = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Zn_mill_grade$)','once','match')) <= num);
                    gmt = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Zn_mill_mass$)','once','match')) <= num);
                    grg = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Zn_rejected_grade$)','once','match')) <= num);
                    grt = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Zn_rejected_mass$)','once','match')) <= num);
                case 6 %aluminium
                    gmg = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Al_mill_grade$)','once','match')) <= num);
                    gmt = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Al_mill_mass$)','once','match')) <= num);
                    grg = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Al_rejected_grade$)','once','match')) <= num);
                    grt = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Al_rejected_mass$)','once','match')) <= num);
                case 7 %uranium
                    gmg = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Ur_mill_grade$)','once','match')) <= num);
                    gmt = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Ur_mill_mass$)','once','match')) <= num);
                    grg = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Ur_rejected_grade$)','once','match')) <= num);
                    grt = find(str2double(regexp(var.Properties.VariableNames, '(?<=^rk)\d+(?=_Ur_rejected_mass$)','once','match')) <= num);
                otherwise
                    error('Wrong metal type!')
            end
            %Empty output
            rk = []; dc = []; dmg = []; dmt = [];
    end
    
end

end
