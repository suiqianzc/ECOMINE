%% This function is used to plot energy consumption and GWP for Optimal profile and Planar profile and compared.
%  1. Energy consumption and GWP of input source for optimal profile and planar profile;
%  2. Energy consumption and GWP of each process for optimal profile and planar profile;
%  3. Energy consumption and GWP of each period for optimal profile and planar profile.
%  2021 © C. Zhang

function Plot_Compare_Optimal_Planar(Optimal, Planar)

% Input
%   Optimal : The ECGWP structure of optimal profile
%   Planar  : The ECGWP structure of planar profile

%  Create the interface
ModuleType = {'GeoviaWhittle', 'Datamine'};
[opt,~] = listdlg('PromptString',{'Please select the imported structs come from which module.',''},...
    'SelectionMode','single','ListString',ModuleType);
switch opt
    
    case 1 %GeoviaWhittle
        %  Collating and sorting data from optimal profile and planar profile
        Name      = cell(10,1);
        EC_Value  = zeros(10,2);
        GWP_Value = zeros(10,2);
        Type1     = repmat({'Optimal'},10,1);
        Type2     = repmat({'Planar'},10,1);
        %  Assign values
        %  'Name'
        Name{1,1} = sprintf('Fuel');   Name{2,1} = sprintf('Explosives');Name{3,1} = sprintf('Electricity');Name{4,1} = sprintf('Drilling');Name{5,1} = sprintf('Blasting');
        Name{6,1} = sprintf('Loading');Name{7,1} = sprintf('Hauling');   Name{8,1} = sprintf('Crushing');   Name{9,1} = sprintf('Grinding');Name{10,1} = sprintf('Total');
        %  'Optimal'
        for i = 1 : size(Optimal.ECGWP,2)
            %'EC_Value'
            EC_Value(1,1)  = EC_Value(1,1) + sum(Optimal.ECGWP(i).EC_Fuel);
            EC_Value(2,1)  = EC_Value(2,1) + sum(Optimal.ECGWP(i).EC_Explosive);
            EC_Value(3,1)  = EC_Value(3,1) + sum(Optimal.ECGWP(i).EC_Electricity);
            EC_Value(4,1)  = EC_Value(4,1) + sum(Optimal.ECGWP(i).EC_Drill);
            EC_Value(5,1)  = EC_Value(5,1) + sum(Optimal.ECGWP(i).EC_Blast);
            EC_Value(6,1)  = EC_Value(6,1) + sum(Optimal.ECGWP(i).EC_Load);
            EC_Value(7,1)  = EC_Value(7,1) + sum(Optimal.ECGWP(i).EC_Haul);
            EC_Value(8,1)  = EC_Value(8,1) + sum(Optimal.ECGWP(i).EC_Crush);
            EC_Value(9,1)  = EC_Value(9,1) + sum(Optimal.ECGWP(i).EC_Grind);
            EC_Value(10,1) = EC_Value(10,1) + sum(Optimal.ECGWP(i).Total_EC);
            %'GWP_Value'
            GWP_Value(1,1)  = GWP_Value(1,1) + sum(Optimal.ECGWP(i).GWP_Fuel);
            GWP_Value(2,1)  = GWP_Value(2,1) + sum(Optimal.ECGWP(i).GWP_Explosive);
            GWP_Value(3,1)  = GWP_Value(3,1) + sum(Optimal.ECGWP(i).GWP_Electricity);
            GWP_Value(4,1)  = GWP_Value(4,1) + sum(Optimal.ECGWP(i).GWP_Drill);
            GWP_Value(5,1)  = GWP_Value(5,1) + sum(Optimal.ECGWP(i).GWP_Blast);
            GWP_Value(6,1)  = GWP_Value(6,1) + sum(Optimal.ECGWP(i).GWP_Load);
            GWP_Value(7,1)  = GWP_Value(7,1) + sum(Optimal.ECGWP(i).GWP_Haul);
            GWP_Value(8,1)  = GWP_Value(8,1) + sum(Optimal.ECGWP(i).GWP_Crush);
            GWP_Value(9,1)  = GWP_Value(9,1) + sum(Optimal.ECGWP(i).GWP_Grind);
            GWP_Value(10,1) = GWP_Value(10,1) + sum(Optimal.ECGWP(i).Total_GWP);
        end
        %  'Planar'
        for i = 1 : size(Planar.ECGWP,2)
            %'EC_Value'
            EC_Value(1,2)  = EC_Value(1,2) + sum(Planar.ECGWP(i).EC_Fuel);
            EC_Value(2,2)  = EC_Value(2,2) + sum(Planar.ECGWP(i).EC_Explosive);
            EC_Value(3,2)  = EC_Value(3,2) + sum(Planar.ECGWP(i).EC_Electricity);
            EC_Value(4,2)  = EC_Value(4,2) + sum(Planar.ECGWP(i).EC_Drill);
            EC_Value(5,2)  = EC_Value(5,2) + sum(Planar.ECGWP(i).EC_Blast);
            EC_Value(6,2)  = EC_Value(6,2) + sum(Planar.ECGWP(i).EC_Load);
            EC_Value(7,2)  = EC_Value(7,2) + sum(Planar.ECGWP(i).EC_Haul);
            EC_Value(8,2)  = EC_Value(8,2) + sum(Planar.ECGWP(i).EC_Crush);
            EC_Value(9,2)  = EC_Value(9,2) + sum(Planar.ECGWP(i).EC_Grind);
            EC_Value(10,2) = EC_Value(10,2) + sum(Planar.ECGWP(i).Total_EC);
            %'GWP_Value'
            GWP_Value(1,2)  = GWP_Value(1,2) + sum(Planar.ECGWP(i).GWP_Fuel);
            GWP_Value(2,2)  = GWP_Value(2,2) + sum(Planar.ECGWP(i).GWP_Explosive);
            GWP_Value(3,2)  = GWP_Value(3,2) + sum(Planar.ECGWP(i).GWP_Electricity);
            GWP_Value(4,2)  = GWP_Value(4,2) + sum(Planar.ECGWP(i).GWP_Drill);
            GWP_Value(5,2)  = GWP_Value(5,2) + sum(Planar.ECGWP(i).GWP_Blast);
            GWP_Value(6,2)  = GWP_Value(6,2) + sum(Planar.ECGWP(i).GWP_Load);
            GWP_Value(7,2)  = GWP_Value(7,2) + sum(Planar.ECGWP(i).GWP_Haul);
            GWP_Value(8,2)  = GWP_Value(8,2) + sum(Planar.ECGWP(i).GWP_Crush);
            GWP_Value(9,2)  = GWP_Value(9,2) + sum(Planar.ECGWP(i).GWP_Grind);
            GWP_Value(10,2) = GWP_Value(10,2) + sum(Planar.ECGWP(i).Total_GWP);
        end
        %  Build 'InputSource' struct
        InputSource           = struct;
        InputSource.Category  = [Name(1,1);Name(2,1);Name(3,1);Name(1,1);Name(2,1);Name(3,1)];
        InputSource.Type      = [Type1(1,1);Type1(2,1);Type1(3,1);Type2(1,1);Type2(2,1);Type2(3,1)];
        InputSource.EC_Value  = [EC_Value(1,1);EC_Value(2,1);EC_Value(3,1);EC_Value(1,2);EC_Value(2,2);EC_Value(3,2)];
        InputSource.GWP_Value = [GWP_Value(1,1);GWP_Value(2,1);GWP_Value(3,1);GWP_Value(1,2);GWP_Value(2,2);GWP_Value(3,2)];
        %  Build 'Process' struct
        Process           = struct;
        Process.Category  = [Name(4,1);Name(5,1);Name(6,1);Name(7,1);Name(8,1);Name(9,1);Name(10,1);...
            Name(4,1);Name(5,1);Name(6,1);Name(7,1);Name(8,1);Name(9,1);Name(10,1)];
        Process.Type      = [Type1(4,1);Type1(5,1);Type1(6,1);Type1(7,1);Type1(8,1);Type1(9,1);Type1(10,1);...
            Type2(4,1);Type2(5,1);Type2(6,1);Type2(7,1);Type2(8,1);Type2(9,1);Type2(10,1)];
        Process.EC_Value  = [EC_Value(4,1);EC_Value(5,1);EC_Value(6,1);EC_Value(7,1);EC_Value(8,1);EC_Value(9,1);EC_Value(10,1);...
            EC_Value(4,2);EC_Value(5,2);EC_Value(6,2);EC_Value(7,2);EC_Value(8,2);EC_Value(9,2);EC_Value(10,2)];
        Process.GWP_Value = [GWP_Value(4,1);GWP_Value(5,1);GWP_Value(6,1);GWP_Value(7,1);GWP_Value(8,1);GWP_Value(9,1);GWP_Value(10,1);...
            GWP_Value(4,2);GWP_Value(5,2);GWP_Value(6,2);GWP_Value(7,2);GWP_Value(8,2);GWP_Value(9,2);GWP_Value(10,2)];
        %  Convert struct to table
        InputSource_table = struct2table(InputSource);
        Process_table     = struct2table(Process);
        
        %  Compare the number of period for optimal profile to planar profile
        %CASE1
        if size(Optimal.ECGWP,2) > size(Planar.ECGWP,2)
            P_EC  = zeros(size(Optimal.ECGWP,2),2);
            P_GWP = zeros(size(Optimal.ECGWP,2),2);
            %Handling energy consumption and GWP for planar profile
            temp  = zeros(size(Planar.ECGWP,2),2);
            for m = 1 : size(Planar.ECGWP,2)
                temp(m,1) = Planar.ECGWP(m).Total_EC;
                temp(m,2) = Planar.ECGWP(m).Total_GWP;
            end
            temp = [temp;zeros(size(Optimal.ECGWP,2)-size(Planar.ECGWP,2),2)];
            for n = 1 : size(Optimal.ECGWP,2)
                %Optimal
                P_EC(n,1)  = Optimal.ECGWP(n).Total_EC;
                P_GWP(n,1) = Optimal.ECGWP(n).Total_GWP;
                %Planar
                P_EC(n,2)  = temp(n,1);
                P_GWP(n,2) = temp(n,2);
            end
        end
        %CASE2
        if size(Optimal.ECGWP,2) < size(Planar.ECGWP,2)
            P_EC  = zeros(size(Planar.ECGWP,2),2);
            P_GWP = zeros(size(Planar.ECGWP,2),2);
            %Handling energy consumption and GWP for optimal profile
            temp  = zeros(size(Optimal.ECGWP,2),2);
            for m = 1 : size(Optimal.ECGWP,2)
                temp(m,1) = Optimal.ECGWP(m).Total_EC;
                temp(m,2) = Optimal.ECGWP(m).Total_GWP;
            end
            temp = [temp;zeros(size(Planar.ECGWP,2)-size(Optimal.ECGWP,2),2)];
            for n = 1 : size(Planar.ECGWP,2)
                %Optimal
                P_EC(n,1)  = temp(n,1);
                P_GWP(n,1) = temp(n,2);
                %Planar
                P_EC(n,2)  = Planar.ECGWP(n).Total_EC;
                P_GWP(n,2) = Planar.ECGWP(n).Total_GWP;
            end
        end
        %CASE3
        if size(Optimal.ECGWP,2) == size(Planar.ECGWP,2)
            P_EC  = zeros(size(Optimal.ECGWP,2),2);
            P_GWP = zeros(size(Optimal.ECGWP,2),2);
            for n = 1 : size(Optimal.ECGWP,2)
                %Optimal
                P_EC(n,1)  = Optimal.ECGWP(n).Total_EC;
                P_GWP(n,1) = Optimal.ECGWP(n).Total_GWP;
                %Planar
                P_EC(n,2)  = Planar.ECGWP(n).Total_EC;
                P_GWP(n,2) = Planar.ECGWP(n).Total_GWP;
            end
        end
        clearvars temp
        %  Calculate the cumulative energy consumption and GWP
        cum_ec      = zeros(size(P_EC,1),2); %1st column:Optimal; 2nd column:Planar
        cum_ec(1,1) = P_EC(1,1);
        cum_ec(1,2) = P_EC(1,2);
        for jj = 2 : size(P_EC,1)
            cum_ec(jj,1) = cum_ec(jj-1,1) + P_EC(jj,1);
            cum_ec(jj,2) = cum_ec(jj-1,2) + P_EC(jj,2);
        end
        cum_gwp      = zeros(size(P_GWP,1),2); %1st column:Optimal; 2nd column:Planar
        cum_gwp(1,1) = P_GWP(1,1);
        cum_gwp(1,2) = P_GWP(1,2);
        for kk = 2 : size(P_GWP,1)
            cum_gwp(kk,1) = cum_gwp(kk-1,1) + P_GWP(kk,1);
            cum_gwp(kk,2) = cum_gwp(kk-1,2) + P_GWP(kk,2);
        end
        %  Build 'Period_EC' struct
        Period_EC           = struct;
        Period_EC.Year      = [(1:size(P_EC,1))';(1:size(P_EC,1))'];
        Period_EC.Type      = [(repmat({'Optimal'},size(P_EC,1),1));(repmat({'Planar'},size(P_EC,1),1))];
        Period_EC.EC_Value  = [P_EC(:,1);P_EC(:,2)];
        Period_EC.CUM_EC    = [cum_ec(:,1);cum_ec(:,2)];
        %  Build 'Period_GWP' struct
        Period_GWP           = struct;
        Period_GWP.Year      = [(1:size(P_GWP,1))';(1:size(P_GWP,1))'];
        Period_GWP.Type      = [(repmat({'Optimal'},size(P_GWP,1),1));(repmat({'Planar'},size(P_GWP,1),1))];
        Period_GWP.GWP_Value = [P_GWP(:,1);P_GWP(:,2)];
        Period_GWP.CUM_GWP    = [cum_gwp(:,1);cum_gwp(:,2)];
        %  Convert struct to table
        Period_EC_table  = struct2table(Period_EC);
        Period_GWP_table = struct2table(Period_GWP);
        %  Plot
        %  figure()
        %  Input Source(Optinal)
        %    g(1,1) = gramm('x',InputSource_table.Category,'y',InputSource_table.EC_Value/1e6,'color',InputSource_table.Type);
        %    g(1,1).geom_bar('dodge',0.6,'width',0.5,'stacked',false);
        %    g(1,1).set_names('color','','x','','y','Energy Consumption (TJ)');
        %    g(1,1).set_title({('Energy Consumption of Input Source');('(Optimal Profile vs Planar Profile)')},'FontSize',12);
        %    g(1,2) = gramm('x',InputSource_table.Category,'y',InputSource_table.GWP_Value/1e3,'color',InputSource_table.Type);
        %    g(1,2).geom_bar('dodge',0.6,'width',0.5,'stacked',false);
        %    g(1,2).set_names('color','','x','','y',{('Global Warming Potential');('(ton CO2 eq)')});
        %    g(1,2).set_title({('Global Warming Potential of Input Source');('(Optimal Profile vs Planar Profile)')},'FontSize',12);
        %  Prcoess(Optinal)
        %    g(2,1) = gramm('x',Process_table.Category,'y',Process_table.EC_Value/1e6,'color',Process_table.Type);
        %    g(2,1).geom_bar('dodge',0.6,'width',0.5,'stacked',false);
        %    g(2,1).set_names('color','','x','','y','Energy Consumption (TJ)');
        %    g(2,1).set_title({('Energy Consumption for Each Process and Whole Process');('(Optimal Profile vs Planar Profile)')},'FontSize',12);
        %    g(2,2) = gramm('x',Process_table.Category,'y',Process_table.GWP_Value/1e3,'color',Process_table.Type);
        %    g(2,2).geom_bar('dodge',0.6,'width',0.5,'stacked',false);
        %    g(2,2).set_names('color','','x','','y',{('Global Warming Potential');('(ton CO2 eq)')});
        %    g(2,2).set_title({('Global Warming Potential for Each Process and Whole Process');('(Optimal Profile vs Planar Profile)')},'FontSize',12);
        %    g.draw();
        %  Period
        clear g
        figure()
        g(1,1) = gramm('x',Period_EC_table.Year,'y',Period_EC_table.EC_Value/1e6,'color',Period_EC_table.Type);
        g(1,1).geom_bar('dodge',0.6,'width',0.5,'stacked',false);
        g(1,1).set_color_options('map','brewer1');
        g(1,1).set_names('color','','x','Years of Mine Production','y','Energy Consumption (TJ)');
        g(1,1).set_title(('Energy Consumption over the Life of Mine (Optimal Profile vs Planar Profile)'),'FontSize',12);
        g(2,1) = gramm('x',Period_GWP_table.Year,'y',Period_GWP_table.GWP_Value/1e3,'color',Period_GWP_table.Type);
        g(2,1).geom_bar('dodge',0.6,'width',0.5,'stacked',false);
        g(2,1).set_color_options('map','brewer1');
        g(2,1).set_names('color','','x','Years of Mine Production','y',{('Global Warming Potential');('(ton CO2 eq)')});
        g(2,1).set_title(('Global Warming Potential over the Life of Mine (Optimal Profile vs Planar Profile)'),'FontSize',12);
        g.draw();
        %  Cumulative energy consumption and GWP
        clear g
        figure()
        g(1,1) = gramm('x',Period_EC_table.Year,'y',Period_EC.CUM_EC/1e6,'color',Period_EC_table.Type,'size',5*ones(size(Period_EC_table,1),1));
        g(1,1).geom_line();
        g(1,1).geom_point();
        g(1,1).set_point_options('markers',{'o'});
        g(1,1).set_color_options('map','brewer2');
        g(1,1).set_names('color','','x','Years of Mine Production','y','Energy Consumption (TJ)');
        g(1,1).set_title({('Cumulative Consumption of Energy over the Life of Mine');('(Optimal Profile vs Planar Profile)')},'FontSize',12);
        g(1,2) = gramm('x',Period_GWP_table.Year,'y',Period_GWP.CUM_GWP/1e3,'color',Period_GWP_table.Type,'size',5*ones(size(Period_GWP_table,1),1));
        g(1,2).geom_line();
        g(1,2).geom_point();
        g(1,2).set_point_options('markers',{'^'});
        g(1,2).set_color_options('map','brewer2');
        g(1,2).set_names('color','','x','Years of Mine Production','y',{('Global Warming Potential');('(ton CO2 eq)')});
        g(1,2).set_title({('Cumulative Emissions over the Life of Mine');('(Optimal Profile vs Planar Profile)')},'FontSize',12);
        g.draw();
        
    case 2 %Datamine
        %  Collating and sorting data from optimal profile and planar profile
        Name      = cell(10,1);
        EC_Value  = zeros(10,2);
        GWP_Value = zeros(10,2);
        Type1     = repmat({'Optimal'},10,1);
        Type2     = repmat({'Planar'},10,1);
        %  Assign values
        %  'Name'
        Name{1,1} = sprintf('Fuel');   Name{2,1} = sprintf('Explosives');Name{3,1} = sprintf('Electricity');Name{4,1} = sprintf('Drilling');Name{5,1} = sprintf('Blasting');
        Name{6,1} = sprintf('Loading');Name{7,1} = sprintf('Hauling');   Name{8,1} = sprintf('Crushing');   Name{9,1} = sprintf('Grinding');Name{10,1} = sprintf('Total');
        %  'EC_Value''Optimal'
        EC_Value(1,1)  = Optimal.ECGWP.E_Fuel;  EC_Value(2,1) = Optimal.ECGWP.E_Explosive; EC_Value(3,1) = Optimal.ECGWP.E_Electricity;
        EC_Value(4,1)  = Optimal.ECGWP.E_Drill; EC_Value(5,1) = Optimal.ECGWP.E_Blast;     EC_Value(6,1) = Optimal.ECGWP.E_Load;
        EC_Value(7,1)  = Optimal.ECGWP.E_Haul;  EC_Value(8,1) = Optimal.ECGWP.E_Crush;     EC_Value(9,1) = Optimal.ECGWP.E_Grind;
        EC_Value(10,1) = Optimal.ECGWP.E_Drill+Optimal.ECGWP.E_Blast+Optimal.ECGWP.E_Load+Optimal.ECGWP.E_Haul+Optimal.ECGWP.E_Crush+Optimal.ECGWP.E_Grind;
        %  'EC_Value''Planar'
        EC_Value(1,2)  = Planar.ECGWP.E_Fuel;  EC_Value(2,2) = Planar.ECGWP.E_Explosive; EC_Value(3,2) = Planar.ECGWP.E_Electricity;
        EC_Value(4,2)  = Planar.ECGWP.E_Drill; EC_Value(5,2) = Planar.ECGWP.E_Blast;     EC_Value(6,2) = Planar.ECGWP.E_Load;
        EC_Value(7,2)  = Planar.ECGWP.E_Haul;  EC_Value(8,2) = Planar.ECGWP.E_Crush;     EC_Value(9,2) = Planar.ECGWP.E_Grind;
        EC_Value(10,2) = Planar.ECGWP.E_Drill+Planar.ECGWP.E_Blast+Planar.ECGWP.E_Load+Planar.ECGWP.E_Haul+Planar.ECGWP.E_Crush+Planar.ECGWP.E_Grind;
        %  'GWP_Value''Optimal'
        GWP_Value(1,1)  = Optimal.ECGWP.G_Fuel;  GWP_Value(2,1) = Optimal.ECGWP.G_Explosive; GWP_Value(3,1) = Optimal.ECGWP.G_Electricity;
        GWP_Value(4,1)  = Optimal.ECGWP.G_Drill; GWP_Value(5,1) = Optimal.ECGWP.G_Blast;     GWP_Value(6,1) = Optimal.ECGWP.G_Load;
        GWP_Value(7,1)  = Optimal.ECGWP.G_Haul;  GWP_Value(8,1) = Optimal.ECGWP.G_Crush;     GWP_Value(9,1) = Optimal.ECGWP.G_Grind;
        GWP_Value(10,1) = Optimal.ECGWP.G_Drill+Optimal.ECGWP.G_Blast+Optimal.ECGWP.G_Load+Optimal.ECGWP.G_Haul+Optimal.ECGWP.G_Crush+Optimal.ECGWP.G_Grind;
        %  'GWP_Value''Planar'
        GWP_Value(1,2)  = Planar.ECGWP.G_Fuel;  GWP_Value(2,2) = Planar.ECGWP.G_Explosive; GWP_Value(3,2) = Planar.ECGWP.G_Electricity;
        GWP_Value(4,2)  = Planar.ECGWP.G_Drill; GWP_Value(5,2) = Planar.ECGWP.G_Blast;     GWP_Value(6,2) = Planar.ECGWP.G_Load;
        GWP_Value(7,2)  = Planar.ECGWP.G_Haul;  GWP_Value(8,2) = Planar.ECGWP.G_Crush;     GWP_Value(9,2) = Planar.ECGWP.G_Grind;
        GWP_Value(10,2) = Planar.ECGWP.G_Drill+Planar.ECGWP.G_Blast+Planar.ECGWP.G_Load+Planar.ECGWP.G_Haul+Planar.ECGWP.G_Crush+Planar.ECGWP.G_Grind;
        %  Build 'InputSource' struct
        InputSource           = struct;
        InputSource.Category  = [Name(1,1);Name(2,1);Name(3,1);Name(1,1);Name(2,1);Name(3,1)];
        InputSource.Type      = [Type1(1,1);Type1(2,1);Type1(3,1);Type2(1,1);Type2(2,1);Type2(3,1)];
        InputSource.EC_Value  = [EC_Value(1,1);EC_Value(2,1);EC_Value(3,1);EC_Value(1,2);EC_Value(2,2);EC_Value(3,2)];
        InputSource.GWP_Value = [GWP_Value(1,1);GWP_Value(2,1);GWP_Value(3,1);GWP_Value(1,2);GWP_Value(2,2);GWP_Value(3,2)];
        %  Build 'Process' struct
        Process           = struct;
        Process.Category  = [Name(4,1);Name(5,1);Name(6,1);Name(7,1);Name(8,1);Name(9,1);Name(10,1);...
            Name(4,1);Name(5,1);Name(6,1);Name(7,1);Name(8,1);Name(9,1);Name(10,1)];
        Process.Type      = [Type1(4,1);Type1(5,1);Type1(6,1);Type1(7,1);Type1(8,1);Type1(9,1);Type1(10,1);...
            Type2(4,1);Type2(5,1);Type2(6,1);Type2(7,1);Type2(8,1);Type2(9,1);Type2(10,1)];
        Process.EC_Value  = [EC_Value(4,1);EC_Value(5,1);EC_Value(6,1);EC_Value(7,1);EC_Value(8,1);EC_Value(9,1);EC_Value(10,1);...
            EC_Value(4,2);EC_Value(5,2);EC_Value(6,2);EC_Value(7,2);EC_Value(8,2);EC_Value(9,2);EC_Value(10,2)];
        Process.GWP_Value = [GWP_Value(4,1);GWP_Value(5,1);GWP_Value(6,1);GWP_Value(7,1);GWP_Value(8,1);GWP_Value(9,1);GWP_Value(10,1);...
            GWP_Value(4,2);GWP_Value(5,2);GWP_Value(6,2);GWP_Value(7,2);GWP_Value(8,2);GWP_Value(9,2);GWP_Value(10,2)];
        %  Convert struct to table
        InputSource_table = struct2table(InputSource);
        Process_table     = struct2table(Process);
        %  Plot
        figure()
        %  Input Source
        g(1,1) = gramm('x',InputSource_table.Category,'y',InputSource_table.EC_Value/1e6,'color',InputSource_table.Type);
        g(1,1).geom_bar('dodge',0.6,'width',0.5,'stacked',false);
        g(1,1).set_names('color','','x','','y','Energy Consumption (TJ)');
        g(1,1).set_title({('Energy Consumption of Input Source');('(Optimal Profile vs Planar Profile)')},'FontSize',12);
        g(1,2) = gramm('x',InputSource_table.Category,'y',InputSource_table.GWP_Value/1e3,'color',InputSource_table.Type);
        g(1,2).geom_bar('dodge',0.6,'width',0.5,'stacked',false);
        g(1,2).set_names('color','','x','','y',{('Global Warming Potential');('(ton CO2 eq)')});
        g(1,2).set_title({('Global Warming Potential of Input Source');('(Optimal Profile vs Planar Profile)')},'FontSize',12);
        %  Prcoess
        g(2,1) = gramm('x',Process_table.Category,'y',Process_table.EC_Value/1e6,'color',Process_table.Type);
        g(2,1).geom_bar('dodge',0.6,'width',0.5,'stacked',false);
        g(2,1).set_names('color','','x','','y','Energy Consumption (TJ)');
        g(2,1).set_title({('Energy Consumption for Each Process and Whole Process');('(Optimal Profile vs Planar Profile)')},'FontSize',12);
        g(2,2) = gramm('x',Process_table.Category,'y',Process_table.GWP_Value/1e3,'color',Process_table.Type);
        g(2,2).geom_bar('dodge',0.6,'width',0.5,'stacked',false);
        g(2,2).set_names('color','','x','','y',{('Global Warming Potential');('(ton CO2 eq)')});
        g(2,2).set_title({('Global Warming Potential for Each Process and Whole Process');('(Optimal Profile vs Planar Profile)')},'FontSize',12);
        g.draw();
        
end

disp('Done!')

end

