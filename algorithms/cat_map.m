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

% # 2D cat map

% * 输入：
%     * P -> $N\times N$ image
%     * type
%         * 'encry': 正向cat_map$$
% \left[\begin{array}{l}
% x^{\prime} \\
% y^{\prime}
% \end{array}\right]=\left[\begin{array}{cc}
% 1 & a \\
% b & a b+1
% \end{array}\right]\left[\begin{array}{l}
% x \\
% y
% \end{array}\right] \bmod N
% $$
%         * else: 反向cat_map$$
% \left[\begin{array}{l}
% x \\
% y
% \end{array}\right]=\left[\begin{array}{cc}
% a b+1 & -a \\
% -b & 1
% \end{array}\right]\left[\begin{array}{l}
% x^{\prime} \\
% y^{\prime}
% \end{array}\right] \bmod N
% $$
% * 输出：
%     * Q -> $N\times N$ image

% * **注意：x, y表示原始像素的坐标，从0开始。而matlab矩阵的下标从1开始**。

% + tags=[]
function Q = cat_map(P, type, a, b, count)
   
    if (nargin < 3)
        a = 2;
        b = 3;
        count = 13;
    end
    
    Q = P;
    N = size(P, 1);
    
    
    if type == 'encry'   %% Arnold map
        A = [1 a;b a*b+1] ^ count;
    else        %% inverse Arnold map
        A = [a*b+1 -a;-b 1] ^ count;
    end
    
    A = mod(A,N);
    x = linspace(0, N - 1, N);
    i = repmat(x, N, 1);
    j = i';
    x = mod( i(:) * A(1,1) + j(:) * A(1,2), N);
    y = mod( i(:) * A(2,1) + j(:) * A(2,2), N);
    
    
    new_pos = uint32(y * N + x + 1);
    old_pos = uint32(j(:) * N + i(:) + 1);
    Q(new_pos) = P(old_pos);

end
