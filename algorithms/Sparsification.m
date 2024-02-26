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

% # 稀疏化

% + [markdown] tags=[]
% * 输入:
%     * P: $N \times N$ image
% * 处理：
%     * type = 'encry'
%         * $\mathbf{Q} =\boldsymbol{\Psi} \times \mathbf{P} \times \boldsymbol{\Psi}^{T}$
%     * else
%         * $\mathbf{Q}=\boldsymbol{\Psi}^{T} \times \mathbf{P}  \times \boldsymbol{\Psi}$
% * 输出：
%     * Q: $N \times N$ image
% -

function Q = Sparsification(P, type)
    N = size(P, 1);
    filename = ['data/dwt_matrix', num2str(N), '.mat'];

    if exist(filename, 'file')
        load(filename, 'ww','wwt');
    else
        ww = DWT(N);
        wwt = ww';
        mkdir('data');
        save(filename, 'ww','wwt');
    end

    if type == 'encry'
        Q = ww * double(P) * wwt;
    else 
        Q = wwt * double(P) * ww;
        Q = uint8(Q);
    end
end

% + [markdown] tags=[]
% # 生成$N \times N$的SWT矩阵

% +
function ww = DWT(N)
    [h,g]= wfilters('sym8','d');      
    L = length(h); %  
    rank_max = log2(N); %  
    rank_min = double(int8(log2(L))) + 1;%  
    ww = 1; %  

    for jj = rank_min:rank_max

        nn = 2^jj;


        p1_0 = sparse([h, zeros(1, nn - L)]);
        p2_0 = sparse([g, zeros(1, nn - L)]);

  
        for ii = 1:nn / 2
            p1(ii, :) = circshift(p1_0', 2 * (ii - 1))';
            p2(ii, :) = circshift(p2_0', 2 * (ii - 1))';
        end

        w1 = [p1; p2];
        mm = 2^rank_max - length(w1);
        w = sparse([w1, zeros(length(w1), mm); zeros(mm, length(w1)), eye(mm, mm)]);
        ww = ww * w;

        clear p1; clear p2;
    end

end
