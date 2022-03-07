%% This function is used to calculate the energy consumption of each process in open pit mine
%  Processes: 1.Drilling; 2.Blasting; 3.Loading; 4.Hauling; 5.Crushinng; 6.Grinding
%  [1] Muñoz, J.I.,et al. 2014. International Journal of Mining and Mineral Engineering, 5(1), pp.38-58.DOI: 10.1504/IJMME.2014.058918
%  2021 © C. Zhang

function EC = Energy_Consumption(A,Ev,L,N,nD,LF,Eblast,PI,lt,Nl,mT,S,Rs,Ri,rs,MT,wi,c_out,c_in,g_out,g_in,Mb,Option)

% Input
%   A      : the area of drilling section(cm2)
%	Ev     : the drilling specific energy for each rock type(MJ/m3)
%   L      : the drilling length of each drill hole(cm)
%   N      : the number of drillhole in each block
%   nD     : the drilling efficiency(%) 
%   LF     : the load factor(kg explosive/ton block)
%   Eblast : the specific energy of the used explosive(MJ/kg explosive)
%   PI     : the loader power(mW)
%   lt     : the average cycle time to meet filling capacity of truck using loader(seconds)
%   Nl     : the loader efficiency(%)
%   mT     : the filling capacity of the truck(tonnes)
%	S      : the distance of the ith block from mine site to processing plant or waste dump(km)
%   Rs     : the rolling resistance of the surface(%)
%   Ri     : the internal resistance of the truck(%)
%   rs     : the ramp slope(%)
%   MT     : the mass of loaded truck(tonnes)
%   wi     : Bond Work Index(kWh/ton)
%   c_in   : the crushing entry material size(microns)
%   c_out  : the crushing exit material size(microns)
%   g_in   : the grinding entry material size(microns)
%   g_out  : the grinding exit material size(microns)
%	Mb     : the tonnage of ore/waste block(ton)
%   Option : the different process in open-pit mining

% Output
%	EC : the energy consumption for each process(MJ)

switch Option
    
    case ('Drill')
        EC = ((A*(Ev*10^-6)*L*N)./((nD/100).*Mb)).*Mb;
        
    case ('Blast')
        EC = LF*Eblast*Mb;
        
    case ('Load')
        EC = ((PI*lt)/((Nl/100)*mT))*Mb; 
        
    case ('Haul')
        EC = ((9.81*S*(mT*(rs/100)+((Rs+Ri)/100)*(2*MT-mT)))/mT).*Mb;
        
    case ('Crush')
        EC = (3.6*10*wi*((1/sqrt(c_out)-(1/sqrt(c_in)))))*Mb;
        
    case ('Grind')
        EC = (3.6*10*wi*((1/sqrt(g_out)-(1/sqrt(g_in)))))*Mb;
        
end

end
