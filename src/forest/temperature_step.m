function new_world_temp = temperature_step(world_temp, world_tree, neighbors)
%TEMPERATURE_STEP Summary of this function goes here
%   Detailed explanation goes here
% tree states
% EMPTY       = 0; not used
% TREE        = 1; not used
BURNING     = 2;
BURNED      = 3;

% temperature increase
t_fire  = 30;
t_empty = 5;

[m, n] = size(world_temp);

tileworld = [world_temp(1, 1)  world_temp(1, :)  world_temp(1, n); 
             world_temp(:, 1)  world_temp        world_temp(:, n); 
             world_temp(m, 1)  world_temp(m, :)  world_temp(m, n)];
tileworld = conv2(tileworld,[1 1 1; 1 0 1; 1 1 1]/8,'same');  
new_world_temp = tileworld(2:end-1,2:end-1);
new_world_temp = min(400, new_world_temp + double(world_tree == BURNING)*t_fire);
new_world_temp = max(24, new_world_temp - double(world_tree == BURNED)*t_empty);
end

