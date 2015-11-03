function nii_anat_batch;
%normalize nifti images and then run nii_anat to check displacement
% requires T1 image (T1) and MRIcron .anat files. Optional lesion maps (Ls)
% mricron .anat files must have same name as corresponind T1: img.nii->img.anat
dir = '/Volumes/Mac_Data/mrtoolbox'; %location of images
ext = '.nii'; %file extension either .hdr or .nii
%next: list of anatomical, pathological and lesion images
T1 = cellstr(strvcat('AS_T1','BF_T1','BS_T1','DC_T1','DV_T1','FJ_T1','HB_T1','JA_T1','JC_T1','JE_T1','JJ_T1','JY_T1','KS_T1','LM_T1','LO_T1','LT_T1','MA_T1','MB_T1','MB2_T1','MC_T1','MC2_T1','MK_T1','MW_T1','PM_T1','RH_T1','SF_T1','TH_T1','WC_T1','WG_T1'));
Ls = cellstr(strvcat('AS_LESION','BF_LESION','BS_LESION','DC_LESION','DV_LESION','FJ_LESION','HB_LESION','JA_LESION','JC_LESION','JE_LESION','JJ_LESION','JY_LESION','KS_LESION','LM_LESION','LO_LESION','LT_LESION','MA_LESION','MB_LESION','MB2_LESION','MC_LESION','MC2_LESION','MK_LESION','MW_LESION','PM_LESION','RH_LESION','SF_LESION','TH_LESION','WC_LESION','WG_LESION'));
%NO NEED TO EDIT BEYOND THIS POINT

disp('SPM must be running and the clinical toolbox installed (run spm from Matlab command line)');
n = size(T1,1);
if  (n ~= size(Ls,1) )
    disp('Error: Unequal numbers of images');
    return;
end;  
%step 1: pre process patient scans
% step 1a: normalize all patient scans
for i=1:n   
    T1i = fullfile(dir,['w' deblank(T1{i}) ext]); %anatomical image
    Lsi = fullfile(dir,['wr' deblank(Ls{i}) ext]); %lesion image
    fprintf('Unified segmentation of %s, job %d/%d\n', T1i, i, n);
    clinical_mrnorm (T1i,Lsi,'', true, [2 2 2],[-78 -112 -50; 78 76 85], false, 0, 0); %lesion mask new sym template
end; %for i : each image

%step 2 - convert source mm from .anat file to normalized mm for analysis…
ref = fullfile(dir,  ['w' deblank(T1{1}) '.anat']);
for i=1:n   
    T1i = fullfile(dir,  ['w' deblank(T1{i}) ext]); %anatomical image
    nii_anatx (T1i, 'stdmaskx.tab', ref);
end; %for i : each image
