clear

S = 8000; % Number Of Ants In Colony 2
N = 1000; %Number Of Ants In Colony 1
M = 50;

food_found = 0; %0: Ant ~ Forager (Still Finding Food Source), 1: Ant ~ Returner (Found Food; Heading Back To Nest)

change_ant_position = 0.001; %The Weighted Difference If Difference In Pheromone Concentration Is Less Than 0 (du < 0 or dr < 0)
delta = 1; %Spatial Step
dt = 0.01; %Temporal Step

%Pheromone Matrix Initial Condition; Boundaries Therefore Occur At 1 And M
U = zeros(M,M); %Pheromone Matrix For Ant Colony 1
W = zeros(M,M); %Pheromone Matrix For Ant Colony 2

gamma = 2; %Degradation Coefficient
D = 10; %Diffusion Coefficient

t = 0; % Start time
T = 20; %Final Time
tt = 0; %Time - Pheromone Diffusion-Reaction

% B_Scalar1 = 0; %Strength Of Pheromone;
% B_Scalar2 = 0; %Strength Of Pheromone;

B_ScalarValues = [0,1,10,100,1000]; %Beta Values For Colony 1 

foodSourceXPos = 20; %X Pos Of Food Source
foodSourceYPos = 20; %Y Pos Of Food Source

nestPositions = 12:1:22; %Different Nest Sites For Colony 1 
excludefoodSourcePositions = [foodSourceXPos, 40]; %Exclude These Sites When Changing Nest Sites For Colony 1 
chosenfoodSourcePositions = ~ismember(nestPositions, excludefoodSourcePositions); %Choosing Nest Sites For Colony 1
finalNestPositions = nestPositions(chosenfoodSourcePositions); %Determined Nest Sites For Colony 1 


NumSimulations = 10; %Number Of Simulations
Colony1FormedTrail = zeros(1, NumSimulations); %Trails Formed From Ant Colony 1 Nest To Each Food (Array - For Each Simulation)
Colony2FormedTrail = zeros(1, NumSimulations); %Trails Formed From Ant Colony 2 Nest To Each Food (Array - For Each Simulation)

distance = 0;  %Distance Between Colony 1's Nest And Food Source
distance2 = 0; %Distance Between Colony 2's Nest And Food Source


stdErrorBarValuesProbability = zeros(1, length(finalNestPositions));


ProbJustColony1 = zeros(length(finalNestPositions),1); %Probability Of ONLY Colony 1 Forming A Trail 
ProbCColony1 = zeros(length(finalNestPositions),1); %Probability Of Colony 1 Forming A Trail
DistanceRatio = zeros(1, length(finalNestPositions)); %Ratio Between Colony 1's Distance And Colony 2's Distance 


for bScalar = 1: length(B_ScalarValues) %Beta Value Changes For Colony 1 

    B_Scalar1 = B_ScalarValues(bScalar); %Strength Of Pheromone
    B_Scalar2 = 55; %Strength Of Pheromone

    for jk = 1: length(finalNestPositions) %Colony 1's Nest Changes 

        nestXPos = finalNestPositions(jk); %Nest X Pos Of Ant Colony 1
        nestYPos = nestXPos; %Nest Y Pos Of Ant Colony 1


        nestX2Pos = 25; %Nest X Pos Of Ant Colony 2
        nestY2Pos = 25; %Nest Y Pos Of Ant Colony 2


        distance2 = sqrt((nestX2Pos - foodSourceXPos)^2 + (nestY2Pos - foodSourceYPos)^2); %distance between colony 2's nest and food source
        distance = sqrt((nestXPos - foodSourceXPos)^2 + (nestYPos - foodSourceYPos)^2); %distance between colony 1's nest and food source
        DistanceRatio(jk) = distance/distance2; %ratio between distance 1 and distance 2


        for nn = 1: NumSimulations %Total Number Of Simulations

            A = zeros(M,M); %Matrix -> Foragers
            A(nestXPos,nestYPos) = N; %Position Of Ants In Colony 1
            A(nestX2Pos,nestY2Pos) = S;   %Position of Ants In Colony 2


            v = [nestXPos - foodSourceXPos, nestYPos - foodSourceYPos]; %Distance Between Nest And Food Source For Ant Colony 1
            z = [nestX2Pos - foodSourceXPos, nestY2Pos - foodSourceYPos]; %Distance Between Nest And Food S ource For Ant Colony 2


            m = norm(v); %Magnitude For Ant Colony 1
            k = norm(z); %Magnitude For Ant Colony 2


            u = v/m;     %Unit Vector For Ant Colony 1
            uu = z/k;     %Unit Vector For Ant Colony 2


            t = 0;  %Time ~ Corresponding To Total Simulation Time
            tt = 0; %Time ~ Corresponding To Pheromone Concentration Diffusion-Reaction Rate


            du = zeros(8,1); %Stores The Difference In Pheromone Concentration Between Ant's Current Position And The Position(s) It Can Move To (Ant Colony 1)
            dr = zeros(8,1); %Stores The Difference In Pheromone Concentration Between Ant's Current Position And The Position(s) It Can Move To (Ant Colony 2)


            weight1 = zeros(8,1); %Stores The Weighted Difference In Pheromone Concentration For Each Ant In Colony 1
            weight2 = zeros(8,1); %Stores The Weighted Difference In Pheromone Concentration For Each Ant In Colony 2
            %Positioning Each Ant In Colony 1 At Nest


            food_found = 0;


            U = zeros(M,M); %Pheromone Matrix For Ant Colony 1
            W = zeros(M,M); %Pheromone Matrix For Ant Colony 2


            J = 0; %Number Of Returners From Colony 1 Set To 0 Once Food Source Is Moved To A Different Site On 50 by 50 Matrix
            Q = 0; %Number Of Returners From Colony 2 Set To 0 Once Food Source Is Moved To A Different Site On 50 by 50 Matrix


            ant_position = zeros(N,3);
            ant1_position = zeros(S,3);


            %Positioning Each Ant In Colony 1 At Nest
            for j = 1:N
                ant_position(j,1) = nestXPos;%Nest X Pos Ant Colony 1
                ant_position(j,2) = nestYPos;%Nest Y Pos Ant Colony 1
                ant_position(j,3) = 0;  %Each Ant Starts As Forager
            end


            %Positioning Each Ant In Colony 2 At Nest
            for l = 1:S
                ant1_position(l,1) = nestX2Pos;%Nest X Pos Ant Colony 2
                ant1_position(l,2) = nestY2Pos;%Nest Y Pos Ant Colony 2
                ant1_position(l,3) = 0; %Each Ant Starts As Forager
            end



            while (t < T) %Ants Forage For Food Until Final Time Is Reached 

                % Same Process For Colonies 1 And 2
                % *** Choose A Random Ant
                % *** Check Ant's Position And If Ant Is On Boundary
                % *** Calculate Difference In Pheromone Concentration Between Ant's Current Position And Position It Can Move To (du)
                % *** Calculate The Weighted Difference In Concentration
                % For Each du (8 Of Them ~ 8 Total Possible Directions), Factoring In The Weighted Different In Concentration For Ant Colony 2
                % *** Sum The Total Weighted Difference
                % *** Calculate The Probability Of The Ant Moving In Each Of The 8 Directions ~ Weight/TotalWeight
                % *** Check If Ant Is Forager (0) And Use Probability To Determine Which Direction Ant Can Move In
                % *** If Ant Is Forager (0), Assign Ant A Random Position With Respect To Boundary Conditions - AKA Unbiased Random Walk
                % *** Calculate The Distance Between Ant's New Position And The Location Of The Food Source
                % *** If Distance < 0, Then Ant Has Found Food Source And Is Classified As A Returner (1), Instead Of As a Forager (0)
                % *** If Ant Is Returner (1), Then Ant's Position Changes As Unit Vector Is Added To Ant's Current Position To Shift It's Movement Towards Nest
                % *** Distance Between Ant's Position And Nest Is Calculated
                % *** If Distance < 1, Ant's Position Is Set To Nest Position; Ant Is Classified As A Forager Again (0)

                for j = 1:N %N Ant Movements
                    R = randi([1,N]); % Choosing A Random Ant
                    current_location = round(ant_position(R,1:2)); % Obtain Ant's Current Position
                    du = ones(8,1);

                    %Calculate Difference In Pheromone Concentration Between Ant's Current Possition & All Possible Directions It Can Move In (Based On Ant's Current Position)
                    if (current_location(1)~=1 && current_location(1)~=M && current_location(2)~=1 && current_location(2)~=M) %Ant Is Not Located At Boundary
                        du(1) = U(current_location(1)+1,current_location(2)) - U(current_location(1),current_location(2));
                        du(2) = U(current_location(1)+1,current_location(2)+1) - U(current_location(1),current_location(2));
                        du(3) = U(current_location(1),current_location(2)+1) - U(current_location(1),current_location(2));
                        du(4) = U(current_location(1)-1,current_location(2)+1) - U(current_location(1),current_location(2));
                        du(5) = U(current_location(1)-1,current_location(2)) - U(current_location(1),current_location(2));
                        du(6) = U(current_location(1)-1,current_location(2)-1) - U(current_location(1),current_location(2));
                        du(7) = U(current_location(1),current_location(2)-1) - U(current_location(1),current_location(2));
                        du(8) = U(current_location(1)+1,current_location(2)-1) - U(current_location(1),current_location(2));

                    elseif(current_location(1) == 1 && current_location(2) == M) %Ant Is Located At Bottom Right Boundary Corner (1,M)
                        du(7) = U(current_location(1),current_location(2)-1)-U(current_location(1),current_location(2));
                        du(1) = U(current_location(1)+1,current_location(2))-U(current_location(1),current_location(2));
                        du(8) = U(current_location(1)+1,current_location(2)-1)-U(current_location(1),current_location(2));

                    elseif(current_location(1) == M && current_location(2) == M) %Ant Is Located At Top Right Boundary Corner (M,M)
                        du(5) = U(current_location(1)-1, current_location(2)) - U(current_location(1),current_location(2));
                        du(7) = U(current_location(1), current_location(2)-1)-U(current_location(1),current_location(2));
                        du(6) = U(current_location(1)-1, current_location(2)-1)-U(current_location(1),current_location(2));

                    elseif(current_location(1) == M && current_location(2) == 1) %Ant Is Located At Top Left Boundary Corner (M,1)
                        du(3) = U(current_location(1),current_location(2)+1) - U(current_location(1),current_location(2));
                        du(4) = U(current_location(1)-1,current_location(2)+1) - U(current_location(1),current_location(2));
                        du(5) = U(current_location(1)-1,current_location(2)) - U(current_location(1),current_location(2));

                    elseif(current_location(1) == 1 && current_location(2) == 1) %Ant Is Located At Bottom Left Boundary Corner (1,1)
                        du(1) = U(current_location(1)+1, current_location(2)) - U(current_location(1),current_location(2));
                        du(3) = U(current_location(1), current_location(2)+1) - U(current_location(1),current_location(2));
                        du(2) = U(current_location(1)+1, current_location(2)+1) - U(current_location(1),current_location(2));

                    elseif(current_location(1) == 1 && current_location(2) ~= 1 && current_location(2) ~= M) %Ant Is Located Somewhere On Bottom Boundary (Not Corners)
                        du(7) = U(current_location(1), current_location(2)-1) - U(current_location(1),current_location(2));
                        du(1) = U(current_location(1)+1, current_location(2)) - U(current_location(1),current_location(2));
                        du(8) = U(current_location(1)+1, current_location(2)-1) - U(current_location(1),current_location(2));
                        du(3) = U(current_location(1), current_location(2)+1) - U(current_location(1),current_location(2));
                        du(2) = U(current_location(1)+1, current_location(2)+1) - U(current_location(1),current_location(2));

                    elseif(current_location(1) == M && current_location(2) ~= 1 && current_location(2) ~= M) %Ant Is Located Somewhere On Top Boundary (Not Corners)
                        du(5) = U(current_location(1)-1, current_location(2)) - U(current_location(1),current_location(2));
                        du(7) = U(current_location(1), current_location(2)-1) - U(current_location(1),current_location(2));
                        du(6) = U(current_location(1)-1, current_location(2)-1) - U(current_location(1),current_location(2));
                        du(3) = U(current_location(1), current_location(2)+1) - U(current_location(1),current_location(2));
                        du(4) = U(current_location(1)-1, current_location(2)+1) - U(current_location(1),current_location(2));

                    elseif(current_location(2) == 1 && current_location(1) ~= 1 && current_location(1) ~= M) %Ant Is Located Somewhere On Left Boundary (Not Corners)
                        du(5) = U(current_location(1)-1, current_location(2)) - U(current_location(1),current_location(2));
                        du(3) = U(current_location(1), current_location(2)+1) - U(current_location(1),current_location(2));
                        du(4) = U(current_location(1)-1, current_location(2)+1) - U(current_location(1),current_location(2));
                        du(1) = U(current_location(1)+1, current_location(2)) - U(current_location(1),current_location(2));
                        du(2) = U(current_location(1)+1, current_location(2)+1) - U(current_location(1),current_location(2));

                    elseif(current_location(2) == M && current_location(1) ~= 1 && current_location(1) ~= M) %Ant Is Located Somewhere On Right Boundary (Not Corners)
                        du(5) = U(current_location(1)-1, current_location(2)) - U(current_location(1),current_location(2));
                        du(7) = U(current_location(1), current_location(2)-1) - U(current_location(1),current_location(2));
                        du(6) = U(current_location(1)-1, current_location(2)-1) - U(current_location(1),current_location(2));
                        du(1) = U(current_location(1)+1, current_location(2)) - U(current_location(1),current_location(2));
                        du(8) = U(current_location(1)+1, current_location(2)-1) - U(current_location(1),current_location(2));
                    end

                    %Accounts For The Weighted Pheromone Difference Pertaining To Ant Colony 2
                    dr = ones(8,1);
                    current_location1 = current_location;
                    if (current_location1(1)~=1 && current_location1(1)~=M && current_location1(2)~=1 && current_location1(2)~=M)
                        dr(1) = W(current_location1(1)+1,current_location1(2)) - W(current_location1(1),current_location1(2));
                        dr(2) = W(current_location1(1)+1,current_location1(2)+1) - W(current_location1(1),current_location1(2));
                        dr(3) = W(current_location1(1),current_location1(2)+1) - W(current_location1(1),current_location1(2));
                        dr(4) = W(current_location1(1)-1,current_location1(2)+1) - W(current_location1(1),current_location1(2));
                        dr(5) = W(current_location1(1)-1,current_location1(2)) - W(current_location1(1),current_location1(2));
                        dr(6) = W(current_location1(1)-1,current_location1(2)-1) - W(current_location1(1),current_location1(2));
                        dr(7) = W(current_location1(1),current_location1(2)-1) - W(current_location1(1),current_location1(2));
                        dr(8) = W(current_location1(1)+1,current_location1(2)-1) - W(current_location1(1),current_location1(2));
                    elseif(current_location1(1) == 1 && current_location1(2) == M)
                        dr(7) = W(current_location1(1),current_location1(2)-1)-W(current_location1(1),current_location1(2));
                        dr(1) = W(current_location1(1)+1,current_location1(2))-W(current_location1(1),current_location1(2));
                        dr(8) = W(current_location1(1)+1,current_location1(2)-1)-W(current_location1(1),current_location1(2));
                    elseif(current_location1(1) == M && current_location1(2) == M)
                        dr(5) = W(current_location1(1)-1, current_location1(2)) - W(current_location1(1),current_location1(2));
                        dr(7) = W(current_location1(1), current_location1(2)-1)-W(current_location1(1),current_location1(2));
                        dr(6) = W(current_location1(1)-1, current_location1(2)-1)-W(current_location1(1),current_location1(2));
                    elseif(current_location1(1) == M && current_location1(2) == 1)
                        dr(3) = W(current_location1(1),current_location1(2)+1) - W(current_location1(1),current_location1(2));
                        dr(4) = W(current_location1(1)-1,current_location1(2)+1) - W(current_location1(1),current_location1(2));
                        dr(5) = W(current_location1(1)-1,current_location1(2)) - W(current_location1(1),current_location1(2));
                    elseif(current_location1(1) == 1 && current_location1(2) == 1)
                        dr(1) = W(current_location1(1)+1, current_location1(2)) - W(current_location1(1),current_location1(2));
                        dr(3) = W(current_location1(1), current_location1(2)+1) - W(current_location1(1),current_location1(2));
                        dr(2) = W(current_location1(1)+1, current_location1(2)+1) - W(current_location1(1),current_location1(2));
                    elseif(current_location1(1) == 1 && current_location1(2) ~= 1 && current_location1(2) ~= M)
                        dr(7) = W(current_location1(1), current_location1(2)-1) - W(current_location1(1),current_location1(2));
                        dr(1) = W(current_location1(1)+1, current_location1(2)) - W(current_location1(1),current_location1(2));
                        dr(8) = W(current_location1(1)+1, current_location1(2)-1) - W(current_location1(1),current_location1(2));
                        dr(3) = W(current_location1(1), current_location1(2)+1) - W(current_location1(1),current_location1(2));
                        dr(2) = W(current_location1(1)+1, current_location1(2)+1) - W(current_location1(1),current_location1(2));
                    elseif(current_location1(1) == M && current_location1(2) ~= 1 && current_location1(2) ~= M)
                        dr(5) = W(current_location1(1)-1, current_location1(2)) - W(current_location1(1),current_location1(2));
                        dr(7) = W(current_location1(1), current_location1(2)-1) - W(current_location1(1),current_location1(2));
                        dr(6) = W(current_location1(1)-1, current_location1(2)-1) - W(current_location1(1),current_location1(2));
                        dr(3) = W(current_location1(1), current_location1(2)+1) - W(current_location1(1),current_location1(2));
                        dr(4) = W(current_location1(1)-1, current_location1(2)+1) - W(current_location1(1),current_location1(2));
                    elseif(current_location1(2) == 1 && current_location1(1) ~= 1 && current_location1(1) ~= M)
                        dr(5) = W(current_location1(1)-1, current_location1(2)) - W(current_location1(1),current_location1(2));
                        dr(3) = W(current_location1(1), current_location1(2)+1) - W(current_location1(1),current_location1(2));
                        dr(4) = W(current_location1(1)-1, current_location1(2)+1) - W(current_location1(1),current_location1(2));
                        dr(1) = W(current_location1(1)+1, current_location1(2)) - W(current_location1(1),current_location1(2));
                        dr(2) = W(current_location1(1)+1, current_location1(2)+1) - W(current_location1(1),current_location1(2));
                    elseif(current_location1(2) == M && current_location1(1) ~= 1 && current_location1(1) ~= M)
                        dr(5) = W(current_location1(1)-1, current_location1(2)) - W(current_location1(1),current_location1(2));
                        dr(7) = W(current_location1(1), current_location1(2)-1) - W(current_location1(1),current_location1(2));
                        dr(6) = W(current_location1(1)-1, current_location1(2)-1) - W(current_location1(1),current_location1(2));
                        dr(1) = W(current_location1(1)+1, current_location1(2)) - W(current_location1(1),current_location1(2));
                        dr(8) = W(current_location1(1)+1, current_location1(2)-1) - W(current_location1(1),current_location1(2));
                    end


                    for jj = 1:8 %Assign Weights For Each Position Ant Can Move In Based On Difference In Pheromone Concentration (With Respect To Colony 2)
                        if du(jj)< 0
                            weight1(jj) = change_ant_position; %No Difference In Pheromone Concentration From Ant's Current Position To Direction(s) Ant Can Move Towards
                        else
                            weight1(jj) = (1 + du(jj))/(1 + (B_Scalar2*dr(jj))); %Weighted Difference Of Ant Colony 1 Pheromone Concentration, With Respect To Ant Colony 2 Pheromone Concentration At Same Position
                        end
                    end


                    total_weight1 = sum(weight1); %Accumulated Weight Of Difference(s) In Pheromone Concentration
                    P_move1 = zeros(8,1);

                    for jj = 1:8
                        P_move1(jj) = weight1(jj)/total_weight1; %Calculating The Probability Of Moving In Each Of The 8 Possible Directions
                    end
                    Prob1 = cumsum(P_move1); %Contains All Probabilities Of Moving In Each Of The 8 Directions


                    if(ant_position(R,3) == 0) %Check If Ant Is Forager
                        R1 = rand;

                        if R1 < Prob1(1) %Check If Ant Can Move Up
                            if(ant_position(R,1) < M)
                                ant_position(R,1) = ant_position(R,1) + 1;
                            else
                                ant_position(R,1) = ant_position(R,1) - 1;
                            end

                        elseif ((R1 > Prob1(1)) && (R1 < Prob1(2))) %Check If Ant Can Move Up And To The Right
                            if(ant_position(R,2) < M && ant_position(R,1) < M)
                                ant_position(R,2) = ant_position(R,2) + 1;
                                ant_position(R,1) = ant_position(R,1) + 1;
                            elseif (ant_position(R,2) < M && ant_position(R,1) == M)
                                ant_position(R,2) = ant_position(R,2) + 1;
                                ant_position(R,1) = ant_position(R,1) - 1;
                            elseif (ant_position(R,2) == M && ant_position(R,1) == M)
                                ant_position(R,2) = ant_position(R,2) - 1;
                                ant_position(R,1) = ant_position(R,1) - 1;
                            elseif (ant_position(R,2) == M && ant_position(R,1) < M)
                                ant_position(R,2) = ant_position(R,2) - 1;
                                ant_position(R,1) = ant_position(R,1) + 1;
                            end

                        elseif ((R1 > Prob1(2)) && (R1 < Prob1(3))) %Check If Ant Can Move To The Right

                            if(ant_position(R,2) < M)
                                ant_position(R,2) = ant_position(R,2) + 1;
                            else
                                ant_position(R,2) = ant_position(R,2) - 1;
                            end

                        elseif ((R1 > Prob1(3)) && (R1 < Prob1(4))) %Check If Ant Can Move Down And To The Right
                            if(ant_position(R,2) < M && ant_position(R,1) > 1)
                                ant_position(R,2) = ant_position(R,2) + 1;
                                ant_position(R,1) = ant_position(R,1) - 1;
                            elseif (ant_position(R,2) < M && ant_position(R,1) == 1)
                                ant_position(R,2) = ant_position(R,2) + 1;
                                ant_position(R,1) = ant_position(R,1) + 1;
                            elseif (ant_position(R,2) == M && ant_position(R,1) == 1)
                                ant_position(R,2) = ant_position(R,2) - 1;
                                ant_position(R,1) = ant_position(R,1) + 1;
                            elseif (ant_position(R,2) == M && ant_position(R,1) > 1)
                                ant_position(R,2) = ant_position(R,2) - 1;
                                ant_position(R,1) = ant_position(R,1) - 1;

                            end

                        elseif ((R1 > Prob1(4)) && (R1 < Prob1(5))) %Check If Ant Can Move Down
                            if ant_position(R,1) > 1
                                ant_position(R,1) = ant_position(R,1) - 1;
                            else
                                ant_position(R,1) = ant_position(R,1) + 1;
                            end

                        elseif((R1 > Prob1(5)) && (R1 < Prob1(6))) %Check If Ant Can Move Down And To The Left
                            if (ant_position(R,2) > 1 && ant_position (R,1) > 1)
                                ant_position(R,2) = ant_position(R,2) - 1;
                                ant_position(R,1) = ant_position(R,1) - 1;
                            elseif(ant_position(R,2) > 1 && ant_position(R,1) == 1)
                                ant_position(R,2) = ant_position(R,2) - 1;
                                ant_position(R,1) = ant_position(R,1) + 1;
                            elseif(ant_position(R,2) == 1 && ant_position(R,1) == 1)
                                ant_position(R,2) = ant_position(R,2) + 1;
                                ant_position(R,1) = ant_position(R,1) + 1;
                            elseif(ant_position(R,2) == 1 && ant_position(R,1) > 1)
                                ant_position(R,2) = ant_position(R,2) + 1;
                                ant_position(R,1) = ant_position(R,1) - 1;
                            end


                        elseif ((R1 > Prob1(6)) && (R1 < Prob1(7))) %Check If Ant Can Move To The Left
                            if(ant_position(R,2) > 1)
                                ant_position(R,2) = ant_position(R,2) - 1;
                            else
                                ant_position(R,2) = ant_position(R,2) + 1;
                            end


                        elseif ((R1 > Prob1(7)) && (R1 < Prob1(8))) %Check If Ant Can Move Up And To The Left
                            if(ant_position(R,2) > 1 && ant_position(R,1) < M)
                                ant_position(R,2) = ant_position(R,2) - 1;
                                ant_position(R,1) = ant_position(R,1) + 1;
                            elseif(ant_position(R,2) > 1 && ant_position(R,1) == M)
                                ant_position(R,2) = ant_position(R,2) - 1;
                                ant_position(R,1) = ant_position(R,1) - 1;
                            elseif(ant_position(R,2) == 1 && ant_position(R,1) == M)
                                ant_position(R,2) = ant_position(R,2) + 1;
                                ant_position(R,1) = ant_position(R,1) - 1;

                            elseif(ant_position(R,2) == 1 && ant_position(R,1) < M)
                                ant_position(R,2) = ant_position(R,2) + 1;
                                ant_position(R,1) = ant_position(R,1) + 1;
                            end

                        end

                        distAntColony1ToFoodSource = sqrt(((ant_position(R,1) - foodSourceXPos)^2) + ((ant_position(R,2) - foodSourceYPos))^2); %Distance Between Ant's Position And Food Source

                        if (distAntColony1ToFoodSource < 1) %Ant Found Food Source; Ant Becomes A Returner
                            ant_position(R,3) = 1;
                            food_found = 1;
                            check = 1;
                        end

                    elseif (ant_position(R,3) == 1) %Check If Ant Is Returner
                        ant_position(R,1:2) = ant_position(R,1:2) + u; %Ant Moves Towards Direction Of Nest If Ant Is Returner
                        dist1 = sqrt(((ant_position(R,1) - nestXPos)^2) + ((ant_position(R,2) - nestYPos)^2)); %Distance Between Ant's Position And Nest
                        if (dist1 < 1) %Ant Becomes A Forager Again
                            ant_position(R,3) = 0;
                            ant_position(R,1) = nestXPos;
                            ant_position(R,2) = nestYPos;
                        end
                    end
                end

                
                %Ant Colony 2; Same Process As Above
                for l = 1:S %S Ant Movements
                    G = randi([1,S]); % Choosing A Random Ant
                    current_location1 = round(ant1_position(G,1:2)); % Obtain Ant's Current Position
                    dr = ones(8,1);

                    %Calculate Difference In Pheromone Concentration Between Ant's Current Possition & All Possible Directions Ant Can Move Towards (Based On Ant's Current Position)
                    if (current_location1(1)~=1 && current_location1(1)~=M && current_location1(2)~=1 && current_location1(2)~=M) %Ant Is Not Located At Boundary
                        dr(1) = W(current_location1(1)+1,current_location1(2)) - W(current_location1(1),current_location1(2));
                        dr(2) = W(current_location1(1)+1,current_location1(2)+1) - W(current_location1(1),current_location1(2));
                        dr(3) = W(current_location1(1),current_location1(2)+1) - W(current_location1(1),current_location1(2));
                        dr(4) = W(current_location1(1)-1,current_location1(2)+1) - W(current_location1(1),current_location1(2));
                        dr(5) = W(current_location1(1)-1,current_location1(2)) - W(current_location1(1),current_location1(2));
                        dr(6) = W(current_location1(1)-1,current_location1(2)-1) - W(current_location1(1),current_location1(2));
                        dr(7) = W(current_location1(1),current_location1(2)-1) - W(current_location1(1),current_location1(2));
                        dr(8) = W(current_location1(1)+1,current_location1(2)-1) - W(current_location1(1),current_location1(2));

                    elseif(current_location1(1) == 1 && current_location1(2) == M) %Ant Is Located At Bottom Right Boundary Corner (1,M)
                        dr(7) = W(current_location1(1),current_location1(2)-1)-W(current_location1(1),current_location1(2));
                        dr(1) = W(current_location1(1)+1,current_location1(2))-W(current_location1(1),current_location1(2));
                        dr(8) = W(current_location1(1)+1,current_location1(2)-1)-W(current_location1(1),current_location1(2));

                    elseif(current_location1(1) == M && current_location1(2) == M) %Ant Is Located At Top Right Boundary Corner (M,M)
                        dr(5) = W(current_location1(1)-1, current_location1(2)) - W(current_location1(1),current_location1(2));
                        dr(7) = W(current_location1(1), current_location1(2)-1)-W(current_location1(1),current_location1(2));
                        dr(6) = W(current_location1(1)-1, current_location1(2)-1)-W(current_location1(1),current_location1(2));

                    elseif(current_location1(1) == M && current_location1(2) == 1) %Ant Is Located At Top Left Boundary Corner (M,1)
                        dr(3) = W(current_location1(1),current_location1(2)+1) - W(current_location1(1),current_location1(2));
                        dr(4) = W(current_location1(1)-1,current_location1(2)+1) - W(current_location1(1),current_location1(2));
                        dr(5) = W(current_location1(1)-1,current_location1(2)) - W(current_location1(1),current_location1(2));

                    elseif(current_location1(1) == 1 && current_location1(2) == 1) %Ant Is Located At Bottom Left Boundary Corner (1,1)
                        dr(1) = W(current_location1(1)+1, current_location1(2)) - W(current_location1(1),current_location1(2));
                        dr(3) = W(current_location1(1), current_location1(2)+1) - W(current_location1(1),current_location1(2));
                        dr(2) = W(current_location1(1)+1, current_location1(2)+1) - W(current_location1(1),current_location1(2));

                    elseif(current_location1(1) == 1 && current_location1(2) ~= 1 && current_location1(2) ~= M) %Ant Is Located Somewhere On Bottom Boundary (Not Corners)
                        dr(7) = W(current_location1(1), current_location1(2)-1) - W(current_location1(1),current_location1(2));
                        dr(1) = W(current_location1(1)+1, current_location1(2)) - W(current_location1(1),current_location1(2));
                        dr(8) = W(current_location1(1)+1, current_location1(2)-1) - W(current_location1(1),current_location1(2));
                        dr(3) = W(current_location1(1), current_location1(2)+1) - W(current_location1(1),current_location1(2));
                        dr(2) = W(current_location1(1)+1, current_location1(2)+1) - W(current_location1(1),current_location1(2));

                    elseif(current_location1(1) == M && current_location1(2) ~= 1 && current_location1(2) ~= M) %Ant Is Located Somewhere On Top Boundary (Not Corners)
                        dr(5) = W(current_location1(1)-1, current_location1(2)) - W(current_location1(1),current_location1(2));
                        dr(7) = W(current_location1(1), current_location1(2)-1) - W(current_location1(1),current_location1(2));
                        dr(6) = W(current_location1(1)-1, current_location1(2)-1) - W(current_location1(1),current_location1(2));
                        dr(3) = W(current_location1(1), current_location1(2)+1) - W(current_location1(1),current_location1(2));
                        dr(4) = W(current_location1(1)-1, current_location1(2)+1) - W(current_location1(1),current_location1(2));

                    elseif(current_location1(2) == 1 && current_location1(1) ~= 1 && current_location1(1) ~= M) %Ant Is Located Somewhere On Left Boundary (Not Corners)
                        dr(5) = W(current_location1(1)-1, current_location1(2)) - W(current_location1(1),current_location1(2));
                        dr(3) = W(current_location1(1), current_location1(2)+1) - W(current_location1(1),current_location1(2));
                        dr(4) = W(current_location1(1)-1, current_location1(2)+1) - W(current_location1(1),current_location1(2));
                        dr(1) = W(current_location1(1)+1, current_location1(2)) - W(current_location1(1),current_location1(2));
                        dr(2) = W(current_location1(1)+1, current_location1(2)+1) - W(current_location1(1),current_location1(2));

                    elseif(current_location1(2) == M && current_location1(1) ~= 1 && current_location1(1) ~= M) %Ant Is Located Somewhere On Right Boundary (Not Corners)
                        dr(5) = W(current_location1(1)-1, current_location1(2)) - W(current_location1(1),current_location1(2));
                        dr(7) = W(current_location1(1), current_location1(2)-1) - W(current_location1(1),current_location1(2));
                        dr(6) = W(current_location1(1)-1, current_location1(2)-1) - W(current_location1(1),current_location1(2));
                        dr(1) = W(current_location1(1)+1, current_location1(2)) - W(current_location1(1),current_location1(2));
                        dr(8) = W(current_location1(1)+1, current_location1(2)-1) - W(current_location1(1),current_location1(2));
                    end
                    
                    %Accounts For The Weighted Pheromone Difference Pertaining To Ant Colony 1
                    du = ones(8,1);
                    current_location = current_location1;
                    if (current_location(1)~=1 && current_location(1)~=M && current_location(2)~=1 && current_location(2)~=M)
                        du(1) = U(current_location(1)+1,current_location(2)) - U(current_location(1),current_location(2));
                        du(2) = U(current_location(1)+1,current_location(2)+1) - U(current_location(1),current_location(2));
                        du(3) = U(current_location(1),current_location(2)+1) - U(current_location(1),current_location(2));
                        du(4) = U(current_location(1)-1,current_location(2)+1) - U(current_location(1),current_location(2));
                        du(5) = U(current_location(1)-1,current_location(2)) - U(current_location(1),current_location(2));
                        du(6) = U(current_location(1)-1,current_location(2)-1) - U(current_location(1),current_location(2));
                        du(7) = U(current_location(1),current_location(2)-1) - U(current_location(1),current_location(2));
                        du(8) = U(current_location(1)+1,current_location(2)-1) - U(current_location(1),current_location(2));
                    elseif(current_location(1) == 1 && current_location(2) == M)
                        du(7) = U(current_location(1),current_location(2)-1)-U(current_location(1),current_location(2));
                        du(1) = U(current_location(1)+1,current_location(2))-U(current_location(1),current_location(2));
                        du(8) = U(current_location(1)+1,current_location(2)-1)-U(current_location(1),current_location(2));
                    elseif(current_location(1) == M && current_location(2) == M)
                        du(5) = U(current_location(1)-1, current_location(2)) - U(current_location(1),current_location(2));
                        du(7) = U(current_location(1), current_location(2)-1)-U(current_location(1),current_location(2));
                        du(6) = U(current_location(1)-1, current_location(2)-1)-U(current_location(1),current_location(2));
                    elseif(current_location(1) == M && current_location(2) == 1)
                        du(3) = U(current_location(1),current_location(2)+1) - U(current_location(1),current_location(2));
                        du(4) = U(current_location(1)-1,current_location(2)+1) - U(current_location(1),current_location(2));
                        du(5) = U(current_location(1)-1,current_location(2)) - U(current_location(1),current_location(2));
                    elseif(current_location(1) == 1 && current_location(2) == 1)
                        du(1) = U(current_location(1)+1, current_location(2)) - U(current_location(1),current_location(2));
                        du(3) = U(current_location(1), current_location(2)+1) - U(current_location(1),current_location(2));
                        du(2) = U(current_location(1)+1, current_location(2)+1) - U(current_location(1),current_location(2));
                    elseif(current_location(1) == 1 && current_location(2) ~= 1 && current_location(2) ~= M)
                        du(7) = U(current_location(1), current_location(2)-1) - U(current_location(1),current_location(2));
                        du(1) = U(current_location(1)+1, current_location(2)) - U(current_location(1),current_location(2));
                        du(8) = U(current_location(1)+1, current_location(2)-1) - U(current_location(1),current_location(2));
                        du(3) = U(current_location(1), current_location(2)+1) - U(current_location(1),current_location(2));
                        du(2) = U(current_location(1)+1, current_location(2)+1) - U(current_location(1),current_location(2));
                    elseif(current_location(1) == M && current_location(2) ~= 1 && current_location(2) ~= M)
                        du(5) = U(current_location(1)-1, current_location(2)) - U(current_location(1),current_location(2));
                        du(7) = U(current_location(1), current_location(2)-1) - U(current_location(1),current_location(2));
                        du(6) = U(current_location(1)-1, current_location(2)-1) - U(current_location(1),current_location(2));
                        du(3) = U(current_location(1), current_location(2)+1) - U(current_location(1),current_location(2));
                        du(4) = U(current_location(1)-1, current_location(2)+1) - U(current_location(1),current_location(2));
                    elseif(current_location(2) == 1 && current_location(1) ~= 1 && current_location(1) ~= M)
                        du(5) = U(current_location(1)-1, current_location(2)) - U(current_location(1),current_location(2));
                        du(3) = U(current_location(1), current_location(2)+1) - U(current_location(1),current_location(2));
                        du(4) = U(current_location(1)-1, current_location(2)+1) - U(current_location(1),current_location(2));
                        du(1) = U(current_location(1)+1, current_location(2)) - U(current_location(1),current_location(2));
                        du(2) = U(current_location(1)+1, current_location(2)+1) - U(current_location(1),current_location(2));
                    elseif(current_location(2) == M && current_location(1) ~= 1 && current_location(1) ~= M)
                        du(5) = U(current_location(1)-1, current_location(2)) - U(current_location(1),current_location(2));
                        du(7) = U(current_location(1), current_location(2)-1) - U(current_location(1),current_location(2));
                        du(6) = U(current_location(1)-1, current_location(2)-1) - U(current_location(1),current_location(2));
                        du(1) = U(current_location(1)+1, current_location(2)) - U(current_location(1),current_location(2));
                        du(8) = U(current_location(1)+1, current_location(2)-1) - U(current_location(1),current_location(2));
                    end

                    for ll = 1:8  %Assign Weights For Each Position Ant Can Move In Based On Difference In Pheromone Concentration (With Respect To Colony 1)
                        if dr(ll)< 0
                            weight2(ll) = change_ant_position;
                        else
                            weight2(ll) = (1 + dr(ll))/(1 + (B_Scalar1 * du(ll)));
                        end
                    end

                    total_weight2 = sum(weight2); %Accumulated Weight Of Difference(s) In Pheromone Concentration
                    P_move2 = zeros(8,1);

                    for ll = 1:8
                        P_move2(ll) = weight2(ll)/total_weight2; %Calculating The Probability Of Moving In Each Of The 8 Possible Directions
                    end
                    Prob2 = cumsum(P_move2); %Contains All Probabilities Of Moving In Each Of The 8 Directions

                    
                    if(ant1_position(G,3) == 0) %Check If Ant Is Forager
                        G1 = rand;

                        if G1 < Prob2(1) %Check If Ant Can Move Up
                            if(ant1_position(G,1) < M)
                                ant1_position(G,1) = ant1_position(G,1) + 1;
                            else
                                ant1_position(G,1) = ant1_position(G,1) - 1;
                            end

                        elseif ((G1 > Prob2(1)) && (G1 < Prob2(2))) %Check If Ant Can Move Up And To The Right
                            if(ant1_position(G,2) < M && ant1_position(G,1) < M)
                                ant1_position(G,2) = ant1_position(G,2) + 1;
                                ant1_position(G,1) = ant1_position(G,1) + 1;
                            elseif (ant1_position(G,2) < M && ant1_position(G,1) == M)
                                ant1_position(G,2) = ant1_position(G,2) + 1;
                                ant1_position(G,1) = ant1_position(G,1) - 1;
                            elseif (ant1_position(G,2) == M && ant1_position(G,1) == M)
                                ant1_position(G,2) = ant1_position(G,2) - 1;
                                ant1_position(G,1) = ant1_position(G,1) - 1;
                            elseif (ant1_position(G,2) == M && ant1_position(G,1) < M)
                                ant1_position(G,2) = ant1_position(G,2) - 1;
                                ant1_position(G,1) = ant1_position(G,1) + 1;
                            end

                        elseif ((G1 > Prob2(2)) && (G1 < Prob2(3))) %Check If Ant Can Move To The Right
                            if(ant1_position(G,2) < M)
                                ant1_position(G,2) = ant1_position(G,2) + 1;
                            else
                                ant1_position(G,2) = ant1_position(G,2) - 1;
                            end

                        elseif ((G1 > Prob2(3)) && (G1 < Prob2(4))) %Check If Ant Can Move Down And To The Right
                            if(ant1_position(G,2) < M && ant1_position(G,1) > 1)
                                ant1_position(G,2) = ant1_position(G,2) + 1;
                                ant1_position(G,1) = ant1_position(G,1) - 1;
                            elseif (ant1_position(G,2) < M && ant1_position(G,1) == 1)
                                ant1_position(G,2) = ant1_position(G,2) + 1;
                                ant1_position(G,1) = ant1_position(G,1) + 1;
                            elseif (ant1_position(G,2) == M && ant1_position(G,1) == 1)
                                ant1_position(G,2) = ant1_position(G,2) - 1;
                                ant1_position(G,1) = ant1_position(G,1) + 1;
                            elseif (ant1_position(G,2) == M && ant1_position(G,1) > 1)
                                ant1_position(G,2) = ant1_position(G,2) - 1;
                                ant1_position(G,1) = ant1_position(G,1) - 1;

                            end

                        elseif ((G1 > Prob2(4)) && (G1 < Prob2(5))) %Check If Ant Can Move Down
                            if ant1_position(G,1) > 1
                                ant1_position(G,1) = ant1_position(G,1) - 1;
                            else
                                ant1_position(G,1) = ant1_position(G,1) + 1;
                            end

                        elseif((G1 > Prob2(5)) && (G1 < Prob2(6))) %Check If Ant Can Move Down And To The Left
                            if (ant1_position(G,2) > 1 && ant1_position(G,1) > 1)
                                ant1_position(G,2) = ant1_position(G,2) - 1;
                                ant1_position(G,1) = ant1_position(G,1) - 1;
                            elseif(ant1_position(G,2) > 1 && ant1_position(G,1) == 1)
                                ant1_position(G,2) = ant1_position(G,2) - 1;
                                ant1_position(G,1) = ant1_position(G,1) + 1;
                            elseif(ant1_position(G,2) == 1 && ant1_position(G,1) == 1)
                                ant1_position(G,2) = ant1_position(G,2) + 1;
                                ant1_position(G,1) = ant1_position(G,1) + 1;
                            elseif(ant1_position(G,2) == 1 && ant1_position(G,1) > 1)
                                ant1_position(G,2) = ant1_position(G,2) + 1;
                                ant1_position(G,1) = ant1_position(G,1) - 1;
                            end


                        elseif ((G1 > Prob2(6)) && (G1 < Prob2(7))) %Check If Ant Can Move To The Left
                            if(ant1_position(G,2) > 1)
                                ant1_position(G,2) = ant1_position(G,2) - 1;
                            else
                                ant1_position(G,2) = ant1_position(G,2) + 1;
                            end


                        elseif ((G1 > Prob2(7)) && (G1 < Prob2(8))) %Check If Ant Can Move Up And To The Left
                            if(ant1_position(G,2) > 1 && ant1_position(G,1) < M)
                                ant1_position(G,2) = ant1_position(G,2) - 1;
                                ant1_position(G,1) = ant1_position(G,1) + 1;
                            elseif(ant1_position(G,2) > 1 && ant1_position(G,1) == M)
                                ant1_position(G,2) = ant1_position(G,2) - 1;
                                ant1_position(G,1) = ant1_position(G,1) - 1;
                            elseif(ant1_position(G,2) == 1 && ant1_position(G,1) == M)
                                ant1_position(G,2) = ant1_position(G,2) + 1;
                                ant1_position(G,1) = ant1_position(G,1) - 1;

                            elseif(ant1_position(G,2) == 1 && ant1_position(G,1) < M)
                                ant1_position(G,2) = ant1_position(G,2) + 1;
                                ant1_position(G,1) = ant1_position(G,1) + 1;
                            end

                        end

                        distAntColony2ToFoodSource = sqrt(((ant1_position(G,1) - foodSourceXPos)^2) + ((ant1_position(G,2) - foodSourceYPos))^2); %Distance Between Ant's Position And Food Source

                        if (distAntColony2ToFoodSource < 1) %Ant Found Food Source; Ant Becomes A Returner
                            ant1_position(G,3) = 1;
                            food_found = 1;
                        end

                    elseif (ant1_position(G,3) == 1) %Check If Ant Is Returner
                        ant1_position(G,1:2) = ant1_position(G,1:2) + uu; %Ant Moves Towards Direction Of Nest
                        dist2 = sqrt(((ant1_position(G,1) - nestX2Pos)^2) + ((ant1_position(G,2) - nestY2Pos)^2)); %Distance Between Ant's Position And Nest
                        if (dist2 < 1) %Ant Becomes A Forager Again
                            ant1_position(G,3) = 0;
                            ant1_position(G,1) = nestX2Pos;
                            ant1_position(G,2) = nestY2Pos;
                        end
                    end
                end


                A = zeros(M,M); %Matrix A Consists Of All The Foragers
                B = zeros(M,M); %Matrix B Consists Of All The Returners


                %Goal: Extract Returner's Positions From AP Matrix For Both Colonies 1 And 2 Below

                AA = 1;

                index1 = (ant_position(:,3) > 0); %For Each Of The N Ants From Colony 1, Check Their Forager (0) /Returner (1) Status
                returners1 = ant_position(index1,:); %Stores Positions Of Ants From Colony 1 With Returner (1) Status
                J = length(returners1(:,1)); %Number Of Returners From Colony 1


                index2 = (ant1_position(:,3) > 0); %For Each Of The N Ants In Colony 2, Check Their Forager (0) /Returner (1) Status
                returners2 = ant1_position(index2,:); %Stores Positions Of Ants From Colony 2 With Returner (1) Status
                Q = length(returners2(:,1)); %Number Of Returners From Colony 2
                

                if (food_found > 0)
                    while (tt < 1)
                        V = zeros(M,M); %Total Pheromone Concentration Accounting For Colony 1 (Diffusion-Reaction Equation)
                        O = zeros(M,M); %Total Pheromone Concentration Accounting For Colony 2 (Diffusion-Reaction Equation)
                        for i = 1:M
                            for j = 1:M
                                if(i~=1 && i~= M && j~=1 && j~=M) %Not At The Boundary
                                    V(i,j) = U(i,j) + dt*D*(U(i+1,j)+U(i-1,j)+U(i,j+1)+U(i,j-1)-4*U(i,j))-dt*gamma*U(i,j);
                                    O(i,j) = W(i,j) + dt*D*(W(i+1,j)+W(i-1,j)+W(i,j+1)+W(i,j-1)-4*W(i,j))-dt*gamma*W(i,j);

                                elseif(i==1 && j~=1 && j~=M) %At Bottom Boundary (No Corners)
                                    V(i,j) = U(i,j) + dt*D*(2*U(i+1,j)+U(i,j+1)+U(i,j-1)+(-(2/D)-4)*U(i,j))-dt*gamma*U(i,j);
                                    O(i,j) = W(i,j) + dt*D*(2*W(i+1,j)+W(i,j+1)+W(i,j-1)+(-(2/D)-4)*W(i,j))-dt*gamma*W(i,j);

                                elseif(i == M && j~=1 && j ~= M) %At Top Boundary (No Corners)
                                    V(i,j) = U(i,j) + dt*D*(2*U(i-1,j)+U(i,j+1)+U(i,j-1)+(-(2/D)-4)*U(i,j))-dt*gamma*U(i,j);
                                    O(i,j) = W(i,j) + dt*D*(2*W(i-1,j)+W(i,j+1)+W(i,j-1)+(-(2/D)-4)*W(i,j))-dt*gamma*W(i,j);

                                elseif(i ~= 1 && i ~= M && j == 1) %At Left Boundary (No Corners)
                                    V(i,j) = U(i,j) + dt*D*(U(i+1,j)+U(i-1,j)+ 2*U(i,j+1)+(-(2/D)-4)*U(i,j))-dt*gamma*U(i,j);
                                    O(i,j) = W(i,j) + dt*D*(W(i+1,j)+W(i-1,j)+ 2*W(i,j+1)+(-(2/D)-4)*W(i,j))-dt*gamma*W(i,j);

                                elseif(i ~= 1 && i ~= M && j == M) %At Right Boundary (No Corners)
                                    V(i,j) = U(i,j) + dt*D*(U(i+1,j)+U(i-1,j)+ 2*U(i,j-1)+(-(2/D)-4)*U(i,j))-dt*gamma*U(i,j);
                                    O(i,j) = W(i,j) + dt*D*(W(i+1,j)+W(i-1,j)+ 2*W(i,j-1)+(-(2/D)-4)*W(i,j))-dt*gamma*W(i,j);

                                elseif(i == M && j == M) %At Top Right Corner
                                    V(i,j) = U(i,j) + dt*D*(2*U(i,j-1)+ 2*U(i-1,j)+ (-(4/D)-4)*U(i,j))-dt*gamma*U(i,j);
                                    O(i,j) = W(i,j) + dt*D*(2*W(i,j-1)+ 2*W(i-1,j)+ (-(4/D)-4)*W(i,j))-dt*gamma*W(i,j);

                                elseif(i == 1 && j == M) %At Bottom Right Corner
                                    V(i,j) = U(i,j) + dt*D*(2*U(i,j-1)+ 2*U(i+1,j)+ (-(4/D)-4)*U(i,j))-dt*gamma*U(i,j);
                                    O(i,j) = W(i,j) + dt*D*(2*W(i,j-1)+ 2*W(i+1,j)+ (-(4/D)-4)*W(i,j))-dt*gamma*W(i,j);

                                elseif(i == 1 && j == 1) %At Bottom Left Corner
                                    V(i,j) = U(i,j) + dt*D*(2*U(i,j+1)+ 2*U(i+1,j)+ (-(4/D)-4)*U(i,j))-dt*gamma*U(i,j);
                                    O(i,j) = W(i,j) + dt*D*(2*W(i,j+1)+ 2*W(i+1,j)+ (-(4/D)-4)*W(i,j))-dt*gamma*W(i,j);

                                elseif(i == M && j == 1) %At Top Left Corner
                                    V(i,j) = U(i,j) + dt*D*(2*U(i,j+1)+ 2*U(i-1,j)+ (-(4/D)-4)*U(i,j))-dt*gamma*U(i,j);
                                    O(i,j) = W(i,j) + dt*D*(2*W(i,j+1)+ 2*W(i-1,j)+ (-(4/D)-4)*W(i,j))-dt*gamma*W(i,j);
                                end
                            end
                        end

                        for jj =1:J %For Each Returner From Colony 1
                            rr = round(returners1(jj,1));
                            cc = round(returners1(jj,2));
                            dd1 = sqrt((returners1(jj,1) - foodSourceXPos)^2 + (returners1(jj,2) - foodSourceYPos)^2);
                            V(rr,cc) = V(rr,cc) + dt*AA*exp(-dd1^2);
                        end

                        for qq =1:Q %For Each Returner From Colony 2
                            ee = round(returners2(qq,1));
                            ff = round(returners2(qq,2));
                            dd2 = sqrt((returners2(qq,1) - foodSourceXPos)^2 + (returners2(qq,2) - foodSourceYPos)^2);
                            O(ee,ff) = O(ee,ff) + dt*AA*exp(-dd2^2);
                        end

                        U = V;
                        W = O;
                        tt = tt + dt;
                    end


                end

                tt=0;
                t = t+1;
                
            end

            if (J >= .25 * N && Q < .25*S) %Checking: Colony 1 Has More Than 25 Returners, Which Is Greater Than The Number Of Returners From Colony 2
                Colony1FormedTrail(nn) = 1;
                Colony2FormedTrail(nn) = 0;
            elseif(Q >= .25*S && J < 0.25*N) %Checking: Colony 2 Has More Than 25 Returners, Which Is Greater Than The Number Of Returners From Colony 1
                Colony2FormedTrail(nn) = 1;
                Colony1FormedTrail(nn) = 0;
            elseif(Q >= .25*S && J >= 0.25*N) %Checking: Both Colonies 1 And 2 Have More Than 25 Returners, Then Another Trail Has Been Formed By Both Colonies
                Colony1FormedTrail(nn) = 1;
                Colony2FormedTrail(nn) = 1;
            elseif(J < 0.25*N && Q < 0.25*S) %Checking: Both Colonies Have Less Than 50 Returners, Then Neither Colony Has Formed A Trail
                Colony1FormedTrail(nn) = 0;
                Colony2FormedTrail(nn) = 0;
            end

        end


        ProbColony1Trail = (sum(Colony1FormedTrail))/ (NumSimulations); %Probability Of Colony 1 Forming A Trail From Nest To A Food Site
        stdProbColony1Trail = (std((Colony1FormedTrail == 1) & (Colony2FormedTrail == 0)))/(sqrt(NumSimulations))
        stdErrorBarValuesProbability(jk) = stdProbColony1Trail;

        ProbColony2Trail = (sum(Colony2FormedTrail))/ (NumSimulations); %Probability Of Colony 2 Forming A Trail From Nest To A Food Site

        ProbBothColoniesTrail = (sum(Colony1FormedTrail & Colony2FormedTrail))/(NumSimulations); %Probability Of Both Colonies Forming A Trail From Their Nests To A Food Site

        ProbOnlyColony1Trail = (sum((Colony1FormedTrail == 1) & (Colony2FormedTrail == 0)))/ (NumSimulations); %Probability Of Only Colony 1 Forming A Trail From Nest To A Food Site

        ProbOnlyColony2Trail = (sum((Colony2FormedTrail == 1) & (Colony1FormedTrail == 0)))/ (NumSimulations); %Probability Of Only Colony 2 Forming A Trail From Nest To A Food Site

        ProbNoColony1Trail = 1 - ProbColony1Trail; %Probability Of Colony 1 Not Forming A Trail

        ProbNoColony2Trail = 1 - ProbColony2Trail; %Probability Of Colony 2 Not Forming A Trail

        ProbNeitherColoniesTrail = (sum((Colony1FormedTrail == 0) & (Colony2FormedTrail == 0)))/(NumSimulations); %Probability Of Neither Colony 1 Nor Colony 2 Forming A Trail


        ProbJustColony1(jk) = ProbOnlyColony1Trail; %Probability Of Only Colony 1 Forming A Trail From Nest To A Food Site
        ProbCColony1(jk) = ProbColony1Trail; %Probability Of Colony 1 Forming A Trail From Nest To A Food Site

    end


    %Plot
    x = DistanceRatio;
    y = ProbJustColony1;

    hold on;

    errorbar(x,y,stdErrorBarValuesProbability);

    hold off;

    xlabel('Distance Ratio (Colony 1 to Colony 2) ');
    ylabel('Probability Of Trail Formation');
    drawnow

end



