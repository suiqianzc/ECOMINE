clc; clear; close all

option=1;	% 1: Plot 3D alphaShape
			% 2: Plot 2D alphaShapes together
			% 3: Plot 2D alphaShapes separately
			% 4: Plot all of the above

%% Load data & separate x,y,z and Energy Consumption and Global Warming Potential
%table=readtable('XYZ_ECGWP_Datamine.xlsx'); %Datamine
 table=readtable('Example_XYZ_ECGWP_GeoviaWhittle.xlsx'); %GeoviaWhittle
%Find the column indexes for EC and GWP 
ind_EC=find(string(table.Properties.VariableNames) == "Energy_Consumption");
ind_GWP=find(string(table.Properties.VariableNames) == "Global_Warming_Potential");
%Convert table to double
%data=table2array(table); %Datamine
data=table2array(table); %GeoviaWhittle

P=data(:,1:3);
x=P(:,1);
y=P(:,2);
z=P(:,3);
EC=data(:,ind_EC)/1e6; %Energy Consumption
%GWP=data(:,ind_GWP)/1e3; %Global Warming Potential
%% 3D scatter plot: Plotted in all cases
figure
scatter3(x,y,z,5,EC,'filled') %Energy Consumption
%scatter3(x,y,z,5,GWP,'filled') %Global Warming Potential
box on %; grid on
% axis off
axis equal
view(3)

cb=colorbar;
cb.Label.String = "Energy Consumption (TJ)";
%cb.Label.String = "Global Warming Potential (ton CO2 eq)";
cb.Label.Rotation=90;
colormap(plasma) %Energy Consumption
%colormap(viridis) %Global Warming Potential

% Get limits of the 3D scatter plot
lim_X=xlim;
lim_Y=ylim;
lim_Z=zlim;

temp=unique(z);		% Unique z coordinates
temp=sort(temp);	% Sort

if temp(2)-temp(1)==temp(3)-temp(2)
	step=temp(2)-temp(1);
end

%% Generate 3D alphaShape of all data
if option==1 || option==4
	% ATTENTION: A problem of this approach is that it does not triangulate
	% flat parts of the mine, that have the same elevation, as it is
	% looking for 3D points with different elevations.
	
	shp3D=alphaShape(P,step*1.01*sqrt(3)); % the square root of 3 is used to capture the 3D diagonal of a cube drawn between adjacent points
	tri=alphaTriangulation(shp3D);
	
	figure
	scatter3(x,y,z,2,EC,'filled') % Here I plot the points just for comparison
    %scatter3(x,y,z,2,GWP,'filled')
	hold on; box on %; grid off
    % axis off
	axis equal
	view(3)
	
	xlim(lim_X) % Apply same X limits as in the scatter plot above
	ylim(lim_Y) % Apply same Y limits as in the scatter plot above
	zlim(lim_Z) % Apply same Z limits as in the scatter plot above
	
	patch('Vertices',P,'Faces',tri,'FaceVertexCData',EC,'FaceColor','interp','EdgeColor','none','EdgeAlpha',0.05,'FaceAlpha',0.5);
    %patch('Vertices',P,'Faces',tri,'FaceVertexCData',GWP,'FaceColor','interp','EdgeColor','none','EdgeAlpha',0.05,'FaceAlpha',0.5);
	% Note: you can set (...,'EdgeColor','k') if you want to show e.g. black edge lines
	%	FaceAlpha controls the transparency of the faces
	%	EdgeAlpha controls the transparency of the edges

	cb=colorbar;
	cb.Label.String = "Energy Consumption (TJ)";
    %cb.Label.String = "Global Warming Potential (ton CO2 eq)";
	cb.Label.Rotation=90;
    colormap(plasma) %Energy Consumption
	%colormap(viridis) %Global Warming Potential
	view(3)
end

%% Isolate 1 elevation, e.g. z=6400 and generate 2D alphaShape
if option==2 || option==4
	figure
	scatter3(x,y,z,2,EC,'filled') % Here I plot the points just for comparison
    %scatter3(x,y,z,2,GWP,'filled')
	hold on; box on %; grid on
    % axis off
	axis equal
	view(3)
	
	xlim(lim_X) % Apply same X limits in all 2D sections
	ylim(lim_Y) % Apply same Y limits in all 2D sections
	zlim(lim_Z) % Apply same Z limits in all 2D sections
	
	cb=colorbar;
	cb.Label.String = "Energy Consumption (TJ)";
    %cb.Label.String = "Global Warming Potential (ton CO2 eq)";
	cb.Label.Rotation=90;
    colormap(plasma) %Energy Consumption
    %colormap(viridis) %Global Warming Potential

	for elevation=[min(temp):step:max(temp)]
		ind=(z==elevation); % indices of points with the elevation of this iteration
		p=P(ind,:);
		e=EC(ind); %Energy Consumption
        %e=GWP(ind); %Global Warming Potential
		
		shp2D=alphaShape(p(:,1),p(:,2),step*sqrt(2));
		tri=alphaTriangulation(shp2D);
		p(:,3)=elevation*ones(size(p,1),1); % Add elevation for the points of each level
		
		patch('Vertices',p,'Faces',tri,'FaceVertexCData',e,'FaceColor','interp','EdgeColor','none','FaceAlpha',0.8); % Use FaceAlpha to control the transparency of the faces
	end
end

%% Isolate each elevation, and generate separate 2D alphaShape
if option==3 || option==4
	for elevation=[min(temp):step:max(temp)] % [6400,6440]
		figure
		hold on; box on %; grid on
        % axis off
		axis equal
		
		xlim(lim_X) % Apply same X limits in all 2D sections
		ylim(lim_Y) % Apply same Y limits in all 2D sections
		zlim(lim_Z) % Apply same Z limits in all 2D sections
		
		cb=colorbar;
		cb.Label.String = "Energy Consumption (TJ)";
        %cb.Label.String = "Global Warming Potential (ton CO2 eq)";
		cb.Label.Rotation=90;
        colormap(plasma) %Energy Consumption
        %colormap(viridis) %Global Warming Potential
		
		view(-50,10); %view(3)
		scatter3(x,y,z,2,EC,'filled') % Here I plot the points just for comparison
		%scatter3(x,y,z,2,GWP,'filled')
        
		ind=(z==elevation); % indices of points with the elevation of this iteration
		p=P(ind,:);
		e=EC(ind); %Energy Consumption
		%e=GWP(ind); %Global Warming Potential
        
		shp2D=alphaShape(p(:,1),p(:,2),step*sqrt(2));
		% shp2D.Points(:,2)=elevation*ones(length(shp2D.Points),1);
		tri=alphaTriangulation(shp2D);
		
		p(:,3)=elevation*ones(size(p,1),1); % Add elevation for the points of each level
		% scatter(p(:,1),p(:,2),'.r')
		% plot(shp2D)
		patch('Vertices',p,'Faces',tri,'FaceVertexCData',e,'FaceColor','interp','EdgeColor','none');
		
		label_string=['Elevation=',num2str(elevation)];
		title(label_string)
		
%		% The lines below add a text within the graph, instead of a title (can be used for 2D views)
% 		NE = [max(xlim) max(ylim)]-[diff(xlim) diff(ylim)]*0.05;  % NE: North East
% 		SW = [min(xlim) min(ylim)]+[diff(xlim) diff(ylim)]*0.05;  % SW: South West
% 		NW = [min(xlim) max(ylim)]+[diff(xlim) -diff(ylim)]*0.05; % NW: North West
% 		SE = [max(xlim) min(ylim)]+[-diff(xlim) diff(ylim)]*0.05; % SE: South East
% 		text(NW(1), NW(2), label_string, 'VerticalAlignment','top', 'HorizontalAlignment','left') % right
	end
end


disp('Done!')