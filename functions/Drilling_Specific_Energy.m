%% This function is input specific energy consumption of drilling (EV) for each rock type
%  Attention: The number of rock type is a variable in the block model!!!
%  1. Obtain the number of rock type; 2. Ask user to input the corresponding EV parameters;
%  3. For weak rocks, if cannot find the corresponding values in 'Comparison of drillability scales' table, we assume the EV = 0.
%  2022 © C. Zhang

function [SECD, num] = Drilling_Specific_Energy(option,RC,numrt,varnm)

% Input
%   option : The code for the execution of the module
%   RC     : The rock code for each rock type in the block model (Datamine attribute)
%   numrt  : The rock type option in the block model (GeoviaWhittle attribute)
%	varnm  : The variable name of the block model file (GeoviaWhittle attribute)

% Output
%	SECD : The specific energy consumption of drilling for each rock type
%	num  : The number of rock types for rk_mill/rejected_tonnage attributes


switch option
    
    case ('Datamine')
        
        RC_Tit = 'Please input specific energy consumption of drilling for each rock type';
        RC_Str = compose("Rock_Code%d", RC(1:size(RC,1)));
        RC_par = inputdlg(RC_Str, RC_Tit, [1,length(RC_Tit)+50]); %Input drilling specific energy for each rock type
        SECD   = str2double(RC_par); %Convert strings to double
        %Empty output
        num = [];
        
    case ('GeoviaWhittle')
        
        switch numrt
            case ('Single') %Single rock type
                num = 1;
                RC_Tit = 'Please input specific energy consumption of drilling for single rock type';
                RC_Str = compose("RockType%d", num);
                RC_par = inputdlg(RC_Str, RC_Tit, [1,length(RC_Tit)+50]); %Input drilling specific energy for single rock type
                SECD   = str2double(RC_par); %Convert strings to double
                
            case ('Multiple') %Multiple rock type
                %%Determine the number of rock types
                %ORE
                for i = 100 : -1 : 1
                    temp_var1 = sprintf('rk%d_mill_tonnage',i);
                    if nnz(strcmp(temp_var1,varnm.Properties.VariableNames))>0 %nnz:number of nonzero matrix elements
                        num1 = i;
                        break
                    end
                end
                clearvars temp_var1
                %WASTE
                for j = 100 : -1 : 1
                    temp_var2 = sprintf('rk%d_rejected_tonnage',j);
                    if nnz(strcmp(temp_var2,varnm.Properties.VariableNames))>0 %nnz:number of nonzero matrix elements
                        num2 = j;
                        break
                    end
                end
                clearvars temp_var2
                %%Determine whether ore rock types equal to waste rock types
                try
                    isequal(num1,num2)
                    num = num1; %or num = num2
                    RC_Tit = 'Please input specific energy consumption of drilling for each rock type';
                    RC_Str = compose("RockType%d", 1 : num);
                    RC_par = inputdlg(RC_Str, RC_Tit, [1,length(RC_Tit)+50]); %Input drilling specific energy for single rock type
                    SECD   = str2double(RC_par); %Convert strings to double
                catch
                    error('Wrong imported Block Model File!')
                end
        end
        
end

end
