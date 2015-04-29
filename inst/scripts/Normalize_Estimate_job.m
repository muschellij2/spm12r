%-----------------------------------------------------------------------
% Job saved on 28-Apr-2015 22:57:10 by cfg_util (rev $Rev: 6134 $)
% spm SPM - SPM12 (6225)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.spatial.normalise.est.subj.vol = {'%filename%'};
matlabbatch{1}.spm.spatial.normalise.est.eoptions.biasreg = 0.0001;
matlabbatch{1}.spm.spatial.normalise.est.eoptions.biasfwhm = 60;
matlabbatch{1}.spm.spatial.normalise.est.eoptions.tpm = {'%spmdir%/tpm/TPM.nii'};
matlabbatch{1}.spm.spatial.normalise.est.eoptions.affreg = 'mni';
matlabbatch{1}.spm.spatial.normalise.est.eoptions.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.normalise.est.eoptions.fwhm = 0;
matlabbatch{1}.spm.spatial.normalise.est.eoptions.samp = 3;
