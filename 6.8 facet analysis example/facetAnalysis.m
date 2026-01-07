fileList = dir('surfaceData/*.obj');
fractions = [];
for i = 1:length(fileList)
    [v,f,obj,center] = snapShot(['surfaceData/', fileList(i).name],~strcmp(fileList(i).name(8),'1'));
    normals = computeMeshNormals(v, f);
    cm = mapNormalsToRGB(normals);
    fraction = sum(cm>0.95);
    
    cm = (permute(cm,[1,3,2])-0.82)/(1-0.82);
    meshX = zeros([3,size(f,1)]);
    meshY = zeros([3,size(f,1)]);
    meshZ = zeros([3,size(f,1)]);
    for j = 1:size(meshX,2)
        meshX(:,j) = v(f(j,:),1);
        meshY(:,j) = v(f(j,:),2);
        meshZ(:,j) = v(f(j,:),3);
    end
    figure(1);clf;
    patch(meshX,meshY,meshZ,cm,'EdgeColor', 'none')
    set(gcf,'color','w');
    set(gcf,'position',[200 200 512 512])
    set(gca,'position',[0 0 1 1])
    axis equal
    view([27 25])
    xlim([-80 80])
    ylim([-80 80])
    zlim([-80 80])
    ax = gca;
    ax.BoxStyle = 'full';
    set(ax,'XTick',[])
    set(ax,'YTick',[])
    set(ax,'ZTick',[])
    
    box on
    axis on
    
    saveas(gcf,['facetVisualize/' ,fileList(i).name , '.png'])

    fractions = [fractions;fraction/size(cm,1)];
    figure(2);clf;
    hold on
    box on
    xlabel('Stage')
    ylabel('Fraction')
    legend
    plot(1:size(fractions,1), fractions(:,1),'r','DisplayName','<100>');
    plot(1:size(fractions,1), fractions(:,2),'g','DisplayName','<110>');
    plot(1:size(fractions,1), fractions(:,3),'b','DisplayName','<111>');
    drawnow
end


function [v0,f0,obj0,center] = snapShot(name, flag)
    obj = readObj(name);
    v = obj.v;
    f = obj.f.v;
    center = COM(f, v);
    %center = mean(v,1);
    v = v-center;
    if flag
        v = particleRot(v,0,90,0);%for 1, 0 90 0; for 2 all 0;
        v = particleRot(v,90,0,0);%for 1, 90 0 0; for 2 all 0;
        v = particleRot(v,0,0,0);%for 1, 0 40 0; for 2 all 0;
    else
        v = particleRot(v,0,90,0);%for 1, 0 90 0; for 2 all 0;
        v = particleRot(v,90,0,0);%for 1, 90 0 0; for 2 all 0;
        v = particleRot(v,0,40,0);%for 1, 0 40 0; for 2 all 0;
    end
    v0 = v;
    f0 = f;
    obj0 = {};
    obj0.vertices = v0;
    obj0.faces = f0;
end

function meshCenter = COM(faces, vertices)
    meshVolume = 0;
    temp = [0,0,0];

    for i = 1:length(faces)
        v1 = vertices(faces(i,1),:);
        v2 = vertices(faces(i,2),:);
        v3 = vertices(faces(i,3),:);
        center = (v1 + v2 + v3) / 4 ;
        volume = dot(v1, cross(v2, v3)) / 6;  
        meshVolume = meshVolume + volume;
        temp = temp + center * volume;
    end
    meshCenter = temp / meshVolume;
end

function v = particleRot(v,xy1,y,xy2)
    Rxy1 = [cosd(xy1) -sind(xy1) 0;
          sind(xy1)  cosd(xy1) 0;
          0 0 1];  
    v = v*Rxy1;  
    
    Ry = [1           0            0;
          0 cosd(y) -sind(y);
          0 sind(y)  cosd(y)];
    v = v*Ry;  
    
    Rxy2 = [cosd(xy2) -sind(xy2) 0;
          sind(xy2)  cosd(xy2) 0;
          0 0 1];  
    v = v*Rxy2;
end

function normals = computeMeshNormals(v, f)
    % computeMeshNormals computes the normalized surface normals for a triangle mesh.
    % Inputs:
    %   v - n-by-3 array of vertex coordinates in 3D space.
    %   f - m-by-3 array of indices, each row defines a triangle using three vertex indices.
    % Output:
    %   normals - m-by-3 array of normalized surface normal vectors.
    
    % Extract the vertices corresponding to each face
    v1 = v(f(:,1), :);
    v2 = v(f(:,2), :);
    v3 = v(f(:,3), :);
    
    % Compute edge vectors
    e1 = v2 - v1;
    e2 = v3 - v1;
    
    % Compute unnormalized normals as cross product of edge vectors
    normals = cross(e1, e2, 2);
    
    % Normalize each normal vector to unit length
    normals = normals ./ vecnorm(normals, 2, 2);
end

function colors = mapNormalsToRGB(normals)
    % mapNormalsToRGB maps surface normals to RGB colors based on Miller indices.
    % Inputs:
    %   normals - m-by-3 array of normalized surface normal vectors.
    % Outputs:
    %   colors  - m-by-3 array of RGB colors mapped from the normals.

    % Take absolute values to consider equivalent orientations
    abs_normals = abs(normals);
    weights = abs_normals;
    
    % Define RGB colors for Miller families
    rgb_1001 = [1, 0, 0];  % {100}, {010}, {001} -> Red
    rgb_1002 = [0, 1, 0];
    rgb_1003 = [0, 0, 1];

    rgb_1101 = [1, 1, 0]/norm([1, 1, 0]);  % {110} -> Green
    rgb_1102 = [1, 0, 1]/norm([1, 0, 1]);  % {101} -> Green
    rgb_1103 = [0, 1, 1]/norm([0, 1, 1]);  % {011} -> Green
    
    rgb_111 = [1, 1, 1]/norm([1, 1, 1]);  % {111}, {-111}, etc. -> Blue
    
    color_1001 = rgb_1001*weights';
    color_1002 = rgb_1002*weights';
    color_1003 = rgb_1003*weights';
    color_100 = max([color_1001',color_1002',color_1003'], [],2);

    color_1101 = rgb_1101*weights';
    color_1102 = rgb_1102*weights';
    color_1103 = rgb_1103*weights';
    color_110 = max([color_1101',color_1102',color_1103'],[],2);

    color_111 = (rgb_111*weights')';
    % Compute the interpolated color
    colors = [color_100, color_110, color_111];
end

function cm_out = applySV_to_cm(cm, S, V)
% cm: N x 1 x 3 RGB colormap (values in [0,1])
% S, V: either scalars or N-by-1 vectors you want to use

    sz = size(cm);           % [N 1 3]
    rgb = reshape(cm, [], 3);          % N x 3
    hsv = rgb2hsv(rgb);                % N x 3  (cols: H,S,V)

    % Set S and V (scalar or per-row)
    if isscalar(S), hsv(:,2) = S; else, hsv(:,2) = S(:); end
    if isscalar(V), hsv(:,3) = V; else, hsv(:,3) = V(:); end

    rgb2 = hsv2rgb(hsv);               % back to RGB
    cm_out = reshape(rgb2, sz);        % N x 1 x 3 (same shape as input)
end