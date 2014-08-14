%   Volterra_LMS.m
%       Implements the Volterra LMS algorithm for REAL valued data.
%       Also runs on the ISS and performs a comparison
%  
%   Input parameters:
%       Nr     : members of ensemble.
%       dim    : iterations.
%       Sx     : standard deviation of input.
%       Sn     : standard deviation of measurement noise.
%       u      : convergence factor matrix.
%       Nw     : length of the adaptive filter.
%      
%   Output parameters:
%       MSE    : mean-square error.
%  

% Input: 
Nr     = 2;
dim    = 1e3;
Sx     = 1; 
Sn     = 1e-2;
Nw     = 55;
u      = single(diag([0.02*ones(1,5) 0.0008*ones(1,15) 0.0003*ones(1,35)]));
% 0.08 0.05 0.005 - uniform distribution
% 0.008 0.0007 0.00005 - gaussian
% 0.02 0.0008 0.0003 - laplacian 
mse = zeros(Nr,dim,'single');
mse_ISS = zeros(Nr,dim, 'single');
for j=1:Nr
    n=(10^-1.5)*Sn*randn(dim,1,'single');        % noise at system output 
    x=Sx*single(laprnd(dim,1,0,0.7));        % input signal
   xl1=zeros(dim,1,'single'); xl2=xl1; xl3=xl1; xl4=xl1;
   xl1(2:dim)=x(1:dim-1);    % x(k-1)
   xl2(3:dim)=x(1:dim-2);    % x(k-2)
   xl3(4:dim)=x(1:dim-3);    % x(k-3)
   xl4(5:dim)=x(1:dim-4);    % x(k-4)
%    d = zeros(dim,1);
   d = single((10^-1.5)*(x+0.01*randi(10)*x.^2+0.01*randi(10)*x.^3) + n);
   exporttwovectors(x,d,'C:\usr\xtensa\Xplorer-5.0.5-workspaces\workspace\Voltera\twovecinput.txt');
%    [retcode,result] = unix('C:\usr\xtensa\XtDevTools\install\tools\RE-2014.5-win32\XtensaTools\bin\xt-run --xtensa-core=hifi2_std --xtensa-system=C:\usr\xtensa\XtDevTools\install\builds\RE-2014.5-win32\hifi2_std\config --xtensa-params= --console C:\usr\xtensa\Xplorer-5.0.5-workspaces\workspace\Voltera\bin\hifi2_std\Release\Voltera twovecinput.txt onevecoutput.txt');
%    if (retcode ~= 0)
%        error(strcat('running of ISS on target code failed SYSTEM:',result));
%    end
%    disp(result);
%    
   keyboard;
   % ISS output
   %mse_ISS(j,:) = execute(x, d, 'xt_main.c voltera.c', 'simple');
   mse_ISS(j,:) = (single(importdata('C:\usr\xtensa\Xplorer-5.0.5-workspaces\workspace\Voltera\onevecoutput.txt').')).^2;
   
   w=zeros(Nw,dim,'single');           % initial coefficient vector
   e=zeros(1,dim, 'single');
   y=zeros(1,dim, 'single');
   uxl=single([x xl1 xl2 xl3 xl4 x.^2 x.*xl1 x.*xl2 x.*xl3 x.*xl4 xl1.^2 xl1.*xl2 xl1.*xl3 xl1.*xl4 xl2.^2 xl2.*xl3 xl2.*xl4 xl3.^2 xl3.*xl4 xl4.^2 x.^3 (x.^2).*xl1 (x.^2).*xl2 (x.^2).*xl3 (x.^2).*xl4 x.*xl1.^2 x.*xl1.*xl2 x.*xl1.*xl3 x.*xl1.*xl4 x.*xl2.^2 x.*xl2.*xl3 x.*xl2.*xl4 x.*xl3.^2 x.*xl3.*xl4 x.*xl4.^2 xl1.^3 (xl1.^2).*xl2 (xl1.^2).*xl3 (xl1.^2).*xl4 xl1.*xl2.^2 xl1.*xl2.*xl3 xl1.*xl2.*xl4 xl1.*xl3.^2 xl1.*xl3.*xl4 xl1.*xl4.^2 xl2.^3 (xl2.^2).*xl3 (xl2.^2).*xl4 xl2.*xl3.^2 xl2.*xl3.*xl4 xl2.*xl4.^2 xl3.^3 (xl3.^2).*xl4 xl3.*xl4.^2 xl4.^3]'); % input vectors
   
   for i=1:dim
      e(i)=d(i)-w(:,i)'*uxl(:,i);    % error sample
      y(i)=w(:,i)'*uxl(:,i);              % output sample
      w(:,i+1)=w(:,i)+2*u*e(i)*uxl(:,i);  % new coefficient vector
   end
   mse(j,:)=e.^2;
end 

MSE=mean(mse);
MSE_ISS = mean(mse_ISS);

% Output:
figure,
plot(10*log10(MSE));
title('Learning Curve for MSE native m code');
xlabel('Number of iterations, k'); ylabel('MSE [dB]');

figure,
plot(10*log10(MSE_ISS));
title('Learning Curve for MSE ISS code');
xlabel('Number of iterations, k'); ylabel('MSE [dB]');


