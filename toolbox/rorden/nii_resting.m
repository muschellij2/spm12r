function nii_resting (rawnames, maskname);
% Given images P, generates an average image
%  rawnames = filename(s) of 4D datasets
%  maskname = filename of output (optional)
%       if not specified, prefix 'mean' appended to first filename
%
% Example
%   nii_resting('/Volumes/mac_data/rest.nii');

if nargin <1 %no files
 rawnames = spm_select(inf,'image','Select images to analyze');
end;


SamplePeriod=2; %by default, set TR=2s
BandLow  =0.01; %0.01 is default for rest/FCON, 0.05 is used for ALFF
BandHigh =0.08; %0.08 is default for rest, 0.1 is default for FCON
Retrend	 ='Yes';
MaskFile = '';


for i=1:size(rawnames,1)
    
    name = deblank(rawnames(i,:));
    [pth,nam,ext]=fileparts(name);
    %detrend
    dname= fullfile(pth, ['d' nam ext ]);% detrend
    rest_detrend (name,'',10, dname);
    %temporal filter 
    dtname= fullfile(pth, ['dt' nam ext ]);% detrend
    rest_bandpass(dname, SamplePeriod,BandHigh,BandLow,Retrend,MaskFile,10,dtname );  
    %v = spm_vol(deblank(rawnames(i,:)));

end;
fprintf('All done.\n');