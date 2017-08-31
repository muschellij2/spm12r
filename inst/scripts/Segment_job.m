%-----------------------------------------------------------------------
% Job saved on 13-Apr-2015 10:05:25 by cfg_util (rev $Rev: 6134 $)
% spm SPM - SPM12 (6225)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.spatial.preproc.channel.vols = {
% quoted filenames
'%filename%'
                                                   % ''
                                                   };
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = %biasreg%;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = %biasfwhm%;
matlabbatch{1}.spm.spatial.preproc.channel.write = [%save_bf% %save_bc%];
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {'%spmdir%/tpm/TPM.nii,1'};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = %ngaus1%;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [%native% %dartel%];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [%unmodulated% %modulated%];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {'%spmdir%/tpm/TPM.nii,2'};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = %ngaus2%;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [%native% %dartel%];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [%unmodulated% %modulated%];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {'%spmdir%/tpm/TPM.nii,3'};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = %ngaus3%;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [%native% %dartel%];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [%unmodulated% %modulated%];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {'%spmdir%/tpm/TPM.nii,4'};
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = %ngaus4%;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [%native% %dartel%];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [%unmodulated% %modulated%];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {'%spmdir%/tpm/TPM.nii,5'};
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = %ngaus5%;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [%native% %dartel%];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [%unmodulated% %modulated%];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {'%spmdir%/tpm/TPM.nii,6'};
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = %ngaus6%;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [%native% %dartel%];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [%unmodulated% %modulated%];
matlabbatch{1}.spm.spatial.preproc.warp.mrf = %mrf%;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = %warp_cleanup%;
matlabbatch{1}.spm.spatial.preproc.warp.reg = %reg%;
matlabbatch{1}.spm.spatial.preproc.warp.affreg = %affreg%;
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = %fwhm%;
matlabbatch{1}.spm.spatial.preproc.warp.samp = %samp%;
matlabbatch{1}.spm.spatial.preproc.warp.write = [%def_inverse% %def_forward%];
