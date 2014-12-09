%% YUV Color Depth Splitting
% 
% YUV Import

num_frames = 1102;

fcolor = '/home/solitaryx88/ROMEO/Seq/Martial Art/martial2.yuv';
fdepth = '/home/solitaryx88/ROMEO/Seq/Martial Art/disparity23.yuv';
fodd = '~/description2-odd.yuv';
feven = '~/description2-even.yuv';

startfrm = 0;
dims = [1920 1080];

inprec = 'ubit8';
sampl = 420;
yuvformat = 'YUV420_8';
writemode = 'a';

% Read file (Color and Depth) and check existence
fidc = fopen(fcolor,'r');
fidd = fopen(fdepth,'r');

if (fidc < 0 || fidd < 0) 
    error('Color or depth file does not exist!');
end;

% Read half even and half odd

fidodd = fopen(fodd,writemode);
fideven = fopen(feven, writemode);

if (fideven < 0 || fidodd < 0) 
    error('Could not open the file half-even or half odd!');
end;

%% Yada yada about subsampling YUV

if (strcmp(yuvformat,'YUV420_16'))
    inprec = 'uint16'; %'ubit16=>uint16'
elseif (strcmp(yuvformat,'YUV444_8'))
    sampl = 444;
end;

if (sampl == 420)
    dimsUV = dims / 2;
else
    dimsUV = dims;
end;

% End of Yada yada about subsampling in YUV

Yd = zeros(dims);
UVd = zeros(dimsUV);
frelem = numel(Yd) + 2*numel(UVd);

fseek(fidc, startfrm * frelem , 0); %go to the starting frame
fseek(fidd, startfrm * frelem , 0); %go to the starting frame

% Y = cell(1,numfrm)
% U = cell(1,numfrm)
% V = cell(1,numfrm)

for i=1:num_frames

% Getting color frame
Yfc = fread(fidc,dims,inprec);
Yc = Yfc';
UVfc = fread(fidc,dimsUV,inprec);
Uc = UVfc';
UVfc = fread(fidc,dimsUV,inprec);
Vc = UVfc';


% Getting depth frame

Yfd = fread(fidd,dims,inprec);
Yd = Yfd';
UVfd = fread(fidd,dimsUV,inprec);
Ud = UVfd';
UVfd = fread(fidd,dimsUV,inprec);
Vd = UVfd';


% Selecting half color 
YHCodd = Yc(:,1:2:end);
YHCeven = Yc(:,2:2:end);

UHCodd = Uc(:,1:2:end);
UHCeven = Uc(:,2:2:end);

VHCodd = Vc(:,1:2:end);
VHCeven = Vc(:,2:2:end);

% Selecting half depth

YHDodd = Yd(:,1:2:end);
YHDeven = Yd(:,2:2:end);

UHDodd = Ud(:,1:2:end);
UHDeven = Ud(:,2:2:end);

VHDodd = Vd(:,1:2:end);
VHDeven = Vd(:,2:2:end);


% Horizontal matrix concatinations of half color and Depth

YHodd = [YHCodd , YHDodd];
UHodd = [UHCodd , UHDodd];
VHodd = [VHCodd , VHDodd];

YHeven = [YHCeven , YHDeven];
UHeven = [UHCeven , UHDeven];
VHeven = [VHCeven , VHDeven];

% YUV odd file
fwrite(fidodd, YHodd', 'uint8'); 
fwrite(fidodd, UHodd', 'uint8');
fwrite(fidodd, VHodd', 'uint8');   

%YUV even file

fwrite(fideven, YHeven', 'uint8');
fwrite(fideven, UHeven', 'uint8');
fwrite(fideven, VHeven', 'uint8');

fprintf(1,'Frame %d processed!\n', i) ;
end

% Close the file pointers

fclose('all');

% fclose(fidodd);
% fclose(fideven);
% 
% fclose(fidc);
% fclose(fidd);

% % Testing result
% 
% frame = yuv2rgb(YHeven, UHeven,VHeven);
% 
% imshow(frame)
