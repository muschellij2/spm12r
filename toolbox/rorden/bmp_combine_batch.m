function bmp_combine_batch(Filename);
%uses bmp_combine to combine a large number of bitmap images


if (nargin < 1)  
   [files,pth] = uigetfile({'*.bmp;*.jpg;*.png;*.tiff;';'*.*'},'Select the Image[s]', 'MultiSelect', 'on');
   files = cellstr(files); %make cellstr regardless of whether user selects single or multiple images
else
    [pth,nam, ext] = fileparts(Filename);
    files = cellstr([nam, ext]);
end;

for i=1:size(files,2)
    nam = strvcat(deblank(files(:,i)));
    Inname = fullfile(pth, [nam]);
    rInname = fullfile(pth, ['r' nam ]);
    bmp_combine(Inname,rInname);
end;