function new_world_temp = temperature_step(world_temp, world_tree, neighbors)
%TEMPERATURE_STEP Summary of this function goes here
%   Detailed explanation goes here
% tree states
EMPTY       = 0;
TREE        = 1;
BURNING     = 2;
BURNED      = 3;

% temperature increase
t_fire = 30;
t_empty = 5;

[m, n] = size(world_temp);
new_world_temp = world_temp;
for x = 1:m
    for y = 1:n
        temp_buff = []; % TODO consider pre-allocating for speed
        for i = x-neighbors:x+neighbors
            if i < 1 || i > m
                continue
            end
            for j = y-neighbors:y+neighbors
                if j < 1 || j > n
                    continue
                end
                temp_buff = [temp_buff world_temp(i, j)];
            end
        end
        new_world_temp(x, y) = mean(temp_buff);
        if world_tree(x, y) == BURNING
            new_world_temp(x, y) = min(400, new_world_temp(x, y) + t_fire);
        elseif world_tree(x, y) == BURNED
            new_world_temp(x, y) = max(24, new_world_temp(x, y) - t_empty);
        end
    end
end
end

