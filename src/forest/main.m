% reset
close all ; clear ; clc ;

% simulation parameters
SZ = [150 150];  % world size
IDLE_TEMP   = 24;  % idle temperature
FOREST_DENSITY = 0.9;  % initial forest density
N_FIRES = 2;  % Number of fire
T_FIRE  = 30;  % temperature to be increased due to fire
T_BURNED = 2;  % temperature to be decreased due to burned area
% probabilities
P_EXTEND_FIRE = 0.1; % tree -> fire (due to neighbours)
P_STOP_FIRE   = 0.05; % fire -> empty (no more wood to get burned)

% tree states
EMPTY       = 0;
TREE        = 1;
BURNING     = 2;
BURNED      = 3;

% For plotting the forest
map_forest = [ 0    0   0.6;
               0    0.8 0;
               1.0  0   0;
               0    0   0];

%For plotting trees burned
X = zeros;
Y = zeros;

% world starts with trees and at the standard temperature everywhere
world_tree = forest_create(SZ(1), SZ(2), FOREST_DENSITY);
world_tree = fire_start(world_tree, N_FIRES);
world_temp = ones(SZ(1), SZ(2)) * IDLE_TEMP;
% iterate for 1440 time steps
for i=1:250
    world_temp = temperature_step(world_temp, world_tree, T_FIRE, T_BURNED, IDLE_TEMP);
    world_tree =fire_step(world_tree, P_EXTEND_FIRE, P_STOP_FIRE);
    X(i)= TreesBurned(world_tree);
    Y(i) =i;
    
    % view the tree world
    ax1 = subplot(1,3,1);
    imagesc(world_tree);
    title(ax1, 'forest state')
    % keep colors ranging from 0 to 3
    caxis(ax1, [0 3]);
    colormap(gca, map_forest);
    cbh1 = colorbar ; %Create Colorbar
    cbh1.Ticks = 0.3750:0.75:4 ;
    cbh1.TickLabels = {'empty', 'tree', 'fire', 'burned'} ;
    title(cbh1, 'state')
    
    % view the temperature world
    ax2 = subplot(1,3,2);
    imagesc(world_temp);
    title(ax2, 'forest temperature')
    caxis(ax2, [0 400]);
    colormap(gca, jet(64));
    cbh2 = colorbar;
    title(cbh2, 'temperature[ºC]')
    
    % graph of the number burned trees
    ax3 = subplot(1,3,3);
    title(ax3, 'trees burned')
    axis([0 250 0 8000]);
    plot(Y,X);hold on
    xlabel('ticks');
    ylabel('Trees burned');
    
    drawnow;
end