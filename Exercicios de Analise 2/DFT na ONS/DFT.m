% ===================================================================================
% Autor: Saulo José Almeida Silva
% Descrição: Utilizando o método do DFT (Discrete Fourier Transformation) para ana-
% lizar os dados de frequências nos dados da ONS, e buscar um padrão nesses
% dados. A base de dados utilizadas foi a curva de carga horária do dia 1
% de janeiro de 2019 até o dia 31 de dezembro de 2019
% Data: 14/03/2022
% ===================================================================================
clear all, close all; clc

%leitura do arquivo para elabora a transformada
%x = xlsread('CurvaCargaHoraria.xlsx',1,'B3:DIP3')'; %Base de dados de 6 meses
x = xlsread('baseDeDados1Ano.xlsx',1,'B3:LXB3')'; %Base de dados de 1 ano.
N = length(x);
time = 0:1:N-1;
% ===============================|| Algorítmo do DFT ||=============================

%Matriz de base da transformada.
matrizBase=((0:1:N-1)'*(0:1:N-1));
nucleo = exp(-(2*pi*1i)/N);
BaseFT = nucleo.^matrizBase;

%Transformada discreta de fourier.
Y = BaseFT*x;

%Normalizando valores, para que a amplitude seja a compatível do sinal original
Y = Y/N;

% ===============================|PLOTANDO DADOS|===================================
%tabela de frequências
fs = 1; %1 amostra por hora
freal = (0:N-1)*fs/N;

%Calculando valor médio do sinal
Vmed = Y(1) %Os dados já estão normalizados

% Analisando a DFT do sinal, observa-se que existe três frequências que se
% sobresaem, portanto, o pode ser aproximado com uma função dessas três
% frequências, da forma
% Xm(t)=Vmed + 2*A1*cos(w1*t+o1)+2*A2*cos(w2*t+o2)+2*A3*cos(w3*t+o3);
% Buscarei o valores dessas frequências, e tomarei como o período o maior
% entre eles...

%Variável para analisar.
Yapoio = Y;

%Procurando primeira frequência de maior intensidade
[Amp1, k1] = max(abs(Yapoio(2:floor(N/2)+1,1)));
freqMax1 = freal(k1+1);

Yapoio(k1+1,1) = 0;%Zerando essa frequência e buscando a outra segunda maior.

%Procurando a segunda frequência de maior intensidade
[Amp2, k2] = max(abs(Yapoio(2:floor(N/2)+1,1)));
freqMax2 = freal(k2+1);

%Procurando a terceira frequência de maior intensidade
Yapoio(k2+1,1)=0;
[Amp3, k3] = max(abs(Yapoio(2:floor(N/2)+1,1)));
freqMax3 = freal(k3+1);

%Período real
T1 = 1/freqMax1 %Período da primeira frequência (maior magnitude)
T2 = 1/freqMax2 %Período da segunda frequências (maior magnitude)
T3 = 1/freqMax3 %Período da terceira frequência (maior magnitude)

%Observação: T1 é o período da frequência de maior magnitude, que condize
%com a variação períodica que mais se sobressai. Os períodos T2 e T3 são
%das outras frequências, que são responsáveis pelos dois comportamentos
%oscilatórios de maior intensidade após o primeiro.

%O T da função aproximada será o MMC dos períodos, já que as duas
%frequências tem períodos diferentes.
T = lcm(floor(T1),floor(T2))
T = lcm(T, floor(T3))

%Sinal que tenha essa frequência 
%Será da forma cos
fase1 = angle(Y(k1+1));
fase2 = angle(Y(k2+1));
fase3 = angle(Y(k3+1));
intervaloApoio = (0:N-1);

%Função aproximada para o sinal com as duas maiores frequências
X2 = Vmed+2*(Amp1*cos(intervaloApoio*2*pi*freqMax1+fase1)+Amp2*cos(intervaloApoio*2*pi*freqMax2+fase2)+Amp3*cos(intervaloApoio*2*pi*freqMax3+fase3));

%Portanto a cada T horas, a função aproximada X2 se repete, porém, a cada T1
%horas, a maior frequência se repete.
% ===============================|PLOTANDO DADOS|===================================
%Plotando resultados da transformada
figure(1);
subplot(2,1,1), stem(freal,abs(Y)),title('Modulo da DFT'),xlabel('Frequência em amostras/Hora')
subplot(2,1,2), stem(freal,angle(Y)),title('Fase'),xlabel('Frequência em amostras/Hora')

%Plotando resultados do sinal aproximado
figure(2)
subplot(2,1,1),
plot(intervaloApoio,x), title('Sinal original'),xlabel('Horas a partir de 15 de junho às 0:00 h'),ylabel(' (MWh/h)');
subplot(2,1,2)
plot(intervaloApoio,X2), title('Sinal aproximado'),xlabel('Horas a partir de 15 de junho às 0:00 h'),ylabel(' (MWh/h)');

%Comparando em mesma escala com o sinal original
figure(3)
plot(intervaloApoio,x,intervaloApoio,X2),title('Comparando os Sinais'),xlabel('Horas a partir de 15 de junho às 0:00 h'),ylabel(' (MWh/h)');

%Mapa de calor
figure(4);
imagesc(time, freal, abs(Y)),xlabel('tempo'),ylabel('frequencia'),colorbar;
