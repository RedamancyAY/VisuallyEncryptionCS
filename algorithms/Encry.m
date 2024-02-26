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

function [cipher, minv, maxv, S, time] = Encry(key, P, Q, CR, re_method)
   
    tic;
    
    paras = key_generation(key);
    x0 = paras(1); 
    x1 = paras(2); y1 =paras(3); u1 = paras(4);
    x2 = paras(5); y2 =paras(6); u2 = paras(7);
    
    
    t = Sparsification(P, 'encry');
    t = cat_map(t, 'encry');
    t = Sampling(t, x0, 'encry', CR, re_method);
    [t, minv, maxv] = Quantization(t, 'encry');
    S = Diffusion(t, x1, y1, u1, 'encry');
    [M, N] = size(S);
    cipher = Embedding(Q, x2, y2, u2, M, N, 'encry', S);
    

    cipher = uint8(cipher);
    S = uint8(S);
    time = toc;
end
