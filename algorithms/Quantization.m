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

% * type = 'encry' -> quantization$$
% \mathbf{Q}=\left\langle\frac{\mathbf{P}-minv}{maxv-minv} \times 255\right\rangle$$

% * else -> de-Quantization$$
% \mathbf{Q}=\frac{\mathbf{P} \times\left(maxv-minv\right)}{255}+minv$$

function [Q, minv, maxv] = Quantization(P,type,minv,maxv)
    if type == 'encry'
        maxv = max(P(:));
        minv = min(P(:));
        Q = round(255 * (P - minv) / (maxv - minv));
        Q = uint8(Q);
    else
        t = (maxv - minv) / 255;
        Q = double(P) .* t + minv;
    end
end
