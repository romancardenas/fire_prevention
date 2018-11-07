classdef sensorNetwork < handle
    %SENSORNETWORK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        state % ALIVE = 1 or DEAD = 0 
        X 
        Y 
        baseTemp
        price
    end
    
    properties (Access = public) % sensor's connected
        tempHumdSensor
    end
    
    properties (Dependent)
        forestState
    end
    
    methods
        function self = sensorNetwork(Y,X,Temp) % constructor
            self.state = 1 ; % alive
            self.X = X ;
            self.Y = Y ;
            self.baseTemp = Temp ;
            % create instance of temp sensor
            self.tempHumdSensor = HDC2010YPAR(Temp) ;
        end
        function update(self,Temp)
            self.tempHumdSensor.getTemp(Temp);
        end
        function cost(self) % cost of device
            self.price = self.tempHumdSensor.price ;
        end
        function val = get.forestState(self) % get function, invoked before forestState is read
            temp = self.tempHumdSensor.temp ;
            if temp > 110  
                tempState = 3 ; % forest is definently burning   
            elseif temp > 80
                tempState = 2 ; % temperature is very high
            elseif temp > (self.baseTemp + 5 )
                tempState = 1 ; % temperature is rising
            else 
                tempState = 0 ; % everything is fine    
            end
            val = tempState ;
        end
    end
    
end

