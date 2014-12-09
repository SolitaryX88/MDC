%% YUV Video reconstruction

% C = ones(size([A,B]));
% C(:,1:2:end) = A;
% C(:,2:2:end) = B;

num_frames = 50;

fodd = '~/ROMEO/Seq/half-odd.yuv';
feven = '~/ROMEO/Seq/half-even.yuv';
fcolor = '~/ROMEO/Seq/color.yuv';
fdepth = '~/ROMEO/Seq/depth.yuv';

startfrm = 0;
dims = [1920 1080];

inprec = 'ubit8';
sampl = 420;
yuvformat = 'YUV420_8';
writemode = 'a';


% Read file (Color and Depth) and check existence
fidc = fopen(fcolor, writemode);
fidd = fopen(fdepth, writemode);

if (fidc < 0 || fidd < 0) 
    error('Color or depth file does not exist!');
end;

fidodd = fopen(fodd,'r');
fideven = fopen(feven, 'r');

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

fseek(fidodd, startfrm * frelem , 0); %go to the starting frame
fseek(fideven, startfrm * frelem , 0); %go to the starting frame

% Y = cell(1,numfrm)
% U = cell(1,numfrm)
% V = cell(1,numfrm)

for i=1:num_frames

% Select from half - odd the color and Depth

Yfodd = fread(fidodd, dims, inprec);
Yodd = Yfodd';

% fprintf(1,'\nSize Yodd: %d & Size Yfodd: %d', size(Yodd), size(Yfodd));

UVfodd = fread(fidodd, dimsUV, inprec);
Uodd = UVfodd';
UVfodd = fread(fidodd, dimsUV, inprec);
Vodd = UVfodd';


% Select from half - odd the color and Depth

Yfeven = fread(fideven, dims, inprec);
Yeven = Yfeven';
UVfeven = fread(fideven, dimsUV, inprec);
Ueven = UVfeven';
UVfeven = fread(fideven, dimsUV, inprec);
Veven = UVfeven';

% Split Color and Depth from odd frame

Yhcodd = Yodd(:,1:dims(1)/2);
Yhdodd = Yodd(:,(dims(1)/2+1):end);

Uhcodd = Uodd(:,1:dims(1)/4);
Uhdodd = Uodd(:,(dims(1)/4+1):end);

Vhcodd = Vodd(:,1:dims(1)/4);
Vhdodd = Vodd(:,(dims(1)/4+1):end);


% Split Color and Depth from even frame

Yhceven = Yeven(:,1:dims(1)/2);
Yhdeven = Yeven(:,(dims(1)/2+1):end);

Uhceven = Ueven(:,1:dims(1)/4);
Uhdeven = Ueven(:,(dims(1)/4+1):end);

Vhceven = Veven(:,1:dims(1)/4);
Vhdeven = Veven(:,(dims(1)/4+1):end);

%     
% frame = yuv2rgb(YHeven, UHeven,VHeven);
% 
% imshow(frame)

% Reconstruct the color frame

Yc = zeros(dims(end:-1:1));
Uc = zeros(dims(end:-1:1)/2);
Vc = zeros(dims(end:-1:1)/2);

Yc(:,1:2:end) = Yhcodd;
Yc(:,2:2:end) = Yhceven;

Uc(:,1:2:end) = Uhcodd;
Uc(:,2:2:end) = Uhceven;

Vc(:,1:2:end) = Vhcodd;
Vc(:,2:2:end) = Vhceven;


% Reconstruct the depth frame

Yd = zeros(dims(end:-1:1));
Ud = zeros(dims(end:-1:1)/2);
Vd = zeros(dims(end:-1:1)/2);

Yd(:,1:2:end) = Yhdodd;
Yd(:,2:2:end) = Yhdeven;

Ud(:,1:2:end) = Uhdodd;
Ud(:,2:2:end) = Uhdeven;

Vd(:,1:2:end) = Vhdodd;
Vd(:,2:2:end) = Vhdeven;


% YUV color file
fwrite(fidc, Yc', 'uint8'); 
fwrite(fidc, Uc', 'uint8');
fwrite(fidc, Vc', 'uint8');   

% YUV depth file

fwrite(fidd, Yd', 'uint8');
fwrite(fidd, Ud', 'uint8');
fwrite(fidd, Vd', 'uint8');

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
