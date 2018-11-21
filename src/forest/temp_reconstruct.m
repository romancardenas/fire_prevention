function [rec_world_temp, new_sensor_temp] = temp_reconstruct(new_sensors, prev_sensors, m, n)
%TEMP_RECONSTRUCT Reconstruct scenario temperature based on sensors
%   sensor_temp_world: reduced scenario with only sensor data
%   m: real scenario width
%   n: real scenario height
%   the reconstruction algorithm that is used is discrete cosine transform

% TODO comparing previous data and new one to create the previous
new_sensor_temp = double(new_sensors == 0).* prev_sensors + new_sensors;
rec_world_temp = resize(new_sensor_temp, [m n]);
end

