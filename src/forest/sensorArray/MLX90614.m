classdef MLX90614 < handle
    %HDC2010YPAR class is a representation of the MLX90614 temp sensor
    % in this class the idea is that there are 4 sensor, one in each 
    % direction
    properties (Access = public)
        ownTemp
    end 
    
    properties (Constant)
        Terror = 0.5 
        price = 384  
    end
    
    properties (Access = public ) 
        range
        temp 
    end
    methods
        function self = MLX90614(temp, range)
            self.temp = temp ; 
            self.range = range;
            self.ownTemp = temp ;
        end
        function getTemp(self, Tmatrix, Tself)
            % simulates a measurement
            maxtemp = max(Tmatrix(:)) ;
            error = rand() - 0.5 ; % we offset the return of rand(0-1) 
            x = 0.5 / self.Terror ; %scaling factor
            error = error / x ; % scaling of error
            self.temp = maxtemp + error ;
            % update own temp
            self.ownTemp = Tself ;
        end 
    end
    
end

