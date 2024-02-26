% ---
% jupyter:
%   jupytext:
%     formats: ipynb,m:light
%     text_representation:
%       extension: .m
%       format_name: light
%       format_version: '1.5'
%       jupytext_version: 1.11.1
%   kernelspec:
%     display_name: Matlab
%     language: matlab
%     name: matlab
% ---

% + tags=[]
warning('off');
addpath('algorithms/')

% + tags=[]
key = '7A09E5F4B5241E49B12CD5521E085A87F414A078E51C08D14535B487CBB3347A0';
CR = 0.25;
re_method = 'SL0';

% + tags=[]
plain_img = ["Brain", "Girl", "Barbara", "Lena", "AirPlane"]';
embedding_img = ["Finger", "Bridge", "Peppers", "Jet", "Baboon"]';

% + tags=[]
psnr_p = zeros(5, 1);
ssim_p = zeros(5, 1);
psnr_q = zeros(5, 1);
ssim_q = zeros(5, 1);


for i = 1:5
    P = imread(strcat("pics/", plain_img(i), ".pgm"));
    Q = imread(strcat("pics/", embedding_img(i), ".pgm"));
    
    [cipher, minv, maxv, S, time] = Encry(key, P, Q, CR, re_method);
    [P_re, time2] = decry(cipher, minv, maxv, key, CR, re_method);
    
    psnr_p(i) = psnr(P, P_re);
    ssim_p(i) = mssim(P, P_re);
    psnr_q(i) = psnr(Q, cipher);
    ssim_q(i) = mssim(Q, cipher);
end

% + tags=[]
res = table(plain_img, embedding_img, psnr_q, ssim_q, psnr_p, ssim_p)
