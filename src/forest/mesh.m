function fucked_up_thing = mesh(world_sensors, max_jumps)
%MESH Summary of this function goes here
%   Detailed explanation goes here
% 1. if they want to send something, change knowlede
[m, n] = size(world_sensors);
fucked_up_thing = zeros(m, n, 3, m, n);

MAILBOX = 1;
KNOWLEDGE = 2;
TOSEND = 3;

for i = 1:m
    for j = 1:n
        if world_sensors(i, j) ~= 0
        %if world_sensors(i, j).somethingToSay ~= 0
            fucked_up_thing(i, j, TOSEND, i, j) = world_sensors(i, j);
            %fucked_up_thing(i, j, TOSEND) = world_sensors(i, j).getTemp();
        end
    end
end
fucked_up_thing(:, :, KNOWLEDGE, :, :) = fucked_up_thing(:, :, TOSEND, :, :);
%% TODO the original sensor forgets its value!!!
for step = 1:max_jumps
    % to send
    for i = 1:m
        for j = 1:n
            if sum(sum(fucked_up_thing(i, j, TOSEND, i, j))) ~= 0
                msg = fucked_up_thing(:, :, TOSEND, i, j);
                %world_sensors(i, j).send()  % reduce battery
                for k = -1:1
                    row = i + k;
                    if (row > 0) || (row <= m)
                        for l = -1:1
                            col = j + l;
                            if (col > 0) || (col <= n) || (row ~= i && col ~= j)
                                % TODO avoid auto erasing
                                mailbox = fucked_up_thing(:, :, MAILBOX, row, col);
                                fucked_up_thing(:, :, MAILBOX, row, col) = double(mailbox == 0) .* msg + mailbox;
                            end
                        end
                    end
                end
            end
        end
    end
    %read mailbox and prepare to send
    for i = 1:m
        for j = 1:n
            mailbox = fucked_up_thing(:, :, MAILBOX, i, j);
            knowledge = fucked_up_thing(:, :, KNOWLEDGE, i, j);
            
            tosend = double(knowledge == 0).*mailbox;
            knowledge = tosend + knowledge .* double(mailbox==0);
            
            fucked_up_thing(:, :, TOSEND, i, j) = tosend;
            fucked_up_thing(:, :, KNOWLEDGE, i, j) = knowledge;
        end
    end
    fucked_up_thing(:, :, MAILBOX, :, :) = 0;
end
end

