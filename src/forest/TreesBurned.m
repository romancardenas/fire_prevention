function burned_trees = TreesBurned(world_tree)
%Burned Trees Summary of this function goes here
%   Detailed explanation goes here
% tree states
EMPTY       = 0;
TREE        = 1;
BURNING     = 2;
BURNED      = 3;
burned_trees = 0;

[m, n] = size(world_tree);


for x = 1:m
    for y = 1:n
        if world_tree(x, y) == BURNED
            burned_trees = burned_trees + 1; 
        end    
    end
end
end

