
function new_world = fire_step(world, extend_fire, stop_fire)
%FIRE_STEP Summary of this function goes here
%   Detailed explanation goes here

% tree states
EMPTY       = 0;
TREE        = 1;
BURNING     = 2;
BURNED      = 3;

[m, n] = size(world);

% count burning neighbors. tileworld gives boundaries for 2d convolution
tileworld = [world(1, 1)  world(1, :)  world(1, n); 
             world(:, 1)  world        world(:, n); 
             world(m, 1)  world(m, :)  world(m, n)];
nconv = conv2(double(tileworld==BURNING),[1 1 1; 1 0 1; 1 1 1],'same');
neighbors = nconv(2:end-1,2:end-1);
% trees with burning neighbors may start burning
toburn = double(world==TREE).*double(neighbors>0).*double(rand(m, n)<extend_fire);

% trees that are burning may get completely burned
toburned = double(world==BURNING).*double(rand(m,n)<stop_fire);

% trees stay trees, and those that starts burning get added on to get value 2.
trees = double(world==TREE) + double(toburn > 0);

% burning trees stay burning, and those that stops get added on to get value 3
burning = double(world==BURNING)*BURNING + double(toburned>0);

% empty spaces are in previous empty spaces
empty = double(world==EMPTY);
% toempty = double(world==EMPTY);

% the world is composed by trees (burning and not) and emptiness
new_world = double(empty == 0) .* (trees + burning + double(world==BURNED)*BURNED);
end

