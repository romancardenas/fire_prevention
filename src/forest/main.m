% world size
sz = [150 150];

% tree states
EMPTY       = 0;
TREE        = 1;
BURNING     = 2;
BURNED      = 3;
% idle temperature
IDLE_TEMP   = 24;

% For plotting the forest
map_forest = [ 0    0   0.6;
               0    0.8 0;
               1.0  0   0;
               0    0   0];



% world starts with trees and at the standard temperature everywhere
world_tree = forest_create(sz(1), sz(2), 0.9);
world_temp = ones(sz(1), sz(2)) * IDLE_TEMP;

% we set a single tree in fire
world_tree = fire_start(world_tree);
% iterate for 1440 time steps
for i=1:250
    world_temp = temperature_step(world_temp, world_tree, 2);
    world_tree =fire_step(world_tree);
    
    % view the tree world
    ax1 = subplot(1,2,1);
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
    ax2 = subplot(1,2,2);
    imagesc(world_temp);
    title(ax2, 'forest temperature')
    caxis(ax2, [0 400]);
    colormap(gca, jet(64));
    cbh2 = colorbar;
    title(cbh2, 'temperature[ºC]')
    drawnow;
end