if ~ispc 
	cd('~/') ;
else 
	cd('C:') ;
end
disp('Directory changed');
% List of open inputs
nrun = 1; % enter the number of runs here
jobfile = {'%jobfile%'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
spm('defaults', 'FMRI');
spm_jobman('initcfg');
spm_get_defaults('cmdline',true);
spm_get_defaults('Cmdline',true);
spm_jobman('run', jobs, inputs{:});
