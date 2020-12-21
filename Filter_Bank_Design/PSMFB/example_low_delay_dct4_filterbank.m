clear all; close all; clc
% we design a low delay cosine modulated filter bank here
% the number of sub-bands is an odd number 

fb = FilterBankStruct( );
fb.B = 3;
fb.T = 4*fb.B;
fb.Gamma = speye(fb.T/2) - fliplr(eye(fb.T/2));
fb.Gamma = [fb.Gamma, -fb.Gamma; -fb.Gamma, fb.Gamma];  % for DCT-IV 
Lh = 64;
Lg = Lh;
fb.tau0 = 32;
eta = 1e5;
lambda = 0;
%fb.symmetry=[-1;0;0]

best_cost = inf;
best_fb = fb;
for num_trial = 1 : 10
    fb.i = floor(rand*fb.T); fb.j = mod(-fb.tau0-fb.i, fb.T); % we randomly search for best pair (fb.i, fb.j)
    %fb.i = floor(fb.T/8)-fb.tau0; fb.j = -floor(fb.T/8);
    %fb.i = -floor(fb.T/8)-fb.tau0; fb.j = floor(fb.T/8);
    %fb.i=-fb.tau0; fb.j=0;
    %fb.i=0; fb.j=-fb.tau0;
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


figure;
subplot(2,1,1)
plot(fb.h, 'b-');
hold on; plot(fb.g, 'k-')
legend('Analysis filter', 'Synthesis filter')
xlabel('Time')
ylabel('Impulse response')
subplot(2,1,2)
for k = 0 : fb.T/4-1
    fft_size = 32768;
    modulated_h = fb.h;
    for t=0:length(fb.h)-1
        modulated_h(t+1) = cos(pi/(fb.T/4)*((-t-fb.i)+0.5)*(k+0.5))*modulated_h(t+1);
    end
    H = 20*log10(abs(fft(modulated_h, fft_size)));
    hold on; plot(pi*[1:fft_size/2]/(fft_size/2-1), H(1:fft_size/2), 'b-')
    xlabel('\omega')
    ylabel('Magnitude in dB')
end