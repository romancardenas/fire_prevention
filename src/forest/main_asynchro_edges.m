close all ; clear ; clc ;
addpath('./sensorArray')
addpath('./resize') ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           SIMULATION PARAMETERS                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
WORKING_TIME = input('Insert total system working time (months): ');  % Working time in months
BATTERY = [3000 6000 9000 12000 16000];  % Different battery capacities for the system
TILE_SIZE = 150;  % tile size in meters
FIRE_SPEED = 150;  % fire speed in meters/minute
MIN_SPACE_PRECISION = 10 * FIRE_SPEED / TILE_SIZE;

SIM_LENGTH = 300;  % number of minutes to simulate
SZ = [150 150];  % world size in tiles
IDLE_TEMP   = 24;  % idle temperature
FOREST_DENSITY = 1;  % initial forest density
TREE_COST = 5;  % Tree cost in DKK
N_FIRES = 1;  % Number of fire
T_FIRE  = 40;  % temperature to be increased due to fire
T_BURNED = 2;  % temperature to be decreased due to burned area
TOTAL_TICKS = WORKING_TIME * 30 * 24 * 60 ;
EPSILON = 0.05 ;

PROCESS_COST_ACT = 5 * 5.2e-3 ; % energy needed for active mode (mAh)
PROCESS_COST_IDLE = 5 * 1.2e-3 ; % energy needed for idle mode (mAh)
SAMPLING_COST = (3.3 * 550e-6) + PROCESS_COST_ACT;  % mAh needed for sampling and processing temperature
SEND_COST_5 = (3.3 * 121e-3) +  PROCESS_COST_ACT;  % mAh needed for sending information at 5 km
LISTEN_COST = (3.3 * 2.8e-3) + PROCESS_COST_IDLE ;  % mAh needed for listening

RANGE = [1, 2, 3, 4, 5];  % Wireless range (km^2)
tiles_btw_sensors = floor((RANGE*1000) ./ (TILE_SIZE * sqrt(2)));
NR_SENSORS = ceil(SZ' ./ tiles_btw_sensors);
SEND_COST = SEND_COST_5 .* (RANGE / 5).^2;

% mandatory window ratio
min_jumps = floor(min(NR_SENSORS(1, :),NR_SENSORS(2, :)) /2);
MAX_JUMPS = floor(min_jumps * 1.5);  % Maximum jumps in the mesh protocol

OPTIONAL_WINDOW_COST = (SAMPLING_COST + LISTEN_COST +  0.1 * SEND_COST ) ;
MANDATORY_WINDOW_COST = (SAMPLING_COST + LISTEN_COST + (SEND_COST .* MAX_JUMPS ));
window = 1;
OPTIONAL_WINDOW = window;

report = zeros(20, 5);
for N = 1:20
    BATTERY_CAP = ceil(TOTAL_TICKS / window * ((N-1)/N*OPTIONAL_WINDOW_COST + 1/N*MANDATORY_WINDOW_COST)/(1-EPSILON));
    report(N, :) = BATTERY_CAP'; 
end
NR_SENSOR = zeros(1, 2);
index = 1;
selected_index = -1;
for i = (tiles_btw_sensors < MIN_SPACE_PRECISION)
    if i
        NR_SENSOR = NR_SENSORS(:, index)';
        selected_index = index;
    end
    index = index + 1;
end

windows_to_study = report(:, selected_index);
[a, b] = size(windows_to_study);
MANDATORY_WINDOW = 0;
aux = ['Optional window size (min):', num2str(OPTIONAL_WINDOW)];
disp(aux)
for i = BATTERY
    for j = 1:a
        if windows_to_study(j) < i
            if MANDATORY_WINDOW == 0
                MANDATORY_WINDOW = OPTIONAL_WINDOW * j;
            end
            aux = ['Mandatory window size (battery capacity =',num2str(i),'mAh)(min):', num2str(OPTIONAL_WINDOW*j)];
            disp(aux)
            break
        end
    end
end

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
world_sensor = main_sensors_create(SZ, NR_SENSOR, IDLE_TEMP, BATTERY_CAP, SAMPLING_COST, SEND_COST, LISTEN_COST, MANDATORY_WINDOW);
final_nsensors = numel(world_sensor);

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
    if ((mod(i-1, MANDATORY_WINDOW) == 0) || (mod(i-1, OPTIONAL_WINDOW) == 0))
        world_sensor = main_sensor_step(world_sensor, world_temp);
        temp_from_sensors = mesh_edges(world_sensor, 1, MAX_JUMPS, i-1);
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
                sensor_state = world_sensor{row,col}.forestState;
                if sensor_state == 0
                    plot(Xsens,Ysens,'og')
                elseif sensor_state == 1
                    plot(Xsens,Ysens,'oy')
                    if fireDetected == -1
                        fireDetected = i;
                    end
                elseif sensor_state == 2
                    plot(Xsens,Ysens,'or')
                elseif sensor_state == 3
                    plot(Xsens,Ysens,'ow')
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