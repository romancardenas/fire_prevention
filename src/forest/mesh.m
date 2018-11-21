function fucked_up_thing = mesh(world_sensors, range, max_jumps, tick)
%MESH Summary of this function goes here
%   Detailed explanation goes here
% 1. if they want to send something, change knowlede
[m, n] = size(world_sensors);
fucked_up_thing = zeros(m, n, 3, m, n);

MAILBOX = 1;
KNOWLEDGE = 2;
TOSEND = 3;

% If a sensor has something to say, it copies it to its own TOSEND table
for i = 1:m
    for j = 1:n
        if world_sensors(i, j) ~= 0
        %if world_sensors(i, j).somethingToSay ~= 0
            fucked_up_thing(i, j, TOSEND, i, j) = world_sensors(i, j);
            %fucked_up_thing(i, j, TOSEND) = world_sensors(i, j).getTemp(tick);
        end
    end
end
% Initially, the KNOWLEDGE table is the same as the TOSEND table
fucked_up_thing(:, :, KNOWLEDGE, :, :) = fucked_up_thing(:, :, TOSEND, :, :);

% Communication protocol takes place as far as the protocol steps allow it
for step = 1:max_jumps
    % Sensors copy their TOSEND table to the MAILBOX table of their neighbors
    for i = 1:m
        for j = 1:n
            if sum(sum(fucked_up_thing(:, :, TOSEND, i, j))) == 0
                continue
            end
            msg = fucked_up_thing(:, :, TOSEND, i, j);
            %world_sensors(i, j).send()  % reduce battery
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
end
%% TODO Check the information in the edges and return all the messages that made it
end
