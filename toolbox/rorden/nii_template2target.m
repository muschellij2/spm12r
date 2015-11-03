function nii_template2target (TPM,iyfield);
%warps SPM new segment's template to native space
if nargin <1 %no Template
 TPM = spm_select(1,'image','Select template for new segment');
end;
if nargin <2 %no field
 iyfield = spm_select(1,'image','Select ''iy'' fieldmap');
end;

[pth,nam,ext] = spm_fileparts(deblank(TPM(1,:)));
Tem = [pth,filesep,nam,ext];


[pth,nam,ext] = spm_fileparts(deblank(iyfield(1,:)));
iy = [pth,filesep,nam,ext];

spm_jobman('initcfg');
matlabbatch{1}.spm.util.defs.comp{1}.def = {iyfield};
matlabbatch{1}.spm.util.defs.ofname = '';
matlabbatch{1}.spm.util.defs.fnames = {[Tem,',1']; [Tem,',2']; [Tem,',3']; [Tem,',4']; [Tem,',5']; [Tem,',6'] };
matlabbatch{1}.spm.util.defs.savedir.savepwd = 1;
matlabbatch{1}.spm.util.defs.interp = 1;
startdir = pwd;
cd(pth); %so we can write warped templates to this folder
spm_jobman('run',matlabbatch);
cd(startdir);
