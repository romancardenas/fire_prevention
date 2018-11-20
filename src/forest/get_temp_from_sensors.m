function temp_sensors = get_temp_from_sensors(world_sensor)
[m, n] = size(world_sensor);
temp_sensors = zeros(m, n);
%GET_TEMP_FROM_SENSORS Summary of this function goes here
%   Detailed explanation goes here
for i = 1:m
    for j = 1:n
        temp_sensors(i, j) = world_sensor{i, j}.sendSensorData();
    end
end
end

