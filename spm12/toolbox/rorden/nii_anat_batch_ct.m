function nii_anat_batch_ct;
%check consistency of normalization across a group of participants
%  each person has an image (img.nii) and a MRIcron landmark file (img.anat)
% The images are normalized and deformation fields generated
%  The points from the landmark file are then transformed to normalized space
%  Good normalization should mean similar locations for normalized points
% mricron .anat files must have same name as corresponind CT: img.nii->img.anat
dir = '/Volumes/Mac_Data/ct_template/'; %location of images
ext = '.nii'; %file extension either .hdr or .nii
%next: list of anatomical, pathological and lesion images
CT = cellstr(strvcat('vp02_CT','vp03_CT','vp04_CT','vp05_CT','vp06_CT','vp10_CT','vp11_CT','vp16_CT','vp20_CT','vp21_CT','vp22_CT','vp23_CT','vp24_CT','vp26_CT','vp28_CT','vp36_CT','vp37_CT','vp38_CT','vp39_CT','vp42_CT','vp47_CT'));
Ls = cellstr(strvcat('vp02_voi','vp03_voi','vp04_voi','vp05_voi','vp06_voi','vp10_voi','vp11_voi','vp16_voi','vp20_voi','vp21_voi','vp22_voi','vp23_voi','vp24_voi','vp26_voi','vp28_voi','vp36_voi','vp37_voi','vp38_voi','vp39_voi','vp42_voi','vp47_voi'));
%NO NEED TO EDIT BEYOND THIS POINT

disp('SPM must be running with the Clinical Toolbox installed (run spm from Matlab command line)');
n = size(CT,1);

if  (n ~= size(Ls,1) )
    disp('Error: Unequal numbers of images');
    return;
end;  

%for i=1:n %for ABLe we use scalp stripped images that have the 'bm' prefix
%    CT{i} = ['bm' CT{i}];
%end;

%step 1: normalize patient scans
for i=1:n   
    CTi = fullfile(dir,[deblank(CT{i}) ext]); %anatomical image
    Lsi = fullfile(dir,[deblank(Ls{i}) ext]); %lesion image
    fprintf('Normalizing %s, job %d/%d\n', CTi, i, n);
    clinical_ctnorm(CTi, Lsi,[2 2 2], [-78 -112 -50; 78 76 85],false,true);   
    %nii_able_norm(CTi); %<- ABLe does not use lesion masking 
    fprintf('Creating deformation field for %s, job %d/%d\n', CTi, i, n);
    [pth,nam,ext, vol] = spm_fileparts(CTi);
    inversesub( fullfile(pth,['c' nam ext]) ); %we need the 'c' extension as we converted from hounsfield
    %inversesub( fullfile(pth,[nam ext]) ); %for ABLe
end; %for i : each image
return
%step 2 - convert source mm from .anat file to normalized mm for analysis…
ref = fullfile(dir,  [deblank(CT{1}) '.anat']);
for i=1:n   
    CTi = fullfile(dir,  [deblank(CT{i}) ext]); %anatomical image
    fprintf('Computing transformed anatomical coordidntes for %s, job %d/%d\n', CTi, i, n);
    nii_anatsub (CTi, 'ablect.tab', ref, i);
end; %for i : each image

function out = inversesub(filename);
%==invert the sn.mat using deformation toolbox
%filename.nii is a NIFTI image with a matching filename_sn.mat
[pth,nam,ext, vol] = spm_fileparts(filename);
matname = fullfile(pth,[nam '_sn.mat']);

matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.matname = {matname};
matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.vox = [NaN NaN NaN];
matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.bb = [NaN NaN NaN
                                                              NaN NaN NaN];
matlabbatch{1}.spm.util.defs.comp{1}.inv.space = {filename ,',1'};
matlabbatch{1}.spm.util.defs.ofname =  nam;
matlabbatch{1}.spm.util.defs.fnames = '';
%matlabbatch{1}.spm.util.defs.savedir.savepwd = 1;
matlabbatch{1}.spm.util.defs.savedir.savesrc = 1;
matlabbatch{1}.spm.util.defs.interp = 1;
spm_jobman('run',matlabbatch);

function nii_anatsub (Img, Outtext, Ref, SubjNum);
% Find normalized mm for MRIcron anat file
%  Img : nifti image before normalizeation
%  Outtext: name for output file [optional]
%  Ref: another .anat file - only regions in both .anat will be recorded [optional]
% Given img.nii, expects img.anat,  y_cimg.nii files
%  e.g. 'img.nii' with 'img.anat' and 'y_cimg.nii
% Depends on nii_map_coords.m
%Examples
%   nii_anat ('AS_T1.nii');
%   nii_anat ('AS_T1.nii', 'results.tab');

if nargin <1 %no image specified
 Img = spm_select(1,'image','Select images to convert');
 [pth,nam,ext,num] = spm_fileparts(Img);
 Img = fullfile(pth,[nam ext]);
end;
if nargin <2 %no text file
    Outtext = '';
end;
[pth,nam,ext] = spm_fileparts(Img);
anat = fullfile(pth,[nam '.anat']);
inv = fullfile(pth,['y_c' nam ext]);
if ( (exist(Img) == 0) || (exist(anat) == 0) || (exist(inv) == 0) )
    fprintf('nii_anat unable to find required files %s %s %s\n',Img,anat,inv);
    return;
end;
[rowHeaders,vx_list] = readanatsub(anat);
if nargin <3 %no reference text file
    [rowHeadersR,vx_listR] = readanatsub(anat);
else
	[rowHeadersR,vx_listR] = readanatsub(Ref);
end;


if length(Outtext) > 0, myfile = fopen(Outtext ,'at'); end; 
rows = length(rowHeadersR(1, :));
%if ( (length(rowHeaders(:)) ~= rows) || (length(vx_list(1, :)) ~= 3) || (rows < 1)   ) fprintf('Problem reading %s\n',anat); return; end;
for r = 1 : rows
	i = find(strcmp([rowHeaders{:}], rowHeadersR{r}));

	if (length(i) > 0) 
		
		XYZ_mm =  vx_list(i, :)';
		%[XYZ_mm XYZ_vx] = nii_map_coords(XYZ_mm, Img); % (XYZ_mm unaltered)
		%[wXYZ_mm wXYZ_vx] = nii_map_coords(XYZ_vx, '', mat);
        [XYZ_mm XYZ_vx] = nii_map_coords(XYZ_mm, Img); % (XYZ_mm unaltered)
        [wXYZ_mm wXYZ_vx] = nii_map_coords(XYZ_vx, '', inv,Img); % <- deform to template space
     		%wXYZ_mm = XYZ_mm; % <- make a copy of original unwarped data....
    		if length(Outtext) > 0
        		fprintf(myfile,'%d\t%d\t%s\t%s\t%f\t%f\t%f\n',SubjNum,r,anat,strvcat(rowHeaders{i}),wXYZ_mm(1),wXYZ_mm(2),wXYZ_mm(3));
    		else
        		fprintf('%d\t%d\t%s\t%s\t%f\t%f\t%f\n',SubjNum,r,anat,strvcat(rowHeaders{i}),wXYZ_mm(1),wXYZ_mm(2),wXYZ_mm(3));
            end;
	else %no items
    
        if length(Outtext) > 0
        		fprintf(myfile,'%d\t%d\t%s\t%s\n',SubjNum,r,anat,strvcat(rowHeadersR{r}));
    		else
        		fprintf('%d\t%d\t%s\t%s\n',SubjNum,r,anat,strvcat(rowHeadersR{r}));
            end;
    end;
end;

if length(Outtext) > 0, fclose(myfile); end;



function [rowHeaders,num_list] = readanatsub(fileName)
%  Syntax to be used: [rowHeaders, num_list] =  readanatsub('filename.anat')
%  where 
%      rowHeaders will be a cell array
%      num_list will be a single-precision array
%  The tab-delimited input text-file should be formatted as follows:
%        F1  -13  16  -17
%        SY  3     4    5
%        VZ  4    -5   16
%  Adapted by Chris Rorden for mricron .anat files
%    based on Manu Raghavan,June 25, 2008
% [rowHeaders,num_list] = readanat('wAS_T1.anat')
%   rowHeaders{1} = 'F1'
%   num_list(1, :) = -13    16   -17
fid=fopen(fileName);
row = 1;
tline = fgetl(fid); % Get second row (first row of data)
while(1)
    tabLocs=findstr(char(9),tline); % find the tabs
    c = textscan(tline,'%s%f32%f32%f32%f32','Delimiter',char(9));
    rowHeaders{row} = c{1}; % Get column header
    for i=2:length(c)-1
        num_list(row,i-1) = c{i}; % Get numeric data
    end
    tline = fgetl(fid); % Go to next line in text file
    if(length(tline)==1)
        if(tline==-1) % Reached end of file, terminate
            break
        end
    else
        row = row+1;
    end        
end;
fclose(fid);
