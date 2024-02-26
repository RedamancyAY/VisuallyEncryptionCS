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

% +
function result = Embedding(Q, x0, y0, u, M, N, type, P)
    %% P: secret image of size M x M , M = N / 2
    %% Q: carrier image of size N x N
    %% S: chaotic image of size N^2 x 1
    %% type:
    %%      1: embedding process
    %%      0: exacting precess
    %     tic
    

    [M2,N2] = size(Q);
    [Ix,Iy] =  LASM_tent(x0, y0, u, M, N, M2, N2);

    
    if type == 'encry'
        result = F_matrix_encoding(Q,Ix,Iy,1,P);
    elseif type == 'decry'
        result = F_matrix_encoding(Q,Ix,Iy,0);
    end
    
end

% + magic_args="generate index matrix for embedding operation"
function [Ix,Iy] = LASM_tent(x0, y0, u, M, N, M2, N2)
    I1 = zeros(M2 * N2,1);
    I2 = zeros(M2 * N2,1);
    for i = 1: M2 * N2
        x0 = sin(pi * u * (y0 + 3) * x0 * (1 - x0));
        y0 = sin(pi * u * (x0 + 3) * y0 * (1 - y0));
        I1(i) = x0;
        I2(i) = y0;
    end
    
    [~,Ix] = sort(I1(:));
    [~,Iy] = sort(I2(:));
end


function Q2 = F_matrix_encoding(Q,Ix,Iy,type,P)
    %% Q: carrier image
    %% type :
    %%      type = 1 : embedding , P is the secret image , Q2 is the cipher iamge.
    %%      type = 0 : exacting, Q2 is the secret image.

    N = size(Q,1);
    Q2 = bitand(Q(:), 7);
    if type == 1
        map = generate_map();
        P = dec2bin(P,8);
        P = reshape(P,N * N ,2);
        P = (P(Iy(:), 1) - '0') * 2 + P(Iy(:), 2) - '0';
        P = uint8(P);
        
        Q2 = Q2(Ix(:)) * 4 + P;
        Q2 = map(Q2(:)+1);
        Q2 = idivide(Q(Ix(:)),8)*8 + Q2(:);
        [~,I2] = sort(Ix);
        Q2 = Q2(I2(:));
        Q2 = reshape(Q2,N,N);

    else
        imap = inverse_map();
        Q2 = imap(Q2(Ix(:))+1);
        [~,iIy] = sort(Iy);
        Q2 = Q2(iIy(:));
        Q2 = dec2bin(Q2,2);
        Q2 = reshape(Q2,N*N/4,8);
        Q2 = bin2dec(Q2);
        Q2 = reshape(Q2,N/4,N);
        Q2 = uint8(Q2);
    end
end

% +
function map = generate_map()
    map = zeros(32, 1);
    for i = 0 : 7
        for j = 0 : 3
            a1 = bitand(i,4) / 4;
            a2 = bitand(i,2) / 2;
            a3 = bitand(i,1);
            x = bitxor(a1, a2 * 2);
            x = bitxor(x, a3 * 3);
            
            y = bitxor(x, j);
            if y == 1
                a1 = 1 - a1;
            elseif y == 2
                a2 = 1 - a2;
            elseif y == 3
                a3 = 1 - a3;
            end
            map(i * 4 + j + 1) = a1 * 4 + a2 * 2 + a3;
        end
    end
    
    map = uint8(map);
end

function imap = inverse_map()
    imap = zeros(8, 1);
    for i = 0 : 7
        a1 = bitand(i,4) / 4;
        a2 = bitand(i,2) / 2;
        a3 = bitand(i,1);
        x = bitxor(a1, bitxor(a2*2, a3 * 3));
        imap(i+1) = x;
    end
end
