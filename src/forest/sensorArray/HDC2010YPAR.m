classdef HDC2010YPAR < handle
    %HDC2010YPAR class is a representation of the HDC2010YPAR temp and 
    % humidty sensor 
    % https://www.digikey.dk/product-detail/en/texas-instruments/HDC2010YPAR/296-47774-2-ND/7561364
    
    properties (Constant)
        Terror = 0.2 
        Herror = 2  
        price = 8.27  % based on digikey price: unit price with bulk purchase of 3000 units
    end
    
    properties (Access = public ) 
        temp 
    end
    
    methods
        function self = HDC2010YPAR(temp)
            self.temp = temp ; 
        end
        function getTemp(self, tact)
            % simulates a measurement
            error = rand() - 0.5 ; % we offset the return of rand(0-1) 
            x = 0.5 / self.Terror ; %scaling factor
            error = error / x ; % scaling of error
            self.temp = tact + error ;
        end 
    end
    
end

