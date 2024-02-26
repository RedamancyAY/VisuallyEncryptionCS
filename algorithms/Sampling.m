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

% # 采样

% * 输入：
%     * P -> $N \times N$ image
%     * x0 -> 逻辑映射的初始状态
%     * type: 'encry' or 'decry'
%     * cr: the sampling ratio
%     * re_method: 重建算法，SL0/OMP

% * 输出
%     * type = 'encry' -> $M\times N$ measurements
%     * else -> $N \times N$ image

% * Encry：
%     1. 生成N个测量矩阵
%     2. 生成稀疏向量
%         * 计算每一列保存的非0元素个数 K
%         * 每一列只保存绝对值前K大的元素
%     3. 并行采样：每一列使用不同的测量矩阵采样

function Q = Sampling(P, x0, type, cr, re_mothod)
    
    N = size(P, 2);
    M = ceil(N * cr);
    MM = Gene_measurement_matrix(x0, M, N, N);
    
    
    if type == 'encry'
    
        % 生成稀疏向量
        if (re_mothod == 'SL0')
            a = 0.3445; b = 1.404; % SL0
        else
            a = 0.2576; b = 1.265; % OMP
        end
        K = floor( a * b * cr^b * exp(-a*cr^b) * N );
        P2 = abs(P);
        th = maxk(P2,K);
        P(find(P2(:,1:N) < th(K,:))) = 0;
        
        
        Q = zeros(M, N);
        for i = 1 : N
            Q(:,i) = MM(:,:,i) * P(:,i);
        end
    else
        Q = zeros(N, N);
        if (re_mothod == 'SL0')
            parfor i = 1:N
                Q(:,i) = CS_SL0(MM(:,:,i), P(:,i),0.000001,0.9);
            end
        else
            parfor i = 1:N
                Q(:, i) = CS_OMP(P(:, i), MM(:, :, i), int16(M / 4));
            end
        end
    end
end

% # 生成C个$M\times N$的测量矩阵

% 1. 使用逻辑映射生成2N列长为M（-1/1）的列向量T
% 2. 使用逻辑映射生成C个长为2N的列向量s
% 3. 对s的每一列进行排序，获取索引向量index
% 4. 对于第i个索引向量，取前N个数，利用这N个数从T中取出N个列向量组成一个测量矩阵。最后一共生成C个测量矩阵。

% + tags=[]
function mm = Gene_measurement_matrix(x0, M, N, C)
    mm = zeros(M,N,C);    
    
    
    T = zeros(M, 2 * N);
    for i = 1 : 2 * M *N
        x0 = 4 * x0 * (1 - x0);
        if (x0 < 0.5)
            T(i) = -1;
        else
            T(i) = 1;
        end
    end


    s = zeros(2 * N,C);
    for i = 1 : 2 * N * C
        x0 = 4 * x0 * (1 - x0);
        s(i) = x0;
    end
    
    [~,index] = sort(s);
    for k = 1 : C
        mm(:,:,k) = T(:,index(1:N,k));
    end
    
end
