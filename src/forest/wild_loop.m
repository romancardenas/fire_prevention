close all ; clear ; clc ;
addpath('./sensorArray')
addpath('./resize') ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           SIMULATION PARAMETERS                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
WORKING_TIME = input('Insert total system working time (months): ');  % Working time in months
TIME_PRECISION = input('Insert time precision (minutes): ');  % How fast should the system detect a fire
TILE_SIZE = 150;  % tile size in meters
FIRE_SPEED = 150;  % fire speed in meters/minute
MIN_SPACE_PRECISION = TIME_PRECISION * FIRE_SPEED / TILE_SIZE;

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
window = floor(TIME_PRECISION/2);
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
for i = 1:a
    if windows_to_study(i) < 3000
        MANDATORY_WINDOW = OPTIONAL_WINDOW * i;
        break
    end
end

aux = ['The most optimal mandatory window is ', num2str(MANDATORY_WINDOW)];
disp(aux);

% probabilities
P_EXTEND_FIRE = 0.1; % tree -> fire (due to neighbours)
P_STOP_FIRE   = 0.05; % fire -> empty (no more wood to get burned)

% tree states
EMPTY       = 0;
TREE        = 1;
BURNING     = 2;
BURNED      = 3;

times = 50;
rate = zeros(times, 1);
for q=1:times
    disp(q)
    % world starts with trees and at the standard temperature everywhere
    world_tree = forest_create(SZ(1), SZ(2), FOREST_DENSITY);
    world_tree = fire_start(world_tree, N_FIRES);
    world_temp = ones(SZ(1), SZ(2)) * IDLE_TEMP;

    % create sensor array 
    world_sensor = sensors_create(SZ, NR_SENSOR, IDLE_TEMP, BATTERY_CAP, SAMPLING_COST, SEND_COST, LISTEN_COST, MANDATORY_WINDOW);
    final_nsensors = numel(world_sensor);

    temp_from_sensors = zeros(size(world_sensor));
    prev_temp_from_sensors = zeros(size(world_sensor));
    est_temp_from_sensors = zeros(SZ(1), SZ(2));
    out = 0;
    d = 0;
    for i=1:SIM_LENGTH % replace with SIM_LENGTH
        if d ~= 0
            break
        end
        world_temp = temperature_step(world_temp, world_tree, T_FIRE, T_BURNED, IDLE_TEMP);
        world_tree =fire_step(world_tree, P_EXTEND_FIRE, P_STOP_FIRE);
        if sum(sum(double(world_tree == BURNING))) == 0
            out = out + 1;
            break
        end
        if ((mod(i-1, MANDATORY_WINDOW) == 0) || (mod(i-1, OPTIONAL_WINDOW) == 0))
            world_sensor = sensor_step(world_sensor, world_temp);
            temp_from_sensors = mesh(world_sensor, 1, MAX_JUMPS, i-1);
            [est_temp_from_sensors, prev_temp_from_sensors] = temp_reconstruct(temp_from_sensors, prev_temp_from_sensors, SZ(1), SZ(2));
            [j, k] = size(world_sensor);
            for row =1:j
                for col = 1:k
                    Xsens = world_sensor{row,col}.X ;
                    Ysens = world_sensor{row,col}.Y ;
                    sensor_state = world_sensor{row,col}.forestState;
                    if sensor_state == 1
                        d = 1;
                        rate(q) = i - 1;
                        break
                    end 
                end
                if d == 1
                    break
                end
            end
        end
    end
end
[a, b] = size(rate);
mean_stuff = sum(rate) / (a - out);
success = mean(double(rate <= TIME_PRECISION));
aux = ['Average time for detecting the fire: ', num2str(mean_stuff)];
disp(aux)
aux = ['Percentage of success detecting the fire: ', num2str(success)];
disp(aux)
step = -1:0.5:1.5;
hist = mean(double(rate <= (TIME_PRECISION+step*TIME_PRECISION)));
plot(TIME_PRECISION+step*TIME_PRECISION, hist)
title('Average System Performance')
ylim([0 1.1])
xlabel('Time Since Fire Starts (Minutes)')
ylabel('Fire Detection Probability')