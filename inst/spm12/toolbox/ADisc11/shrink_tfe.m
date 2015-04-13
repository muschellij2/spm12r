function new_img = shrink_tfe(img,expand_dim);
%-------------------------------------------------------------------------
% function : recover the dimensions of images expanded with expand_tfe.m  
% input : img : a struct array containing the images whose dimensions need
%               to be shrinked.
%          expand_dim: expansion parameter generated from expand_tfe.m
% output: new_img: new img file containing shrinked images.
% modified 22nd June by Jussi Tohka: a bug fix
%-------------------------------------------------------------------------
   

 [X,Y,Z] = size(img);
  X = X - expand_dim(1,2);
  Y = Y - expand_dim(2,2);
  Z = Z - expand_dim(3,2);
  new_img = img((1 + expand_dim(1,1)):(X + expand_dim(1,1)), (1 + expand_dim(2,1)):(Y + expand_dim(2,1)),(1 + expand_dim(3,1)):(Z + expand_dim(3,1)));      

 

     

