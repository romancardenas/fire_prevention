
function new_world = fire_step_spark(world)
%FIRE_STEP_SPARK Summary of this function goes here
%   Detailed explanation goes here

% probabilities
spark       = 0.0001; % tree -> fire (spontaneous)
extend_fire = 0.1; % tree -> fire (due to neighbours)
stop_fire   = 0.01; % fire -> empty (no more wood to get burned)

% tree states
EMPTY       = 0;
TREE        = 1;
BURNING     = 2;

[m, n] = size(world);

% count burning neighbors. tileworld gives boundaries for 2d convolution
tileworld = [world(1, 1)  world(1, :)  world(1, n); 
             world(:, 1)  world        world(:, n); 
             world(m, 1)  world(m, :)  world(m, n)];
nconv = conv2(double(tileworld==BURNING),[1 1 1; 1 0 1; 1 1 1],'same');
neighbors = nconv(2:end-1,2:end-1);
% trees with burning neighbors may start burning
toburn = double(world==TREE).*double(neighbors>0).*double(rand(m, n)<extend_fire);

% some trees may start burning due to a spark
lightning = double(world==TREE).*double(rand(m,n) < spark);

% trees stay trees, and those that are burning get added on to get value 2.
trees = double(world==TREE) + double(toburn + lightning > 0);
trees = trees + double(world==BURNING) * BURNING;

% empty spaces are in previous empty spaces and fires that estinguishes
toempty = double(world==EMPTY) + double(world==BURNING).*double(rand(m,n)<stop_fire);
% toempty = double(world==EMPTY);

% the world is composed by trees (burning and not) and emptiness
new_world = (double(toempty == 0) .* trees);
end

