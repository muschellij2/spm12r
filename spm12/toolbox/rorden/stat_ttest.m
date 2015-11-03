function stat_ttest;
% Compute actual probability of observed t-value by permuting the observed data
% Inputs:
%  critp: observed t-value 
%  obs: observed data
%  k : number of observations from one of the two groups

critp = 0.0035; %critical p-value
obs = [0 0 0 0 -1 0 -5 -3 -2 -3 -1 1 -1 -4 0 1 0 -2 -2 0 2 0 -4 0 0 0 1 -4 1 0 -1 -2 1 0 -1 1 -3 -5 -5 1 -6 -1 -2 2 0 -2 -7 -1 -7 0]; %observed data
%%to test: provide values from normally a random distribution
%  critp = 0.05;
%  obs = normrnd(0,1,1,50);
k = 3;
n = length(obs);
%no need to edit beyond this point
if k >= n, disp('n choose k error: population must be larger than number of samples'); end; 
if k ~= 3, disp('n choose k error: set up for k == 3'); end; 

nhit = 0;
ntest = 0;
for a = 1 : (n-k+1)
    for b = (a+1) : (n-k+2)
        for c = (b+1) : (n-k+3)
            ntest = ntest + 1;
            x = [];
            y = [];
            for i = 1 : n 
                if ( (i == a) || (i == b) || (i == c) )
                    x = [x obs(i)];                
                else
                    y = [y obs(i)];
                end;
                

            end; %for i: each observation
            [h, p] = ttest2(x,y, critp);
            if p <= critp, nhit = nhit+1; end;
        end;%c
    end; %b
end;%a
fprintf('%d out of %d permutations exceeded threshold p %f, permuted p = %f\n', nhit, ntest, critp, nhit/ntest);
%ntest should equal ch(n,k) as computed here http://www.math.sc.edu/cgi-bin/sumcgi/calculator.pl

% The function
% 	nii_minnotzero('I3C10MNCvsCttestPred1.nii') 
% reveals to the minimum z-score surviving in this image is
% 	z = 2.699595
% The web page
%    http://faculty.vassar.edu/lowry/tabs.html#z
% tells us that the one-tailed p-value is
%  0.0035
% (one tailed, as we only expect injury to make people worse at a task, not better).
% 
% We edit stat_ttest such that critp = 0.0035 and the observations are those reported in the .val file.
% 
% We then run stat_ttest (requires Matlab statistics toolbox) determine the true probability that this distribution would generate such an extreme t-test value.
% 	114 out of 19600 permutations exceeded threshold p 0.003500, permuted p = 0.005816
% Note 19600 is the n-choose-k for 3 people out of 50 having a lesion ch(50,3) - http://www.math.sc.edu/cgi-bin/sumcgi/calculator.pl
% 
% therefore, the true probability for the least significant voxel in this cluster is p = 0.005816 uncorrected for multiple comparisons.






