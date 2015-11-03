function nii_anat_batch_duke;
%normalize nifti images and then run nii_anat to check displacement
% requires T1 image (T1) and MRIcron .anat files.
% mricron .anat files must have same name as corresponding T1: img.nii->img.anat
dir = '/Volumes/Mac_Data/230/anat100'; %location of images
ext = '.nii'; %file extension either .hdr or .nii
aext = '.anat'; %file extension for anatomy files
%next: list of anatomical, pathological and lesion images
T1 = cellstr(strvcat('10156_anat','10168_anat','10181_anat','10199_anat','10255_anat','10256_anat','10264_anat','10265_anat','10279_anat','10280_anat','10281_anat','10286_anat','10287_anat','10294_anat','10304_anat','10305_anat','10306_anat','10314_anat','10315_anat','10335_anat','10350_anat','10351_anat','10352_anat','10358_anat','10359_anat','10360_anat','10387_anat','10414_anat','10415_anat','10416_anat','10424_anat','10425_anat','10426_anat','10471_anat','10472_anat','10474_anat','10481_anat','10482_anat','10483_anat','10512_anat','10515_anat','10521_anat','10523_anat','10524_anat','10525_anat','10558_anat','10560_anat','10565_anat','10583_anat','10602_anat','10605_anat','10615_anat','10657_anat','10659_anat','10665_anat','10670_anat','10696_anat','10697_anat','10698_anat','10699_anat','10705_anat','10706_anat','10707_anat','10746_anat','10747_anat','10749_anat','10757_anat','10762_anat','10782_anat','10783_anat','10785_anat','10793_anat','10794_anat','10795_anat','10817_anat','10827_anat','10844_anat','10845_anat','10858_anat','10890_anat','11021_anat','11022_anat','11024_anat','11029_anat','11058_anat','11059_anat','11065_anat','11066_anat','11067_anat','11171_anat','11176_anat','11196_anat','11209_anat','11210_anat','11212_anat','11215_anat','11216_anat','11217_anat','11232_anat','11233_anat'));
Template = 'restricted'; %Optional - if 'template' then only landmarks appearing in 'template.anat' will be used
%NO NEED TO EDIT BEYOND THIS POINT

disp('SPM must be running (run spm from Matlab command line)');
n = size(T1,1);
 n = 1; disp('TEST MODE: ONLY RUNNING FIRST IMAGE!'); %<- for testing, only process at first image

% step 0: check that files exist
for i=1:n   
    T1i = fullfile(dir,[deblank(T1{i}) ext]); %anatomical image
    if (~exist(T1i)), fprintf('Error: can not find file %s\n', T1i); return; end;
    T1a = fullfile(dir,[deblank(T1{i}) aext]);
    if (~exist(T1a)), fprintf('Error: can not find file %s\n', T1a); return; end;
end; %for i : each image
fprintf('Found all %d images and anatomical files\n', n);
ref = fullfile(dir,  [Template '.anat']);
if (~exist(ref)), fprintf('Warning: no template name %s found - all landmarks will be analyzed!\n', ref); ref = ''; end;


%step 1: Normalize
% for i=1:n   
%     T1i = fullfile(dir,[deblank(T1{i}) ext]); %anatomical image
%     fprintf('normalization of %s, job %d/%d\n', T1i, i, n);
%     normT1sub(T1i);
%     inversesub(T1i);
%     anatsub (T1i, 'norm.tab', ref, i);
% end; %for i : each image

%step 2: Unified segment-normalize
% for i=1:n   
%     T1i = fullfile(dir,[deblank(T1{i}) ext]); %anatomical image
%     fprintf('unified segment-normalize of %s, job %d/%d\n', T1i, i, n);
%     segT1sub(T1i);
%     anatsub (T1i, 'segment.tab', ref, i);
% end; %for i : each image

%step 3: Default new segment
for i=1:n   
    T1i = fullfile(dir,[deblank(T1{i}) ext]); %anatomical image
    fprintf('new segment of %s, job %d/%d\n', T1i, i, n);
    newsegT1sub(T1i, true);
    %anatsub (T1i, 'newseg.tab', ref, i);
end; %for i : each image


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBROUTINES BELOW

function anatsub (Img, Outtext, Ref, SubjNum);
% Find normalized mm for MRIcron anat file
%  Img : nifti image before normalizeation
%  Outtext: name for output file [optional]
%  Ref: another .anat file - only regions in both .anat will be recorded [optional]
% Given img.nii, expects img.anat,  y_img.nii files
%  e.g. 'img.nii' with 'img.anat' and 'y_img.nii
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
inv = fullfile(pth,['y_' nam ext]);
mat = fullfile(pth,[nam '_seg_inv_sn.mat']);
if ( (exist(Img) == 0) || (exist(anat) == 0) )
    fprintf('nii_anat unable to find required files %s %s %s\n',Img,anat,inv);
    return;
end;

if (exist(inv) == 0)
    if (exist(mat) == 0)
        fprintf('nii_anat unable to find either type of required file: %s %s\n',mat,inv);
        return;
    end;
    inv = '';
end;


[rowHeaders,vx_list] = readanatsub(anat);
if (( nargin <3) || (exist(Ref) == 0  )) %no reference text file
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
        if length(inv) < 1
            [wXYZ_mm wXYZ_vx] = nii_map_coords(XYZ_vx, '', mat); % <- deform based on matrix
        else
            [wXYZ_mm wXYZ_vx] = nii_map_coords(XYZ_vx, '', inv,Img); % <- deform to template space
         end;
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
% end for subfunction anatsub

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
% end for subfunction readanatsub

function out = inversesub(filename);
%==invert the sn.mat using deformation toolbox
%filename.nii is a NIFTI image with a matching filename_sn.mat
[pth,nam,ext, vol] = spm_fileparts(filename);
matname = fullfile(pth,[nam '_sn.mat']);
matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.matname = {matname};
matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.vox = [NaN NaN NaN];
matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.bb = [NaN NaN NaN; NaN NaN NaN];
matlabbatch{1}.spm.util.defs.comp{1}.inv.space = {filename ,',1'};
matlabbatch{1}.spm.util.defs.ofname =  nam;
matlabbatch{1}.spm.util.defs.fnames = '';
matlabbatch{1}.spm.util.defs.savedir.savesrc = 1;
matlabbatch{1}.spm.util.defs.interp = 1;
spm_jobman('run',matlabbatch);
% end for subfunction inversesub


function  normT1sub(SrcName);
%normalize image using SPM8's default normalization
t1template = fullfile(spm('Dir'),'templates','T1.nii');
matlabbatch{1}.spm.spatial.normalise.est.subj.source = {[SrcName ,',1']};
matlabbatch{1}.spm.spatial.normalise.est.subj.wtsrc = '';
matlabbatch{1}.spm.spatial.normalise.est.eoptions.template = {[t1template ,',1']};
matlabbatch{1}.spm.spatial.normalise.est.eoptions.weight = '';
matlabbatch{1}.spm.spatial.normalise.est.eoptions.smosrc = 8;
matlabbatch{1}.spm.spatial.normalise.est.eoptions.smoref = 0;
matlabbatch{1}.spm.spatial.normalise.est.eoptions.regtype = 'mni';
matlabbatch{1}.spm.spatial.normalise.est.eoptions.cutoff = 25;
matlabbatch{1}.spm.spatial.normalise.est.eoptions.nits = 16;
matlabbatch{1}.spm.spatial.normalise.est.eoptions.reg = 1;
spm_jobman('run',matlabbatch);
%end for subfunction normT1sub

function  segmentT1sub(SrcName);
%normalize image using SPM8's default segment
gm = fullfile(spm('Dir'),'tpm','grey.nii');
wm = fullfile(spm('Dir'),'tpm','white.nii');
csf = fullfile(spm('Dir'),'tpm','csf.nii');
matlabbatch{1}.spm.spatial.preproc.data = {[SrcName ,',1']};
matlabbatch{1}.spm.spatial.preproc.output.GM = [0 0 0];
matlabbatch{1}.spm.spatial.preproc.output.WM = [0 0 0];
matlabbatch{1}.spm.spatial.preproc.output.CSF = [0 0 0];
matlabbatch{1}.spm.spatial.preproc.output.biascor = 0;
matlabbatch{1}.spm.spatial.preproc.output.cleanup = 0;
matlabbatch{1}.spm.spatial.preproc.opts.tpm = {gm; wm; csf};
matlabbatch{1}.spm.spatial.preproc.opts.ngaus = [2;2;2; 4];
matlabbatch{1}.spm.spatial.preproc.opts.regtype = 'mni';
matlabbatch{1}.spm.spatial.preproc.opts.warpreg = 1;
matlabbatch{1}.spm.spatial.preproc.opts.warpco = 25;
matlabbatch{1}.spm.spatial.preproc.opts.biasreg = 0.0001;
matlabbatch{1}.spm.spatial.preproc.opts.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.opts.samp = 3;
matlabbatch{1}.spm.spatial.preproc.opts.msk = {''};
spm_jobman('run',matlabbatch);
%end for subfunction segmentT1sub

function  newsegT1sub(SrcName, DefaultTemplate);
if DefaultTemplate
    Template = fullfile(spm('Dir'),'toolbox','Seg','TPM.nii');%SPM8 default template
else
    Template = fullfile(fileparts(which(mfilename)),'TPM4mm.nii'); %MNI152 2009 nonlinear, smoothed with 4mm FWHM and with custom soft tissue, air and bone masks
end;
if (~exist(Template)), fprintf('Error: can not find new segment template %s\n', Template); return; end;
matlabbatch{1}.spm.tools.preproc8.channel.vols = {[SrcName ,',1']};
matlabbatch{1}.spm.tools.preproc8.channel.biasreg = 0.0001;
matlabbatch{1}.spm.tools.preproc8.channel.biasfwhm = 60;
matlabbatch{1}.spm.tools.preproc8.channel.write = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(1).tpm = {[Template ,',1']};
matlabbatch{1}.spm.tools.preproc8.tissue(1).ngaus = 2;
matlabbatch{1}.spm.tools.preproc8.tissue(1).native = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(1).warped = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(2).tpm = {[Template ,',2']};
matlabbatch{1}.spm.tools.preproc8.tissue(2).ngaus = 2;
matlabbatch{1}.spm.tools.preproc8.tissue(2).native = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(2).warped = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(3).tpm = {[Template ,',3']};
matlabbatch{1}.spm.tools.preproc8.tissue(3).ngaus = 2;
matlabbatch{1}.spm.tools.preproc8.tissue(3).native = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(3).warped = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(4).tpm = {[Template ,',4']};
matlabbatch{1}.spm.tools.preproc8.tissue(4).ngaus = 3;
matlabbatch{1}.spm.tools.preproc8.tissue(4).native = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(4).warped = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(5).tpm = {[Template ,',5']};
matlabbatch{1}.spm.tools.preproc8.tissue(5).ngaus = 4;
matlabbatch{1}.spm.tools.preproc8.tissue(5).native = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(5).warped = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(6).tpm = {[Template ,',6']};
matlabbatch{1}.spm.tools.preproc8.tissue(6).ngaus = 2;
matlabbatch{1}.spm.tools.preproc8.tissue(6).native = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(6).warped = [0 0];
matlabbatch{1}.spm.tools.preproc8.warp.reg = 4;
matlabbatch{1}.spm.tools.preproc8.warp.affreg = 'mni';
matlabbatch{1}.spm.tools.preproc8.warp.samp = 3;
matlabbatch{1}.spm.tools.preproc8.warp.write = [1 0];
spm_jobman('run',matlabbatch);
