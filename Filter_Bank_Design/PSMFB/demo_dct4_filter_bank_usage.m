clear all; close all; clc
% shows the usage of a cosine modulated filter bank
% all designed cosine modulated filter banks, including windows for MDCT,
% work here

load my_dct4_fb;
h=fb.h; g=fb.g; Lh=length(h); Lg=length(g); T=fb.T; B=fb.B; shift_i=fb.i; shift_j=fb.j;

x = zeros(100, 1);
for i = 1 : 10
    x(ceil(rand*length(x))) = sign(randn);
end

% DCT-IV is available only in very recent Matlab versions
% Here I just use the DCT-IV matrix for this transformation 
dct_iv_mtx = zeros(T/4);    
for k = 0 : T/4-1
    for n = 0 : T/4-1
        dct_iv_mtx(k+1, n+1) = sqrt(2/(T/4))*cos(pi/(T/4)*(n+0.5)*(k+0.5));
    end
end

h = [h; zeros(ceil(Lh/T)*T-Lh, 1)]; % padding zeros for code vectorization
g = [g; zeros(ceil(Lg/T)*T-Lg, 1)]; % padding zeros for code vectorization
analysis_bfr = zeros(length(h), 1);
synthesis_bfr = zeros(length(g), 1);
y = zeros(size(x));

t = 1;
while t + B - 1 <= length(x)
    analysis_bfr = [analysis_bfr(B+1:end); x(t:t+B-1)]; % update analysis buffer
    bar_x = sum(reshape(h(end:-1:1).*analysis_bfr, T, length(h)/T), 2); % this is the bar_x
    shift_bar_x = circshift(bar_x, -shift_i+1); % circular shifting shift_i-1 positions (1-shift_i in Matlab)
    X = dct_iv_mtx*(shift_bar_x(1:T/4) - shift_bar_x(T/2:-1:T/4+1) - shift_bar_x(T/2+1:3*T/4) + shift_bar_x(T:-1:3*T/4+1) );
    
    hat_X = 1*X + 0;  % do any processing here
    
    idct_iv_X = dct_iv_mtx'*hat_X;
    v = circshift([idct_iv_X; -idct_iv_X(end:-1:1); -idct_iv_X; idct_iv_X(end:-1:1)], -shift_j);
    synthesis_bfr = synthesis_bfr + g.*kron(ones(length(g)/T, 1), v); % overlap and add
    y(t:t+B-1) = synthesis_bfr(1:B);    % read out the oldest B samples
    synthesis_bfr = [synthesis_bfr(B+1:end); zeros(B, 1)];  % pop out old samples, and pad zeros
    
    t = t + B;  % go to next block 
end

stem(x, '.');
hold on; stem(y, '.')
xlabel('Time')
legend('Original signal', 'Reconstructed signal')
title('Delay showing in the plot should be \tau_0 - \it B + 1') % because the oldest in the block already waits for B -1 samples for the newest sample