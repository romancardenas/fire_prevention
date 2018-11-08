% reset
close all ; clear ; clc ;
% we add a path to the sensor classes 
addpath('./sensorArray')
addpath('./resize') ;
% simulation parameters
SIM_LENGTH = 300;
SZ = [150 150];  % world size
IDLE_TEMP   = 24;  % idle temperature
FOREST_DENSITY = 0.9;  % initial forest density
N_FIRES = 1;  % Number of fire
T_FIRE  = 40;  % temperature to be increased due to fire
T_BURNED = 2;  % temperature to be decreased due to burned area
NR_SENSOR = 25 ; % number of sensors
TREE_COST = 5;  % Tree cost in DKK
% probabilities
P_EXTEND_FIRE = 0.1; % tree -> fire (due to neighbours)
P_STOP_FIRE   = 0.05; % fire -> empty (no more wood to get burned)

% tree states
EMPTY       = 0;
TREE        = 1;
BURNING     = 2;
BURNED      = 3;

% For plotting the forest
map_forest = [ 0    0   0.6;
               0    0.8 0;
               1.0  0   0;
               0    0   0];

%For plotting trees burned
% X = zeros;
Y = 1:SIM_LENGTH;
fireDetected = -1;
XtreesBurned = zeros(1,SIM_LENGTH ) ;
XpriceTree = zeros(1,SIM_LENGTH) ;
XpriceSens = ones(1,SIM_LENGTH) ;
% world starts with trees and at the standard temperature everywhere
world_tree = forest_create(SZ(1), SZ(2), FOREST_DENSITY);
world_tree = fire_start(world_tree, N_FIRES);
world_temp = ones(SZ(1), SZ(2)) * IDLE_TEMP;

% create sensor array 
world_sensor = sensor_create(SZ, NR_SENSOR, IDLE_TEMP);
final_nsensors = numel(world_sensor);

XpriceSens = XpriceSens * (final_nsensors * world_sensor{1,1}.price); % Don't like price inside the object 

for i=1:SIM_LENGTH % replace with SIM_LENGTH
    world_temp = temperature_step(world_temp, world_tree, T_FIRE, T_BURNED, IDLE_TEMP);
    world_tree =fire_step(world_tree, P_EXTEND_FIRE, P_STOP_FIRE);
    world_sensor = sensor_step(world_sensor, world_temp);
    temp_from_sensors = get_temp_from_sensors(world_sensor);
    temp_from_sensors = temp_reconstruct(temp_from_sensors, SZ(1), SZ(2));
    XtreesBurned(i)= TreesBurned(world_tree);
    XpriceTree(i) = XtreesBurned(i) * TREE_COST;
  
    figure(1)
    % view the tree world
    ax1 = subplot(4,3,[1 4]);
    imagesc(world_tree);
    title(ax1, 'forest state')
    % keep colors ranging from 0 to 3
    caxis(ax1, [0 3]);
    colormap(gca, map_forest);
    cbh1 = colorbar ; %Create Colorbar
    cbh1.Ticks = 0.3750:0.75:4 ;
    cbh1.TickLabels = {'empty', 'tree', 'fire', 'burned'} ;
    title(cbh1, 'state')
    
    % view the temperature world
    ax2 = subplot(4,3,[2 5]);
    imagesc(world_temp);
    title(ax2, 'forest temperature')
    caxis(ax2, [0 400]);
    colormap(gca, jet(64));
    cbh2 = colorbar;
    title(cbh2, 'temperature[ºC]')
    
    % graph of the number burned trees
    ax3 = subplot(4,3,3);
    title(ax3, 'trees burned')
    axis([0 SIM_LENGTH 0 15000]);
    p = plot(Y(1:i),XtreesBurned(1:i));hold on
    p(1).LineWidth = 3;
    p(1).Color = 'k';   
    xlabel('ticks');
    ylabel('Trees burned');
    %figure(2)
    
    %Price
    ax31 = subplot(4,3,6);
    title(ax31, 'Price')
    axis([0 SIM_LENGTH 0 100000]);
    p = plot(Y(1:i),XpriceTree(1:i)) ;
    p(1).LineWidth = 3;
    p(1).Color = 'r';
    hold on
    s = plot(Y(1:i),XpriceSens(1:i)); hold on 
    s(1).LineWidth = 3 ;
    s(1).Color = 'k' ;
    xlabel('ticks');
    ylabel('DKK');
    if fireDetected ~= -1
        v=fireDetected; % Point where you want the line
        t = plot([v v], ylim); % Plot Vertical Line
        t(1).Color = 'b';
    end
    legend('trees','sensors') ;
    
    % graph of sensor data
    ax4 = subplot(4,3,[7 10]) ;
    title(ax4, 'sensors') 
    %plot(1,1) 
    axis([0 SZ(1) 0 SZ(2)])
    axis ij
    set(gca,'Color','k')
    [i, j] = size(world_sensor);
    for row =1:i
        for col = 1:j
            Xsens = world_sensor{row,col}.X ;
            Ysens = world_sensor{row,col}.Y ;
            if world_sensor{row,col}.forestState == 0
                plot(Xsens,Ysens,'og')
            elseif world_sensor{row,col}.forestState == 1
                plot(Xsens,Ysens,'oy')
            elseif world_sensor{row,col}.forestState == 2
                plot(Xsens,Ysens,'or')
                if fireDetected == -1
                    fireDetected = i;
                end
            else
                plot(Xsens,Ysens,'ow')
            end 
        end
        hold on
    end
   
    % view the reconstructed temperature world
    ax5 = subplot(4,3,[8 11]);
    imagesc(temp_from_sensors);
    title(ax5, 'reconstructed temperature')
    caxis(ax5, [0 400]);
    colormap(gca, jet(64));
    cbh5 = colorbar;
    title(cbh5, 'temperature[ºC]')
    drawnow;
end