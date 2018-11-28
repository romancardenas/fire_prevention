function n_world_sensor = main_sensor_step(world_sensor, world_temp)
%SENSOR_STEP Summary of this function goes here
%   Detailed explanation goes here
% update temperature for sensors

[m, n] = size(world_sensor);
n_world_sensor = world_sensor;
range = world_sensor{1,1}.getRange() ;
dim = size(world_temp ) ;
for row = 1:m
    for col = 1:n 
        Xsens = world_sensor{row,col}.X ;
        Ysens = world_sensor{row,col}.Y ;
        b = [Xsens-range , Xsens+range , Ysens-range , Ysens+range ] ;
        if b(1) < 1  
            b(1) = 1 ;
        end     % y is row
        if b(3) < 1 
            b(3) = 1 ;
        end 
        if b(2) > dim(2)
            b(2) = dim(2) ;
        end 
        if b(4) > dim(1)
            b(4) = dim(1) ;
        end 
        n_world_sensor{row, col}.updateForestState(world_temp(b(3):b(4),b(1):b(2)), ...
        world_temp(Ysens,Xsens)) ; % Sample and Process
    end
end
end
