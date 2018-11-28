function world_sensor = main_sensors_create(world_size, n_sensors, base_temp, ...
    batt_capacity, sampling, send, listen, mand_window)
%SENSOR_CREATE Creates initial sensor scenario
%   world_size: tuple containing the number of tiles (m, n)
%   n_sensors: tuple containing the number of sensors per column and row (col_sensors, row_sensors)
%   base_temp: initial temperature for all the sensors (celsius)
%   batt_capacity: maximum battery capacity for each sensor (mAh)
%   sampling: sampling cost (mAh)
%   send: send cost (mAh)
%   listen: listen cost (mAh)
%   mand_window: mandatory window size (minutes)
m = world_size(1);
n = world_size(2);
col_sensors = n_sensors(1);
row_sensors = n_sensors(2);

% col_sensors = fix(sqrt(n_sensors));
% row_sensors = fixcol_sensors - mod(col_sensors, 2);
% row_sensors = fix(n_sensors/col_sensors) + mod(n_sensors, col_sensors);
% create sensor array 
y_first = m/col_sensors/2;
x_first = n/row_sensors/2;
Ysensor = double(int16(linspace(y_first, m-y_first, col_sensors))); % row 
Xsensor = double(int16(linspace(x_first, n-x_first, row_sensors))); % col

world_sensor = cell(col_sensors, row_sensors) ;
for row = 1:col_sensors
    for col = 1:row_sensors
        world_sensor{row,col} = sensorNode(Ysensor(row),Xsensor(col), base_temp,batt_capacity, sampling, send, listen, mand_window);
    end 
end
end

