function nii_collapse (P);
%convert image from one set of look-up-table to a different look up table
% Designed to convert John E. Richards' segmented images to SPM tissue types
%  Consider JER codes 7=muscle and 6=scalp fat
%  Whereas SPM8's "New Segment" TPM treats both of these as a single tissue
%  type (non-brain soft tissue).
%
%Example
% nii_collapse('S0815_segmented.nii');


if nargin <1 %no files
 P = spm_select(inf,'image','Select images to collapse');
end;

%INPUT VALUES
iAIR = 0;
iWM=1;
iGM=2;
iCSF=3;
iDURA=4;
iSKULL=5;
iSKIN=6;
iMUSCLE=7;
iEYES=8;
iNASALCAVITY=9;
%OUTPUT VALUES
oAIR=0;
oGM=1;
oWM=2;
oCSF=3;
oSKULL=4;
oNONBRAINSOFT=5;

for n=1:size(P,1)
    ih = deblank(P(n,:));
    [pth,nam,ext] = spm_fileparts(ih);
    ih = spm_vol(ih); %input header
    i = spm_read_vols(ih);%Input image
    o = i; %output image
    %set all voxels to air 
    %  we will not set iAIR and iNASALCAVITY, so these will remain oAIR
    o(:) = oAIR;
    %GM
    tmp      = find((i==iGM));
    o(tmp)  = oGM;
    %WM
    tmp      = find((i==iWM));
    o(tmp)  = oWM;
    %CSF
    tmp      = find((i==iCSF));
    o(tmp)  = oCSF;
    tmp      = find((i==iDURA));
    o(tmp)  = oCSF;
    tmp      = find((i==iEYES));
    o(tmp)  = oCSF;
    %SKULL
    tmp      = find((i==iSKULL));
    o(tmp)  = oSKULL;
    %NONBRAINSOFT
    tmp      = find((i==iSKIN));
    o(tmp)  = oNONBRAINSOFT;
    tmp      = find((i== iMUSCLE));
    o(tmp)  = oNONBRAINSOFT; 
    %save results...
    ih.fname = fullfile(pth,['fx',  nam, ext]);
    spm_write_vol(ih,o);
    
    %optional last bit - save as 8-bit to save disk space....
    spm_jobman('initcfg');
    matlabbatch{1}.spm.util.imcalc.input = {ih.fname};
    ih.fname = fullfile(pth,['8fx',  nam, ext]);
    matlabbatch{1}.spm.util.imcalc.output = ih.fname;
    matlabbatch{1}.spm.util.imcalc.outdir = {pth};
    matlabbatch{1}.spm.util.imcalc.expression = 'i1';
    matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{1}.spm.util.imcalc.options.mask = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp = 1;
    matlabbatch{1}.spm.util.imcalc.options.dtype = 2; % uint8=2; int16=4; int32=8; float32=16; float64=64
    spm_jobman('run',matlabbatch);
end;%for each image