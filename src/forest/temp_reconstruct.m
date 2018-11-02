function rec_world_temp = temp_reconstruct(sensor_temp_world,m, n)
%TEMP_RECONSTRUCT Reconstruct scenario temperature based on sensors
%   sensor_temp_world: reduced scenario with only sensor data
%   m: real scenario width
%   n: real scenario height
%   the reconstruction algorithm that is used is discrete cosine transform
rec_world_temp = resize(sensor_temp_world, [m n]);
end

