clear all; close all; clc
% this example shows how to design the windows in modified DCT
% MDCT: https://en.wikipedia.org/wiki/Modified_discrete_cosine_transform

fb = FilterBankStruct( );
fb.B = 16;
fb.T = 4*fb.B;
fb.Gamma = speye(fb.T/2) - fliplr(eye(fb.T/2));
fb.Gamma = [fb.Gamma, -fb.Gamma; -fb.Gamma, fb.Gamma];  
Lh = 2*fb.B;
Lg = Lh;
fb.tau0 = Lh-1;
fb.zeta = 0;
eta = 1e3;
lambda = 1e-10;

best_cost = inf;
best_fb = fb;
for num_trial = 1 : 10
    [h, g] = fbd_random_initial_guess(Lh, Lg, fb.B, fb.tau0);
    fb.h = h;   fb.g = g;
    fb.i = floor(fb.T/8)-fb.tau0; fb.j = -floor(fb.T/8);
    [fb, cost, recon_err, iter] = FilterBankDesign(fb, eta, lambda, 100);
    fprintf('Trial: %g; cost: %g; reconstruction error: %g; iterations %g\n', num_trial, cost, recon_err, iter)
    if cost < best_cost
        best_cost = cost;
        best_fb = fb;
    end
end
[fb, cost, recon_err, iter] = FilterBankDesign(best_fb, eta, lambda, 1000);
fprintf('Refinement. Cost: %g; reconstruction error: %g; iterations %g\n', cost, recon_err, iter)

plot(fb.h, 'b-');
hold on; plot(fb.g, 'k-')
legend('Analysis window', 'Synthesis window')
xlabel('Time')
ylabel('Impulse response')
title('Analysis window is smoother as we set \zeta=0')