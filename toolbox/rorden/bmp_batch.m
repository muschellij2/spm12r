function bmp_batch;
%have user select multiple images and apply bmp_blend

T1 = spm_select(inf,'^*.png$','Select images that were used for normalization');

for i=1:size(T1,1), %repeat for each image the user selected
    [p,n,x] = spm_fileparts(deblank(T1(i,:)));
    a = fullfile(p, [n x]);
    b = fullfile(p, ['a' n x]);
    frac = i/(1+size(T1,1))
    fprintf('%f of %s blended with %s %d of %d\n',frac,a,b,i,size(T1,1));
    bmp_blend(a,b,frac);
end;

