classdef sensorNode < handle
    
    properties (Access = private) % only access if sensor is alive
        battery 
        forestStatePrev
        % sensor's connected
        tempSensor
    end
    
    properties (Access = public) % things we know about the sensor
        X 
        Y 
        baseTemp
        price
        forestState
        SamplingCost
        SendingCost
        ListenCost
        ResendCost
        manWindow
        state % ALIVE = 1 or DEAD = 0
        end
    
    properties (Constant)
        minBatPow = 10 % minimum battery power
        maxWorkT = 125 % maximum working temperature
    end
    
    methods
        function self = sensorNode(Y,X,Temp,BattCap,SamplingCost,SendingCost,ListenCost, manWindow) % constructor
            self.state = 1 ; % alive
            self.X = X ;
            self.Y = Y ;
            self.baseTemp = Temp ;
            % create instance of temp sensor
            self.tempSensor = MLX90614(Temp) ;
            % get price of sensor network
            self.price = self.tempSensor.price + 300 ; % 300 is random
            % set battery vars
            self.battery = BattCap ; 
            self.SamplingCost = SamplingCost ; 
            self.SendingCost = SendingCost ;
            self.ListenCost = ListenCost ;
            self.manWindow = manWindow ;
            self.forestState = 0;
            self.forestStatePrev = self.forestState ;
        end
        function range = getRange(self)
            range = self.tempSensor.range ;
        end        
        function updateTemp(self,Temp,Tcenter)
            % update all sensor variables based on sensor data
            self.tempSensor.getTemp(Temp,Tcenter);
        end
        
        function status = somethingToSay(self,tick)
            if self.state == 1
                if (mod(tick, self.manWindow) == 0)
                    status = -1;
                elseif (self.forestState ~= self.forestStatePrev)
                    status = -1 ;
                else
                    status = 0 ;
                end
            else
                status = 0 ;
            end
        end
    
        function updateState(self)
            % check if the state should be alive
            % if temperature > maxWorkT
            temp = self.tempSensor.ownTemp ;
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
        
        function temp = getSensorData(self)
            % ouptut all data from sensors
            temp = self.tempSensor.temp ;
        end 
        
        function updateForestState(self, temp,Tcenter)
            if self.state == 1
                self.updateTemp(temp,Tcenter);
                self.updateState();
            end
            if self.state == 1 
                temp = self.tempSensor.temp ;
                self.forestStatePrev = self.forestState;  % Previous state is inherited
                if temp > 70  
                	tempState = 3 ; % forest is definently burning   
                elseif temp > 50
                	tempState = 2 ; % temperature is very high
                elseif temp > (self.baseTemp + 5 )
                	tempState = 1 ; % temperature is rising
                else 
                	tempState = 0 ; % everything is fine    
                end
                self.forestState = tempState; % forest State is different
                self.updateBatteryPow(self.SamplingCost); % Cost of sampling
            else
                self.forestState = -1;
            end
        end
        
        function val = getForestState(self) % get function, invoked before forestState is read
            if self.state == 1 
                val = self.forestState;
            else 
                val = -1 ;
            end
        end
        
        function send(self)
            self.updateBatteryPow(self.SendingCost) ;
        end 
        
        function listen(self)
            self.updateBatteryPow(self.ListenCost) ;
        end 
        
    end
end

