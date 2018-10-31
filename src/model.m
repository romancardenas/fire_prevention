base_temp = 24 ; % in degress
t = 0 ; 
n = 100 ; % size of n*n model
max_temp = 1400 ; 
flashpoint = 590 ; % temperature at which a fire start
neighbour_absorb_rate = 0.8 ;
heat_gain = 1.4 ;
act_buffer = 1 ; % we operate with a dual buffer
pre_buffer = 1 ;
run_time = 800 ;

% create 3D buffer with zero padding, set temp to base_temp
buffer(:,:,1) = ones(n+2,n+2)*base_temp ;
buffer(:,:,2) = ones(n+2,n+2)*base_temp ;

% at time 0 we start a fire randomly

row = uint32(n*rand()) ; col = uint32(n*rand()) ;

fire = [row,col] ;

buffer(row,col,act_buffer) = flashpoint ;

act_buffer = 2 ;
% now we start
figure('pos',[10 10 2000 850]) 
while t < run_time 
    t = t+1 ;
    for row = 2:(n+1) 
        for col = 2:(n+1)
            mean_temp = sum(buffer((row-1):(row+1),(col-1):(col+1),pre_buffer)) ;
            mean_temp = (sum(mean_temp(:)) - buffer(row,col,pre_buffer)) / 8 ;
            prev_temp = buffer(row,col,pre_buffer) ;
            temp = tree(mean_temp,prev_temp,flashpoint,heat_gain,neighbour_absorb_rate,max_temp);
            buffer(row,col,act_buffer) = temp ;
       end
    end 
    
    % display buffer (create image) 
    heatmap(buffer(:,:,act_buffer)) ;
    title(t)
    % change active buffer
    if act_buffer == 1 
        act_buffer = 2 ;
        pre_buffer = 1 ;
    else 
        act_buffer = 1 ;
        pre_buffer = 2 ;
    end
    %disp(t)
    pause(0.05);
end

function temp = tree(neighbour_temp,own_temp,flashpoint,heat_gain,neighbour_absorb_rate,max_temp)

    if own_temp >= flashpoint 
        temp = own_temp * heat_gain ;
    else 
        temp = own_temp + ((neighbour_temp - own_temp)* neighbour_absorb_rate ) ;
    end
    
    if temp > max_temp
        temp = max_temp ; 
    end 

end
