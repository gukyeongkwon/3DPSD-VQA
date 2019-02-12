function [Corr_val,  Corr_map] = CrossCorre(X, Y) 

dynmRange = diff(getrangefromclass(X));        
C = [(0.01*dynmRange).^2 (0.03*dynmRange).^2 ((0.03*dynmRange).^2)/2];
radius = 1.5;

if isempty(X)
    Corr_val = zeros(0, 'like', X);
    Corr_map = X;
    return;
end

if isa(X,'int16') % int16 is the only allowed signed-integer type for A and ref.
    % Add offset for signed-integer types to bring values in the
    % non-negative range.
    X = double(X) - double(intmin('int16'));
    Y = double(Y) - double(intmin('int16'));
elseif isinteger(X)
    X = double(X);
    Y = double(Y);
end
      
% Gaussian weighting function
gaussFilt = getGaussianWeightingFilter(radius,ndims(X));

% Weighted-mean and weighted-variance computations
mux2 = imfilter(X, gaussFilt,'conv','replicate');
muy2 = imfilter(Y, gaussFilt,'conv','replicate');
muxy = mux2.*muy2;
mux2 = mux2.^2;
muy2 = muy2.^2;

sigmax2 = imfilter(X.^2,gaussFilt,'conv','replicate') - mux2;
sigmay2 = imfilter(Y.^2,gaussFilt,'conv','replicate') - muy2;
sigmaxy = imfilter(X.*Y,gaussFilt,'conv','replicate') - muxy;
sigmaxsigmay = sqrt(sigmax2.*sigmay2);

%%%%%%%%%%%%%%%% Change is required in this part %%%%%%%%%%%%%%%%%
% Compute SSIM index
num = (sigmaxy + C(3));
den = sigmaxsigmay + C(3);
Corr_map = num./(den);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
Corr_val = mean(Corr_map(:)); 

end

% -------------------------------------------------------------------------

function gaussFilt = getGaussianWeightingFilter(radius,N)
% Get 2D or 3D Gaussian weighting filter

filtRadius = ceil(radius*3); % 3 Standard deviations include >99% of the area. 
filtSize = 2*filtRadius + 1;

if (N < 3)
    % 2D Gaussian mask can be used for filtering even one-dimensional
    % signals using imfilter. 
    gaussFilt = fspecial('gaussian',[filtSize filtSize],radius);
else 
    % 3D Gaussian mask
     [x,y,z] = ndgrid(-filtRadius:filtRadius,-filtRadius:filtRadius, ...
                    -filtRadius:filtRadius);
     arg = -(x.*x + y.*y + z.*z)/(2*radius*radius);
     gaussFilt = exp(arg);
     gaussFilt(gaussFilt<eps*max(gaussFilt(:))) = 0;
     sumFilt = sum(gaussFilt(:));
     if (sumFilt ~= 0)
         gaussFilt  = gaussFilt/sumFilt;
     end
end

end
