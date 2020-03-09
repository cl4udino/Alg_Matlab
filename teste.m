clear; %limpa as variáveis de ambiente do matlab

%Configuração para imprimir mais casas decimais nos disp() do programa
format long;

%Seleciona os arquivos contendo os dados do dia para ver em outros dias só autera a data para 20190705, 20190704, 20190703, 20190702, 20190701.
file_id = '20190705_PETR4';


M = 4; %Quantidade de tipos diferentes de eventos 
T = 3600.0; %Tamanho da janela 3600 segundos -> 1 hora

%O bloco de código abaixo serve para pegar todos os dados do dia separados por tipo
str_csv_file_name = 'Final_Data/inc_bid_%s.csv';
cfn = sprintf(str_csv_file_name,file_id);
inc_bid = readtable(cfn);
str_csv_file_name = 'Final_Data/inc_ask_%s.csv';
cfn = sprintf(str_csv_file_name,file_id);
inc_ask = readtable(cfn);
str_csv_file_name = 'Final_Data/dec_bid_%s.csv';
cfn = sprintf(str_csv_file_name,file_id);
dec_bid = readtable(cfn);
str_csv_file_name = 'Final_Data/dec_ask_%s.csv';
cfn = sprintf(str_csv_file_name,file_id);
dec_ask = readtable(cfn);
data_inc_bid = table2array(inc_bid(1:height(inc_bid),1));
data_inc_ask = table2array(inc_ask(1:height(inc_ask),1));
data_dec_bid = table2array(dec_bid(1:height(dec_bid),1));
data_dec_ask = table2array(dec_ask(1:height(dec_ask),1));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


fim_data = 39600.0; %hora final da janela
init_data = fim_data - T; %hora inicial da janela

%Aqui eu defino os parâmetros iniciais
x0 = ones(1,M+2*M*M);
x0(1:M) = 0.5;
x0(M+1:M+M*M) = 0.2;
x0(M+M*M+1:end) = 1.0;

%Configuração das opções do fmincon
options=optimset('Algorithm','interior-point','Display','iter-detailed','MaxIter',100,'MaxFunEvals',100000,'FunValCheck','on','ObjectiveLimit',-1.0000e+5);

while(fim_data <= 54000.0) %Loop da janela deslizante

    %Este bloco pega todos os dados que estão presentes na faixa da janela de tempo entre init_data e fim_data
    filtered_data = data_inc_bid >= init_data & data_inc_bid < fim_data;
    learn_data_inc_bid = data_inc_bid(filtered_data);
    learn_data_inc_bid = learn_data_inc_bid-init_data;
    filtered_data = data_inc_ask >= init_data & data_inc_ask < fim_data;
    learn_data_inc_ask = data_inc_ask(filtered_data);
    learn_data_inc_ask = learn_data_inc_ask-init_data;
    filtered_data = data_dec_bid >= init_data & data_dec_bid < fim_data;
    learn_data_dec_bid = data_dec_bid(filtered_data);
    learn_data_dec_bid = learn_data_dec_bid-init_data;
    filtered_data = data_dec_ask >= init_data & data_dec_ask < fim_data;
    learn_data_dec_ask = data_dec_ask(filtered_data);
    learn_data_dec_ask = learn_data_dec_ask-init_data;

    %Configuração das restrições do fmincon
    nonlcon = @mycon; %a restrição mycon está no arquivo mycon.m
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    lb = zeros(1,M+2*M*M);
    lb(1:M) = 1.0000e-9;
    ub = [];
    fun = @(x)loglike(x,M,T,learn_data_dec_ask,learn_data_inc_bid,learn_data_dec_bid,learn_data_inc_ask); %seta as variáveis de entrada

    [x,fval] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options); %Executa o fmincon

    %Realiza a impressão dos parâmetros e o valor da avaliação de função final
    print_val = fval;
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
    fprintf('Os valores de mu, alpha e beta no periodo %f - %f eh:\n',init_data,fim_data);
    disp(vpa(mus))
    disp(vpa(alphas))
    disp(vpa(betas))
    disp(print_val)
    disp(vpa(x))

    %Atualização da janela deslizante
    fim_data = fim_data + T/2; %Aumenta em 30 minutos (1800 segundos) a parte final da janela
    init_data = fim_data - T; %Trás a parte inicial da janela a uma distância de 1 hora da parte final atualizada

end
