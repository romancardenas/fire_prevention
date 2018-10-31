function new_world = fire_start(world)
%FIRE_SPARK Summary of this function goes here
%   Detailed explanation goes here

% tree states
EMPTY       = 0;
TREE        = 1;
BURNING     = 2;
BURNED      = 3;

[m, n] = size(world);
coor = zeros(1, 2);
while 1
    coor = round(rand(1, 2) .* [m n]);
    if world(coor(1), coor(2)) == TREE
        break
    end
end
new_world = world;
new_world(coor(1), coor(2)) = BURNING;
end

