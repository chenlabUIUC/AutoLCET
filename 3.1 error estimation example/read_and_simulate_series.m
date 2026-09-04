function [Idx] = read_and_simulate_series(input_dir, theta_0, theta_end, delta_theta)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
addpath('astra-1.9.0.dev11-matlab-win-x64\astra-1.9.0.dev11\tools')
addpath('astra-1.9.0.dev11-matlab-win-x64\astra-1.9.0.dev11\mex')
addpath('utils')

files = dir(fullfile(input_dir, '*.tif'));
[~, idx] = sort({files.name});
files = files(idx);
filePaths = fullfile({files.folder}, {files.name});

betas = theta_0:delta_theta:theta_end;

N = numel(files);
n = length(betas);
s = n - 1;

% compute number of blocks
m = floor((N - n) / s) + 1;

% build index matrix
Idx = (1:n) + (0:s:(m-1)*s).';

V_all = [];

outfolder = [input_dir '/sims'];

if ~exist(outfolder, 'dir')
    mkdir(outfolder);
end

for i = 1:size(Idx, 1)
    fprintf('Processing %d/%d\n',i,size(Idx, 1))
    outfile = [outfolder '/stage_' num2str(i) '.tif'];
    for j = 1:length(betas)
        V = tiffreadVolume(filePaths{Idx(i, j)})>0;

        vol_geom = astra_create_vol_geom(size(V,1), size(V,2), size(V,3));
        proj_geom = astra_create_proj_geom('parallel3d', 1.0, 1.0, size(V,1), size(V,2), betas(j)/180*pi+pi/2); %carefully cabrilated, don't change
        [proj_id, proj_data] = astra_create_sino3d_cuda(V, proj_geom, vol_geom);%carefully cabrilated, don't change
        proj_data = permute(proj_data,[3,1,2]);%carefully cabrilated, don't change
        MM = max(proj_data,[],'all');
        
        sim = proj_data/MM;
        figure(1);clf;
        set(gcf,'position',[200 200 256 256])
        set(gca,'position',[0 0 1 1])
        imshow(sim);
        drawnow;
        
        astra_mex_data3d('delete', proj_id);
    
        if j==1
            imwrite(sim, outfile, 'WriteMode', 'overwrite',  'Compression','none');
        else
            imwrite(sim, outfile, 'WriteMode', 'append',  'Compression','none');
        end
    end
    V_all = [V_all sum(V(:))];
end

figure
plot(V_all, '-o')

end