function new_world_tree = forest_create(size_x, size_y, density)
new_world_tree = ones(size_x, size_y).*double(rand(size_x, size_y) < density);
end

