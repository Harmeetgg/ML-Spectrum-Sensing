clear all; close all; clc
% GDFT filter bank; irregular designs

fb = FilterBankStruct( );
fb.T = 22;
fb.B = 7;
fb.Gamma = [speye(fb.T/2), -speye(fb.T/2); -speye(fb.T/2), speye(fb.T/2)];

Lh = 47;
Lg = 31;
fb.tau0 = 37;
eta = 1e4;
lambda = 0;
%fb.symmetry = [0;1;0];

best_cost = inf;
best_fb = fb;
for num_trial = 1 : 10
    [h, g] = fbd_random_initial_guess(Lh, Lg, fb.B, fb.tau0);
    %fb.i=floor(rand*fb.T); fb.j = -fb.i-fb.tau0;
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

figure;
subplot(2,1,1)
plot(fb.h, 'b-');
hold on; plot(fb.g, 'k-')
legend('Analysis filter', 'Synthesis filter')
xlabel('Time')
ylabel('Impulse response')
subplot(2,1,2)
fft_size = 32768;
H = 20*log10(abs(fft(fb.h, fft_size)));
hold on; plot(pi*[1:fft_size/2]/(fft_size/2-1), H(1:fft_size/2), 'b-')
H = 20*log10(abs(fft(fb.g, fft_size)));
hold on; plot(pi*[1:fft_size/2]/(fft_size/2-1), H(1:fft_size/2), 'k-')
xlabel('\omega')
ylabel('Magnitude in dB')