% reset
close all ; clear ; clc ;
% we add a path to the sensor classes 
addpath('./sensorArray')
addpath('./resize') ;
% simulation parameters
SZ = [150 150];  % world size
IDLE_TEMP   = 24;  % idle temperature
FOREST_DENSITY = 0.9;  % initial forest density
N_FIRES = 2;  % Number of fire
T_FIRE  = 40;  % temperature to be increased due to fire
T_BURNED = 2;  % temperature to be decreased due to burned area
NR_SENSOR = 20 ; % number of sensors
SENSOR_COST = 300; % Sensor cost in DKK
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
X = zeros;
Y = zeros;
fireDetected = -1;

% world starts with trees and at the standard temperature everywhere
world_tree = forest_create(SZ(1), SZ(2), FOREST_DENSITY);
world_tree = fire_start(world_tree, N_FIRES);
world_temp = ones(SZ(1), SZ(2)) * IDLE_TEMP;
% create sensor array 
dim = size(world_temp) ;
Ysensor = double(int16(linspace(dim(2)/NR_SENSOR,dim(2)-(dim(2)/NR_SENSOR),5))) ; % row 
Xsensor = double(int16(linspace(dim(1)/NR_SENSOR,dim(1)-(dim(1)/NR_SENSOR),4))) ; % col


world_sensor = cell(5,4) ;
for row = 1:5
    for col = 1:4
    world_sensor{row,col} = sensorNetwork(Ysensor(row),Xsensor(col), IDLE_TEMP) ;
    end 
end

looplength = 300;
% iterate for 1440 time steps
for i=1:looplength
    world_temp = temperature_step(world_temp, world_tree, T_FIRE, T_BURNED, IDLE_TEMP);
    world_tree =fire_step(world_tree, P_EXTEND_FIRE, P_STOP_FIRE);
    XtreesBurned(i)= TreesBurned(world_tree);
    Y(i) =i;
    Xprice(i) = NR_SENSOR * SENSOR_COST + XtreesBurned(i) * TREE_COST;
    % update temperature for sensors
    for row = 1:5 
        for col = 1:4 
        Xsens = world_sensor{row,col}.X ;
        Ysens = world_sensor{row,col}.Y ;
       world_sensor{row,col}.update(world_temp(Ysens,Xsens)) ;
        end
    end
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
    axis([0 looplength 0 15000]);
    p = plot(Y,XtreesBurned);hold on
    p(1).LineWidth = 3;
    p(1).Color = 'k';   
    xlabel('ticks');
    ylabel('Trees burned');
    %figure(2)
    
    %Price
    ax31 = subplot(4,3,6);
    title(ax31, 'Price')
    axis([0 looplength 0 100000]);
    p = plot(Y,Xprice);hold on
    p(1).LineWidth = 3;
    p(1).Color = 'r';
    xlabel('ticks');
    ylabel('DKK');
    if fireDetected ~= -1
        v=fireDetected; % Point where you want the line
        t = plot([v v], ylim); % Plot Vertical Line
        t(1).Color = 'b';
    end
    
    % graph of sensor data
    ax4 = subplot(4,3,[7 10]) ;
    title(ax4, 'sensors') 
    plot(1,1) 
    axis([0 dim(1) 0 dim(2)])
    axis ij
    set(gca,'Color','k')

    for row =1:5
        for col = 1:4 
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
    
    temp_from_sensors = get_temp_from_sensors(world_sensor);
    temp_from_sensors = temp_reconstruct(temp_from_sensors, SZ(1), SZ(2));
    
    % view the temperature world
    ax5 = subplot(4,3,[8 11]);
    imagesc(temp_from_sensors);
    title(ax5, 'reconstructed temperature')
    caxis(ax5, [0 400]);
    colormap(gca, jet(64));
    cbh5 = colorbar;
    title(cbh5, 'temperature[ºC]')
    drawnow;
end