%%
%%%1. Define input parameters
addpath('utils/EMIODist2')
FileName = '_20240612_124708.mrc';
inputPath = 'input/';
timeCali = importdata([inputPath,'2024_06_12_17_43_37.csv']);
timeTable = timeTable_extract([inputPath,FileName(1:end-4),'.xml']);
qp = [37;53;69;93;109;125;142;167]; %qp is for time offset calibration
%for different data, you must first review the stack with imageJ and type in
%above first ~10 frame number before the tilt happens
angle_cor = 3.62; %This parameter is to correct the tilt angle in TEM, set it to zero if the tilt axis is image Y axis
%%
%%%2. This step is for finding the time offset between the time in mrc and the time in tilt angle data.
timeCali(sum(timeCali,2)==0,:) = []; %remove the zero rows
timeCali(:,2) = [timeCali(1,2);timeCali(1,2);timeCali(1,2);timeCali(1:end-3,2)];
if max(timeCali(:,2))<pi
    timeCali(:,2) = timeCali(:,2)/pi*180; %in some versions the angle is in degree
end
[h s]=ReadMRC([inputPath,FileName],1,-1);
N = s.nz;
qp = timeTable(qp);
timeCali = [timeCali,[diff(timeCali(:,2));0]];
sampledPoints = timeCali(logical(timeCali(:,3)),1:2);

searchRange = -4:0.05:2;%sample the offet in possible range and find the one giving minimal difference
diffs = zeros([length(searchRange),1]);
itr = 1;
for offsetTime_i = searchRange
    qp_i = qp + offsetTime_i;
    [diff_i,D_i] = knnsearch(sampledPoints(:,1),qp_i);
    diffs(itr) = sum(D_i);
    itr = itr+1;
end
figure(1);clf
set(gcf,'position',[200 200 512 512])
set(gca,'position',[0.1 0.1 .8 .8])
hold on
grid on
plot(searchRange,diffs)
xlabel('Time offset (s)')
ylabel('Summed time difference (s)')
[~,idx] = min(diffs);
offsetTime = searchRange(idx) + 0.2;
timeTable = timeTable + offsetTime;
qp = qp + offsetTime;

figure(2);clf
set(gcf,'position',[200 200 512 512])
set(gca,'position',[0.1 0.1 .8 .8])
hold on
grid on
plot(timeCali(:,1),timeCali(:,2))
scatter(timeCali(logical(timeCali(:,3)),1),timeCali(logical(timeCali(:,3)),2),'red')
scatter(qp, qp*0,'g')
xlabel('Time (s)')
ylabel('Tile angle (°)')
frameList = knnsearch(timeTable,sampledPoints(:,1));
%%
%%%3. Do the segmentation and fit the background intensity
mask = double(~imread([inputPath,'mask.tif'])); %need a mask to exclude the NP when calculating the background intensity
angles = sampledPoints(1:end,2);
bkgInts = zeros([length(frameList),1]);
itr = 1;
for i = (frameList')
    [I0,s]=ReadMRC([inputPath,FileName],i, 1,0);
    I0 = double(I0);
    I = ptc_norm_crop(I0,0.01,0.25,s);
    Ib = imgaussfilt(I,12);
    Ib = Ib<0.4;
    Ib = imclearborder(Ib);
    Ib = imfill(Ib,"holes");
    L = bwlabel(Ib);
    props = regionprops(L,'Centroid','Area');
    [~,idx] = max([props.Area]);
    centroids = props(idx).Centroid;
    trans = -centroids+(s.nx+1)/2;
    It = imtranslate(I0,trans);
    It = imrotate(It,angle_cor,"bicubic","crop");
    
    Ib = imtranslate(Ib,trans);
    Ib = imrotate(Ib,angle_cor,"bicubic","crop");

    lnI = It(s.nx/4+1:s.nx/4*3,s.nx/4+1:s.nx/4*3);
    bkg = lnI(logical(mask));
     
    figure(3);clf
    set(gcf,'position',[800 200 512 512])
    set(gca,'position',[0.1 0.1 .8 .8])
    hold on
    h = histogram(bkg,0:10:500);
    y = h.Values;
    x = (h.BinEdges(1:end-1) + h.BinEdges(2:end))/2;
    [pks,locs] = findpeaks(y,'MinPeakProminence',80);
    plot(x,y,'color','r','LineWidth',1.25)
    scatter(x(locs),pks,'MarkerEdgeColor','b')
    xlabel('Intensity')
    ylabel('Count')
    bkgInts(itr) = mean(bkg);
    scatter( mean(bkg), 30000,'r')
    figure(4);clf
    set(gcf,'position',[200 200 512 512])
    set(gca,'position',[0 0 1 1])
    imagesc(It)
    colormap('gray')
    hold on
    text(25,25,num2str(sampledPoints(itr,2)),'Color','white','FontSize',15)
    drawnow
    write_tiff32(lnI,['output/backgroundTest/',FileName,'/',num2str(itr,'%05d'),'.tif']); %check the sanity of segmentation
    itr = itr+1;
end
icodst = 1./cosd(angles);
lnbkgInts = log(bkgInts);
icodst = [icodst,icodst.*0+1];
A = icodst\lnbkgInts;
figure(5)
scatter(icodst(:,1),lnbkgInts )
hold on
plot(1:0.01:2,(1:0.01:2).*A(1)+A(2))
xlabel('1/cos(tilt angle)')
ylabel('ln(background intensity)')
%%
%%%5. Center the NP and output the natural log of the original image
bkgInts = zeros([length(frameList),1]);
itr = 1;
for i = (frameList')
    [I0,s]=ReadMRC([inputPath,FileName],i, 1,0);
    I0 = double(I0);
    I = ptc_norm_crop(I0,0.01,0.25,s);
    Ib = imgaussfilt(I,12);
    Ib = Ib<0.4;
    Ib = imclearborder(Ib);
    Ib = imfill(Ib,"holes");
    L = bwlabel(Ib);
    props = regionprops(L,'Centroid','Area');
    [~,idx] = max([props.Area]);
    centroids = props(idx).Centroid;
    trans = -centroids+(s.nx+1)/2;
    It = imtranslate(I0,trans);
    It = imrotate(It,angle_cor,"bicubic","crop");
    
    Ib = imtranslate(Ib,trans);
    Ib = imrotate(Ib,angle_cor,"bicubic","crop");

    lnI = It(s.nx/4+1:s.nx/4*3,s.nx/4+1:s.nx/4*3);
    bkg = lnI(logical(mask));
     
    figure(6);clf
    set(gcf,'position',[800 200 512 512])
    set(gca,'position',[0.1 0.1 .8 .8])
    hold on
    h = histogram(bkg,0:10:500);
    y = h.Values;
    x = (h.BinEdges(1:end-1) + h.BinEdges(2:end))/2;
    [pks,locs] = findpeaks(y,'MinPeakProminence',80);
    plot(x,y,'color','r','LineWidth',1.25)
    scatter(x(locs),pks,'MarkerEdgeColor','b')
    xlabel('Intensity')
    ylabel('Count')
    bkgInts(itr) = mean(bkg);
    scatter(mean(bkg), 30000,'r')
    lnI = log(lnI)-A(2);
    lnI = -lnI + log(x(locs(1)))-A(2);

    figure(7);clf
    set(gcf,'position',[200 200 512 512])
    set(gca,'position',[0 0 1 1])
    imagesc(lnI)
    colormap('gray')
    hold on
    text(25,25,num2str(sampledPoints(itr,2)),'Color','white','FontSize',15)
    drawnow
    write_tiff32(lnI,['output/frames/',FileName,'/',num2str(itr,'%05d'),'.tif']);
    itr = itr+1;
end
writematrix(sampledPoints(1:itr-1,:),['output/tiltAnglesSeries_',FileName(1:end-4),'.csv'])
disp(sampledPoints(end,1)/size(sampledPoints,1))

function I = ptc_norm_crop(I,ptc1,ptc2,s)
    I_crop = I(s.nx/4+1:s.nx/4*3,s.nx/4+1:s.nx/4*3);
    MI = prctile(I_crop(:),ptc1*100);
    MA = prctile(I_crop(:),ptc2*100);
    I = (I-MI)/(MA-MI);
end

function write_tiff32(I,name)
    t = Tiff(name, 'w');
    tagstruct.ImageLength = size(I, 1);
    tagstruct.ImageWidth = size(I, 2);
    tagstruct.Compression = Tiff.Compression.None;
    tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP;
    tagstruct.Photometric = Tiff.Photometric.LinearRaw;
    tagstruct.BitsPerSample = 32;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    t.setTag(tagstruct);
    t.write(single(I));
    t.close();
end

function timeTable = timeTable_extract(name)
    xmlHeader = xmlread(name);
    allListItems = getElementsByTagName(xmlHeader,'Time');
    L = allListItems.getLength-1;
    timeTable = zeros([L,1]);
    thisListItem = item(allListItems,1);
    childNode = getFirstChild(thisListItem);
    childText = char(getData(childNode));
    t0 = datetime(childText,'InputFormat','HH:mm:ss.SSS');
    for i=2:L
        thisListItem = item(allListItems,i);
        childNode = getFirstChild(thisListItem);
        childText = char(getData(childNode));
        t = datetime(childText,'InputFormat','HH:mm:ss.SSS');
        t = seconds(t-t0);
        timeTable(i) = t;
        if ~mod(i,100)
            disp(['Analyzing timestamps: ',num2str(i),'/',num2str(L)])
        end
    end
end