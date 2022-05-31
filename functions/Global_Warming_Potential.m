%% This function is used to calculate the global warming potential(GWP) for ore/waste blocks of each process in open pit mine
%  Processes: 1.Drilling; 2.Blasting; 3.Loading; 4.Hauling; 5.Crushinng; 6.Grinding
%  [1] Muñoz, J.I.,et al. 2014. International Journal of Mining and Mineral Engineering, 5(1), pp.38-58.DOI: 10.1504/IJMME.2014.058918
%  2022 © C. Zhang

function GWP = Global_Warming_Potential(EC_pro,Eblast,EF_fuel,EF_expl,EF_elec,wf_a1,wf_b1,wf_a2,wf_b2,wf_a3,wf_b3,wf_a4,wf_b4,wf_a5,wf_b5,Option)

% Input
%   EC_pro  : the corresponding processes for energy consumption of ore/waste blocks(MJ)
%   Eblast  : the specific energy of the used explosive (MJ/kg explosive)
%   EF_fuel : the CO2 emission factor when 1 MJ of fuel burned(kg CO2 eq/MJ)
%   EF_expl : the CO2 emission factor of 1 kg industrial explosives blasted(kg CO2 eq/kg)
%   EF_elec : the CO2 emission factor of 1kWh electricity consumed(kg CO2 eq/kWh)
%   wf_a1   : the energy consumption of fuel as a proportion for drilling(%) 
%   wf_b1   : the energy consumption of electricity as a proportion for drilling(%)
%   wf_a2   : the energy consumption of fuel as a proportion for loading(%)
%   wf_b2   : the energy consumption of electricity as a proportion for loading(%)
%   wf_a3   : the energy consumption of fuel as a proportion for hauling(%)
%   wf_b3   : the energy consumption of electricity as a proportion for hauling(%)
%   wf_a4   : the energy consumption of fuel as a proportion for crushing(%)
%   wf_b4   : the energy consumption of electricity as a proportion for crushing(%)
%   wf_a5   : the energy consumption of fuel as a proportion for grinding(%)
%   wf_b5   : the energy consumption of electricity as a proportion for grinding(%)
%   Option  : the different process in open-pit mining

% Output
%   GWP     : the global warming potential for ore/waste blocks of each process(kg CO2 eq)

switch Option

    case ('Drill')
        GWP = EF_fuel*(wf_a1*EC_pro)+EF_elec*(wf_b1*(EC_pro/3.6));

    case ('Blast')
        GWP = (EC_pro/Eblast)*EF_expl;

    case ('Load')
        GWP = EF_fuel*(wf_a2*EC_pro)+EF_elec*(wf_b2*(EC_pro/3.6));

    case ('Haul')
        GWP = EF_fuel*(wf_a3*EC_pro)+EF_elec*(wf_b3*(EC_pro/3.6));

    case ('Crush')
        GWP = (wf_a4*EC_pro)*EF_fuel+(wf_b4*(EC_pro/3.6))*EF_elec;

    case ('Grind')
        GWP = (wf_a5*EC_pro)*EF_fuel+(wf_b5*(EC_pro/3.6))*EF_elec;

end

end
