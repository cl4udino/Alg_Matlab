#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

//================================================================================================//
//
// Este Algoritmo não realiza a minimização! Apenas faz o cálculo da avaliação da função!
// É uma tradução dos códigos loglike.m e loglike_m_old.m
//
//================================================================================================//

double loglike(double x[36], int M, double T, double history[4][10000]);

int main(int argc, char const *argv[])
{
    FILE * fp;
    char * line = NULL;
    size_t len = 0;
    ssize_t read;

    double x[] = {0.29281270113767277063487881605397, 0.082796120876248185949108915338002, 0.10474420353571649300317147890382, 0.17957601697120231798443512616359, 42.822776235317583370942884357646, 0.00000049621574527384834851155125806654, 6.9404920237774643254624606925063, 0.35868384880080778076560932277062, 23.657983179366667059184692334384, 0.069031088077339777808738574549352, 22.664199084463266586908503086306, 2.6533286266461773017510950012365, 0.27099058623294952630189413866901, 0.020278061483877826698396518168011, 52.129660064445126010923559078947, 2.9661066391249133467056253721239, 3.250666423157652751285695558181, 0.51764149801236436498896864577546, 7.5576880001359443284059125289787, 31.32022783904522356124289217405, 88.477952770133626358983747195452, 0.0000014812471768179794315208617008772, 111.63832633328418353357847081497, 3.2486360922659036631898743507918, 131.48983934318553679077012930065, 0.13984934883107230652043995178246, 202.38331275219491089956136420369, 85.666637573813090966723393648863, 6.6676999883113303724258003057912, 0.042770995513957431322094038250725, 117.79933077558322906952525954694, 72.308384400991954521487059537321, 39.858174085565103439421363873407, 4.6275988456170047413706924999133, 148.79142065288462504213384818286, 241.97859266503681396898173261434};

    double history[4][10000];
    char file_name_aux[4][200] = {"./Final_Data/dec_ask_%s.csv","./Final_Data/inc_bid_%s.csv","./Final_Data/dec_bid_%s.csv","./Final_Data/inc_ask_%s.csv"};
    char file_name[4][200];
    
    //Aqui coloca os valores da hora de começo e fim da janela. 
    double start = 36000.0;
    double finish = start + 3600.0;
    int j;

    //Aqui apenas faz a leitura dos dados no arquivo.
    for (int i = 0; i < 4; i++)
    {
    	sprintf(file_name[i], file_name_aux[i], argv[1]);
    	fp = fopen(file_name[i], "r");
	    if (fp == NULL){
	    	printf("Não foi possivel abrir o arquivo %s\n", file_name[i]);
	        return 0;
	    }
	    getline(&line, &len, fp);
	    j=0;
    	while ((read = getline(&line, &len, fp)) != -1) {
	        char * raw_data = strtok(line, ",");
	        double data = atof(raw_data);
	        if (data >= start && data < finish){
	        	history[i][j] = data - start;
	        	j++;
	        }
	    }
	    fclose(fp);
    }

    clock_t begin = clock();

    double result = loglike(x, 4, 3600.0, history); // Faz o cálculo da Fórmula do LogLikelihood
    
    clock_t end = clock();
	double time_spent = (double)(end - begin) / CLOCKS_PER_SEC; //Faz o cálculo do tempo de execução

    printf("The result is: %.15lf\n", result);
    printf("The exec time is: %.15lf seconds\n", time_spent);

}

double loglike_m(double mu_m, double alphas_m[4], double betas_m[4], int M, double T, int m, double history[4][10000]){
	double tot = mu_m * T;
	double soma;
    int n = 1;
    for (int n = 0; n < M; n++)
    {
    	soma = 0.0;
    	for (int i = 0; i < 10000; i++)
    	{
    		if (history[n][i] != 0.0){
    			soma += 1 - exp(-betas_m[n]*(T-history[n][i]));
    		}
    		else{
    			break;
    		}
    	}
        tot = tot + (alphas_m[n]/betas_m[n])*soma;
    }

    for (int k = 0; k < 10000; k++)
    {
    	if (history[m][k] != 0.0){
    		soma = mu_m;
			for (int n = 0; n < M; n++)
    		{
    			if (n == m && k == 0)
    			{
    				soma = soma + 0.0;
    			}
    			else{
    				double aux = 0.0;
    				for (int i = 0; history[n][i] < history[m][k]; i++)
    				{
    					aux = aux + exp(-betas_m[n]*(history[m][k]-history[n][i]));
    				}
    				soma = soma + alphas_m[n]*aux;	
    			}
    		}
    		tot = tot - log(soma);
		}
		else{
			break;
		}
    }
	return tot;
}

double loglike(double x[36], int M, double T, double history[4][10000]){
	double mus[4], alphas[4][4], betas[4][4];

	for (int i = 0; i < M; i++)
	{
		mus[i] = x[i];
	}

    int k = M;
    for (int i = 0; i < M; i++)
    {
    	for (int j = 0; j < M; j++)
    	{
    		alphas[i][j] = x[k];
    		k++;
    	}
    }
    for (int i = 0; i < M; i++)
    {
    	for (int j = 0; j < M; j++)
    	{
    		betas[i][j] = x[k];
    		k++;
    	}
    }
    double tot = 0.0;
    for (int m = 0; m < M; m++)
    {
    	tot = tot + loglike_m(mus[m],alphas[m],betas[m],M,T,m,history);
    }
	return tot;
}