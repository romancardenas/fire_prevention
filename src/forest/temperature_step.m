function new_world_temp = temperature_step(world_temp, world_tree, t_fire, t_burned, t_base)
%TEMPERATURE_STEP Computes temperature of the scenario for the next step
%   world_temp: previous temperature scenario
%   world_tree: previous tree scenario
%   t_fire: temperature to be incremented if there is a fire
%   t_burned: temperature to be decremented if there is a burned tree

% tree states
BURNING     = 2;
BURNED      = 3;

[m, n] = size(world_temp);
% TODO implement the neighbors thing
tileworld = [world_temp(1, 1) world_temp(1, 1)  world_temp(1, :)  world_temp(1, n) world_temp(1, n);
             world_temp(1, 1) world_temp(1, 1)  world_temp(1, :)  world_temp(1, n) world_temp(1, n);
             world_temp(:, 1) world_temp(:, 1)    world_temp      world_temp(:, n) world_temp(:, n);
             world_temp(m, 1) world_temp(m, 1)  world_temp(m, :)  world_temp(m, n) world_temp(m, n);
             world_temp(m, 1) world_temp(m, 1)  world_temp(m, :)  world_temp(m, n) world_temp(m, n)];
tileworld = conv2(tileworld,[1 1 1 1 1; 1 1 1 1 1; 1 1 1 1 1; 1 1 1 1 1; 1 1 1 1 1;]/25,'same');  
new_world_temp = tileworld(3:end-2,3:end-2);
new_world_temp = min(400, new_world_temp + double(world_tree == BURNING)*t_fire);
new_world_temp = max(t_base, new_world_temp - double(world_tree == BURNED)*t_burned);
end

