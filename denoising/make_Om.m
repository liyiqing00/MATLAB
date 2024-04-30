function [Om] = make_Om(m,n,r);

t0 = rand(m*n,1);
[t1 indx] = sort(t0);

num_nonzero = floor(m*n*r); %0でない画素の数

Om = zeros(m,n);
Om( indx(1:num_nonzero) ) = 1;