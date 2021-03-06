function [NBM, ECGWP] = BlockModel_Computation_GeoviaWhittle
%% ECOMINE is a framework to compute the energy consumption and global warming potential (GWP) for open pit mine
%  Implementation and improvement of Energy consumption and GWP computation based on the approach proposed by Muñoz et al (2014) [1]
%  This version of the function can be used to calculate the block model from GEOVIA Whittle software
%  2022 © C. Zhang
%  [1] Muñoz, J.I., Guzmán, R.R. and Botín, J.A., 2014. International Journal of Mining and Mineral Engineering, 5(1), pp.38-58.DOI: 10.1504/IJMME.2014.058918

%% The main highlights of this framework
%  1. The block-based life cycle assessment(LCA) approach is applied to the ultimate pit limit (UPL) of open-pit mine
%     to estimate the energy consumption and global warming potential(GWP) for mining and comminution stages.
%  2. This framework considers the attributes of UPL block model such as block type,block hardness(based on rock type),
%     coordinates of blocks, and other block attributes.
%  3. The framework is developed from basic engineering equations of energy consumption and global warming potential(GWP), 
%     which the required computation parameters are easy to obtain.
%  4. The energy consumption and GWP can be estimated through this framework, and these two attributes can be assigned to 
%     the corresponding blocks to form the energy and environmental block model respectively.
%  5. Results from this framework can be used to analyze the relationship between grade and energy consumption, also
%     provide greater detials base for better evaluation of equipment,input source selection, mining and processing schedule.
%
%% INPUT:
%  - RockType: Select between "Single Rock Type" or "Multiple Rock Types"
%
%  - BM file: Block model file of GEOVIA Whittle Software, used to import block attributes
%
%      - Block attributes:
%          - block coordinates
%          - block size
%          - block volume
%          - block tonnage
%          - specific gravity
%          - volume factor: coefficient related to the actual block volume
%          - rk_mill_tonnage: ore block tonnage
%          - rk_rejected_tonnage: waste block tonnage
%          - metal_mill/rejected_grade: metal garde degree in ore/waste blocks(e.g. Au_mill_grade/Au_rejected_grade)
%          - metal_mill/rejected_mass:  metal mass in ore/waste blocks(e.g. Au_mill_mass/Au_rejected_mass)
%
%  - CP file: Computation parameters file, used to import inventory analysis dataset related to basic engineering equations.
%
%  - EV(MJ/m3): Specific energy consumption of Rotary Drilling which depends on the rock type and estimated based on 
%               the "Unified Classification" system of rock according to drillablility(Isheyskiy and Sanchidrián, 2020)
%
%  - Metal type: Select among Gold, Copper, Iron, Silver, Zinc, Aluminium, Uranium
%
%  - Units: Select between "Feet" and "Meters".
%
%% OUTPUT:
%
%  - NMB:  structure containing all block attributes and new block attributes 'Energy Consumption' 'Global Warming Potential'
%          - Export new block model file, with format:[X,Y,Z,x_size,y_size,z_size,sg,volume,volume_factor,block_tonnage,
%                                                      rk_mill/rejected_tonnage,rk_metal_mill/rejected_grade,rk_metal_mill/rejected_mass,EnergyConsumption,GWP]
%
%  - ECGWP: structure containing energy consumption and GWP for each period within the open pit mine life
%
%% Determine rock type and Import files and calculation parameters
[rk_ind,~,~,~,~,~,~,~,~] = Interface_Selection(1,[],[]);
switch rk_ind
    case 1
        %% Single Rock Type
        %  BM file
        G_V = Import_File('GeoviaWhittle','Single');
        %  CP file
        p_v = Import_File('Computation parameter',[]);
        %  EV parameters(Note:If only one rock type in the block model, the EV cannot equal to 0)
        [S_EV,sn_rk] = Drilling_Specific_Energy('GeoviaWhittle',[],'Single',[]);
        %  Identify the column index of block attributes for the imported BM file
        [~,~,P,~,~,MG,MT,RG,RT] = Interface_Selection(4,'Single',G_V,[]);
        %  Convert table to double type
        BM = table2array(G_V);

        %% Screening and assign the corresponding blocks to single rock type
        %  Create cells and exclude air blocks based on block attribute 'sg'
        %  Rock
        rock    = cell(1,1);
        ind_rk  = BM(:,P.SG) ~= 0;
        rock{:} = BM(ind_rk,:);
        %  Air
        air     = cell(1,1);
        ind_air = BM(:,P.SG) == 0;
        air{:}  = BM(ind_air,:);
        %  Create cells and extract ore/waste blocks based on block attributes 'mill/rejected_tonnage'
        %  Ore
        ore     = cell(1,1);
        ind_ore = rock{:}(:,P.RMT) > 0;
        ore{:}  = rock{:}(ind_ore,:);
        %  Waste
        waste     = cell(1,1);
        ind_waste = rock{:}(:,P.RRT) > 0;
        waste{:}  = rock{:}(ind_waste,:);

        %% Assign values to the corresponding period
        %  Identify the number of periods for mine based on block attribute 'mined_period_a_value'
        per = table2array(unique(G_V(:,P.Year)));
        per(per == 0) = []; %remove period 0
        %  Create cell to store each period value for ore and waste
        %  Value
        p_o = cell(size(per,1),1);
        p_w = cell(size(per,1),1);
        %  Execution loop
        for m = 1 : size(per,1)
            %Ore
            ind_po = ore{:}(:,P.Year) == per(m);
            p_o{m} = ore{:}(ind_po,:);
            %Waste
            ind_pw = waste{:}(:,P.Year) == per(m);
            p_w{m} = waste{:}(ind_pw,:);
        end

        %% Attention: Select correct unit measure of block coordinates before executing computation
        %  This framework provides two common units of coordinates: meters and feet
        %  (1)S_op: ore to plant; (2)S_wd: waste to dump
        S_op  = cell(size(per,1),1);
        S_wd  = cell(size(per,1),1);
        %  Execution loop
        [~,Distance_Computation,~,~,~,~,~,~,~] = Interface_Selection(2,[],[]);
        switch Distance_Computation
            case 1 %feet
                for m = 1 : size(per,1) %convert distance unit from feet to km
                    if ~isempty(p_o{m}) || ~isempty(p_w{m})
                        S_op{m,1}  = (Transportation_Distance(p_v.X_plant,p_v.Y_plant,p_v.Z_plant,p_o{m}(:,P.X),p_o{m}(:,P.Y),p_o{m}(:,P.Z))).*3.048e-04;
                        S_wd{m,1}  = (Transportation_Distance(p_v.X_dump,p_v.Y_dump,p_v.Z_dump,p_w{m}(:,P.X),p_w{m}(:,P.Y),p_w{m}(:,P.Z))).*3.048e-04;
                    end
                end
            case 2 %meters
                for m = 1 : size(per,1) %convert distance unit from meters to km
                    if ~isempty(p_o{m}) || ~isempty(p_w{m})
                        S_op{m,1}  = (Transportation_Distance(p_v.X_plant,p_v.Y_plant,p_v.Z_plant,p_o{m}(:,P.X),p_o{m}(:,P.Y),p_o{m}(:,P.Z))).*0.001;
                        S_wd{m,1}  = (Transportation_Distance(p_v.X_dump,p_v.Y_dump,p_v.Z_dump,p_w{m}(:,P.X),p_w{m}(:,P.Y),p_w{m}(:,P.Z))).*0.001;
                    end
                end
        end

        %% Computing the energy consumption and GWP
        %  Create energy consumption and GWP cells for ore
        %  Column:1-drill,2-blast,3-load,4-haul,5-crush,6-grind
        o_ec  = cell(size(per,1),6);
        o_gwp = cell(size(per,1),6);
        %  Execution loop
        for m = 1 : size(per,1)
            if ~isempty(p_o{m}) && ~isequal(S_EV,0)
                %Drilling
                o_ec{m,1}  = Energy_Consumption(p_v.A,S_EV,p_v.L,p_v.N,p_v.nD,[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],p_o{m}(:,P.RMT),'Drill');
                o_gwp{m,1} = Global_Warming_Potential(o_ec{m,1},[],p_v.EF_fuel,[],p_v.EF_electricity,p_v.wf_a1,p_v.wf_b1,[],[],[],[],[],[],[],[],'Drill');
                %Blasting
                o_ec{m,2}  = Energy_Consumption([],[],[],[],[],p_v.LF,p_v.Eblast,[],[],[],[],[],[],[],[],[],[],[],[],[],[],p_o{m}(:,P.RMT),'Blast');
                o_gwp{m,2} = Global_Warming_Potential(o_ec{m,2},p_v.Eblast,[],p_v.EF_explosive,[],[],[],[],[],[],[],[],[],[],[],'Blast');
                %Loading
                o_ec{m,3}  = Energy_Consumption([],[],[],[],[],[],[],p_v.PI,p_v.lt,p_v.Nl,p_v.mTruck,[],[],[],[],[],[],[],[],[],[],p_o{m}(:,P.RMT),'Load');
                o_gwp{m,3} = Global_Warming_Potential(o_ec{m,3},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],p_v.wf_a2,p_v.wf_b2,[],[],[],[],[],[],'Load');
                %Hauling
                o_ec{m,4}  = Energy_Consumption([],[],[],[],[],[],[],[],[],[],p_v.mTruck,S_op{m,1},p_v.Rs,p_v.Ri,p_v.rs,p_v.MTruck,[],[],[],[],[],p_o{m}(:,P.RMT),'Haul');
                o_gwp{m,4} = Global_Warming_Potential(o_ec{m,4},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],[],[],p_v.wf_a3,p_v.wf_b3,[],[],[],[],'Haul');
                %Crushing
                o_ec{m,5}  = Energy_Consumption([],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],p_v.wi,p_v.c_out,p_v.c_in,[],[],p_o{m}(:,P.RMT),'Crush');
                o_gwp{m,5} = Global_Warming_Potential(o_ec{m,5},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],[],[],[],[],p_v.wf_a4,p_v.wf_b4,[],[],'Crush');
                %Grinding
                o_ec{m,6}  = Energy_Consumption([],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],p_v.wi,[],[],p_v.g_out,p_v.g_in,p_o{m}(:,P.RMT),'Grind');
                o_gwp{m,6} = Global_Warming_Potential(o_ec{m,6},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],[],[],[],[],[],[],p_v.wf_a5,p_v.wf_b5,'Grind');
            end
        end
        %  Create energy consumption and GWP cells for waste
        %  Column:1-drill,2-blast,3-load,4-haul
        w_ec  = cell(size(per,1),4);
        w_gwp = cell(size(per,1),4);
        %  Execution loop
        for m = 1 : size(per,1)
            if ~isempty(p_w{m}) && ~isequal(S_EV,0)
                %Drilling
                w_ec{m,1}  = Energy_Consumption(p_v.A,S_EV,p_v.L,p_v.N,p_v.nD,[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],p_w{m}(:,P.RRT),'Drill');
                w_gwp{m,1} = Global_Warming_Potential(w_ec{m,1},[],p_v.EF_fuel,[],p_v.EF_electricity,p_v.wf_a1,p_v.wf_b1,[],[],[],[],[],[],[],[],'Drill');
                %Blasting
                w_ec{m,2}  = Energy_Consumption([],[],[],[],[],p_v.LF,p_v.Eblast,[],[],[],[],[],[],[],[],[],[],[],[],[],[],p_w{m}(:,P.RRT),'Blast');
                w_gwp{m,2} = Global_Warming_Potential(w_ec{m,2},p_v.Eblast,[],p_v.EF_explosive,[],[],[],[],[],[],[],[],[],[],[],'Blast');
                %Loading
                w_ec{m,3}  = Energy_Consumption([],[],[],[],[],[],[],p_v.PI,p_v.lt,p_v.Nl,p_v.mTruck,[],[],[],[],[],[],[],[],[],[],p_w{m}(:,P.RRT),'Load');
                w_gwp{m,3} = Global_Warming_Potential(w_ec{m,3},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],p_v.wf_a2,p_v.wf_b2,[],[],[],[],[],[],'Load');
                %Hauling
                w_ec{m,4}  = Energy_Consumption([],[],[],[],[],[],[],[],[],[],p_v.mTruck,S_wd{m,1},p_v.Rs,p_v.Ri,p_v.rs,p_v.MTruck,[],[],[],[],[],p_w{m}(:,P.RRT),'Haul');
                w_gwp{m,4} = Global_Warming_Potential(w_ec{m,4},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],[],[],p_v.wf_a3,p_v.wf_b3,[],[],[],[],'Haul');
            end
        end
        %  Calculate energy consumption and GWP of each period
        %  Create cells for each unit process of ore/waste
        O_EC  = zeros(size(per,1),6); O_GWP  = zeros(size(per,1),6); %ore
        W_EC  = zeros(size(per,1),4); W_GWP  = zeros(size(per,1),4); %waste
        %  Create cells for each unit process (1-energy consumption, 2-GWP)
        Drill = zeros(size(per,1),2); Blast = zeros(size(per,1),2); Load  = zeros(size(per,1),2);
        Haul  = zeros(size(per,1),2); Crush = zeros(size(per,1),2); Grind = zeros(size(per,1),2);
        %  Create cells for EC and GWP
        EC  = zeros(size(per,1),1); GWP = zeros(size(per,1),1);
        %  Execution loop
        for m = 1 : size(per,1)
            %ORE
            if ~isempty(o_ec(m)) && ~isempty(o_gwp(m))
                O_EC(m,1) = sum(o_ec{m,1}); O_GWP(m,1) = sum(o_gwp{m,1}); %drill
                O_EC(m,2) = sum(o_ec{m,2}); O_GWP(m,2) = sum(o_gwp{m,2}); %blast
                O_EC(m,3) = sum(o_ec{m,3}); O_GWP(m,3) = sum(o_gwp{m,3}); %load
                O_EC(m,4) = sum(o_ec{m,4}); O_GWP(m,4) = sum(o_gwp{m,4}); %haul
                O_EC(m,5) = sum(o_ec{m,5}); O_GWP(m,5) = sum(o_gwp{m,5}); %crush
                O_EC(m,6) = sum(o_ec{m,6}); O_GWP(m,6) = sum(o_gwp{m,6}); %grind
            end
            %WASTE
            if ~isempty(w_ec(m)) && ~isempty(w_gwp(m))
                W_EC(m,1) = sum(w_ec{m,1}); W_GWP(m,1) = sum(w_gwp{m,1}); %drill
                W_EC(m,2) = sum(w_ec{m,2}); W_GWP(m,2) = sum(w_gwp{m,2}); %blast
                W_EC(m,3) = sum(w_ec{m,3}); W_GWP(m,3) = sum(w_gwp{m,3}); %load
                W_EC(m,4) = sum(w_ec{m,4}); W_GWP(m,4) = sum(w_gwp{m,4}); %haul
            end
            %EC and GWP of each unit
            %Drill
            Drill(m,1) = O_EC(m,1)+W_EC(m,1); Drill(m,2) = O_GWP(m,1)+W_GWP(m,1);
            %Blast
            Blast(m,1) = O_EC(m,2)+W_EC(m,2); Blast(m,2) = O_GWP(m,2)+W_GWP(m,2);
            %Load
            Load(m,1)  = O_EC(m,3)+W_EC(m,3); Load(m,2)  = O_GWP(m,3)+W_GWP(m,3);
            %Haul
            Haul(m,1)  = O_EC(m,4)+W_EC(m,4); Haul(m,2)  = O_GWP(m,4)+W_GWP(m,4);
            %Crush
            Crush(m,1) = O_EC(m,5);           Crush(m,2) = O_GWP(m,5);
            %Grind
            Grind(m,1) = O_EC(m,6);           Grind(m,2) = O_GWP(m,6);
            %Energy consumption
            EC(m,1)  = Drill(m,1)+Blast(m,1)+Load(m,1)+Haul(m,1)+Crush(m,1)+Grind(m,1);
            %GWP
            GWP(m,1) = Drill(m,2)+Blast(m,2)+Load(m,2)+Haul(m,2)+Crush(m,2)+Grind(m,2);
        end

        %% Build 'NBM' struct
        NBM = struct;
        %  Create cells of energy consumption and GWP for 1-ore(o_ec/gwp) and 2-waste(w_ec/gwp)
        enecon = cell(size(per,1),2); glowarpot = cell(size(per,1),2);
        %  Assign values to NBM struct
        for m = 1: size(per,1)
            %Calculate Values for 1-ore(o_ec/gwp) and 2-waste(w_ec/gwp)
            %Energy consumption
            enecon{m,1} = o_ec{m,1}+o_ec{m,2}+o_ec{m,3}+o_ec{m,4}+o_ec{m,5}+o_ec{m,6};
            enecon{m,2} = w_ec{m,1}+w_ec{m,2}+w_ec{m,3}+w_ec{m,4};
            %Global warming potential
            glowarpot{m,1} = o_gwp{m,1}+o_gwp{m,2}+o_gwp{m,3}+o_gwp{m,4}+o_gwp{m,5}+o_gwp{m,6};
            glowarpot{m,2} = w_gwp{m,1}+w_gwp{m,2}+w_gwp{m,3}+w_gwp{m,4};
            %Assign values to struct
            NBM(m).Period                   = sprintf('Period%d', per(m));
            NBM(m).X                        = [p_o{m,1}(:,P.X)   ; p_w{m,1}(:,P.X)];
            NBM(m).Y                        = [p_o{m,1}(:,P.Y)   ; p_w{m,1}(:,P.Y)];
            NBM(m).Z                        = [p_o{m,1}(:,P.Z)   ; p_w{m,1}(:,P.Z)];
            NBM(m).X_size                   = [p_o{m,1}(:,P.XS)  ; p_w{m,1}(:,P.XS)];
            NBM(m).Y_size                   = [p_o{m,1}(:,P.YS)  ; p_w{m,1}(:,P.YS)];
            NBM(m).Z_size                   = [p_o{m,1}(:,P.ZS)  ; p_w{m,1}(:,P.ZS)];
            NBM(m).Sg                       = [p_o{m,1}(:,P.SG)  ; p_w{m,1}(:,P.SG)];
            NBM(m).Volume                   = [p_o{m,1}(:,P.Vol) ; p_w{m,1}(:,P.Vol)];
            NBM(m).Volume_factor            = [p_o{m,1}(:,P.VF)  ; p_w{m,1}(:,P.VF)];
            NBM(m).Block_tonnage            = [p_o{m,1}(:,P.BT)  ; p_w{m,1}(:,P.BT)];
            NBM(m).rk_mill_tonnage          = [p_o{m,1}(:,P.RMT) ; p_w{m,1}(:,P.RMT)];
            NBM(m).rk_metal_mill_grade      = [p_o{m,1}(:,MG)    ; p_w{m,1}(:,MG)];
            NBM(m).rk_metal_mill_mass       = [p_o{m,1}(:,MT)    ; p_w{m,1}(:,MT)];
            NBM(m).rk_rejected_tonnage      = [p_o{m,1}(:,P.RRT) ; p_w{m,1}(:,P.RRT)];
            NBM(m).rk_metal_rejected_grade  = [p_o{m,1}(:,RG)    ; p_w{m,1}(:,RG)];
            NBM(m).rk_metal_rejected_mass   = [p_o{m,1}(:,RT)    ; p_w{m,1}(:,RT)];
            NBM(m).Energy_Consumption       = [enecon{m,1}       ; enecon{m,2}];
            NBM(m).Global_Warming_Potential = [glowarpot{m,1}    ; glowarpot{m,2}];
        end

    case 2
        %% Multiple Rock Types
        %  BM file
        G_V = Import_File('GeoviaWhittle','Multiple');
        %  CP file
        p_v = Import_File('Computation parameter',[]);
        %  EV parameters
        [M_EV,mn_rk] = Drilling_Specific_Energy('GeoviaWhittle',[],'Multiple',G_V);
        %  Identify the column index of block attributes for the imported BM file
        [~,~,P,~,~,MG,MT,RG,RT] = Interface_Selection(4,'Multiple',G_V,mn_rk);
        %  Convert table to double type
        BM = table2array(G_V);

        %% Screening and assign the corresponding blocks to multiple rock types
        %  Create cells and exclude air blocks based on block attribute 'sg'
        %  Rock
        rock    = cell(1,1);
        ind_rk  = BM(:,P.SG) ~= 0;
        rock{:} = BM(ind_rk,:);
        %  Air
        air     = cell(1,1);
        ind_air = BM(:,P.SG) == 0;
        air{:}  = BM(ind_air,:);
        %  Create cells and extract ore/waste of each rock type
        %  based on block attributes 'rk(n)_mill/rejected_tonnage'
        ore   = cell(mn_rk,1);
        waste = cell(mn_rk,1);
        %  Execution loop
        for i = 1 : mn_rk
            %ore
            ind_ore  = rock{:}(:,P.RMT(i)) > 0;
            ore{i,1} = rock{:}(ind_ore,:);
            %waste
            ind_waste  = rock{:}(:,P.RRT(i)) > 0;
            waste{i,1} = rock{:}(ind_waste,:);
        end

        %% Assign values to the corresponding period
        %  Identify the number of periods for mine based on block attribute 'mined_period_a_value'
        per = table2array(unique(G_V(:,P.Year)));
        per(per == 0) = []; %remove period 0
        %  Create cell to store each period value for ore/waste
        %  Value
        p_o  = cell(size(per,1),mn_rk);
        p_w  = cell(size(per,1),mn_rk);
        %  Execution loop
        for m = 1 : size(per,1)
            for i = 1 : mn_rk
                %Ore
                ind_po   = ore{i,1}(:,P.Year) == per(m);
                p_o{m,i} = ore{i,1}(ind_po,:);
                %Waste
                ind_pw   = waste{i,1}(:,P.Year) == per(m);
                p_w{m,i} = waste{i,1}(ind_pw,:);
            end
        end

        %% Attention: Select correct unit measure of block coordinates before executing computation
        %  Create cells
        S_op  = cell(size(per,1),mn_rk);
        S_wd  = cell(size(per,1),mn_rk);
        %  Execution loop
        [~,Distance_Computation,~,~,~,~,~,~,~] = Interface_Selection(2,[],[]);
        switch Distance_Computation
            case 1 %feet
                for m = 1 : size(per,1) %convert distance unit from feet to km
                    for i = 1 : mn_rk
                        if ~isempty(p_o{m,i}) || ~isempty(p_w{m,i})
                            S_op{m,i}  = (Transportation_Distance(p_v.X_plant,p_v.Y_plant,p_v.Z_plant,p_o{m,i}(:,P.X),p_o{m,i}(:,P.Y),p_o{m,i}(:,P.Z))).*3.048e-04;
                            S_wd{m,i}  = (Transportation_Distance(p_v.X_dump,p_v.Y_dump,p_v.Z_dump,p_w{m,i}(:,P.X),p_w{m,i}(:,P.Y),p_w{m,i}(:,P.Z))).*3.048e-04;
                        end
                    end
                end
            case 2 %meters
                for m = 1 : size(per,1) %convert distance unit from meters to km
                    for i = 1 : mn_rk
                        if ~isempty(p_o{m,i}) || ~isempty(p_w{m,i})
                            S_op{m,i}  = (Transportation_Distance(p_v.X_plant,p_v.Y_plant,p_v.Z_plant,p_o{m,i}(:,P.X),p_o{m,i}(:,P.Y),p_o{m,i}(:,P.Z))).*0.001;
                            S_wd{m,i}  = (Transportation_Distance(p_v.X_dump,p_v.Y_dump,p_v.Z_dump,p_w{m,i}(:,P.X),p_w{m,i}(:,P.Y),p_w{m,i}(:,P.Z))).*0.001;
                        end
                    end
                end
        end

        %% Computing the energy consumption and GWP
        %  Create energy consumption and GWP cells of each unit process for ore
        %  The 3rd column: 1-drill,2-blast,3-load,4-haul,5-crush,6-grind
        o_ec  = cell(size(per,1),mn_rk,6);
        o_gwp = cell(size(per,1),mn_rk,6);
        %  Execution loop
        for m = 1 : size(per,1)
            for i = 1 : mn_rk
                if ~isempty(p_o{m,i}) && ~isequal(M_EV(i),0)
                    %Drilling
                    o_ec{m,i,1}  = Energy_Consumption(p_v.A,M_EV(i),p_v.L,p_v.N,p_v.nD,[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],p_o{m,i}(:,P.RMT(i)),'Drill');
                    o_gwp{m,i,1} = Global_Warming_Potential(o_ec{m,i,1},[],p_v.EF_fuel,[],p_v.EF_electricity,p_v.wf_a1,p_v.wf_b1,[],[],[],[],[],[],[],[],'Drill');
                    %Blasting
                    o_ec{m,i,2}  = Energy_Consumption([],[],[],[],[],p_v.LF,p_v.Eblast,[],[],[],[],[],[],[],[],[],[],[],[],[],[],p_o{m,i}(:,P.RMT(i)),'Blast');
                    o_gwp{m,i,2} = Global_Warming_Potential(o_ec{m,i,2},p_v.Eblast,[],p_v.EF_explosive,[],[],[],[],[],[],[],[],[],[],[],'Blast');
                    %Loading
                    o_ec{m,i,3}  = Energy_Consumption([],[],[],[],[],[],[],p_v.PI,p_v.lt,p_v.Nl,p_v.mTruck,[],[],[],[],[],[],[],[],[],[],p_o{m,i}(:,P.RMT(i)),'Load');
                    o_gwp{m,i,3} = Global_Warming_Potential(o_ec{m,i,3},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],p_v.wf_a2,p_v.wf_b2,[],[],[],[],[],[],'Load');
                    %Hauling
                    o_ec{m,i,4}  = Energy_Consumption([],[],[],[],[],[],[],[],[],[],p_v.mTruck,S_op{m,i},p_v.Rs,p_v.Ri,p_v.rs,p_v.MTruck,[],[],[],[],[],p_o{m,i}(:,P.RMT(i)),'Haul');
                    o_gwp{m,i,4} = Global_Warming_Potential(o_ec{m,i,4},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],[],[],p_v.wf_a3,p_v.wf_b3,[],[],[],[],'Haul');
                    %Crushing
                    o_ec{m,i,5}  = Energy_Consumption([],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],p_v.wi,p_v.c_out,p_v.c_in,[],[],p_o{m,i}(:,P.RMT(i)),'Crush');
                    o_gwp{m,i,5} = Global_Warming_Potential(o_ec{m,i,5},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],[],[],[],[],p_v.wf_a4,p_v.wf_b4,[],[],'Crush');
                    %Grinding
                    o_ec{m,i,6}  = Energy_Consumption([],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],p_v.wi,[],[],p_v.g_out,p_v.g_in,p_o{m,i}(:,P.RMT(i)),'Grind');
                    o_gwp{m,i,6} = Global_Warming_Potential(o_ec{m,i,6},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],[],[],[],[],[],[],p_v.wf_a5,p_v.wf_b5,'Grind');
                end
                if ~isempty(p_o{m,i}) && isequal(M_EV(i),0)
                    %Loading
                    o_ec{m,i,3}  = Energy_Consumption([],[],[],[],[],[],[],p_v.PI,p_v.lt,p_v.Nl,p_v.mTruck,[],[],[],[],[],[],[],[],[],[],p_o{m,i}(:,P.RMT(i)),'Load');
                    o_gwp{m,i,3} = Global_Warming_Potential(o_ec{m,i,3},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],p_v.wf_a2,p_v.wf_b2,[],[],[],[],[],[],'Load');
                    %Hauling
                    o_ec{m,i,4}  = Energy_Consumption([],[],[],[],[],[],[],[],[],[],p_v.mTruck,S_op{m,i},p_v.Rs,p_v.Ri,p_v.rs,p_v.MTruck,[],[],[],[],[],p_o{m,i}(:,P.RMT(i)),'Haul');
                    o_gwp{m,i,4} = Global_Warming_Potential(o_ec{m,i,4},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],[],[],p_v.wf_a3,p_v.wf_b3,[],[],[],[],'Haul');
                    %Crushing
                    o_ec{m,i,5}  = Energy_Consumption([],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],p_v.wi,p_v.c_out,p_v.c_in,[],[],p_o{m,i}(:,P.RMT(i)),'Crush');
                    o_gwp{m,i,5} = Global_Warming_Potential(o_ec{m,i,5},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],[],[],[],[],p_v.wf_a4,p_v.wf_b4,[],[],'Crush');
                    %Grinding
                    o_ec{m,i,6}  = Energy_Consumption([],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],p_v.wi,[],[],p_v.g_out,p_v.g_in,p_o{m,i}(:,P.RMT(i)),'Grind');
                    o_gwp{m,i,6} = Global_Warming_Potential(o_ec{m,i,6},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],[],[],[],[],[],[],p_v.wf_a5,p_v.wf_b5,'Grind');
                end
                if isempty(p_o{m,i}) && isequal(M_EV(i),0)
                    o_ec  = [];
                    o_gwp = [];
                end
            end
        end
        %  Create energy consumption and GWP cells of each unit for waste
        %  3rd-column:1-drill,2-blast,3-load,4-haul
        w_ec  = cell(size(per,1),mn_rk,4);
        w_gwp = cell(size(per,1),mn_rk,4);
        %  Execution loop
        for m = 1 : size(per,1)
            for i = 1 : mn_rk
                if ~isempty(p_w{m,i}) && ~isequal(M_EV(i),0)
                    %Drilling
                    w_ec{m,i,1}  = Energy_Consumption(p_v.A,M_EV(i),p_v.L,p_v.N,p_v.nD,[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],p_w{m,i}(:,P.RRT(i)),'Drill');
                    w_gwp{m,i,1} = Global_Warming_Potential(w_ec{m,i,1},[],p_v.EF_fuel,[],p_v.EF_electricity,p_v.wf_a1,p_v.wf_b1,[],[],[],[],[],[],[],[],'Drill');
                    %Blasting
                    w_ec{m,i,2}  = Energy_Consumption([],[],[],[],[],p_v.LF,p_v.Eblast,[],[],[],[],[],[],[],[],[],[],[],[],[],[],p_w{m,i}(:,P.RRT(i)),'Blast');
                    w_gwp{m,i,2} = Global_Warming_Potential(w_ec{m,i,2},p_v.Eblast,[],p_v.EF_explosive,[],[],[],[],[],[],[],[],[],[],[],'Blast');
                    %Loading
                    w_ec{m,i,3}  = Energy_Consumption([],[],[],[],[],[],[],p_v.PI,p_v.lt,p_v.Nl,p_v.mTruck,[],[],[],[],[],[],[],[],[],[],p_w{m,i}(:,P.RRT(i)),'Load');
                    w_gwp{m,i,3} = Global_Warming_Potential(w_ec{m,i,3},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],p_v.wf_a2,p_v.wf_b2,[],[],[],[],[],[],'Load');
                    %Hauling
                    w_ec{m,i,4}  = Energy_Consumption([],[],[],[],[],[],[],[],[],[],p_v.mTruck,S_wd{m,i},p_v.Rs,p_v.Ri,p_v.rs,p_v.MTruck,[],[],[],[],[],p_w{m,i}(:,P.RRT(i)),'Haul');
                    w_gwp{m,i,4} = Global_Warming_Potential(w_ec{m,i,4},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],[],[],p_v.wf_a3,p_v.wf_b3,[],[],[],[],'Haul');
                end
                if ~isempty(p_w{m,i}) && isequal(M_EV(i),0)
                    %Loading
                    w_ec{m,i,3}  = Energy_Consumption([],[],[],[],[],[],[],p_v.PI,p_v.lt,p_v.Nl,p_v.mTruck,[],[],[],[],[],[],[],[],[],[],p_w{m,i}(:,P.RRT(i)),'Load');
                    w_gwp{m,i,3} = Global_Warming_Potential(w_ec{m,i,3},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],p_v.wf_a2,p_v.wf_b2,[],[],[],[],[],[],'Load');
                    %Hauling
                    w_ec{m,i,4}  = Energy_Consumption([],[],[],[],[],[],[],[],[],[],p_v.mTruck,S_wd{m,i},p_v.Rs,p_v.Ri,p_v.rs,p_v.MTruck,[],[],[],[],[],p_w{m,i}(:,P.RRT(i)),'Haul');
                    w_gwp{m,i,4} = Global_Warming_Potential(w_ec{m,i,4},[],p_v.EF_fuel,[],p_v.EF_electricity,[],[],[],[],p_v.wf_a3,p_v.wf_b3,[],[],[],[],'Haul');
                end
                if isempty(p_w{m,i}) && isequal(M_EV(i),0)
                    w_ec  = [];
                    w_gwp = [];
                end
            end
        end
        %  Calculate energy consumption and GWP of each period
        %  Create cells for each unit of ore/waste
        O_EC  = zeros(size(per,1),mn_rk,6); O_GWP  = zeros(size(per,1),mn_rk,6); %ore
        W_EC  = zeros(size(per,1),mn_rk,4); W_GWP  = zeros(size(per,1),mn_rk,4); %waste
        %  Create cells for each unit(1-energy consumption, 2-GWP)
        Drill = zeros(size(per,1),2); Blast = zeros(size(per,1),2); Load  = zeros(size(per,1),2);
        Haul  = zeros(size(per,1),2); Crush = zeros(size(per,1),2); Grind = zeros(size(per,1),2);
        %  Create cells for EC and GWP
        EC  = zeros(size(per,1),1); GWP = zeros(size(per,1),1);
        %  Execution loop
        for m = 1 : size(per,1)
            for i = 1 : mn_rk
                %ORE
                if ~isempty(o_ec(m,i)) && ~isempty(o_gwp(m,i))
                    O_EC(m,i,1) = sum(o_ec{m,i,1}); O_GWP(m,i,1) = sum(o_gwp{m,i,1}); %drill
                    O_EC(m,i,2) = sum(o_ec{m,i,2}); O_GWP(m,i,2) = sum(o_gwp{m,i,2}); %blast
                    O_EC(m,i,3) = sum(o_ec{m,i,3}); O_GWP(m,i,3) = sum(o_gwp{m,i,3}); %load
                    O_EC(m,i,4) = sum(o_ec{m,i,4}); O_GWP(m,i,4) = sum(o_gwp{m,i,4}); %haul
                    O_EC(m,i,5) = sum(o_ec{m,i,5}); O_GWP(m,i,5) = sum(o_gwp{m,i,5}); %crush
                    O_EC(m,i,6) = sum(o_ec{m,i,6}); O_GWP(m,i,6) = sum(o_gwp{m,i,6}); %grind
                end
                %WASTE
                if ~isempty(w_ec(m,i)) && ~isempty(w_gwp(m,i))
                    W_EC(m,i,1) = sum(w_ec{m,i,1}); W_GWP(m,i,1) = sum(w_gwp{m,i,1}); %drill
                    W_EC(m,i,2) = sum(w_ec{m,i,2}); W_GWP(m,i,2) = sum(w_gwp{m,i,2}); %blast
                    W_EC(m,i,3) = sum(w_ec{m,i,3}); W_GWP(m,i,3) = sum(w_gwp{m,i,3}); %load
                    W_EC(m,i,4) = sum(w_ec{m,i,4}); W_GWP(m,i,4) = sum(w_gwp{m,i,4}); %haul
                end
                %EC and GWP of each unit process
                %Drill
                Drill(m,1) = sum(O_EC(m,:,1))+sum(W_EC(m,:,1));
                Drill(m,2) = sum(O_GWP(m,:,1))+sum(W_GWP(m,:,1));
                %Blast
                Blast(m,1) = sum(O_EC(m,:,2))+sum(W_EC(m,:,2));
                Blast(m,2) = sum(O_GWP(m,:,2))+sum(W_GWP(m,:,2));
                %Load
                Load(m,1)  = sum(O_EC(m,:,3))+sum(W_EC(m,:,3));
                Load(m,2)  = sum(O_GWP(m,:,3))+sum(W_GWP(m,:,3));
                %Haul
                Haul(m,1)  = sum(O_EC(m,:,4))+sum(W_EC(m,:,4));
                Haul(m,2)  = sum(O_GWP(m,:,4))+sum(W_GWP(m,:,4));
                %Crush
                Crush(m,1) = sum(O_EC(m,:,5));
                Crush(m,2) = sum(O_GWP(m,:,5));
                %Grind
                Grind(m,1) = sum(O_EC(m,:,6));
                Grind(m,2) = sum(O_GWP(m,:,6));
                %Energy consumption
                EC(m,1)  = Drill(m,1)+Blast(m,1)+Load(m,1)+Haul(m,1)+Crush(m,1)+Grind(m,1);
                %GWP
                GWP(m,1) = Drill(m,2)+Blast(m,2)+Load(m,2)+Haul(m,2)+Crush(m,2)+Grind(m,2);
            end
        end

        %% Build 'NBM' struct
        NBM = struct;
        %  Merge each rock type for ore and waste
        p_ore   = cell(size(p_o,1),1);
        p_waste = cell(size(p_w,1),1);
        for m = 1 : size(per,1)
            o_dummy = p_o{m,1};
            w_dummy = p_w{m,1};
            for j = 2 : size(p_o,2)
                o_dummy = [o_dummy ; p_o{m,j}];
                for k = 2 : size(p_w,2)
                    w_dummy = [w_dummy ; p_w{m,k}];
                end
            end
            p_ore{m}   = o_dummy;
            p_waste{m} = w_dummy;
        end
        clearvars o_dummy w_dummy
        %  Create cells of energy consumption and GWP for 1-ore(o_ec/gwp) and 2-waste(w_ec/gwp)
        enecon = cell(size(per,1),mn_rk,2); glowarpot = cell(size(per,1),mn_rk,2);
        EneCon = cell(size(per,1),2);       GloWarPot = cell(size(per,1),2);
        %  Calculate energy consumption and global warming potential for ore and waste
        for m = 1 : size(per,1)
            for i = 1 : mn_rk
                enecon{m,i,1}    = o_ec{m,i,1}+o_ec{m,i,2}+o_ec{m,i,3}+o_ec{m,i,4}+o_ec{m,i,5}+o_ec{m,i,6};
                enecon{m,i,2}    = w_ec{m,i,1}+w_ec{m,i,2}+w_ec{m,i,3}+w_ec{m,i,4};
                glowarpot{m,i,1} = o_gwp{m,i,1}+o_gwp{m,i,2}+o_gwp{m,i,3}+o_gwp{m,i,4}+o_gwp{m,i,5}+o_gwp{m,i,6};
                glowarpot{m,i,2} = w_gwp{m,i,1}+w_gwp{m,i,2}+w_gwp{m,i,3}+w_gwp{m,i,4};
                %Merge energy consumption and GWP for each rock type
                eo_dummy = enecon{m,1,1};
                ew_dummy = enecon{m,1,2};
                go_dummy = glowarpot{m,1,1};
                gw_dummy = glowarpot{m,1,2};
                for j = 2 : size(enecon,2)
                    eo_dummy = [eo_dummy ; enecon{m,j,1}];
                    ew_dummy = [ew_dummy ; enecon{m,j,2}];
                    for k = 2 : size(glowarpot,2)
                        go_dummy = [go_dummy ; glowarpot{m,k,1}];
                        gw_dummy = [gw_dummy ; glowarpot{m,k,2}];
                    end
                end
                EneCon{m,1}    = eo_dummy; EneCon{m,2}    = ew_dummy;
                GloWarPot{m,1} = go_dummy; GloWarPot{m,2} = gw_dummy;
            end
        end
        clearvars eo_dummy ew_dummy go_dummy gw_dummy
        %  Create fieldname cells for NBM struct
        fieldname1 = cell(mn_rk,1); fieldname2 = cell(mn_rk,1); fieldname3 = cell(mn_rk,1);fieldname4 = cell(mn_rk,1); fieldname5 = cell(mn_rk,1); fieldname6 = cell(mn_rk,1);
        %  Assign values to NBM struct
        for m = 1 : size(per,1)
            for i = 1 : mn_rk
                %Ore fieldnames
                fieldname1{i} = sprintf('rk%d_mill_tonnage',i); fieldname2{i} = sprintf('rk%d_metal_mill_grade',i); fieldname3{i} = sprintf('rk%d_metal_mill_mass',i);
                %Waste fieldnames
                fieldname4{i} = sprintf('rk%d_rejected_tonnage',i); fieldname5{i} = sprintf('rk%d_metal_rejected_grade',i); fieldname6{i} = sprintf('rk%d_metal_rejected_mass',i);
                %Assign values to struct
                NBM(m).Period                   = sprintf('Period%d', per(m));
                NBM(m).X                        = [p_ore{m,1}(:,P.X)      ; p_waste{m,1}(:,P.X)];
                NBM(m).Y                        = [p_ore{m,1}(:,P.Y)      ; p_waste{m,1}(:,P.Y)];
                NBM(m).Z                        = [p_ore{m,1}(:,P.Z)      ; p_waste{m,1}(:,P.Z)];
                NBM(m).x_size                   = [p_ore{m,1}(:,P.XS)     ; p_waste{m,1}(:,P.XS)];
                NBM(m).y_size                   = [p_ore{m,1}(:,P.YS)     ; p_waste{m,1}(:,P.YS)];
                NBM(m).z_size                   = [p_ore{m,1}(:,P.ZS)     ; p_waste{m,1}(:,P.ZS)];
                NBM(m).Sg                       = [p_ore{m,1}(:,P.SG)     ; p_waste{m,1}(:,P.SG)];
                NBM(m).Volume                   = [p_ore{m,1}(:,P.Vol)    ; p_waste{m,1}(:,P.Vol)];
                NBM(m).Volume_factor            = [p_ore{m,1}(:,P.VF)     ; p_waste{m,1}(:,P.VF)];
                NBM(m).Block_tonnage            = [p_ore{m,1}(:,P.BT)     ; p_waste{m,1}(:,P.BT)];
                NBM(m).(fieldname1{i})          = [p_ore{m,1}(:,P.RMT(i)) ; p_waste{m,1}(:,P.RMT(i))];
                NBM(m).(fieldname2{i})          = [p_ore{m,1}(:,MG(i))    ; p_waste{m,1}(:,MG(i))];
                NBM(m).(fieldname3{i})          = [p_ore{m,1}(:,MT(i))    ; p_waste{m,1}(:,MT(i))];
                NBM(m).(fieldname4{i})          = [p_ore{m,1}(:,P.RRT(i)) ; p_waste{m,1}(:,P.RRT(i))];
                NBM(m).(fieldname5{i})          = [p_ore{m,1}(:,RG(i))    ; p_waste{m,1}(:,RG(i))];
                NBM(m).(fieldname6{i})          = [p_ore{m,1}(:,RT(i))    ; p_waste{m,1}(:,RT(i))];
                NBM(m).Energy_Consumption       = [EneCon{m,1}            ; EneCon{m,2}];
                NBM(m).Global_Warming_Potential = [GloWarPot{m,1}         ; GloWarPot{m,2}];
            end
        end
        clearvars fieldname1 fieldname2 fieldname3 fieldname4 fieldname5 fieldname6
end

%% Build 'ECGWP' structure
ECGWP = struct;
for m = 1 : size(per,1)
    ECGWP(m).Period          = sprintf('Period%d', per(m));
    ECGWP(m).EC_Drill        = Drill(m,1);
    ECGWP(m).EC_Blast        = Blast(m,1);
    ECGWP(m).EC_Load         = Load(m,1);
    ECGWP(m).EC_Haul         = Haul(m,1);
    ECGWP(m).EC_Crush        = Crush(m,1);
    ECGWP(m).EC_Grind        = Grind(m,1);
    ECGWP(m).GWP_Drill       = Drill(m,2);
    ECGWP(m).GWP_Blast       = Blast(m,2);
    ECGWP(m).GWP_Load        = Load(m,2);
    ECGWP(m).GWP_Haul        = Haul(m,2);
    ECGWP(m).GWP_Crush       = Crush(m,2);
    ECGWP(m).GWP_Grind       = Grind(m,2);
    ECGWP(m).Total_EC        = EC(m,1);
    ECGWP(m).Total_GWP       = GWP(m,1);
end

%% Plotting 'ECGWP' struct
%  Create 'Name' 'EC_Value' 'GWP_Value' for each unit process
N         = size(ECGWP,2);
Name      = cell(size(ECGWP,2),8);
EC_Value  = zeros(size(ECGWP,2),7);
GWP_Value = zeros(size(ECGWP,2),7);
for m = 1 : N
    %Subject
    Name{m,1}      = sprintf('Drilling');
    Name{m,2}      = sprintf('Blasting');
    Name{m,3}      = sprintf('Loading');
    Name{m,4}      = sprintf('Hauling');
    Name{m,5}      = sprintf('Crushing');
    Name{m,6}      = sprintf('Grinding');
    Name{m,7}      = sprintf('EC');
    Name{m,8}      = sprintf('GWP');
    %EC
    EC_Value(m,1)  = ECGWP(m).EC_Drill;
    EC_Value(m,2)  = ECGWP(m).EC_Blast;
    EC_Value(m,3)  = ECGWP(m).EC_Load;
    EC_Value(m,4)  = ECGWP(m).EC_Haul;
    EC_Value(m,5)  = ECGWP(m).EC_Crush;
    EC_Value(m,6)  = ECGWP(m).EC_Grind;
    EC_Value(m,7)  = ECGWP(m).Total_EC;
    %GWP
    GWP_Value(m,1) = ECGWP(m).GWP_Drill;
    GWP_Value(m,2) = ECGWP(m).GWP_Blast;
    GWP_Value(m,3) = ECGWP(m).GWP_Load;
    GWP_Value(m,4) = ECGWP(m).GWP_Haul;
    GWP_Value(m,5) = ECGWP(m).GWP_Crush;
    GWP_Value(m,6) = ECGWP(m).GWP_Grind;
    GWP_Value(m,7) = ECGWP(m).Total_GWP;
end
%  Build 'Unit Process' struct
Unit_Process           = struct;
Unit_Process.Year      = [(1:N)';(1:N)';(1:N)';(1:N)';(1:N)';(1:N)'];
Unit_Process.Type      = [Name(:,1);Name(:,2);Name(:,3);Name(:,4);Name(:,5);Name(:,6)];
Unit_Process.EC_Value  = [EC_Value(:,1);EC_Value(:,2);EC_Value(:,3);EC_Value(:,4);EC_Value(:,5);EC_Value(:,6)];
Unit_Process.GWP_Value = [GWP_Value(:,1);GWP_Value(:,2);GWP_Value(:,3);GWP_Value(:,4);GWP_Value(:,5);GWP_Value(:,6)];
%  Build 'MineEC' struct
MineEC          = struct;
MineEC.Year     = (1:N)';
MineEC.Type     = Name(:,7);
MineEC.EC_Value = EC_Value(:,7);
%  Build 'MineGWP' struct
MineGWP           = struct;
MineGWP.Year      = (1:N)';
MineGWP.Type      = Name(:,8);
MineGWP.GWP_Value = GWP_Value(:,7);
%  Convert struct to table
Unit_Process_table = struct2table(Unit_Process);
MineEC_table       = struct2table(MineEC);
MineGWP_table      = struct2table(MineGWP);
%  Calculate the cumulative energy consumption and GWP
cum_ecgwp      = zeros(N,2); %1st column:EC 2nd column:GWP
cum_ecgwp(1,1) = MineEC_table.EC_Value(1);
cum_ecgwp(1,2) = MineGWP_table.GWP_Value(1);
for jj = 2 : N
    cum_ecgwp(jj,1) = cum_ecgwp(jj-1,1) + MineEC_table.EC_Value(jj);
    cum_ecgwp(jj,2) = cum_ecgwp(jj-1,2) + MineGWP_table.GWP_Value(jj);
end
%  Unit Prcoess
clear g
figure()
g(1,1) = gramm('x',Unit_Process_table.Year,'y',Unit_Process_table.EC_Value/1e6,'color',Unit_Process_table.Type);
g(1,1).geom_bar('dodge',0.6,'width',0.5);
g(1,1).set_color_options('map','brewer2');
g(1,1).set_names('color','','x','Years of Mine Production','y','Energy Consumption (TJ)');
g(1,1).set_title('Energy Consumption of Each Process','FontSize',16);
g(2,1) = gramm('x',Unit_Process_table.Year,'y',Unit_Process_table.GWP_Value/1e3,'color',Unit_Process_table.Type);
g(2,1).geom_bar('dodge',0.6,'width',0.5);
g(2,1).set_color_options('map','brewer2');
g(2,1).set_names('color','','x','Years of Mine Production','y',{('Global Warming Potential');('(ton CO2 eq)')});
g(2,1).set_title('Global Warming Potential of Each Process','FontSize',16);
g.draw();
%  Energy consumption and GWP each period(optional, can uncomment if you want to analyse)
%    clear g
%    figure()
%    g(1,1) = gramm('x',MineEC_table.Year,'y',MineEC_table.EC_Value/1e6,'color',MineEC_table.Type);
%    g(1,1).geom_bar('dodge',0.6,'width',0.5);
%    g(1,1).set_names('x','Years of Mine Production','y','Energy Consumption (TJ)');
%    g(1,1).set_title('Energy Consumption over the Life of Mine','FontSize',16);
%    g(2,1) = gramm('x',MineGWP_table.Year,'y',MineGWP_table.GWP_Value);
%    g(2,1).geom_bar('dodge',0.6,'width',0.5);
%    g(2,1).set_color_options('map','brewer2');
%    g(2,1).set_names('x','Years of Mine Production','y',{('Global Warming Potential');('(ton CO2 eq)')});
%    g(2,1).set_title('Global Warming Potential over the Life of Mine','FontSize',16);
%    g.draw();
%  Cumulative energy consumption and GWP emissions within the life of mine
clear g
figure()
g(1,1) = gramm('x',MineEC_table.Year,'y',cum_ecgwp(:,1)/1e6,'size',ones(N,1));
g(1,1).geom_line();
g(1,1).geom_point();
g(1,1).set_point_options('base_size',6,'markers',{'o'});
g(1,1).set_names('x','Years of Mine Production','y','Energy Consumption (TJ)');
g(1,1).set_title('Cumulative Consumption of Energy over the Life of Mine','FontSize',16);
g(1,2) = gramm('x',MineGWP_table.Year,'y',cum_ecgwp(:,2)/1e3,'size',ones(N,1));
g(1,2).geom_line();
g(1,2).geom_point();
g(1,2).set_point_options('base_size',6,'markers',{'^'});
g(1,2).set_color_options('map','brewer2');
g(1,2).set_names('x','Years of Mine Production','y',{('Global Warming Potential');('(ton CO2 eq)')});
g(1,2).set_title('Cumulative Emissions over the Life of Mine','FontSize',16);
g.draw();

%% Export 'NBM' structure (optional)
for n = 1 : size(NBM,2)
    temp   = NBM(n);
    Period = temp.Period;
    temp   = rmfield(temp,'Period');
    writetable(struct2table(temp),'NewBlockModel_GeoviaWhittle.xlsx','sheet',Period)
end
clearvars temp
%  Alternative: If user want to put all data in one sheet the following code can do this.
%  for n = 1 : size(NBM,2)
%      temp1  = NBM(n);
% 	   Period = temp1.Period;
% 	   temp1  = rmfield(temp1,'Period');
%      if n == 1
%          tb = struct2table(temp1);
%      else
%          stru_tab = struct2table(temp1);
%          tb = [tb;stru_tab];
%      end
%      writetable(tb,'NewBlockModel_GeoviaWhittle.xlsx','sheet','All_results')
% 	   clearvars temp1
%  end

disp('Done')

end