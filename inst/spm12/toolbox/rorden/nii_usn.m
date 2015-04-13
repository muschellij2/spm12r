function nii_usn (P, Cleanup, Normalize);
%perform unified segmentation normalization
%  P : input images
%  Cleanup : [optional tissue cleanup] 0=none, 1=light, 2=thorough 
%example nii_usn('T1.nii');


gm = fullfile(spm('Dir'),'tpm','grey.nii');
wm = fullfile(spm('Dir'),'tpm','white.nii');
csf = fullfile(spm('Dir'),'tpm','csf.nii');

if nargin <1 %no files
 P = spm_select(inf,'image','Select images for unified segmentation normalization');
end;
if nargin <2 %Cleanup not specified
 Cleanup = 2; %default: thorough cleanup
end;
if nargin <3 %Normalize not specified
    Normalize = false;
end;

spm_jobman('initcfg');
for i=1:size(P,1)
    ref = deblank(P(i,:));
    [pth,nam,ext] = spm_fileparts(ref);
    matlabbatch{1}.spm.spatial.preproc.data = {ref};
    
    fprintf('Unified New Segmentation of T1 %s job %d/%d\n', ref,i,size(P,1));
    if Normalize
        matlabbatch{1}.spm.spatial.preproc.output.GM = [0 1 0];
        matlabbatch{1}.spm.spatial.preproc.output.WM = [0 1 0];
        matlabbatch{1}.spm.spatial.preproc.output.CSF = [0 1 0];
        matlabbatch{1}.spm.spatial.preproc.output.biascor = 0;
    else
        matlabbatch{1}.spm.spatial.preproc.output.GM = [0 0 1];
        matlabbatch{1}.spm.spatial.preproc.output.WM = [0 0 1];
        matlabbatch{1}.spm.spatial.preproc.output.CSF = [0 0 1];
        matlabbatch{1}.spm.spatial.preproc.output.biascor = 1;
    end;
    matlabbatch{1}.spm.spatial.preproc.output.cleanup = Cleanup;
    matlabbatch{1}.spm.spatial.preproc.opts.tpm = {gm; wm; csf};
    matlabbatch{1}.spm.spatial.preproc.opts.ngaus = [2; 2; 2; 4];
    matlabbatch{1}.spm.spatial.preproc.opts.regtype = 'mni';
    matlabbatch{1}.spm.spatial.preproc.opts.warpreg = 1;
    matlabbatch{1}.spm.spatial.preproc.opts.warpco = 25;
    matlabbatch{1}.spm.spatial.preproc.opts.biasreg = 0.0001;
    matlabbatch{1}.spm.spatial.preproc.opts.biasfwhm = 60;
    matlabbatch{1}.spm.spatial.preproc.opts.samp = 3;
    matlabbatch{1}.spm.spatial.preproc.opts.msk = {''};
    fprintf('Cleanup level for %s is %d \n', ref, Cleanup);
    spm_jobman('run',matlabbatch);
end; %for each image...

% function template2native(native, tpm)   
%     [pth,nam,ext] = spm_fileparts(native);
%     matlabbatch{1}.spm.util.defs.comp{1}.sn2def.matname = {[pth,filesep, nam,'_seg_inv_sn.mat']};
%     matlabbatch{1}.spm.util.defs.comp{1}.sn2def.vox = [NaN NaN NaN];
%     matlabbatch{1}.spm.util.defs.comp{1}.sn2def.bb = [NaN NaN NaN; NaN NaN NaN];
%     matlabbatch{1}.spm.util.defs.ofname = '';
%     matlabbatch{1}.spm.util.defs.fnames = {tpm};
%     matlabbatch{1}.spm.util.defs.savedir.savepwd = 1;
%     matlabbatch{1}.spm.util.defs.interp = 1;
%     spm_jobman('run',matlabbatch);


