%Simulate tilt series from simulated etching particles
%Prior to running the codes, please acquire ASTRA Toolbox and add it to
%the current directory.
for i=[30, 60, 90, 120, 180, 240, 300, 360]
    
    sfx = [num2str(i) 's'];
    Idx_PdPt1 = read_and_simulate_series(['simulated_outputs\PdPt1_' sfx],...
        -60, 50, 2.5);
    writematrix(Idx_PdPt1, ['reprojections/Idx_PdPt1_' sfx '.csv']);

    Idx_ChiralAu = read_and_simulate_series(['simulated_outputs\ChiralAu_' sfx],...
        -60, 55, 2.5);
    writematrix(Idx_ChiralAu, ['reprojections/Idx_ChiralAu_' sfx '.csv']);

    Idx_PdAu1 = read_and_simulate_series(['simulated_outputs\PdAu1_' sfx],...
        -55, 60, 5);
    writematrix(Idx_PdAu1, ['reprojections/Idx_PdAu1_' sfx '.csv']);
    % 
    % Idx_PdAu3 = read_and_simulate_series(['D:\Fast tomo\simulated_outputs\PdAu3_' sfx],...
    %     -55, 60, 5);
    % writematrix(Idx_PdAu3, ['exports/Idx_PdAu3_' sfx '.csv']);
    % 
    % Idx_PdRu = read_and_simulate_series(['D:\Fast tomo\simulated_outputs\PdRu_' sfx],...
    %     -50, 55, 2.5);
    % writematrix(Idx_PdRu, ['exports/Idx_PdRu_' sfx '.csv']);
    % 
    % Idx_Cu3As = read_and_simulate_series(['D:\Fast tomo\simulated_outputs\Cu3As_' sfx],...
    %     -60, 50, 2.5);
    % writematrix(Idx_Cu3As, ['exports/Idx_Cu3As_' sfx '.csv']);
end
