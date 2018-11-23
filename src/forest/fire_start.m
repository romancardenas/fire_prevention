function new_world = fire_start(world, n_fires)
%FIRE_SPARK Summary of this function goes here
%   Detailed explanation goes here

% tree states
EMPTY       = 0;
TREE        = 1;
BURNING     = 2;
BURNED      = 3;

[m, n] = size(world);
coor = zeros(1, 2);
new_world = world;
for i = 1:n_fires
    while 1
        coor = ceil(rand(1, 2) .* [m n]);
        if world(coor(1), coor(2)) == TREE
            break
        end
    end
    new_world(coor(1), coor(2)) = BURNING;
end
end

