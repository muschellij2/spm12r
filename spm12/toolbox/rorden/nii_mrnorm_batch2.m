function nii_mrnorm_batch2;
%demo of clinical toolbox
dir = '/Volumes/Mac_Data/mrtoolbox'; %location of images
ext = '.nii'; %file extension either .hdr or .nii
%next: list of anatomical, pathological and lesion images
T1 = cellstr(strvcat('AS_T1','BF_T1','BS_T1','DC_T1','DV_T1','FJ_T1','HB_T1','JA_T1','JC_T1','JE_T1','JJ_T1','JY_T1','KS_T1','LM_T1','LO_T1','LT_T1','MA_T1','MB_T1','MB2_T1','MC_T1','MC2_T1','MK_T1','MW_T1','PM_T1','RH_T1','SF_T1','TH_T1','WC_T1','WG_T1'));
T2 = cellstr(strvcat('AS_flair','BF_T2','BS_flair','DC_T2','DV_flair','FJ_T2','HB_flair','JA_T2','JC_flair','JE_flair','JJ_flair','JY_T2','KS_T2','LM_T2','LO_T2','LT_T2','MA_T2','MB_flair','MB2_T2','MC_T2','MC2_T2','MK_T2','MW_T2','PM_T2','RH_T2','SF_T2','TH_flair','WC_flair','WG_T2'));
Ls = cellstr(strvcat('AS_LESION','BF_LESION','BS_LESION','DC_LESION','DV_LESION','FJ_LESION','HB_LESION','JA_LESION','JC_LESION','JE_LESION','JJ_LESION','JY_LESION','KS_LESION','LM_LESION','LO_LESION','LT_LESIOIN','MA_LESION','MB_LESION','MB2_LESION','MC_LESION','MC2_LESION','MK_LESION','MW_LESION','PM_LESION','RH_LESION','SF_LESION','TH_LESION','WC_LESION','WG_LESION'));

%%%%%%%NO NEED TO EDIT BEYOND THIS POINT %%%%%%
disp('SPM must be running with the clinical toolbox installed to execute this script (run spm from matlab command line)');
n = size(T1,1);
if ((n ~= size(T2,1)) ||  (n ~= size(Ls,1)))
    disp('Unequal numbers of images');
    return;
end;  

n =3;

%step 1: pre process patient scans
% step 1a: normalize all patient scans
for i=1:n   
    T1i = fullfile(dir,[deblank(T1{i}) ext]); %anatomical image
    T2i = fullfile(dir,[deblank(T2{i}) ext]); %pathological image
    Lsi = fullfile(dir,[deblank(Ls{i}) ext]); %lesion image
    fprintf('Unified segmentation of %s, job %d/%d\n', T1i, i, n);
    clinical_mrnorm_lin (T1i,Lsi,T2i, true, [1 1 1],[  -90 -126  -72;  90   90  108], false, 0.005, 2);  
end; %for i : each image
