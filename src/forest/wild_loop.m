close all ; clear ; clc ;
addpath('./sensorArray')
addpath('./resize') ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           SIMULATION PARAMETERS                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Time to predict the fire: 10 minutes');
times = input('Insert number of scenarios to test: ');
TIME_PRECISION = 10;
TILE_SIZE = 150;  % tile size in meters
FIRE_SPEED = 150;  % fire speed in meters/minute

SIM_LENGTH = 50;  % number of minutes to simulate
SZ = [150 150];  % world size in tiles
IDLE_TEMP   = 24;  % idle temperature
FOREST_DENSITY = 1;  % initial forest density
TREE_COST = 5;  % Tree cost in DKK
N_FIRES = 1;  % Number of fire
T_FIRE  = 40;  % temperature to be increased due to fire
T_BURNED = 2;  % temperature to be decreased due to burned area
PROCESS_COST_ACT = 5 * 5.2e-3 ; % energy needed for active mode (mAh)
PROCESS_COST_IDLE = 5 * 1.2e-3 ; % energy needed for idle mode (mAh)
SAMPLING_COST = (3.3 * 550e-6) + PROCESS_COST_ACT;  % mAh needed for sampling and processing temperature
SEND_COST_5 = (3.3 * 121e-3) +  PROCESS_COST_ACT;  % mAh needed for sending information at 5 km
LISTEN_COST = (3.3 * 2.8e-3) + PROCESS_COST_IDLE ;  % mAh needed for listening

RANGE = 2;  % Wireless range (km^2)
tiles_btw_sensors = floor((RANGE*1000) ./ (TILE_SIZE * sqrt(2)));
NR_SENSORS = ceil(SZ' ./ tiles_btw_sensors);
SEND_COST = SEND_COST_5 .* (RANGE / 5).^2;

min_jumps_edge = floor(min(NR_SENSORS(1, :),NR_SENSORS(2, :)) /2);
MAX_JUMPS_EDGE = floor(min_jumps_edge * 1.5);  % Maximum jumps in the mesh protocol (edge)
min_jumps_forest = floor(min(NR_SENSORS(1, :)/2,NR_SENSORS(2, :)/2) /2);
MAX_JUMPS_FOREST = floor(min_jumps_forest * 1.5);  % Maximum jumps in the mesh protocol (forest)

BATTERY_CAP = 9000;
MANDATORY_WINDOW = 10;
OPTIONAL_WINDOW = 5;

% probabilities
P_EXTEND_FIRE = 0.1; % tree -> fire (due to neighbours)
P_STOP_FIRE   = 0.05; % fire -> empty (no more wood to get burned)

% tree states
EMPTY       = 0;
TREE        = 1;
BURNING     = 2;
BURNED      = 3;

rate_synchro = zeros(times, 1);
rate_asynchro = zeros(times, 1);
for q=1:times
    disp(q)
    % world starts with trees and at the standard temperature everywhere
    world_tree = forest_create(SZ(1), SZ(2), FOREST_DENSITY);
    world_tree = fire_start(world_tree, N_FIRES);
    world_temp = ones(SZ(1), SZ(2)) * IDLE_TEMP;

    % create sensor arrays
    sensors_sync = main_sensors_create(SZ, NR_SENSORS, IDLE_TEMP, BATTERY_CAP, SAMPLING_COST, SEND_COST, LISTEN_COST, MANDATORY_WINDOW);
    sensors_async = main_sensors_create(SZ, NR_SENSORS, IDLE_TEMP, BATTERY_CAP, SAMPLING_COST, SEND_COST, LISTEN_COST, MANDATORY_WINDOW);
    
    out = 0;
    
    sync_flag = 0;
    async_flag = 0;
    
    for i=1:SIM_LENGTH
        if sync_flag == 1 && async_flag == 1
            break
        end
        world_temp = temperature_step(world_temp, world_tree, T_FIRE, T_BURNED, IDLE_TEMP);
        world_tree =fire_step(world_tree, P_EXTEND_FIRE, P_STOP_FIRE);
        if sum(sum(double(world_tree == BURNING))) == 0
            out = out + 1;
            break
        end
        % synchronous sensors
        if sync_flag == 0
            if ((mod(i-1, MANDATORY_WINDOW) == 0) || (mod(i-1, OPTIONAL_WINDOW) == 0))
                sensors_sync = main_sensor_step(sensors_sync, world_temp);
                for row =1:NR_SENSORS(1)
                    for col = 1:NR_SENSORS(2)
                        Xsens = sensors_sync{row,col}.X ;
                        Ysens = sensors_sync{row,col}.Y ;
                        sensor_state = sensors_sync{row,col}.forestState;
                        if sensor_state == 1
                            sync_flag = 1;
                            rate_synchro(q) = i - 1;
                            break
                        end 
                    end
                    if sync_flag == 1
                        break
                    end
                end
            end
        end
        % asynchronous sensors
        if async_flag == 0
            sensors_async = main_sensor_step(sensors_async, world_temp);
            for row =1:NR_SENSORS(1)
                for col = 1:NR_SENSORS(2)
                    Xsens = sensors_async{row,col}.X ;
                    Ysens = sensors_async{row,col}.Y ;
                    sensor_state = sensors_async{row,col}.forestState;
                    if sensor_state == 1
                        async_flag = 1;
                        rate_asynchro(q) = i - 1;
                        break
                    end 
                end
                if async_flag == 1
                    break
                end
            end
        end
    end
end

mean_synchro = sum(rate_synchro) / (times - out);
mean_asynchro = sum(rate_asynchro) / (times - out);
aux = ['Average time for detecting the fire (synchro): ', num2str(mean_synchro)];
disp(aux)
aux = ['Average time for detecting the fire (asynchro): ', num2str(mean_asynchro)];
disp(aux)

success_synchro = mean(double(rate_synchro <= TIME_PRECISION));
success_asynchro = mean(double(rate_asynchro <= TIME_PRECISION));
aux = ['Percentage of success detecting the fire (synchro): ', num2str(success_synchro)];
disp(aux)
aux = ['Percentage of success detecting the fire (asynchro): ', num2str(success_asynchro)];
disp(aux)

step_synchro = 0:5:20;
hist_synchro = mean(double(rate_synchro <= (step_synchro)));
step_asynchro = 0:20;
hist_asynchro = mean(double(rate_asynchro <= (step_asynchro)));
%hist_synchro = interp1(step_synchro, hist_synchro, step_asynchro);

plot(step_synchro, hist_synchro)
hold on
plot(step_asynchro, hist_asynchro)
title('Systems Average Performance')
ylim([0 1.1])
xlabel('Time Since Fire Starts (Minutes)')
ylabel('Fire Detection Probability')
legend('Synchronous', 'Asynchronous', 'Location', 'northwest')
hold off