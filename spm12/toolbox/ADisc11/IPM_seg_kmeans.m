function segmented_image = IPM_seg_kmeans(I)
%--------------------------------------------------------------------------
% k-means clustering the information potential map(IPM). In the output, high
% potential part is labeled as 1, low potential part is labeled as 2.
%--------------------------------------------------------------------------
% Copyright (C) 2010 Lu Zhao
% McConnell Brain Imaging Center,
% Montreal Neurological Institute,
% McGill University, Montreal, QC, Canada
% zhao<at>bic.mni.mcgill.ca
% -------------------------------------------------------------------------
% The method is described in
% L. Zhao, U. Ruotsalainen, J. Hirvonen, J. Hietala and J. Tohka.
% Automatic cerebral and cerebellar hemisphere segmentation in 3D MRI:
% adaptive disconnection algorithm. Medical Image Analysis, 14(3):360-372, 
% 2010.
% L. Zhao and J. Tohka. Automatic compartmental decomposition for 3D MR 
% images of human brain. Proc. of 30th Annual International Conference 
% of the IEEE Engineering in Medicine and Biology Society, EMBC08, pages
% 3888-3891, Vancouver, Canada, August 2008.
% -------------------------------------------------------------------------
% Permission to use, copy, modify, and distribute this software for any 
% purpose and without fee is hereby granted, provided that the above 
% copyright notice appear in all copies.  The author makes no 
% representations about the suitability of this software for any purpose. 
% It is provided "as is" without express or implied warranty.
% -------------------------------------------------------------------------

% reshape the 3D image into 1D
ID = I(:); 

% find the voxels belonging to IPM 
ind_brain = find(ID~=0);  
num_brain = size(ind_brain,1);  

vals = zeros(num_brain,1); % value of IPM voxels
for j = 1 : num_brain
    vals(j) = ID(ind_brain(j));
end

% k-means clustering
[IDX,Cents] = kmeans2cluster(vals); 
% Thresholding
Thr = (Cents(1) + Cents(2))/2;
segmented_image = double(I>=Thr) + double((I>0)&(I<Thr)).*2;


function [Idx,cent]=kmeans2cluster(X)
%   Partititions the elements in the input vector X into 2 clusters using 
%   k-means clustering. 


n=length(X);
md = (max(X)+min(X))/2;
cent=[(max(X)+md)/2, (md+min(X))/2];

% allocating variables
I0=ones(n,1);
Idx=zeros(n,1);
D=zeros(n,2);

while I0~=Idx
    I0=Idx;
    % Loop for each centroid
    for t=1:2
        d=zeros(n,1);
        d=d+(X-cent(t)).^2;
        D(:,t)=d;
    end
    % Partition data to closest centroids
    [z,Idx]=min(D,[],2);
    % Update centroids using means of partitions
    for t=1:2
        cent(t)=mean(X(Idx==t));
    end
end