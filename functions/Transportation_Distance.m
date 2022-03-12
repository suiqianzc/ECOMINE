%% This function is to calculate the theoretical shortest distance between two points in the spatial coordinate system
%  Reference: https://www.math.usm.edu/lambers/mat169/fall09/lecture17.pdf
%  2022 © C. Zhang

function SAB = Transportation_Distance(Xa,Ya,Za,xb,yb,zb)
%This function is calculating the distance from point A to point B

% Input
%	Xa :  X coord of plant/dump (user inputs)
%	Ya :  Y coord of plant/dump (user inputs)
%	Za :  Z coord of plant/dump (user inputs)
%	xb :  x coord of ore/waste/unmineralised
%	yb :  y coord of ore/waste/unmineralised
%	zb :  z coord of ore/waste/unmineralised

% Output
%	SAB : distance from point A to point B

SAB  = sqrt((Xa - xb).^2 + (Ya - yb).^2 + (Za - zb).^2);

end