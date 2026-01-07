skipping = 1;
maxRate = 0;
stepSize = 5;
for i = skipping*1:skipping:13   
    [v0,f0,obj0,center] = snapShot(i-skipping);
    [v,f,obj] = snapShot(i-skipping+stepSize);

    stageLabel = stack_reader_RGB(128,128,128,['Pd@Au NP1 ML prediction/121723-1-',num2str(i-skipping,'%02d'),'.tif']);

    stageAu = stageLabel(:,:,:,2);
    stageAu = imrotate3(stageAu, -90, [0 0 1],"crop");
    stageAu = edge3(stageAu>0.5,"approxcanny",0.5);

    stagePd = stageLabel(:,:,:,1);
    stagePd = imrotate3(stagePd, -90, [0 0 1],"crop");
    stagePd = edge3(stagePd>0.5,"approxcanny",0.5);
    
    [xPd2,yPd2,zPd2] = ind2sub(size(stagePd),find(stagePd));
    vPd = [xPd2,yPd2,zPd2];
    vPd = vPd  + [-1.0,1.5,-1.0] - center;
    xPd2 = vPd(:,1); yPd2 = -vPd(:,2); zPd2 = vPd(:,3);

    [xAu2,yAu2,zAu2] = ind2sub(size(stageAu),find(stageAu));
    vAu = [xAu2,yAu2,zAu2];
    vAu = vAu + [-1.0,1.5,-1.0] - center;
    xAu2 = vAu(:,1); yAu2 = -vAu(:,2); zAu2 = vAu(:,3);

    figure(1);clf
    hold on
    box on
    set(gcf,'color','w');
    set(gcf,'position',[200 200 512 512])
    set(gca,'position',[0 0 1 1])

    %scatter3(v0(:,1),v0(:,2),v0(:,3))
    dists = pdist2(v0,v);
    [D,M] = min(dists,[],2);
    signs = (double(inpolyhedron(obj0, v))-0.5)*2;
    meshX = zeros([3,size(f0,1)]);
    meshY = zeros([3,size(f0,1)]);
    meshZ = zeros([3,size(f0,1)]);
    color = zeros([3,size(f0,1)]);

    labels = zeros([length(D), 1]);
    species_label_2 = [zeros([length(xPd2),1]);ones([length(xAu2),1])];
    coor_label_2 = [[xPd2;xAu2],[yPd2;yAu2],[zPd2;zAu2]]; %%yxz!!
    for j = 1:length(D)
        dists_e = pdist2(v0(j,:),coor_label_2);
        [~,idx] = min(dists_e);
        labels(j) = species_label_2(idx);
    end

    for j = 1:size(meshX,2)
        meshX(:,j) = v0(f0(j,:),1);
        meshY(:,j) = v0(f0(j,:),2);
        meshZ(:,j) = v0(f0(j,:),3);
        color(:,j) = [dists(f0(j,1) , M(f0(j,1)) )*signs(M(f0(j,1))), dists(f0(j,2),M(f0(j,2)) )*signs(M(f0(j,2))),dists(f0(j,3), M(f0(j,3)) )*signs(M(f0(j,3)))];
    end
    maxRate = max(maxRate,max(color(:)));
    disp(maxRate)
    patch(meshX,meshY,meshZ,color)
    %scatter3(xAu2,yAu2,zAu2,'green')
    %scatter3(xPd2,yPd2,zPd2,'red')

    axis equal
    view([-221 26])
    xlim([-60 60])
    ylim([-60 60])
    zlim([-60 60])
    box on
    ax = gca;
    ax.BoxStyle = 'full';
    set(ax,'XTick',[])
    set(ax,'YTick',[])
    set(ax,'ZTick',[])
    caxis([0 0.03*75.8*stepSize])
    shading interp
    drawnow
    box off 
    axis off

    saveas(gcf,['localEtchingRate/' ,num2str(i-skipping,'%03d') , '.png'])

    rateValues = D.*signs(M)/stepSize/75.8; %75.8s is the average time interval between two nearby stages
    curvature = importAmCurvature(['Pd@Au NP1 ML curvature/',num2str(i-skipping,'%03d'), ' MeanCurvature.am'],size(v0,1));
    T = [rateValues,curvature,labels];
    T = array2table(T,'VariableNames',{'Rate (nm/s)','Curvature (/nm)','Species'});
    writetable(T, ['localEtchingRate/' ,num2str(i-skipping,'%03d') , '.csv'])
        
    
    figure(3);clf
    hold on
    box on
    scatter(curvature(logical(labels)),rateValues(logical(labels)), 'MarkerEdgeColor','None','MarkerFaceColor','g','MarkerFaceAlpha',0.05,'DisplayName','Au')
    scatter(curvature(~logical(labels)),rateValues(~logical(labels)), 'MarkerEdgeColor','None','MarkerFaceColor','r','MarkerFaceAlpha',0.05,'DisplayName','Pd')
    xlim([-0.05 0.1])
    ylim([0 0.065])
    xlabel('Curvature (nm^-^1)')
    ylabel('Rate (nm s^-^1)')
    grid on
    legend
    saveas(gcf,['localEtchingRate/corelation_' ,num2str(i-skipping,'%03d') , '.png'])
end
figure(2);clf
box off 
axis off

h = colorbar();
colormap(parula(1000))
caxis([0 0.03])
set(gcf,'color','w');
ylabel(h,'Local etching rate (nm/s)');
saveas(gcf,['localEtchingRate/colorbar.png'])

function [v0,f0,obj0,center] = snapShot(i)
    obj = readObj(['Pd@Au NP1 ML surface/',num2str(i,'%03d'),'.obj']);
    v = obj.v;
    f = obj.f.v;
    center = COM(f, v);
    %center = mean(v,1);
    v = v-center;
    %v = particleRot(v,0,90,0);
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

function A = importAmCurvature(fileName,sz)

    fileID = fopen(fileName,'r');
    A = textscan(fileID, '%s', 'Delimiter', '');
    A = A{1};
    L= length(A);
    A = A(L-sz+1:L);
    A = cellfun( @str2num, A ) ;
    fclose(fileID);
end

function data = stack_reader_RGB(m,n,k,path)
    data = zeros([m,n,k,3]);
    for i = 1 :k
        data(:,:,i,:) = double(imread(path,i))/255;
    end
end