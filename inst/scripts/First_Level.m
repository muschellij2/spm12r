% List of open inputs
% fMRI model specification: Name - cfg_entry
% fMRI model specification: Onsets - cfg_entry
% fMRI model specification: Durations - cfg_entry
nrun = X; % enter the number of runs here
jobfile = {'/Users/johnmuschelli/Dropbox/Packages/spm12r/inst/scripts/First_Level_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(3, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % fMRI model specification: Name - cfg_entry
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % fMRI model specification: Onsets - cfg_entry
    inputs{3, crun} = MATLAB_CODE_TO_FILL_INPUT; % fMRI model specification: Durations - cfg_entry
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
