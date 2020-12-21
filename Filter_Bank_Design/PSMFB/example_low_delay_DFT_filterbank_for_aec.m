clear all; close all; clc
% for 8 KHz sampling rate, the system delay is about 16 ms
% analysis filters is more important than synthesis filters in adaptive filtering. Thus zeta=0.1
% global minimum is about 0.057

fb = FilterBankStruct( );
fb.T = 64;
fb.B = 40;
Lh = 256;
Lg = Lh;
fb.tau0 = 128-1;
fb.zeta=0.1;
eta = 1e3;
lambda = 0;

best_cost = inf;
best_fb = fb;
for num_trial = 1 : 10
    [h, g] = fbd_random_initial_guess(Lh, Lg, fb.B, fb.tau0);
    fb.h = h;   fb.g = g;
    [fb, cost, recon_err, iter] = FilterBankDesign(fb, eta, lambda, 100);
    fprintf('Trial: %g; cost: %g; reconstruction error: %g; iterations %g\n', num_trial, cost, recon_err, iter)
    if cost < best_cost
        best_cost = cost;
        best_fb = fb;
    end
end
[fb, cost, recon_err, iter] = FilterBankDesign(best_fb, eta, lambda, 1000);
fprintf('Refinement. Cost: %g; reconstruction error: %g; iterations %g\n', cost, recon_err, iter)

freqz(fb.h, 1, 32768)