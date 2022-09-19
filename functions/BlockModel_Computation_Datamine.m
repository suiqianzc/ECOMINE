function [NBM, ECGWP] = BlockModel_Computation_Datamine

%% ECOMINE is a framework to compute the energy consumption and global warming potential (GWP) for mining and comminution of open pit mine
%  Implementation and improvement of Energy consumption and GWP computation based on the approach proposed by Muñoz et al (2014) [1]
%  This function can be used to calculate the block model from Datamine software
%  2022 © C. Zhang

%% The main highlights of this framework
%  1. The block-based life cycle assessment(LCA) approach is applied to the ultimate pit limit of open-pit mine
%     to estimate the energy consumption and global warming potential(GWP) for mining and comminution stages.
%  2. This framework considers block type,block hardness(based on rock type),location of blocks, and other factors.
%  3. The framework is developed from basic engineering equations of energy consumption and global warming potential(GWP), 
%     which the required computation parameters are easy to obtain.
%  4. The energy consumption and GWP can be estimated through this framework, and these two attributes can be assigned to 
%     the corresponding blocks to form the energy and environmental block model respectively.
%  5. Results from this framework can be used to analyze the relationship between grade and energy consumption, also
%     provide greater detials base for better evaluation of equipment,input source selection, mining and processing schedule.
%
%% INPUT:
%  - BM file: Block model file of Datamine Software, used to import block attributes
%
%      - Block attributes:
%          - coordinates:    X, Y, Z
%          - block size:     X_size, Y_size, Z_size
%          - block density:  Densitygithubmatlab
%          - rock type:      Rock_code
%          - ore percentage: Ore_per
%          - metal grade  :  e.g. Au_grade, Cu_grade, Fe_grade,...
%          - block tonnage:  Block_ton(actual tonnage of each block mined corresponding to the NPV)
%          - metal mass   :  e.g. Au_mass, Cu_mass, Fe_mass,...
%
%  - CP file: Computation parameters file, used to import inventory analysis dataset related to basic engineering equations
%
%  - EV(MJ/m^3): Specific energy consumption of Rotary Drilling which depends on the rock type and
%               estimated based on the "Unified Classification" system of rock according to drillablility(Isheyskiy and Sanchidrián, 2020)
%
%  - Metal type: Select among Gold, Copper, Iron, Silver, Zinc, Aluminium, Uranium
%
%  - Units: Select between "Feet" and "Meters".
%
%% OUTPUT:
%
%  - ECGWP: This structure containing total energy consumption and GWP for each process and input source respectively in the mine life cycle
%
%  - NBM: This structure containing the energy consumption and GWP of each block of mining and comminution
%          to form a new block model to identify the distribution of energy consumption and GWP for the open-pit mine
%         - Export new block model file, with format:[X,Y,Z,x_size,y_size,z_size,Density,Grade,Tonnage,Energy,GWP]
%
%% Import and process files and calculation parameters
%  BM file
D_V = Import_File('Datamine',[]);
BM  = table2array(D_V);
%  CP file
p_v = Import_File('Computation parameter',[]);
%  EV parameters
rock_code = unique(D_V{:,'Rock_code'}); %Identify various rock type codes in the block model
[EV,~]    = Drilling_Specific_Energy('Datamine',rock_code,[],[]);
%  Identify the column index of block attributes for the imported BM file
[~,~,V,MG,MT,~,~,~,~] = Interface_Selection(3,[],D_V,[]);

%% Screening and assign the corresponding blocks to each rock code
%  Create cell for each rock code to store the corresponding values
sub_rc = cell(size(rock_code,1),1);
%  Assign values and to sub_rc
for m = 1 : size(rock_code,1)
    row_ind     = BM(:,V.RC) == rock_code(m);%determine the row index according to the corresponding rock code
    sub_rc{m,1} = BM(row_ind,:);
end
%  Screening of ore blocks and waste blocks for each Rock Code
%  Create cell for ore and waste to store values
sub_ore   = cell(size(rock_code,1),1);
sub_waste = cell(size(rock_code,1),1);
%  Determine the row index for ore and waste according to block attribute 'Metal_mass'
for m = 1 : size(rock_code,1)
    %Ore: metal_mass ~= 0
    row_ore      = sub_rc{m,1}(:,MT) ~= 0;
    sub_ore{m,1} = sub_rc{m,1}(row_ore,:);
    %Waste: metal_mass = 0
    row_waste      = sub_rc{m,1}(:,MT) == 0;
    sub_waste{m,1} = sub_rc{m,1}(row_waste,:);
end
%  Create cells for ore blocks which contain unmineralised materials
%  Note: we only consider the non-mineralised material in the ore blocks if the block
%  model from Datamine due to the impact of 'ore percentage' block attribute
ore_um = cell(size(rock_code,1),1);
%  Use block attribute 'Ore_per' to screen unmineralised materials of ore
%  blocks for each rock code and assign values to the corresponding cell
for m = 1 : size(rock_code,1)
    if ~isempty(sub_ore(m,1)) % Determine 'Ore_per' = 100%? If = 100%, ore blocks without unmineralised
        row_ore_um  = sub_ore{m,1}(:,V.Per) < 100; % Else < 100%, ore blocks contain unmineralised
        ore_um{m,1} = sub_ore{m,1}(row_ore_um,:);
    end
end

%% Build "Ore" "Waste" "Unmineralised" structures for each rock type with the corresponding block attributes
%  "Ore" structure
Ore           = struct;
Ore.Group1    = [];
Ore.X1_coord  = [];
Ore.Y1_coord  = [];
Ore.Z1_coord  = [];
Ore.X1_size   = [];
Ore.Y1_size   = [];
Ore.Z1_size   = [];
Ore.Density1  = [];
Ore.Percent1  = [];
Ore.Grade1    = [];
Ore.Metalmass = [];
Ore.Tonnage1  = [];
Ore.SEC_D1    = [];
Ore.E1_drill  = [];
Ore.E1_blast  = [];
Ore.E1_load   = [];
Ore.E1_haul   = [];
Ore.E1_crush  = [];
Ore.E1_grind  = [];
Ore.G1_drill  = [];
Ore.G1_blast  = [];
Ore.G1_load   = [];
Ore.G1_haul   = [];
Ore.G1_crush  = [];
Ore.G1_grind  = [];
Ore.Energy1   = [];
Ore.GWP1      = [];
%  "Waste" structure
Waste          = struct;
Waste.Group2   = [];
Waste.X2_coord = [];
Waste.Y2_coord = [];
Waste.Z2_coord = [];
Waste.X2_size  = [];
Waste.Y2_size  = [];
Waste.Z2_size  = [];
Waste.Density2 = [];
Waste.Grade2   = [];
Waste.Tonnage2 = [];
Waste.SEC_D2   = [];
Waste.E2_drill = [];
Waste.E2_blast = [];
Waste.E2_load  = [];
Waste.E2_haul  = [];
Waste.G2_drill = [];
Waste.G2_blast = [];
Waste.G2_load  = [];
Waste.G2_haul  = [];
Waste.Energy2  = [];
Waste.GWP2     = [];
%  "Unmineralised" structure
Unmine          = struct;
Unmine.Group3   = [];
Unmine.X3_coord = [];
Unmine.Y3_coord = [];
Unmine.Z3_coord = [];
Unmine.X3_size  = [];
Unmine.Y3_size  = [];
Unmine.Z3_size  = [];
Unmine.Density3 = [];
Unmine.Percent3 = [];
Unmine.Tonnage3 = [];
Unmine.SEC_D3   = [];
Unmine.E3_blast = [];
Unmine.E3_load  = [];
Unmine.E3_haul  = [];
Unmine.E3_crush = [];
Unmine.E3_grind = [];
Unmine.G3_blast = [];
Unmine.G3_load  = [];
Unmine.G3_haul  = [];
Unmine.G3_crush = [];
Unmine.G3_grind = [];
Unmine.Energy3  = [];
Unmine.GWP3     = [];
%  Assign values to "Ore" "Waste" "Unmineralised" structure
for m = 1 : size(rock_code,1)
    %"Ore" structure
    Ore(m).Group1    = sprintf('Ore_RC%d',rock_code(m));
    Ore(m).X1_coord  = sub_ore{m,1}(:,V.X);
    Ore(m).Y1_coord  = sub_ore{m,1}(:,V.Y);
    Ore(m).Z1_coord  = sub_ore{m,1}(:,V.Z);
    Ore(m).X1_size   = sub_ore{m,1}(:,V.XS);
    Ore(m).Y1_size   = sub_ore{m,1}(:,V.YS);
    Ore(m).Z1_size   = sub_ore{m,1}(:,V.ZS);
    Ore(m).Density1  = sub_ore{m,1}(:,V.Den);
    Ore(m).Percent1  = sub_ore{m,1}(:,V.Per);
    Ore(m).Grade1    = sub_ore{m,1}(:,MG);
    Ore(m).Metalmass = sub_ore{m,1}(:,MT);
    Ore(m).Tonnage1  = ((Ore(m).Percent1)./100).*sub_ore{m,1}(:,V.BT);
    Ore(m).SEC_D1    = EV(m);
    %"Waste" structure
    Waste(m).Group2   = sprintf('Waste_RC%d',rock_code(m));
    Waste(m).X2_coord = sub_waste{m,1}(:,V.X);
    Waste(m).Y2_coord = sub_waste{m,1}(:,V.Y);
    Waste(m).Z2_coord = sub_waste{m,1}(:,V.Z);
    Waste(m).X2_size  = sub_waste{m,1}(:,V.XS);
    Waste(m).Y2_size  = sub_waste{m,1}(:,V.YS);
    Waste(m).Z2_size  = sub_waste{m,1}(:,V.ZS);
    Waste(m).Density2 = sub_waste{m,1}(:,V.Den);
    Waste(m).Grade2   = sub_waste{m,1}(:,MG);
    Waste(m).Tonnage2 = sub_waste{m,1}(:,V.BT);
    Waste(m).SEC_D2   = EV(m);
    %"Unmineralised" structure
    Unmine(m).Group3   = sprintf('Unmineralised_RC%d',rock_code(m));
    Unmine(m).X3_coord = ore_um{m,1}(:,V.X);
    Unmine(m).Y3_coord = ore_um{m,1}(:,V.Y);
    Unmine(m).Z3_coord = ore_um{m,1}(:,V.Z);
    Unmine(m).X3_size  = ore_um{m,1}(:,V.XS);
    Unmine(m).Y3_size  = ore_um{m,1}(:,V.YS);
    Unmine(m).Z3_size  = ore_um{m,1}(:,V.ZS);
    Unmine(m).Density3 = ore_um{m,1}(:,V.Den);
    Unmine(m).Percent3 = (100 - ore_um{m,1}(:,V.Per));
    Unmine(m).Tonnage3 = ((Unmine(m).Percent3)./100).*ore_um{m,1}(:,V.BT);
    Unmine(m).SEC_D3   = EV(m);
end

%% Attention: we need to select correct unit measure of block coordinates before executing computation so that we can accuratly estimate the energy consumption and GWP for transportation
%  This framework provides two common units of coordinates: meters and feet
%  If unit of block coordinates is meter, execute case I; Else, execute case II
%  Create three types of cells to store the corresponding distance values for each rock code
%  (1)S_op: from ore block to processing plant; (2)S_wd: from waste block to dumpsite; (3)S_up: from ore block containing unmineralised materials to processing plant
S_op = cell(size(rock_code,1),1);
S_wd = cell(size(rock_code,1),1);
S_up = cell(size(rock_code,1),1);

%  1. Select correct unit measure of block coordinates
%  2. Use 3D distance formula to calculate the distance: d(P1,P2) = sqrt((X2-X1)^2+(Y2-Y1)^2+(Z2-Z1)^2) (where P1 = (X1,Y1,Z1), P2 = (X2,Y2,Z2))
%  Note: We only consider the theoretical shortest distance between two points in the spatial coordinate system in this framework
%  and there may be some differneces with the actual distance of transportation, which is also a part of the future work to be improved.
[~,Distance_Computation,~,~,~,~,~,~,~] = Interface_Selection(2,[],[]);
switch Distance_Computation
    case 1 %feet
        for m = 1 : size(rock_code,1)%convert distance unit from feet to km
            S_op{m,1} = (Transportation_Distance(p_v.X_plant,p_v.Y_plant,p_v.Z_plant,Ore(m).X1_coord,Ore(m).Y1_coord,Ore(m).Z1_coord)).*3.048e-04;
            S_wd{m,1} = (Transportation_Distance(p_v.X_dump,p_v.Y_dump,p_v.Z_dump,Waste(m).X2_coord,Waste(m).Y2_coord,Waste(m).Z2_coord)).*3.048e-04;
            S_up{m,1} = (Transportation_Distance(p_v.X_plant,p_v.Y_plant,p_v.Z_plant,Unmine(m).X3_coord,Unmine(m).Y3_coord,Unmine(m).Z3_coord)).*3.048e-04;
        end
    case 2 %meters
        for m = 1 : size(rock_code,1)%convert distance unit from meters to km
            S_op{m,1} = (Transportation_Distance(p_v.X_plant,p_v.Y_plant,p_v.Z_plant,Ore(m).X1_coord,Ore(m).Y1_coord,Ore(m).Z1_coord)).*0.001;
            S_wd{m,1} = (Transportation_Distance(p_v.X_dump,p_v.Y_dump,p_v.Z_dump,Waste(m).X2_coord,Waste(m).Y2_coord,Waste(m).Z2_coord)).*0.001;
            S_up{m,1} = (Transportation_Distance(p_v.X_plant,p_v.Y_plant,p_v.Z_plant,Unmine(m).X3_coord,Unmine(m).Y3_coord,Unmine(m).Z3_coord)).*0.001;
        end
end

%% Energy consumption and GWP computation
%% TODO
%  1.Calculate energy consumption and GWP of blocks in each unit and assign values to the corresponding structure, then combine sub-structs to output a new structure
%  2.Calculate energy consumption and GWP for each unit and input source(fuel/explosive/electricity) respectively and assign values to structure
%  Create energy and GWP cells for each processing unit
%  Note:The ore and unmineralised materials are mixed together in the ore blocks, therefore these two materials will be considered as a whole 
%  when calculating the energy consumption and GWP for the ore blocks in the drilling unit
%  Drilling
energy_d = cell(size(rock_code,1),2);
GWP_d    = cell(size(rock_code,1),2);
%  Blasting
energy_b = cell(size(rock_code,1),3);
GWP_b    = cell(size(rock_code,1),3);
%  Loading
energy_l = cell(size(rock_code,1),3);
GWP_l    = cell(size(rock_code,1),3);
%  Hauling
energy_h = cell(size(rock_code,1),3);
GWP_h    = cell(size(rock_code,1),3);
%  Crushing
energy_c = cell(size(rock_code,1),3);
GWP_c    = cell(size(rock_code,1),3);
%  Grinding
energy_g = cell(size(rock_code,1),3);
GWP_g    = cell(size(rock_code,1),3);
%  Setup the initial value and temporary cells for calculation
%ORE
EO_Drill = 0; EO_Blast = 0; EO_Load = 0; EO_Haul = 0; EO_Crush = 0; EO_Grind = 0;
GO_Drill = 0; GO_Blast = 0; GO_Load = 0; GO_Haul = 0; GO_Crush = 0; GO_Grind = 0;
%WASTE
EW_Drill = 0; EW_Blast = 0; EW_Load = 0; EW_Haul = 0;
GW_Drill = 0; GW_Blast = 0; GW_Load = 0; GW_Haul = 0;
%Non-mineralised
EU_Blast = 0; EU_Load = 0; EU_Haul = 0; EU_Crush = 0; EU_Grind = 0;
GU_Blast = 0; GU_Load = 0; GU_Haul = 0; GU_Crush = 0; GU_Grind = 0;
%  Temporary cells
temp     = cell(size(rock_code,1),2);
new_ore  = cell(size(rock_code,1),2);
for m = 1 : size(rock_code,1)
    %Ore
    if ~isequal(Ore(m).SEC_D1,0) && ~isempty(sub_ore(m,1))
        energy_d{m,1} = Energy_Consumption(p_v.A,Ore(m).SEC_D1,p_v.L,p_v.N,p_v.nD,[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],sub_ore{m,1}(:,V.BT),'Drill');
        GWP_d{m,1}    = Global_Warming_Potential(energy_d{m,1},[],p_v.EF_fuel,[],p_v.EF_electricity,p_v.wf_a1,p_v.wf_b1,[],[],[],[],[],[],[],[],'Drill');
    end
    if ~isequal(Ore(m).SEC_D1,0) && ~isempty(Ore(m).Tonnage1)
        energy_b{m,1} = Energy_Consumption([],[],[],[],[],p_v.LF,p_v.Eblast,[],[],[],[],[],[],[],[],[],[],[],[],[],[],Ore(m).Tonnage1,'Blast');
        GWP_b{m,1}    = Global_Warming_Potential(energy_b{m,1},p_v.Eblast,[],p_v.EF_explosive,[],[],[],[],[],[],[],[],[],[],[],'Blast');
    end
    if ~isempty(Ore(m).Tonnage1)
        energy_l{m,1} = Energy_Consumption([],[],[],[],[],[],[],p_v.PI,p_v.lt,p_v.Nl,p_v.mTruck,[],[],[],[],[],[],[],[],[],[],Ore(m).Tonnage1,'Load');
        energy_h{m,1} = Energy_Consumption([],[],[],[],[],[],[],[],[],[],p_v.mTruck,S_op{m,1},p_v.Rs,p_v.Ri,p_v.rs,p_v.MTruck,[],[],[],[],[],Ore(m).Tonnage1,'Haul');
        energy_c{m,1} = Energy_Consumption([],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],p_v.wi,p_v.c_out,p_v.c_in,[],[],Ore(m).Tonnage1,'Crush');
        energy_g{m,1} = Energy_Consumption([],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],p_v.wi,[],[],p_v.g_out,p_v.g_in,Ore(m).Tonnage1,'Grind');
        GWP_l{m,1}    = Global_Warming_Potential(energy_l{m,1},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],p_v.wf_a2,p_v.wf_b2,[],[],[],[],[],[],'Load');
        GWP_h{m,1}    = Global_Warming_Potential(energy_h{m,1},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],[],[],p_v.wf_a3,p_v.wf_b3,[],[],[],[],'Haul');
        GWP_c{m,1}    = Global_Warming_Potential(energy_c{m,1},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],[],[],[],[],p_v.wf_a4,p_v.wf_b4,[],[],'Crush');
        GWP_g{m,1}    = Global_Warming_Potential(energy_g{m,1},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],[],[],[],[],[],[],p_v.wf_a5,p_v.wf_b5,'Grind');
    end
    Ore(m).E1_drill = energy_d{m,1};
    Ore(m).E1_blast = energy_b{m,1};
    Ore(m).E1_load  = energy_l{m,1};
    Ore(m).E1_haul  = energy_h{m,1};
    Ore(m).E1_crush = energy_c{m,1};
    Ore(m).E1_grind = energy_g{m,1};
    Ore(m).G1_drill = GWP_d{m,1};
    Ore(m).G1_blast = GWP_b{m,1};
    Ore(m).G1_load  = GWP_l{m,1};
    Ore(m).G1_haul  = GWP_h{m,1};
    Ore(m).G1_crush = GWP_c{m,1};
    Ore(m).G1_grind = GWP_g{m,1};
    if ~isequal(Ore(m).SEC_D1,0) && ~isempty(Ore(m).Tonnage1) && ~isempty(sub_ore(m,1)) %Calculate total energy consumption and GWP for each ore block
        Ore(m).Energy1 = Ore(m).E1_drill + Ore(m).E1_blast + Ore(m).E1_load + Ore(m).E1_haul + Ore(m).E1_crush + Ore(m).E1_grind;
        Ore(m).GWP1    = Ore(m).G1_drill + Ore(m).G1_blast + Ore(m).G1_load + Ore(m).G1_haul + Ore(m).G1_crush + Ore(m).G1_grind;
    elseif isequal(Ore(m).SEC_D1,0) && ~isempty(Ore(m).Tonnage1)
        Ore(m).Energy1 = Ore(m).E1_load + Ore(m).E1_haul + Ore(m).E1_crush + Ore(m).E1_grind;
        Ore(m).GWP1    = Ore(m).G1_load + Ore(m).G1_haul + Ore(m).G1_crush + Ore(m).G1_grind;
    elseif isequal(Ore(m).SEC_D1,0) && isempty(Ore(m).Tonnage1) && isempty(sub_ore(m,1))
        Ore(m).Energy1 = [];
        Ore(m).GWP1    = [];
    end
    if ~isequal(Ore(m).SEC_D1,0) && ~isempty(sub_ore(m,1))
        EO_Drill = EO_Drill + sum([Ore(m).E1_drill]);
        GO_Drill = GO_Drill + sum([Ore(m).G1_drill]);
    end
    if ~isequal(Ore(m).SEC_D1,0) && ~isempty(Ore(m).Tonnage1)    
        EO_Blast = EO_Blast + sum([Ore(m).E1_blast]);
        GO_Blast = GO_Blast + sum([Ore(m).G1_blast]);
    end
    if ~isempty(Ore(m).Tonnage1)
        EO_Load  = EO_Load  + sum([Ore(m).E1_load]);
        EO_Haul  = EO_Haul  + sum([Ore(m).E1_haul]);
        EO_Crush = EO_Crush + sum([Ore(m).E1_crush]);
        EO_Grind = EO_Grind + sum([Ore(m).E1_grind]);
        GO_Load  = GO_Load  + sum([Ore(m).G1_load]);
        GO_Haul  = GO_Haul  + sum([Ore(m).G1_haul]);
        GO_Crush = GO_Crush + sum([Ore(m).G1_crush]);
        GO_Grind = GO_Grind + sum([Ore(m).G1_grind]);
    end
    %Waste
    if ~isequal(Waste(m).SEC_D2,0) && ~isempty(Waste(m).Tonnage2)
        energy_d{m,2} = Energy_Consumption(p_v.A,Waste(m).SEC_D2,p_v.L,p_v.N,p_v.nD,[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],Waste(m).Tonnage2,'Drill');
        energy_b{m,2} = Energy_Consumption([],[],[],[],[],p_v.LF,p_v.Eblast,[],[],[],[],[],[],[],[],[],[],[],[],[],[],Waste(m).Tonnage2,'Blast');
        GWP_d{m,2}    = Global_Warming_Potential(energy_d{m,2},[],p_v.EF_fuel,[],p_v.EF_electricity,p_v.wf_a1,p_v.wf_b1,[],[],[],[],[],[],[],[],'Drill');
        GWP_b{m,2}    = Global_Warming_Potential(energy_b{m,2},p_v.Eblast,[],p_v.EF_explosive,[],[],[],[],[],[],[],[],[],[],[],'Blast');
    end
    if ~isempty(Waste(m).Tonnage2)
        energy_l{m,2} = Energy_Consumption([],[],[],[],[],[],[],p_v.PI,p_v.lt,p_v.Nl,p_v.mTruck,[],[],[],[],[],[],[],[],[],[],Waste(m).Tonnage2,'Load');
        energy_h{m,2} = Energy_Consumption([],[],[],[],[],[],[],[],[],[],p_v.mTruck,S_wd{m,1},p_v.Rs,p_v.Ri,p_v.rs,p_v.MTruck,[],[],[],[],[],Waste(m).Tonnage2,'Haul');
        GWP_l{m,2}    = Global_Warming_Potential(energy_l{m,2},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],p_v.wf_a2,p_v.wf_b2,[],[],[],[],[],[],'Load');
        GWP_h{m,2}    = Global_Warming_Potential(energy_h{m,2},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],[],[],p_v.wf_a3,p_v.wf_b3,[],[],[],[],'Haul');
    end
    Waste(m).E2_drill = energy_d{m,2};
    Waste(m).E2_blast = energy_b{m,2};
    Waste(m).E2_load  = energy_l{m,2};
    Waste(m).E2_haul  = energy_h{m,2};
    Waste(m).G2_drill = GWP_d{m,2};
    Waste(m).G2_blast = GWP_b{m,2};
    Waste(m).G2_load  = GWP_l{m,2};
    Waste(m).G2_haul  = GWP_h{m,2};
    if ~isequal(Waste(m).SEC_D2,0) && ~isempty(Waste(m).Tonnage2) %Calculate total energy consumption and GWP for each waste block
        Waste(m).Energy2 = Waste(m).E2_drill + Waste(m).E2_blast + Waste(m).E2_load + Waste(m).E2_haul;
        Waste(m).GWP2    = Waste(m).G2_drill + Waste(m).G2_blast + Waste(m).G2_load + Waste(m).G2_haul;
    elseif isequal(Waste(m).SEC_D2,0) && ~isempty(Waste(m).Tonnage2)
        Waste(m).Energy2 = Waste(m).E2_load + Waste(m).E2_haul;
        Waste(m).GWP2    = Waste(m).G2_load + Waste(m).G2_haul;
    else
        Waste(m).Energy2 = [];
        Waste(m).GWP2    = [];
    end
    if ~isequal(Waste(m).SEC_D2,0) && ~isempty(Waste(m).Tonnage2)
        EW_Drill = EW_Drill + sum([Waste(m).E2_drill]);
        EW_Blast = EW_Blast + sum([Waste(m).E2_blast]);
        GW_Drill = GW_Drill + sum([Waste(m).G2_drill]);
        GW_Blast = GW_Blast + sum([Waste(m).G2_blast]);
    end
    if ~isempty(Waste(m).Tonnage2)
        EW_Load  = EW_Load + sum([Waste(m).E2_load]);
        EW_Haul  = EW_Haul + sum([Waste(m).E2_haul]);
        GW_Load  = GW_Load + sum([Waste(m).G2_load]);
        GW_Haul  = GW_Haul + sum([Waste(m).G2_haul]);
    end
    %Unmineralised
    if ~isequal(Unmine(m).SEC_D3,0) && ~isempty(Unmine(m).Tonnage3)
        energy_b{m,3} = Energy_Consumption([],[],[],[],[],p_v.LF,p_v.Eblast,[],[],[],[],[],[],[],[],[],[],[],[],[],[],Unmine(m).Tonnage3,'Blast');
        GWP_b{m,3}    = Global_Warming_Potential(energy_b{m,3},p_v.Eblast,[],p_v.EF_explosive,[],[],[],[],[],[],[],[],[],[],[],'Blast');
    end
    if ~isempty(Unmine(m).Tonnage3)
        energy_l{m,3} = Energy_Consumption([],[],[],[],[],[],[],p_v.PI,p_v.lt,p_v.Nl,p_v.mTruck,[],[],[],[],[],[],[],[],[],[],Unmine(m).Tonnage3,'Load');
        energy_h{m,3} = Energy_Consumption([],[],[],[],[],[],[],[],[],[],p_v.mTruck,S_up{m,1},p_v.Rs,p_v.Ri,p_v.rs,p_v.MTruck,[],[],[],[],[],Unmine(m).Tonnage3,'Haul');
        energy_c{m,3} = Energy_Consumption([],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],p_v.wi,p_v.c_out,p_v.c_in,[],[],Unmine(m).Tonnage3,'Crush');
        energy_g{m,3} = Energy_Consumption([],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],p_v.wi,[],[],p_v.g_out,p_v.g_in,Unmine(m).Tonnage3,'Grind');
        GWP_l{m,3}    = Global_Warming_Potential(energy_l{m,3},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],p_v.wf_a2,p_v.wf_b2,[],[],[],[],[],[],'Load');
        GWP_h{m,3}    = Global_Warming_Potential(energy_h{m,3},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],[],[],p_v.wf_a3,p_v.wf_b3,[],[],[],[],'Haul');
        GWP_c{m,3}    = Global_Warming_Potential(energy_c{m,3},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],[],[],[],[],p_v.wf_a4,p_v.wf_b4,[],[],'Crush');
        GWP_g{m,3}    = Global_Warming_Potential(energy_g{m,3},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],[],[],[],[],[],[],p_v.wf_a5,p_v.wf_b5,'Grind');
    end
    Unmine(m).E3_blast = energy_b{m,3};
    Unmine(m).E3_load  = energy_l{m,3};
    Unmine(m).E3_haul  = energy_h{m,3};
    Unmine(m).E3_crush = energy_c{m,3};
    Unmine(m).E3_grind = energy_g{m,3};
    Unmine(m).G3_blast = GWP_b{m,3};
    Unmine(m).G3_load  = GWP_l{m,3};
    Unmine(m).G3_haul  = GWP_h{m,3};
    Unmine(m).G3_crush = GWP_c{m,3};
    Unmine(m).G3_grind = GWP_g{m,3};
    if ~isequal(Unmine(m).SEC_D3,0) && ~isempty(Unmine(m).Tonnage3) %Calculate the total energy consumption and GWP of the unmineralized materials of ore block
        Unmine(m).Energy3 = Unmine(m).E3_blast + Unmine(m).E3_load + Unmine(m).E3_haul + Unmine(m).E3_crush + Unmine(m).E3_grind;
        Unmine(m).GWP3    = Unmine(m).G3_blast + Unmine(m).G3_load + Unmine(m).G3_haul + Unmine(m).G3_crush + Unmine(m).G3_grind;
    elseif isequal(Unmine(m).SEC_D3,0) && ~isempty(Unmine(m).Tonnage3)
        Unmine(m).Energy3 = Unmine(m).E3_load + Unmine(m).E3_haul + Unmine(m).E3_crush + Unmine(m).E3_grind;
        Unmine(m).GWP3    = Unmine(m).G3_load + Unmine(m).G3_haul + Unmine(m).G3_crush + Unmine(m).G3_grind;
    else
        Unmine(m).Energy3 = [];
        Unmine(m).GWP3    = [];
    end
    if ~isequal(Unmine(m).SEC_D3,0) && ~isempty(Unmine(m).Tonnage3)
        EU_Blast = EU_Blast + sum([Unmine(m).E3_blast]);
        GU_Blast = GU_Blast + sum([Unmine(m).G3_blast]);
    end
    if ~isempty(Unmine(m).Tonnage3)
        EU_Load  = EU_Load + sum([Unmine(m).E3_load]);
        EU_Haul  = EU_Haul + sum([Unmine(m).E3_haul]);
        EU_Crush = EU_Crush + sum([Unmine(m).E3_crush]);
        EU_Grind = EU_Grind + sum([Unmine(m).E3_grind]);
        GU_Load  = GU_Load + sum([Unmine(m).G3_load]);
        GU_Haul  = GU_Haul + sum([Unmine(m).G3_haul]);
        GU_Crush = GU_Crush + sum([Unmine(m).G3_crush]);
        GU_Grind = GU_Grind + sum([Unmine(m).G3_grind]);
    end
    %  Attention: For ore blocks with unmineralised, we need to calculate energy consumption and GWP for both ore and unmineralised components.
    if ~isempty(Ore(m).Percent1)
        row_temp = Ore(m).Percent1 < 100;
    end
    if ~isempty(Ore(m).Energy1) && ~isempty(Unmine(m).Energy3) && ~isempty(Ore(m).GWP1) && ~isempty(Unmine(m).GWP3)
        temp{m,1} = Ore(m).Energy1(row_temp,:) + Unmine(m).Energy3; %temp is used to store the total energy consumption and GWP
        temp{m,2} = Ore(m).GWP1(row_temp,:) + Unmine(m).GWP3;       %of ore blocks containing unmineralised components
    end
    if ~isempty(Ore(m).Energy1) && ~isempty(Ore(m).GWP1)
        new_ore{m,1}             = Ore(m).Energy1;
        new_ore{m,2}             = Ore(m).GWP1;
        new_ore{m,1}(row_temp,:) = temp{m,1}; %replace the energy consumption and GWP of some ore blocks that containing
        new_ore{m,2}(row_temp,:) = temp{m,2}; %unmineralsied components in new_ore with the corresponding values in temp
    end
end
clearvars temp

%% Output
%% "ECGWP" structure
%  (1)Energy consumption and GWP for each unit of mine life cycle;
%  (2)Energy consumption and GWP of each input source(fuel/explosive/electricity) of mine life cycle
ECGWP               = struct;
ECGWP.E_Drill       = EO_Drill + EW_Drill;
ECGWP.E_Blast       = EO_Blast + EW_Blast + EU_Blast;
ECGWP.E_Load        = EO_Load  + EW_Load  + EU_Load;
ECGWP.E_Haul        = EO_Haul  + EW_Haul  + EU_Haul;
ECGWP.E_Crush       = EO_Crush + EU_Crush;
ECGWP.E_Grind       = EO_Grind + EU_Grind;
ECGWP.G_Drill       = GO_Drill + GW_Drill;
ECGWP.G_Blast       = GO_Blast + GW_Blast + GU_Blast;
ECGWP.G_Load        = GO_Load  + GW_Load  + GU_Load;
ECGWP.G_Haul        = GO_Haul  + GW_Haul  + GU_Haul;
ECGWP.G_Crush       = GO_Crush + GU_Crush;
ECGWP.G_Grind       = GO_Grind + GU_Grind;

%% "NBM" structure
%  Create a new Energy-GWP block model
NBM = struct;
%  Assign energy consumption and GWP of each block to this model
for m = 1: size(rock_code,1)
    NBM(m).RockType = sprintf('RockCode%d', rock_code(m));
    NBM(m).X        = [Ore(m).X1_coord      ; Waste(m).X2_coord];
    NBM(m).Y        = [Ore(m).Y1_coord      ; Waste(m).Y2_coord];
    NBM(m).Z        = [Ore(m).Z1_coord      ; Waste(m).Z2_coord];
    NBM(m).x_size   = [Ore(m).X1_size       ; Waste(m).X2_size];
    NBM(m).y_size   = [Ore(m).Y1_size       ; Waste(m).Y2_size];
    NBM(m).z_size   = [Ore(m).Z1_size       ; Waste(m).Z2_size];
    NBM(m).Density  = [Ore(m).Density1      ; Waste(m).Density2];
    NBM(m).Grade    = [Ore(m).Grade1        ; Waste(m).Grade2];
    NBM(m).Tonnage  = [sub_ore{m,1}(:,V.BT) ; Waste(m).Tonnage2];
    NBM(m).Energy   = [new_ore{m,1}         ; Waste(m).Energy2];
    NBM(m).GWP      = [new_ore{m,2}         ; Waste(m).GWP2];
end

%% Plot ECGWP
%  Create 'Name' 'EC_Value' 'GWP_Value' for unit process
Name      = cell(7,1);
EC_Value  = zeros(10,1);
GWP_Value = zeros(10,1);
%  Assign values
%  'Name'
Name{1,1} = sprintf('Drilling');
Name{2,1} = sprintf('Blasting');
Name{3,1} = sprintf('Loading');
Name{4,1} = sprintf('Hauling');
Name{5,1} = sprintf('Crushing');
Name{6,1} = sprintf('Grinding');
Name{7,1} = sprintf('Total');
%  'EC_Value'
EC_Value(1,1) = ECGWP.E_Drill;
EC_Value(2,1) = ECGWP.E_Blast;
EC_Value(3,1) = ECGWP.E_Load;
EC_Value(4,1) = ECGWP.E_Haul;
EC_Value(5,1) = ECGWP.E_Crush;
EC_Value(6,1) = ECGWP.E_Grind;
EC_Value(7,1) = ECGWP.E_Drill+ECGWP.E_Blast+ECGWP.E_Load+ECGWP.E_Haul+ECGWP.E_Crush+ECGWP.E_Grind;
%  'GWP_Value'
GWP_Value(1,1) = ECGWP.G_Drill;
GWP_Value(2,1) = ECGWP.G_Blast;
GWP_Value(3,1) = ECGWP.G_Load;
GWP_Value(4,1) = ECGWP.G_Haul;
GWP_Value(5,1) = ECGWP.G_Crush;
GWP_Value(6,1) = ECGWP.G_Grind;
GWP_Value(7,1) = ECGWP.G_Drill+ECGWP.G_Blast+ECGWP.G_Load+ECGWP.G_Haul+ECGWP.G_Crush+ECGWP.G_Grind;
%  Build 'Process' struct
Process           = struct;
Process.Category  = [Name(1,1);Name(2,1);Name(3,1);Name(4,1);Name(5,1);Name(6,1);Name(7,1)];
Process.EC_Value  = [EC_Value(1,1);EC_Value(2,1);EC_Value(3,1);EC_Value(4,1);EC_Value(5,1);EC_Value(6,1);EC_Value(7,1)];
Process.GWP_Value = [GWP_Value(1,1);GWP_Value(2,1);GWP_Value(3,1);GWP_Value(4,1);GWP_Value(5,1);GWP_Value(6,1);GWP_Value(7,1)];
%  Convert struct to table
Process_table     = struct2table(Process);
%  Plot
figure()
%  Prcoess
g(1,1) = gramm('x',Process_table.Category,'y',Process_table.EC_Value/1e6,'color',Process_table.Category);
g(1,1).geom_bar('dodge',0.6,'width',0.5);
g(1,1).set_color_options('map','brewer2');
g(1,1).set_names('color','','x','Unit Process','y','Energy Consumption (TJ)');
g(1,1).set_title('Energy Consumption for Total and Each Process','FontSize',16);
g(1,1).no_legend();
g(1,2) = gramm('x',Process_table.Category,'y',Process_table.GWP_Value/1e3,'color',Process_table.Category);
g(1,2).geom_bar('dodge',0.6,'width',0.5);
g(1,2).set_color_options('map','brewer2');
g(1,2).set_names('color','','x','Unit Process','y',{('Global Warming Potential');('(ton CO2 eq)')});
g(1,2).set_title('Global Warming Potential for Total and Each Process','FontSize',16);
g(1,2).no_legend();
g.draw();

%% Export NBM (optional)
% for i = 1 : size(NBM,2)
%     temp1    = NBM(i); %The number of columns of NBM
%     rocktype = temp1.RockType;
%     temp1    = rmfield(temp1,'RockType');
%     writetable(struct2table(temp1), 'NewBlockModel_Datamine.xlsx','sheet', rocktype)
%     clearvars temp1
% end
% 
%  Alternative: If user want to put all data in one sheet the following code can do this.
%  for i = 1 : size(NBM,2)
%      temp1 = NBM(i);
% 	   rocktype = temp1.RockType;
% 	   temp1 = rmfield(temp1,'RockType');
%      if i == 1
%          tb = struct2table(temp1);
%      else
%          stru_tab = struct2table(temp1);
%          tb = [tb;stru_tab];
%      end
%      writetable(tb,'NewBlockModel.xlsx','sheet','All_results')
% 	   clearvars temp1
%  end

disp('Done!')

end