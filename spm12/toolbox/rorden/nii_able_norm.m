function nii_able_norm (P);
%Simulates ABLe's method for CT normalization
%  P: Images to normalize
%
%Example
%  nii_able_norm('CT.nii');


if nargin <1 %no files
 P = spm_select(inf,'image','Select skull-stripped CT scans');
end;

template = fullfile(spm('Dir'),'templates','able_ct_template.nii'); 
%template = fullfile(fileparts(which(mfilename)),'able_ct_template.nii');
spm('defaults','fmri');
spm_jobman('initcfg');

for i=1:size(P,1)
    ref = deblank(P(i,:));
    [pth,nam,ext] = spm_fileparts(ref);
    fprintf('Using %s to normalize CT %s job %d/%d\n', template, ref,i,size(P,1));
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.source = {fullfile(pth, [ nam, ext])};
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.wtsrc = '';
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = {ref};
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.template = {template};
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.weight = '';
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smosrc = 8;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smoref = 0;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.regtype = 'mni';
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.cutoff = Inf; %<- only linear
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.nits = 0;%<- only linear
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = 1;
    matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
    matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.bb = [NaN NaN NaN; NaN NaN NaN];
    matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.vox = [NaN NaN NaN];
    matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.interp = 1;
    matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.prefix = 'w';
    spm_jobman('run',matlabbatch);
end;%for each image