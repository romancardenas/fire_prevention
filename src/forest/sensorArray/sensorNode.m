classdef sensorNode < handle
    
    properties (Access = private) % only access if sensor is alive
        battery 
        state % ALIVE = 1 or DEAD = 0 
        % sensor's connected
        tempSensor
    end
    
    properties (Access = public) % things we know about the sensor
        X 
        Y 
        baseTemp
        price
        SamplingCost
        SendingCost
        ListenCost
        ResendCost
        end
    
    properties (Constant)
        minBatPow = 10 % minimum battery power
        maxWorkT = 125 % maximum working temperature
    end
    
    properties (Dependent)
        forestState
    end
    
    
    methods
        function self = sensorNode(Y,X,Temp,BattCap,SamplingCost, ...
            SendingCost,ListenCost,ResendCost) % constructor
            self.state = 1 ; % alive
            self.X = X ;
            self.Y = Y ;
            self.baseTemp = Temp ;
            % create instance of temp sensor
            self.tempSensor = HDC2010YPAR(Temp) ;
            % get price of sensor network
            self.price = self.tempSensor.price + 300 ; % 300 is random
            % set battery vars
            self.battery = BattCap ; 
            self.SamplingCost = SamplingCost ; self.SendingCost = SendingCost ;
            self.ListenCost = ListenCost ; self.ResendCost = ResendCost ;
        end
        
        function update(self,Temp)
            % update all sensor variables based on sensor data
            if self.state == 1 
            self.tempSensor.getTemp(Temp);
            samp = double(self.SamplingCost) ;
            self.updateBatteryPow(samp) % sampling
            end
        end
        
        function updateState(self)
            % check if the state should be alive
            % if temperature > maxWorkT
            temp = self.tempSensor.temp ;
            if temp > self.maxWorkT 
                self.state = 0 ;
            end
            % if battery < minBatPow
            if self.battery < self.minBatPow
                self.state = 0 ;
            end
            % random change for failure(not implemented)
        end
        
        function updateBatteryPow(self,powCons)
            self.battery = self.battery - powCons ;
            self.updateState() ;
        end
        
        function temp = sendSensorData(self)
            % ouptut all data from sensors
            if self.state == 1 
                temp = self.tempSensor.temp ;
                self.updateBatteryPow(self.SendingCost) % send data
            else 
                temp = 0 ;
            end
        end 
        
        function val = get.forestState(self) % get function, invoked before forestState is read
            if self.state == 1 
                    temp = self.tempSensor.temp ;
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
            else 
                val = 0 ;
            end
        end
    end
end

