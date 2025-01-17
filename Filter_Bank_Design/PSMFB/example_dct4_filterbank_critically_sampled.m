clear all; close all; clc
% critically sampled cosine modulated filter using DCT-IV transform 

fb = FilterBankStruct( );
fb.T = 64;
fb.B = fb.T/4;
fb.Gamma = speye(fb.T/2) - fliplr(eye(fb.T/2));
fb.Gamma = [fb.Gamma, -fb.Gamma; -fb.Gamma, fb.Gamma];  % for DCT-IV 
Lh = 256;
Lg = Lh;
fb.tau0 = Lh-1;
fb.symmetry = [1;0;0];
eta = 0.1;
lambda = 0;

best_cost = inf;
best_fb = fb;
for num_trial = 1 : 10
    [h, g] = fbd_random_initial_guess(Lh, Lg, fb.B, fb.tau0);
    %fb.i = floor(rand*fb.T); fb.j = mod(-fb.tau0-fb.i, fb.T); % we randomly search for best pair (fb.i, fb.j)
    %fb.i = -fb.tau0; fb.j = 0;
    %fb.i = 0; fb.j = -fb.tau0;
    fb.i = floor(fb.T/8)-fb.tau0; fb.j = -floor(fb.T/8);
    %fb.i = -floor(fb.T/8)-fb.tau0; fb.j = floor(fb.T/8);
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


for k = 0 : fb.T/4-1
    fft_size = 32768;
    modulated_h = fb.h;
    for t=0:length(fb.h)-1
        modulated_h(t+1) = cos(pi/(fb.T/4)*((-t-fb.i)+0.5)*(k+0.5))*modulated_h(t+1);
    end
    H = 20*log10(abs(fft(modulated_h, fft_size)));
    if mod(k,2)==0
        hold on; plot(pi*[1:fft_size/2]/(fft_size/2-1), H(1:fft_size/2), 'k-')
    else
        hold on; plot(pi*[1:fft_size/2]/(fft_size/2-1), H(1:fft_size/2), 'k--')
    end
    xlabel('\omega')
    ylabel('Magnitude in dB')
end