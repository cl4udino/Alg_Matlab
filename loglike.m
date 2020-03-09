function f = loglike(x,M,T,learn_data_dec_ask,learn_data_inc_bid,learn_data_dec_bid,learn_data_inc_ask)
    history = {learn_data_dec_ask,learn_data_inc_bid,learn_data_dec_bid,learn_data_inc_ask};
    %Faz o parse dos parametros que vem juntos no x
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

    %Faz a computação da Fórmula do Loglikelihood
    m = 1;
    tot = 0.0;
    while(m <= M)
        tot = tot + loglike_m_old(mus(m),alphas(m,:),betas(m,:),M,T,m,history);
        m=m+1;
    end
    f = tot;
end