function [c,ceq]=mycon(x)
    M = 4;
    mus = x(1:M);
    alphas = ones(M);
    betas = ones(M);
    k = M+1;
    for i=1:M
        for j=1:M
            alphas(i,j) = x(k);
            k=k+1;
        end
    end
    for i=1:M
        for j=1:M
            betas(i,j) = x(k);
            k=k+1;
        end
    end
    om = alphas./betas;
    c = [max(abs(eig(om))) - 0.9999999999999];
    ceq = [];
end