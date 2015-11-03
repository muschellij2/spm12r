function [outmm] = maflip(mat,vec);


x = vec(1).*mat(1,1)+vec(2).*mat(1,2)+vec(3).*mat(1,3) + mat(1,4);
y = vec(2).*mat(2,1)+vec(2).*mat(2,2)+vec(3).*mat(2,3) + mat(2,4);
z = vec(3).*mat(3,1)+vec(2).*mat(3,2)+vec(3).*mat(3,3) + mat(3,4);

outmm = [x y z];