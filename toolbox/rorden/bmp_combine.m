function bmp_combine (Top,Bottom,Outname);
%Creates a new bitmap with image Top above image Bottom
%  Top,Bottom: names of bitmaps to be combined [optional]
%  Outname: name for blended image [optional]
%Example
% bmp_combine('cat.png','dog.png');

if (nargin < 1)  %A not specified
   [Top,Toppth] = uigetfile({'*.bmp;*.jpg;*.png;*.tiff;';'*.*'},'Select top image');
   Top = [Toppth, Top];
end;
if (nargin < 2)  %B not specified
   [Bottom,Bottompth] = uigetfile({'*.bmp;*.jpg;*.png;*.tiff;';'*.*'},'Select bottom image');
   Bottom = [Bottompth, Bottom];
end;
if (nargin < 3) %outname not specified
    [pth,nam, ext] = fileparts(Top);
	Outname = fullfile(pth, ['c' nam ext]);
end;

It =  imread(Top);
Ib =  imread(Bottom);
maxw = max(size(It,2),size(Ib,2)); %maximum width
h = size(It,1)+size(Ib,1); %combined height
if size(It,3) ~= size(Ib,3)
    error('bmp_combine error: both images must have same bit-depth');
end;
Io = zeros(h,maxw,size(It,3),'uint8');

for x=1:size(It,2)
    for y=1:size(It,1)
        Io(y,x,:)=It(y,x,:);
    end; %for y
end;%for x
topy=size(It,1);
for x=1:size(Ib,2)
    for y=1:size(Ib,1)
        Io(y+topy,x,:)=Ib(y,x,:);
    end; %for y
end;%for x
imwrite(Io,Outname);


