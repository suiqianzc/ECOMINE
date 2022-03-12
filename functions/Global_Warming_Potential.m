%% This function is used to calculate the global warming potential(GWP) of each process in open pit mine
%  Processes: 1.Drilling; 2.Blasting; 3.Loading; 4.Hauling; 5.Crushinng; 6.Grinding
%  [1] Muñoz, J.I.,et al. 2014. International Journal of Mining and Mineral Engineering, 5(1), pp.38-58.DOI: 10.1504/IJMME.2014.058918
%  [2] Islam, K., et al. 2020.Resources, Conservation and Recycling, 154, pp.1-13. https://doi.org/10.1016/j.resconrec.2019.104630
%  [3] Chen, L.,et al. 2019. Journal of Economic Structures, 8(1), pp.1-12. https://doi.org/10.1186/s40008-019-0142-6
%  2022 © C. Zhang

function GWP = Global_Warming_Potential(EC_pro,Eblast,EF_fuel,EF_expl,EF_elec,Option)

% Input
%   EC_pro  : the energy consumption of each process(MJ)
%	Eblast  : the specific energy of the used explosive (MJ/kg explosive)
%	EF_fuel : the CO2 emission factor when 1 MJ of fuel burned(kg CO2 eq/MJ)
%	EF_expl : the CO2 emission factor of 1 kg explosive blasted(kg CO2 eq/kg)
%	EF_elec : the CO2 emission factor of 1kWh electricity consumed(kg CO2 eq/kWh)
%   Option  : the different process in open-pit mining

% Output
%	GWP : the global warming potential for each process(kg CO2 eq)

switch Option
    
    case ('Drill')
        GWP = EF_fuel*EC_pro;
        
    case ('Blast')
        GWP = (EC_pro/Eblast)*EF_expl;
        
    case ('Load')
        GWP = EF_fuel*EC_pro;
        
    case ('Haul')
        GWP = EF_fuel*EC_pro;
        
    case ('Crush')
        GWP = (EC_pro/3.6)*EF_elec;
        
    case ('Grind')
        GWP = (EC_pro/3.6)*EF_elec;
        
end

end
