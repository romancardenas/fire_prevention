close all ; clear ; clc ;
addpath('./sensorArray')
addpath('./resize') ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           SIMULATION PARAMETERS                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SIM_LENGTH = 300;  % number of minutes to simulate
TILE_SIZE = 150;  % tile size in meters
SZ = [150 150];  % world size in tiles
IDLE_TEMP   = 24;  % idle temperature
FOREST_DENSITY = 0.9;  % initial forest density
N_FIRES = 1;  % Number of fire
T_FIRE  = 40;  % temperature to be increased due to fire
T_BURNED = 2;  % temperature to be decreased due to burned area
TOTAL_TICKS = 3 * 30 * 24 * 60 ;
EPSILON = 0.05 ;

BATTERY_CAP = 3000;  % Battery capacity in mAh (for the sensors)
PROCESS_COST_ACT = 5 * 5.2e-3 ; % battery needed for active mode
PROCESS_COST_IDLE = 5 * 1.2e-3 ; % battery needed for idle mode
SAMPLING_COST = (3.3 * 550e-6) + PROCESS_COST_ACT;  % mAh needed for sampling and processing temperature
SEND_COST_5 = (3.3 * 121e-3) +  PROCESS_COST_ACT;  % mAh needed for sending information
LISTEN_COST = (3.3 * 2.8e-3) + PROCESS_COST_IDLE ;  % mAh needed for listening

RANGE = input('Select a range from 1 to 5 km: ');  % Wireless range (neighbors)
NEIGHBORS = 1;
max_tiles_btw_sensors = floor((RANGE*1000) / (TILE_SIZE*sqrt(2)));
tiles_btw_sensors = floor(max_tiles_btw_sensors/NEIGHBORS);
NR_SENSORS = ceil(SZ/tiles_btw_sensors);
SEND_COST = SEND_COST_5 .* (RANGE / 5)^2;

% mandatory window ratio
min_jumps = floor(min(NR_SENSORS(1),NR_SENSORS(2)) /2);
MAX_JUMPS = floor(min_jumps * 1.5);  % Maximum jumps in the protocol
for N = 1:5
    OPTIONAL_WINDOW_COST = (SAMPLING_COST + LISTEN_COST +  0.1 * SEND_COST ) ;
    MANDATORY_WINDOW_COST = (SAMPLING_COST + LISTEN_COST + (SEND_COST*MAX_JUMPS ))  ;
    
    window = TOTAL_TICKS / (BATTERY_CAP * ( 1 - EPSILON ) ) * ((N-1)/N * OPTIONAL_WINDOW_COST + MANDATORY_WINDOW_COST/N) ;
    window = ceil(window ) ;
    
    
    OPTIONAL_WINDOW = window ;
    
    MANDATORY_WINDOW = window * N ;
    
    
    
    A = 0 ;
    
end

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
% TODO change this to the new stuff...
world_sensor = sensors_create(SZ, NR_SENSORS, IDLE_TEMP, BATTERY_CAP, SAMPLING_COST, SEND_COST, LISTEN_COST, MANDATORY_WINDOW);
final_nsensors = numel(world_sensor);
% TODO ... until here

temp_from_sensors = zeros(size(world_sensor));
prev_temp_from_sensors = zeros(size(world_sensor));
est_temp_from_sensors = zeros(SZ(1), SZ(2));

XpriceSens = XpriceSens * (final_nsensors * world_sensor{1,1}.price); % Don't like price inside the object 

% create figure
figure(1)
for i=1:SIM_LENGTH % replace with SIM_LENGTH
    world_temp = temperature_step(world_temp, world_tree, T_FIRE, T_BURNED, IDLE_TEMP);
    world_tree =fire_step(world_tree, P_EXTEND_FIRE, P_STOP_FIRE);
    XtreesBurned(i)= TreesBurned(world_tree);
    XpriceTree(i) = XtreesBurned(i) * TREE_COST;
    if ((mod(i, MANDATORY_WINDOW) == 0) || (mod(i, OPTIONAL_WINDOW) == 0))
        world_sensor = sensor_step(world_sensor, world_temp);
        temp_from_sensors = mesh(world_sensor, NEIGHBORS, MAX_JUMPS, i);
        [est_temp_from_sensors, prev_temp_from_sensors] = temp_reconstruct(temp_from_sensors, prev_temp_from_sensors, SZ(1), SZ(2));
        
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
        [j, k] = size(world_sensor);
        for row =1:j
            for col = 1:k
                Xsens = world_sensor{row,col}.X ;
                Ysens = world_sensor{row,col}.Y ;
                if world_sensor{row,col}.forestState == 0
                    plot(Xsens,Ysens,'og')
                elseif world_sensor{row,col}.forestState == 1
                    plot(Xsens,Ysens,'oy')
                elseif world_sensor{row,col}.forestState == 2
                    plot(Xsens,Ysens,'or')
                elseif world_sensor{row,col}.forestState == 3
                    plot(Xsens,Ysens,'ow')
                    if fireDetected == -1
                        fireDetected = i;
                    end
                else
                    plot(Xsens,Ysens,'ok')
                end 
            end
            hold on
        end
        
        % view the reconstructed temperature world
        ax5 = subplot(4,3,[8 11]);
        imagesc(est_temp_from_sensors);
        title(ax5, 'reconstructed temperature')
        caxis(ax5, [0 100]);
        colormap(gca, jet(64));
        cbh5 = colorbar;
        title(cbh5, 'temperature[ºC]')
        drawnow;
    end
end