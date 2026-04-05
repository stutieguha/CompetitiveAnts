
clear; clc; close all;

%% 1. Set Up the Sweeps for the Data Collapse
% To get a clean curve, we must lock Colony 1's Base Effort (E1).
% We set E1 = 1.0 (Colony 1 has ~63% chance to find food optimally).
base_effort = 1.0; 

% WARNING: For a quick test, leave num_sims = 20. 
% For the final paper quality, change to num_sims = 1000.
num_sims = 1000; 
num_configurations = 15; 

actual_delta_d = zeros(num_configurations, 1);
actual_N_ratio = zeros(num_configurations, 1);
actual_P2_win  = zeros(num_configurations, 1);
actual_chi     = zeros(num_configurations, 1);

% Sweep the mathematical advantage of Colony 2 from 10^-1 to 10^1
chi_sweep = logspace(-1.5, 1.5, num_configurations);

fprintf('Starting full PDE/Agent-based simulations for %d configurations...\n', num_configurations);

for idx = 1:num_configurations
    % -- Lock Colony 1 Base Effort --
    d1 = randi([2, 3]); 
    p1 = 8^(-d1);
    N1 = round(base_effort / p1); 
    
    % -- Set Colony 2 to hit the target chi --
    target_chi = chi_sweep(idx);
    d2 = randi([2, 4]);
    p2 = 8^(-d2);
    N2 = round((target_chi * base_effort) / p2);
    
    % Prevent N2 from being 0 (minimum 1 ant)
    if N2 < 1; N2 = 1; end
    
    % Record actual parameters
    actual_N_ratio(idx) = N2 / N1;
    actual_delta_d(idx) = d2 - d1;
    actual_chi(idx)     = (N2 * p2) / (N1 * p1);
    
    fprintf('Config %d/%d: d1=%d, N1=%d | d2=%d, N2=%d (Chi = %.3f)... ', ...
        idx, num_configurations, d1, N1, d2, N2, actual_chi(idx));
    
    % Run simulation to extract first passage times
    p2_win = run_ant_competition(N1, N2, d1, d2, num_sims);
    actual_P2_win(idx) = p2_win;
    
    fprintf('P(Colony 2 Finds First) = %.3f\n', p2_win);
end

%% 2. Generate the PRL Figure
fig = figure('Position', [100, 100, 1000, 450], 'Color', 'w');

% -------------------------------------------------------------------------
% PANEL A: Theoretical Phase Diagram
% -------------------------------------------------------------------------
subplot(1, 2, 1);
hold on; box on;

% Create theoretical grid
DD = linspace(-2, 4, 50);      
NN_ratio = logspace(-1, 3, 50);    
[DD_grid, NN_grid] = meshgrid(DD, NN_ratio);
chi_grid = NN_grid .* 8.^(-DD_grid); 

% Theoretical Probability Equation
P2_win_theory = (1 - exp(-chi_grid * base_effort)) .* exp(-base_effort);

% Plot Heatmap
[C, h] = contourf(DD_grid, log10(NN_grid), P2_win_theory, 20, 'LineColor', 'none');
colormap(gca, parula);
cbar = colorbar;
cbar.Label.String = '$\mathbb{P}(T_2 < T_1)$ (Theoretical)';
cbar.Label.Interpreter = 'latex'; cbar.Label.FontSize = 14;

% Overlay Theoretical Boundary
plot(DD, log10(8.^(DD)), 'w--', 'LineWidth', 2.5);
text(1.5, log10(8^1.5) + 0.3, 'Asymptotic Balance', 'Color', 'w', ...
    'Interpreter', 'latex', 'FontSize', 14, 'Rotation', 38);

set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 14);
xlabel('Spatial Disadvantage, $d_2 - d_1$', 'Interpreter', 'latex', 'FontSize', 16);
ylabel('Population Ratio, $\log_{10}(N_2/N_1)$', 'Interpreter', 'latex', 'FontSize', 16);
title('\textbf{(A) Absorbing State Phase Diagram}', 'Interpreter', 'latex', 'FontSize', 16);
xlim([-1, 3]); ylim([-0.5, 3]);

% -------------------------------------------------------------------------
% PANEL B: Data Collapse
% -------------------------------------------------------------------------
subplot(1, 2, 2);
hold on; box on;

% Define the continuous line for plotting fits
chi_line = logspace(-2, 2, 200)';

% 1. Plot Theoretical Limit (Dashed Red Line)
theoretical_P2_line = (1 - exp(-chi_line * base_effort)) .* exp(-base_effort);
h_theory = plot(chi_line, theoretical_P2_line, 'r--', 'LineWidth', 2);

% % 2. Fit and Plot Empirical Logistic Curve (Solid Blue Line)
% % Logistic Equation: y = 1 / (1 + exp(-k * (log10(x) - c)))
% try
%     ft = fittype('1 / (1 + exp(-k * (log10(x) - c)))', 'independent', 'x', 'dependent', 'y');
%     opts = fitoptions('Method', 'NonlinearLeastSquares', 'StartPoint', [2, 0]);
%     empirical_fit = fit(actual_chi(:), actual_P2_win(:), ft, opts);
%     empirical_P2_line = empirical_fit(chi_line);
% 
%     h_fit = plot(chi_line, empirical_P2_line, 'b-', 'LineWidth', 2.5);
%     fprintf('\n--- Fit Results ---\nSteepness (k) = %.3f\nMidpoint shift (c) = %.3f\n', empirical_fit.k, empirical_fit.c);
% catch
%     warning('Curve fitting failed. Ensure Curve Fitting Toolbox is installed.');
%     h_fit = plot(NaN, NaN, 'b-', 'LineWidth', 2.5); % Dummy handle for legend
% end

% 3. Plot Actual Simulated Data Points
h_data = scatter(actual_chi, actual_P2_win, 60, 'k', 'o', 'filled', ...
    'MarkerFaceAlpha', 0.7, 'MarkerEdgeColor', 'k');

set(gca, 'XScale', 'log', 'TickLabelInterpreter', 'latex', 'FontSize', 14);
xlabel('Scaling Parameter, $\chi = \frac{N_2}{N_1} 8^{d_1 - d_2}$', 'Interpreter', 'latex', 'FontSize', 16);
ylabel('Empirical Probability, $\mathbb{P}(T_2 < T_1)$', 'Interpreter', 'latex', 'FontSize', 16);
title('\textbf{(B) Extreme Statistics Data Collapse}', 'Interpreter', 'latex', 'FontSize', 16);

legend([h_data, h_theory], ...
    {'Simulations (Full PDE)', 'Idealized Scaling Limit'}, ...
    'Interpreter', 'latex', 'Location', 'northwest', 'FontSize', 12);
xlim([1e-2, 1e2]); ylim([0, 1.1]);

sgtitle('Stochastic Symmetry Breaking in Competitive Foraging', 'Interpreter', 'latex', 'FontSize', 18, 'FontWeight', 'bold');



%% =========================================================================
% SIMULATION ENGINE: Extreme First-Passage Extraction
% =========================================================================
function ProbOnlyColony2_FirstPassage = run_ant_competition(N1, N2, d1, d2, NumSimulations)
    M = 50;
    dt = 0.01; 
    T_end = 20; 
    gamma = 2; 
    D = 10; 
    change_ant_position = 0.001;
    
    B_Scalar1 = 55; % Symmetrical fear
    B_Scalar2 = 55; 
    
    foodSourceXPos = 25; 
    foodSourceYPos = 25;
    
    nestXPos  = 25 - d1; nestYPos  = 25 - d1;
    nestX2Pos = 25 - d2; nestY2Pos = 25 - d2;
    
    T_first_1 = zeros(1, NumSimulations);
    T_first_2 = zeros(1, NumSimulations);
    
    for nn = 1:NumSimulations
        U = zeros(M,M); W = zeros(M,M);
        
        ant_position  = zeros(N1, 3);
        ant1_position = zeros(N2, 3);
        
        ant_position(:,1) = nestXPos; ant_position(:,2) = nestYPos; ant_position(:,3) = 0;
        ant1_position(:,1) = nestX2Pos; ant1_position(:,2) = nestY2Pos; ant1_position(:,3) = 0;
        
        v = [nestXPos - foodSourceXPos, nestYPos - foodSourceYPos]; 
        z = [nestX2Pos - foodSourceXPos, nestY2Pos - foodSourceYPos]; 
        u = v/norm(v); uu = z/norm(z);
        
        t = 0; tt = 0; food_found = 0;
        
        while (t < T_end)
            % --- COLONY 1 ---
            for j = 1:N1 
                R = randi([1,N1]); 
                if(ant_position(R,3) == 0) 
                    x = round(ant_position(R,1)); y = round(ant_position(R,2)); 
                    du = ones(8,1); dr = ones(8,1);
                    
                    if (x > 1 && x < M && y > 1 && y < M)
                        du(1) = U(x+1,y)-U(x,y); du(2) = U(x+1,y+1)-U(x,y); du(3) = U(x,y+1)-U(x,y); du(4) = U(x-1,y+1)-U(x,y);
                        du(5) = U(x-1,y)-U(x,y); du(6) = U(x-1,y-1)-U(x,y); du(7) = U(x,y-1)-U(x,y); du(8) = U(x+1,y-1)-U(x,y);
                        
                        dr(1) = W(x+1,y)-W(x,y); dr(2) = W(x+1,y+1)-W(x,y); dr(3) = W(x,y+1)-W(x,y); dr(4) = W(x-1,y+1)-W(x,y);
                        dr(5) = W(x-1,y)-W(x,y); dr(6) = W(x-1,y-1)-W(x,y); dr(7) = W(x,y-1)-W(x,y); dr(8) = W(x+1,y-1)-W(x,y);
                    end
                    
                    weight1 = zeros(8,1);
                    for jj = 1:8
                        if du(jj) < 0
                            weight1(jj) = change_ant_position; 
                        else
                            weight1(jj) = (1 + du(jj))/(1 + (B_Scalar2*dr(jj))); 
                        end
                    end
                    
                    Prob1 = cumsum(weight1 / sum(weight1)); R1 = rand;
                    
                    if R1 < Prob1(1), ant_position(R,1) = min(M, x+1);
                    elseif R1 < Prob1(2), ant_position(R,1) = min(M, x+1); ant_position(R,2) = min(M, y+1);
                    elseif R1 < Prob1(3), ant_position(R,2) = min(M, y+1);
                    elseif R1 < Prob1(4), ant_position(R,1) = max(1, x-1); ant_position(R,2) = min(M, y+1);
                    elseif R1 < Prob1(5), ant_position(R,1) = max(1, x-1);
                    elseif R1 < Prob1(6), ant_position(R,1) = max(1, x-1); ant_position(R,2) = max(1, y-1);
                    elseif R1 < Prob1(7), ant_position(R,2) = max(1, y-1);
                    else, ant_position(R,1) = min(M, x+1); ant_position(R,2) = max(1, y-1);
                    end
                    
                    % Track First Passage Time
                    if norm(ant_position(R,1:2) - [foodSourceXPos, foodSourceYPos]) < 1.5
                        ant_position(R,3) = 1; food_found = 1;
                        if T_first_1(nn) == 0; T_first_1(nn) = t; end
                    end
                else 
                    ant_position(R,1:2) = ant_position(R,1:2) + u; 
                    if norm(ant_position(R,1:2) - [nestXPos, nestYPos]) < 1.5
                        ant_position(R,3) = 0; ant_position(R,1:2) = [nestXPos, nestYPos];
                    end
                end
            end
            
            % --- COLONY 2 ---
            for l = 1:N2 
                G = randi([1,N2]); 
                if(ant1_position(G,3) == 0) 
                    x = round(ant1_position(G,1)); y = round(ant1_position(G,2)); 
                    du = ones(8,1); dr = ones(8,1);
                    
                    if (x > 1 && x < M && y > 1 && y < M)
                        dr(1) = W(x+1,y)-W(x,y); dr(2) = W(x+1,y+1)-W(x,y); dr(3) = W(x,y+1)-W(x,y); dr(4) = W(x-1,y+1)-W(x,y);
                        dr(5) = W(x-1,y)-W(x,y); dr(6) = W(x-1,y-1)-W(x,y); dr(7) = W(x,y-1)-W(x,y); dr(8) = W(x+1,y-1)-W(x,y);
                        
                        du(1) = U(x+1,y)-U(x,y); du(2) = U(x+1,y+1)-U(x,y); du(3) = U(x,y+1)-U(x,y); du(4) = U(x-1,y+1)-U(x,y);
                        du(5) = U(x-1,y)-U(x,y); du(6) = U(x-1,y-1)-U(x,y); du(7) = U(x,y-1)-U(x,y); du(8) = U(x+1,y-1)-U(x,y);
                    end
                    
                    weight2 = zeros(8,1);
                    for ll = 1:8
                        if dr(ll) < 0
                            weight2(ll) = change_ant_position; 
                        else
                            weight2(ll) = (1 + dr(ll))/(1 + (B_Scalar1*du(ll))); 
                        end
                    end
                    
                    Prob2 = cumsum(weight2 / sum(weight2)); G1 = rand;
                    
                    if G1 < Prob2(1), ant1_position(G,1) = min(M, x+1);
                    elseif G1 < Prob2(2), ant1_position(G,1) = min(M, x+1); ant1_position(G,2) = min(M, y+1);
                    elseif G1 < Prob2(3), ant1_position(G,2) = min(M, y+1);
                    elseif G1 < Prob2(4), ant1_position(G,1) = max(1, x-1); ant1_position(G,2) = min(M, y+1);
                    elseif G1 < Prob2(5), ant1_position(G,1) = max(1, x-1);
                    elseif G1 < Prob2(6), ant1_position(G,1) = max(1, x-1); ant1_position(G,2) = max(1, y-1);
                    elseif G1 < Prob2(7), ant1_position(G,2) = max(1, y-1);
                    else, ant1_position(G,1) = min(M, x+1); ant1_position(G,2) = max(1, y-1);
                    end
                    
                    % Track First Passage Time
                    if norm(ant1_position(G,1:2) - [foodSourceXPos, foodSourceYPos]) < 1.5
                        ant1_position(G,3) = 1; food_found = 1;
                        if T_first_2(nn) == 0; T_first_2(nn) = t; end
                    end
                else 
                    ant1_position(G,1:2) = ant1_position(G,1:2) + uu; 
                    if norm(ant1_position(G,1:2) - [nestX2Pos, nestY2Pos]) < 1.5
                        ant1_position(G,3) = 0; ant1_position(G,1:2) = [nestX2Pos, nestY2Pos];
                    end
                end
            end
            
            % --- PDE DIFFUSION ---
            if (food_found > 0)
                while (tt < 1)
                    V = U; O = W;
                    for i = 2:M-1
                        for j = 2:M-1
                            V(i,j) = U(i,j) + dt*D*(U(i+1,j)+U(i-1,j)+U(i,j+1)+U(i,j-1)-4*U(i,j))-dt*gamma*U(i,j);
                            O(i,j) = W(i,j) + dt*D*(W(i+1,j)+W(i-1,j)+W(i,j+1)+W(i,j-1)-4*W(i,j))-dt*gamma*W(i,j);
                        end
                    end
                    
                    ret1 = ant_position(ant_position(:,3) == 1, :);
                    for jj=1:size(ret1,1)
                        rr = max(1, min(M, round(ret1(jj,1)))); cc = max(1, min(M, round(ret1(jj,2))));
                        V(rr,cc) = V(rr,cc) + dt*exp(-norm(ret1(jj,1:2) - [foodSourceXPos, foodSourceYPos])^2);
                    end
                    
                    ret2 = ant1_position(ant1_position(:,3) == 1, :);
                    for qq=1:size(ret2,1)
                        ee = max(1, min(M, round(ret2(qq,1)))); ff = max(1, min(M, round(ret2(qq,2))));
                        O(ee,ff) = O(ee,ff) + dt*exp(-norm(ret2(qq,1:2) - [foodSourceXPos, foodSourceYPos])^2);
                    end
                    
                    U = V; W = O; tt = tt + dt;
                end
            end
            tt=0; t = t+1;
        end
    end
    
    % CALCULATE FIRST-PASSAGE EXTREME WIN PROBABILITY (Handling Ties)
    C2_wins = (T_first_2 > 0) & ((T_first_2 < T_first_1) | (T_first_1 == 0));
    C2_ties = (T_first_2 > 0) & (T_first_1 > 0) & (T_first_2 == T_first_1);
    
    ProbOnlyColony2_FirstPassage = (sum(C2_wins) + 0.5 * sum(C2_ties)) / NumSimulations;
end