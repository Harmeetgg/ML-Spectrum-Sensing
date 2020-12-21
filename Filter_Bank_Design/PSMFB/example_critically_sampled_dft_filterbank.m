clear all; close all; clc
% Critically sampled DFT filter bank. We design good analysis filters, and do not care about synthesis filters by
% setting zeta = 0

fb = FilterBankStruct( );
fb.T = 8; 
fb.B = fb.T; 
fb.zeta = 0;
Lh = 128;
Lg = Lh;
fb.tau0 = Lh - 1; 
fb.w_cut = 1.3*pi/fb.B; 
eta = 1e6;
lambda = 1e-2;

best_cost = inf;
best_fb = fb;
for num_trial = 1 : 10
    [h, g] = fbd_random_initial_guess(Lh, Lg, fb.B, fb.tau0);
    fb.h = h;   fb.g = g;
    [fb, cost, recon_err, iter] = FilterBankDesign(fb, eta, lambda, 1000);
    fprintf('Trial: %g; cost: %g; reconstruction error: %g; iterations %g\n', num_trial, cost, recon_err, iter)
    if cost < best_cost
        best_cost = cost;
        best_fb = fb;
    end
end
[fb, cost, recon_err, iter] = FilterBankDesign(best_fb, eta, lambda, 1000);
fprintf('Refinement. Cost: %g; reconstruction error: %g; iterations %g\n', cost, recon_err, iter)


fft_size = 32768;
H = 20*log10(abs(fft(fb.h, fft_size)));
plot(pi*[0:fft_size/2-1]/(fft_size/2-1), H(1:end/2), 'k-')
xlabel('\omega')
ylabel('Magnitude in dB')