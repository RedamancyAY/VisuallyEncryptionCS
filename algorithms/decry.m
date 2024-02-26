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
function [P, time] = Decry(cipher, minv, maxv, key, CR, re_method)
    
    tic;
    N = size(cipher, 1);
    paras = key_generation(key);
    x0 = paras(1); 
    x1 = paras(2); y1 =paras(3); u1 = paras(4);
    x2 = paras(5); y2 =paras(6); u2 = paras(7);
     
    S = Embedding(cipher, x2, y2, u2, ceil(N * CR), N, 'decry');
    P = Diffusion(S, x1, y1, u1, 'decry');
    P = Quantization(P, 'decry', minv, maxv);
    P = Sampling(P, x0, 'decry', CR, re_method);
    P = cat_map(P, 'decry');
    P = Sparsification(P, 'decry');
    time = toc;
end
% -


