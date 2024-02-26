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

% * 生成混沌系统的初始状态
%     * 输入：k => 256位的01字符串 或者 64位的16进制字符串
%     * 处理：
%         1. 使用 SHA256 对 `k` 进行加密, 得到一个64位的16进制的数 `s`
%         2. 将`s`转换成256位的二进制 K
%         3. 计算干涉参数
%             $$
%             \begin{aligned}
%             &x_{0}=\left(\sum_{i=1}^{64} \mathbf{K}^{\prime}[i] \times 2^{i-1}\right) / 2^{64}\\
%             &y_{0}=\left(\sum_{i=65}^{128} \mathbf{K}^{\prime}[i] \times 2^{i-65}\right) / 2^{64}\\
%             &\mu=\left(\sum_{i=129}^{192} \mathbf{K}^{\prime}[i] \times 2^{i-129}\right) / 2^{64}\\
%             & \gamma_{1}=\left(\sum_{i=193}^{213} \mathbf{K}^{\prime}[i] \times 2^{i-193}\right) / 2^{21}\\
%             &\gamma_{2}=\left(\sum_{i=214}^{234} \mathbf{K}^{\prime}[i] \times 2^{i-214}\right) / 2^{21}\\
%             &\gamma_{3}=\left(\sum_{i=235}^{256} \mathbf{K}^{\prime}[i] \times 2^{i-235}\right) / 2^{22}\\
%             \end{aligned}
%             $$
%             
%         4. 计算参数
%             $$
%             \begin{aligned}
%             & x_{0}^{(1)}=\left(\left(x_{0}+x_{0} \times 2^{5} \times \gamma_{1}\right) \quad \bmod 1\right)+10^{-5}\\
%             &\text {  for } i=2: 3 \text { do }\\
%             &\begin{array}{l|ll}
%             & x_{0}^{(i)}=\left(\left(x_{0}+x_{0} \times 2^{i \times 5} \times \gamma_{i}\right) \quad \bmod 1\right)+10^{-5} \\
%             & y_{0}^{(i)}=\left(\left(y_{0}+y_{0} \times 2^{i \times 5} \times \gamma_{i}\right) \bmod 1\right)+10^{-5} \\
%             & \mu^{(i)}=\left(\left(\mu+\mu \times 2^{i \times 5} \times \gamma_{i}\right) \quad \bmod 0.4\right)+0.5 ; \\
%             \text { end }
%             \end{array}
%             \end{aligned}
%             $$
%     * 输出：Initial states $\left(x_{0}^{(1)}\right)$,$\left(x_{0}^{(2)}, y_{0}^{(2)}, \mu^{(2)}\right)$ and $\left(x_{0}^{(3)}, y_{0}^{(3)}, \mu^{(3)}\right)$

% + tags=[]
function res = key_generation(k)

    command = ['openssl sha256  <<<"' , k,  '" '];
    [~,s] = system(command);
    
    if s(1) == '('
        s = split(string(s));
        s = char(s(2));
    end


    K = char();
    for i = 1:64
        K = strcat(K, dec2bin(hex2dec(s(i)), 4));
    end
    

    x0 = help(K, 1, 64);
    y0 = help(K, 65, 128);
    u =  help(K, 129, 192);
    r1 = help(K, 193, 213);
    r2 = help(K, 214, 234);
    r3 = help(K, 235, 256);
    
    r = [r1, r2, r3];
    
    
    res = zeros(1, 7);
    res(1) = mod(x0 + x0 * (2^5) * r(1), 1) + 10^(-5);
    for i = 2 : 3
        res(3 * i - 4) = mod(x0 + x0 * 2^(i*5) * r(i), 1) + 10^(-5);
        res(3 * i - 3) = mod(y0 + y0 * 2^(i*5) * r(i), 1) + 10^(-5);
        res(3 * i - 2) = mod(u + u * 2^(i*5) * r(i), 0.4) + 0.5;
    end    
end


function v = help(bits, s, e)
    n = e - s + 1;
    v = 0;
    for i = s : e
        v = v + bin2dec(bits(i)) * (2 ^ (i - s));
    end
    v = double(v / (2 ^ n));
end
