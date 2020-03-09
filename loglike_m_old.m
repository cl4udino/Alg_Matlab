function res = loglike_m_old(mu_m,alphas_m,betas_m,M,T,m,history)
    tot = mu_m * T; 
    n = 1;
    while(n <= M)
        soma = (alphas_m(n)/betas_m(n))*sum(1 - exp(-betas_m(n)*(T-history{n}))); %Estes são os pontos mais demorados.
        n = n + 1;
        tot = tot + soma;
    end
    k = 1;
    while (k<=size(history{m},1))
        n = 1;
        soma = mu_m;
        while(n <= M)
            if ((n == m) && (k==1))
                soma = soma + 0;
            else
                filtered = (history{n} < history{m}(k));%filtra todos os dados do tipo n com timestamp menor do que history{m}(k)
                data = history{n}(filtered);
                if isempty(data)
                    soma = soma + 0;
                else
                    soma = soma + alphas_m(n)*sum(exp(-betas_m(n)*(history{m}(k)-data))); %Estes são os pontos mais demorados.
                end
            end
            n = n + 1;
        end
        tot = tot - log(soma);
        k = k + 1;
    end
    res = tot;
end