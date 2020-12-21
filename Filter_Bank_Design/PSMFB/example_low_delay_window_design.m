clear all; close all; clc
% low delay window design for short time Fourier transform analysis

fb = FilterBankStruct( );
fb.T = 64; 
fb.B = 16; 
Lh = 48;
Lg = 48;
fb.tau0 = 32; 
eta = 1e3;
lambda = 0;

[h, g] = fbd_random_initial_guess(Lh, Lg, fb.B, fb.tau0);
fb.h = h; fb.g = g;
[fb, cost, recon_err, iter] = FilterBankDesign(fb, eta, lambda, 1000);
fprintf('Cost: %g; reconstruction error: %g; iterations %g\n', cost, recon_err, iter)
plot(fb.h); hold on; plot(fb.g); legend('analysis', 'synthesis')
title('Low delay windows')
