function report = mesh(world_sensors, range, max_jumps, tick)
%MESH Summary of this function goes here
%   Detailed explanation goes here
% 1. if they want to send something, change knowlede
[m, n] = size(world_sensors);
fucked_up_thing = zeros(m, n, 3, m, n);
report = zeros(m, n);

MAILBOX = 1;
KNOWLEDGE = 2;
TOSEND = 3;

% If a sensor has something to say, it copies it to its own TOSEND table
a = 1;
for i = 1:m
    for j = 1:n
        world_sensors{i, j}.listen()
        if world_sensors{i, j}.somethingToSay(tick) ~= 0
            if a == 1
                a = 0;
            end
            %fucked_up_thing(i, j, TOSEND, i, j) = world_sensors(i, j);
            a = world_sensors{i, j}.getSensorData();
            fucked_up_thing(i, j, KNOWLEDGE, i, j) = a;
            fucked_up_thing(i, j, TOSEND, i, j) = a;
        end
    end
end

% Communication protocol takes place as far as the protocol steps allow it
for step = 1:max_jumps
    % Sensors copy their TOSEND table to the MAILBOX table of their neighbors
    for i = 1:m
        for j = 1:n
            if sum(sum(fucked_up_thing(:, :, TOSEND, i, j))) == 0
                continue
            end
            msg = fucked_up_thing(:, :, TOSEND, i, j);
            world_sensors{i, j}.send()  % reduce battery
            for k = -range:range
                row = i + k;
                if (row < 1) || (row > m)
                    continue
                end
                for l = -range:range
                    col = j + l;
                    if (col < 1) || (col > n)
                        continue
                    end
                    mailbox = fucked_up_thing(:, :, MAILBOX, row, col);
                    fucked_up_thing(:, :, MAILBOX, row, col) = double(mailbox == 0) .* msg + mailbox;
                end
            end
        end
    end
    
    % Each sensor copies new info in MAILBOX table to KNOWLEDGE and TOSEND tables
    mailbox = fucked_up_thing(:, :, MAILBOX, :, :);
    knowledge = fucked_up_thing(:, :, KNOWLEDGE, :, :);
    tosend = double(knowledge == 0) .* mailbox;
    knowledge = tosend + knowledge;
    fucked_up_thing(:, :, TOSEND, :, :) = tosend;
    fucked_up_thing(:, :, KNOWLEDGE, :, :) = knowledge;
    fucked_up_thing(:, :, MAILBOX, :, :) = 0;
    
    % Ensure that dead sensors don't participate in communication
    for i = 1:m
        for j = 1:n
            if world_sensors{i, j}.state == 0
                fucked_up_thing(:, :, TOSEND, i, j) = 0;
                fucked_up_thing(:, :, KNOWLEDGE, i, j) = 0;
            end
        end
    end
end

% Check the edges of the scenario in order to find the information that made it to the gateways
i = 1;
for j = 1:n
    report = double(report == 0).*fucked_up_thing(:, :, KNOWLEDGE, i, j) + report;
end
j = n;
for i = 1:m
    report = double(report == 0).*fucked_up_thing(:, :, KNOWLEDGE, i, j) + report;
end
i = m;
for j = n:-1:1
    report = double(report == 0).*fucked_up_thing(:, :, KNOWLEDGE, i, j) + report;
end
j = 1;
for i = m:-1:1
    report = double(report == 0).*fucked_up_thing(:, :, KNOWLEDGE, i, j) + report;
end
end
