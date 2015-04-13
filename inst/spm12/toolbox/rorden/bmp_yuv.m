function bmp_yuv(Filename, Sigma, ShowFigures);
%Blurs y, u, v components of an image, saving output as bitmap with prefix
%  Filename: name of bitmap [optional]
%  BlurPixels: images will be smoothed with based on this FWHM
%  ShowFigures: if TRUE results displayed, else results saved
%Example
% bmp_yuv('photo.png');
% bmp_yuv('cat.jpg',0.75,-0.5,false,'N95'); %non-linear, auto-bias
% bmp_yuv('cat.jpg',0.75,-0.5,true,'L95'); %linear, auto-bias

fprintf('Demo: Humans are more sensitive to changes in brightness than hue.\n');

if (nargin < 1)  
   [files,pth] = uigetfile({'*.bmp;*.jpg;*.png;*.tiff;';'*.*'},'Select the Image[s]', 'MultiSelect', 'on'); 
   files = cellstr(files); %make cellstr regardless of whether user selects single or multiple images
else
    [pth,nam, ext] = fileparts(Filename);
    files = cellstr([nam, ext]); 
end;
if (nargin < 2)  
    Sigma = 3.0;
end;
if (nargin < 3)
    ShowFigures = true;
end;
Cutoff = ceil(3*Sigma);
%h = fspecial('gaussian',[1,2*Cutoff+1],Sigma)% requires image pro toolbox
h  = fspecial_sub(Cutoff, Sigma);

for i=1:size(files,2) %apply to image(s)
    nam = strvcat(deblank(files(:,i)));
    Inname = fullfile(pth, [nam]);

    %Im = Imread_mat2gray_sub(Inname); 
    Im = imread(Inname);
    ImSize = size(Im);
    %determine layers: grayscale =1, red/green/blue =3
    if length(ImSize) == 2
        fprintf('Only able to process RGB images - not grayscale\n');
        return; %only one layer - e.g. grayscale image
    end;
    %scale to range 0..1
    if isa(Im,'uint16')
        scale = 1/65535;
    elseif isa(Im,'uint8')
        scale = 1/255;
    else 
        fprintf('Unsupported data format\n');
        return;
    end;
    Im = double(Im) .* scale;
    %convert to Y,U,V
    [Y,U,V]=YUV_RGB_sub(Im);
    sY = conv2(h,h,Y,'same'); %smoothed (blurred) Y
    sU = conv2(h,h,U,'same'); %smoothed (blurred) U
    sV = conv2(h,h,V,'same'); %smoothed (blurred) V
    Im_sYUV=RGB_YUV_sub(sY,U,V); %image with blurred Y
    Im_YsUV=RGB_YUV_sub(Y,sU,V); %image with blurred U
    Im_YUsV=RGB_YUV_sub(Y,U,sV); %image with blurred V
    if ShowFigures %display histogram
        figure;
        set(gcf,'color','w');
        subplot(4,3,1);
        image(Im);
        xlabel('Original');
        set(gca,'XTick',[],'YTick',[]);

        
        subplot(4,3,4);
        image(RGB_Grayscale_sub(Y));
        xlabel('Intensity');
        set(gca,'XTick',[],'YTick',[]);
        subplot(4,3,5);
        image(RGB_GrayscaleX_sub(U));
        xlabel('R-G');
        set(gca,'XTick',[],'YTick',[]);
        subplot(4,3,6);
        image(RGB_GrayscaleX_sub(V));
        xlabel('B-G');
        set(gca,'XTick',[],'YTick',[]);
        
        subplot(4,3,7);
        image(RGB_Grayscale_sub(sY));
        xlabel('Blurred Intensity');
        set(gca,'XTick',[],'YTick',[]);
        subplot(4,3,8);
        image(RGB_GrayscaleX_sub(sU));
        xlabel('Blurred R-G');
        set(gca,'XTick',[],'YTick',[]);
        subplot(4,3,9);
        image(RGB_GrayscaleX_sub(sV));
        xlabel('Blurred B-G');
        set(gca,'XTick',[],'YTick',[]);
        
        
        subplot(4,3,10);
        image(Im_sYUV);
        xlabel('Blurred Intensity');
        set(gca,'XTick',[],'YTick',[]);
        subplot(4,3,11);
        image(Im_YsUV);
        xlabel('Blurred R-G');
        set(gca,'XTick',[],'YTick',[]);
        subplot(4,3,12);
        image(Im_YUsV);
        xlabel('Blurred B-G');
        set(gca,'XTick',[],'YTick',[]);        
    else     
        imwrite(RGB_Grayscale_sub(sY),fullfile(pth, ['sY_' nam ]));
        imwrite(RGB_GrayscaleX_sub(sU),fullfile(pth, ['sU_' nam ]));
        imwrite(RGB_GrayscaleX_sub(sV),fullfile(pth, ['sV_' nam ]));
        
        imwrite(Im_sYUV,fullfile(pth, ['sYUV_' nam ]) );
        imwrite(Im_YsUV,fullfile(pth, ['YsUV_' nam ]) );
        imwrite(Im_YUsV,fullfile(pth, ['YUsV_' nam ]) );
    end;
end;

function [H] = fspecial_sub(Cutoff,Sigma);
%construct Gaussian filter
% clones Image Processing Toolbox command
%   h = fspecial('gaussian',[1,2*Cutoff+1],Sigma)
%http://www1.ynao.ac.cn/~jinhuahe/know_base/othertopics/math.htm
%   g(x) = 1/Sigma/sqrt(2*pi) * exp[-(x)^2/2/Sigma^2],
% where sigma is the standard diviation of the gaussian probability distribution. 
%   FWHM = 2*sqrt(2*log(2)) * Sigma
% in other words http://en.wikipedia.org/wiki/Full_width_at_half_maximum
%   FWHM = 2.35482004503 * Sigma
% The gaussian function can be expressed in terms of  FWHM as
%    g(x) = 2*sqrt(log(2)/pi)/FWHM * exp(-4*log(2) * (x)^2/FWHM^2)
%    h = 2*sqrt(log(2)/pi)/FWHM * exp(-4*log(2) * [-Cutoff: 1: Cutoff].^2/FWHM^2)
H = 1/Sigma/sqrt(2*pi) * exp(-[-Cutoff: 1: Cutoff].^2/2/Sigma ^2);
H = H/sum(H); %normalize results
%end 
 

function [Y,U,V]=YUV_RGB_sub(Im)
    % This program transform RGB layers to YUV layers....
    %  By  Mohammed Mustafa Siddeq
    %  Date 25/7/2010
    Im=double(Im);
    R=Im(:,:,1); G=Im(:,:,2); B=Im(:,:,3);
    % transfom layers to YUV
    Y=((R+2*G+B)/4);
    U=R-G;
    V=B-G;
% end YUV_RGB_sub




function Im=RGB_Grayscale_sub(I)
% This function transforms a grayscale image to RGB 
%min(I(:))
%max(I(:))
Im(:,:,1)=I; Im(:,:,2)=I; Im(:,:,3)=I;
Im(Im>1) = 1;% Clip >1 
Im(Im<0) = 0;% clip < 0


% end RGB_YUV_sub

function Im=RGB_GrayscaleX_sub(I)
% This function transforms a grayscale image with range -1..1 to RGB with
% range 0..1
Im(:,:,1)=(I+1)/2; Im(:,:,2)=(I+1)/2; Im(:,:,3)=(I+1)/2; 
%imshow(uint8(Im)); %warning - imshow requires the image procesing toolbox
% end RGB_YUV_sub

function Im=RGB_YUV_sub(Y,U,V)
% This program transform YUV layers to RGB Layers in one matrix 'Im'....
%  By   Mohammed Mustafa Siddeq
%  Date 25/7/2010
G=((Y-(U+V)/4));
R=U+G;
B=V+G;
%next clip intensities to range 0..1
R(R<0) = 0;
G(G<0) = 0;
B(B<0) = 0;
R(R>1) = 1;
G(G>1) = 1;
B(B>1) = 1;
Im(:,:,1)=R; Im(:,:,2)=G; Im(:,:,3)=B; 
%imshow(uint8(Im)); %warning - imshow requires the image procesing toolbox
% end RGB_YUV_sub


%with regards to RGB_YUV and YUV_RGB:
% Copyright (c) 2011, Mohammed Siddeq
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
%     * Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the distribution
%       
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.


