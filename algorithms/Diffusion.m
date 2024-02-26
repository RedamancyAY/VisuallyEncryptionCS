% -*- coding: utf-8 -*-
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

function Q = Diffusion(P, x0, y0, u, type)
 %% 对图像进行 diffusion 操作
    
    [M,N] = size(P);
    D = LASM_tent(x0, y0, u, M, N);
    Q = zeros(M * N, 1);
    P = P(:);
    if type == 'encry'
        Q(1) = bitxor(P(1),D(1));
        for i = 2 : M * N
            Q(i) = bitxor(Q(i-1), bitxor(P(i),D(i)));
        end
    else
        Q(1) = bitxor(P(1),D(1));
        for i = 2 : M * N
            Q(i) = bitxor(P(i-1), bitxor(P(i),D(i)));
        end
    end
    Q = reshape(Q, M, N);
end

% + tags=[] magic_args="generate diffusion matrix for diffusion operation"
function D = LASM_tent(x0, y0, u, M, N)
    D = zeros(M * N,1);
    for i = 1: M * N
        x0 = sin(pi * u * (y0 + 3) * x0 * (1 - x0));
        y0 = sin(pi * u * (x0 + 3) * y0 * (1 - y0));
        D(i) = x0;
    end

    t = 2 ^ 30;
    D = uint8(mod(floor(D * t), 256));
end
