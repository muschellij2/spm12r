WARN = warndlg('All input files within a single folder must be of same size, otherwise you will get error message: "Index exceeds matrix dimensions. Error at line 90."', 'Filesize', 'replace');
uiwait(WARN);
clear WARN;

%%% Get directory info %%%
DCMpath = uigetdir;
cd(DCMpath);
DCMdir = dir(DCMpath);


%%% Remove non-file elements from list %%%
for i=length(DCMdir):-1:1
    if DCMdir(i).isdir == 1
        DCMdir(i) = [];
    end
end

%%% Read metadata from dicoms %%%
DIRlength = length(DCMdir);
DCMinfo(DIRlength,1) = struct('field',[]);

%%% Tangens of Gantry angle %%%
%GNT = zeros(DIRlength,1); 
%GNTtan = zeros(DIRlength,1);
%%DCMwidth = zeros(DIRlength,1);
%DCMheigth = zeros(DIRlength,1);
%PIXlength = zeros(DIRlength,1);
%TEMP = zeros(DIRlength, 1);
%SLCthick = zeros(DIRlength,1);

%get dicominfo from first slice to get gantry angle and image type
DCMinfo(1,1).data = dicominfo(DCMdir(i,1).name);
%%% Stop if fileset is not CT %%%
W = strcmp(DCMinfo(1,1).data.Modality, 'CT');
switch W
    case 0            
        msgbox('This is not a CT fileset!', 'Filetype error!', 'error'); clear DCMdir DCMinfo DCMpath DIRlength W i; return
    case 1
        disp('OK... the fileset seems to contain CTs.')
end

%get tilt angle in radians and then get tangent
GNT = convang([DCMinfo(i,1).data.GantryDetectorTilt],'deg','rad');
GNTtan = tan(GNT);

%%% Continue only if Gantry angles are unequal to zero %%%    
switch (GNTtan>0)
    case 0             
        msgbox('No need to convert! Gantry angle is zero.', 'Conversion aborted!', 'warn'); clear DCMpath DCMdir DIRlength DCMinfo GNTtan Z i W; return
    case 1
        disp('Calculating...')
end

%get dicom metadata
DCMwidth = DCMinfo(i,1).data.Width;
DCMheigth = DCMinfo(i,1).data.Height;
PIXlength = DCMinfo(i,1).data.PixelSpacing(2,1);
SLCthick = DCMinfo(i,1).data.SliceThickness;
tEnd = 0;
tStart = tic;    %time the code
for i=1:DIRlength
    
    disp(['Converting slice #',num2str(i),' of ',num2str(DIRlength)])
    %calculate offset from (gantry angle =0) in pixels based on instance
    %number. Instance number is important because the first few images in
    %the series may in fact be blank(?)
   
    Offset = GNTtan*SLCthick*([DCMinfo(i,1).data.InstanceNumber]-1)/PIXlength;
    Offset = round(Offset);
    filein = dicomread(DCMdir(i).name);
    
    %transform image in the Y direction by offset # of pixels, using an
    %affine transformation matrix. Image is moved in negative Y direction
    %(i.e. up)
    offsetmatrix = [1 0 0;0 1 0;0 (Offset*-1) 1];
    xform = maketform('affine',offsetmatrix);
    fileout = imtransform(filein,xform,'XData', [1 512],'YData', [1+offsetmatrix(2,3) 512+offsetmatrix(2,3)]);
    %set gantry tilt to 0 for this slice
    DCMinfo(i,1).data.GantryDetectorTilt = 0;
    DCMinfo(i,1).data.SeriesDescription = [DCMinfo(i,1).data.SeriesDescription,' gantry corrected'];
    dicomwrite(fileout,DCMdir(i).name,DCMinfo(i).data);        
    if (i<DIRlength)
        DCMinfo(i+1,1).data = dicominfo(DCMdir(i+1,1).name);
    end
end
tEnd = toc(tStart)/DIRlength;
disp(['Finished with an average slice conversion time of: ',num2str(tEnd),' seconds'])
clear all;

