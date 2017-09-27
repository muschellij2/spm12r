% List of open inputs
nrun = 1; % enter the number of runs here
jobfile = {'%jobfile%'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
spm('defaults', 'FMRI');
spm_jobman('initcfg');
spm_jobman('run', jobs, inputs{:});
