%J -- 1st order 3D moment invariants; I -- 2nd order 3D moment invariants.
master_dir = 'Example'; %This should be the parent directory containing all trajectories to be analyzed. 
dirs = {dir(master_dir).name};
dirs = dirs(3:end);
close all
%%
sortedFiles = struct(); % Initialize structure to hold sorted filenames

for i = 1:numel(dirs)
    currDir = dirs{i};
    tifFiles = dir(fullfile([master_dir '\' currDir], '*.tif'));
    
    % Extract filenames
    fileNames = {tifFiles.name};
    
    % Extract numeric part from filenames using regexp
    fileNumbers = cellfun(@(x) sscanf(x, '%d.tif'), fileNames);
    
    % Sort according to numeric values
    [~, sortIdx] = sort(fileNumbers);
    sortedFileNames = fileNames(sortIdx);
    
    % Save sorted filenames in a structure
    sortedFiles(i).directory = currDir;
    sortedFiles(i).fileNames = sortedFileNames;
    sortedFiles(i).trajectory = load_trajectory(master_dir, sortedFiles(i));
end

%% Moments
for i = 1:numel(dirs)
    
    Js = zeros([length(sortedFiles(i).fileNames), 3]);
    Is = zeros([length(sortedFiles(i).fileNames), 2]);

    for j = 1:length(sortedFiles(i).fileNames)
        [Js(j,:), Is(j,:)] = moments_3d(sortedFiles(i).trajectory{j});
    end

    sortedFiles(i).moments = [Js, Is];

end
%%
moment_names = {'J1', 'J2', 'I1', 'I2', 'I3'};
for i = 1:5
    figure
    title(moment_names{i})
    hold on
    for j = 1:length({sortedFiles.directory})
        plot(0:length(sortedFiles(j).fileNames)-1, sortedFiles(j).moments(:, i))
    end
    legend({sortedFiles.directory})
    hold off
end

%% Moments with fixed CoM
for i = 1:length({sortedFiles.directory})
    V0 = sortedFiles(i).trajectory{1};
    sortedFiles(i).CoM = [m(V0,1,0,0)/m(V0,0,0,0), m(V0,0,1,0)/m(V0,0,0,0), m(V0,0,0,1)/m(V0,0,0,0)];
end

%%
for i = 1:numel(dirs)


    Js_etched = zeros([length(sortedFiles(i).fileNames), 3]);
    Is_etched = zeros([length(sortedFiles(i).fileNames), 2]);

    for j = 1:length(sortedFiles(i).fileNames)
        [Js_etched(j,:), Is_etched(j,:)] = moments_3d(sortedFiles(i).trajectory{1}-sortedFiles(i).trajectory{j}, sortedFiles(i).CoM);
    end

    sortedFiles(i).moments_etched = [Js_etched, Is_etched];

end


%%
moment_names = {'J1', 'J2', 'I1', 'I2', 'I3'};
for i = 1:5
    figure
    title([moment_names{i} ' etched'])
    hold on
    for j = 1:length({sortedFiles.directory})
        % plot(4:(length(sortedFiles(j).fileNames)-1), log(abs(sortedFiles(j).moments_etched(5:end, i))))
        plot(1:(length(sortedFiles(j).fileNames)), sortedFiles(j).moments_etched(:, i))
    end
    legend({sortedFiles.directory})
    hold off
end


%%
function [V_traj] = load_trajectory(master_dir, sortedFiles_indexed)

V_traj = {};

for i=1:length([sortedFiles_indexed.fileNames])

    tif_file = [master_dir '\' sortedFiles_indexed.directory '\' sortedFiles_indexed.fileNames{i}];
    V = im2double(tiffreadVolume(tif_file));
    V(V==max(V(:))) = 1;
    V_traj = [V_traj {V}];

end

end

function [m_pqr] = m(V, p, q, r)
    
    dims = size(V);
    x = 1:dims(1);
    y = 1:dims(2);
    z = 1:dims(3);
    [xx, yy, zz] = meshgrid(x, y, z);
    m_pqr = sum(xx.^p.*yy.^q.*zz.^r.*V, 'all');
    % m_pqr = 0;
    % for x = 1:dims(1)
    %     for y = 1:dims(2)
    %         for z = 1:dims(3)
    %             m_pqr = m_pqr + x^p*y^q*z^r*V(x, y, z);
    %         end
    %     end
    % end
end
