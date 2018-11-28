function n_world_sensor = main_sensor_step(world_sensor, world_temp)
%SENSOR_STEP Summary of this function goes here
%   Detailed explanation goes here
% update temperature for sensors

[m, n] = size(world_sensor);
n_world_sensor = world_sensor;
for row = 1:m
    for col = 1:n 
        Xsens = world_sensor{row,col}.X ;
        Ysens = world_sensor{row,col}.Y ;
        n_world_sensor{row,col}.updateForestState(world_temp(Ysens,Xsens)) ;
    end
end
end
