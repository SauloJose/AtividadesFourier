% ===================================================================================
% Autor: Saulo José Almeida Silva 
% Descrição: Utilizando o método do STFT (Short Time Fourier Transformation)
% para identificar os digitos discados num celular antigo 
% Data: 13/02/2022
% ===================================================================================
clear all, close all; clc

%leitura do arquivo para elabora a transformada
[x, fs] = audioread('123456789.wav');
L = length(x);
realTime = L/fs;
tempo = linspace(0,realTime, L);

%sound(x,fs);%Exibir o som
% =====================|| Aplicar transformada no sinal ||============================
%Variáveis necessárias
%quantidade de amostras de uma janela
N = 512;

%Passo para cada janela H, ou seja, quantas "amostras" ele pula para gerar
%uma nova janela
H = 256;

%Número de janelas (subintervalos) divididos
M = floor((L-N)/H);

%função de janela
t = linspace(-2,2,N); %variável intermediária
w = exp((-t.^2)/1.5);

%Matriz de base da transformada.
matrizBase=((0:1:N-1)'*(0:1:N-1));
nucleo = exp(-(2*pi*1i)/N);
BaseFT = nucleo.^matrizBase;

%Heinkelização do sinal
hx=zeros(N,M+1);
for a=0:1:M
        hx(:,a+1) = x(1+a*H:N+a*H)';
end

% ===================================================================================
%Transformada de FOURIER de tempo Curto
hx=w'.*hx;
Y = BaseFT*hx;
Y2 = fft(hx); %Utilizando apenas para comparar os resultados.
%Cada coluna representa uma das janelas, e em cada janela existe N
%amostras, para caracterizar as frequências e as fazes é necessário
%realizar mais algumas transformações para cada número de cada coluna

%Foi necessário utilizar a transposta da função de janela w, pois assim
%ficaria 1xN e então poderia aplicar para cada coluna da heinkelização

%vetor frequências
%frequência real = f(discreta) * f(amostragem)

freqDisc = 1/N; %Frequência+ discreta
freqReal= freqDisc * fs * (0:1:N-1); %Em kHz

%plotando um gráfico específico
S =1304; %Número da janela
figure(1);
subplot(3,1,1), plot(tempo, x), title('sinal sonoro'),xlabel('tempo em segundos')
str = "módulo do STFT na janela "+S;
subplot(3,1,2), stem(freqReal,abs(Y(:,S))), title(str),xlabel('frequência em Hz')
subplot(3,1,3), stem(freqReal,angle(Y(:,S))), title('fase'),xlabel('frequência em Hz')
%title('fase'),xlabel('frequência em Hz')

% ==========================|| Encontrar os Dígitos ||================================
%Preciso varrer cada janela, e observar as maiores frequências observadas.
% para cada janela, observo apenas metade de N, e varro esse vetor buscando
% e para essas amplitudes observo as frequências associadas a elas, em kHz

%varrer as janelas e calcular as potências de cada uma
pot = zeros(1,M+1);

%Matriz para guardar os valores de frequência numa janela
num = zeros(2,6);
cont =1;
intervalo1 = floor(N*600/fs)+1:floor(N*1000/fs)+1; %frequências menores
intervalo2 = floor(N*1100/fs)+1:floor(N*1500/fs)+1; %frequencias maiores

%Calcular todas as potências antes.
for m=0:1:M
    pot(m+1)=(hx(:,m+1)'*hx(:,m+1))*(1/N); %potência da janela Sum (x(n)^2)/N
end
potAux=pot;

%Encontrar a potência máxima
potMax =max(max(pot));

%Transformar em pulsos retangulares.
pulso = find(pot > 0.15*potMax);
pot(pulso)=potMax;

for m=0:1:M
    %procurar as janelas cuja potência indique que haja frequência
    if (pot(1,m+1) >= potMax*0.25)%se a potência é grande
        %dividindo as frequências
        %frequências de 600 a 1000hz
        if m+25 < M-1 %Pegar um valor mais central do pulso
            Ymin = abs(Y(intervalo1,m+25));
            [a, f1Max] = max(Ymin);
            f1Max = (intervalo1(f1Max)-1)*fs/N;
        
            %frequências de 1100 a 1500 hz
        
            Ymax = abs(Y(intervalo2,m+25));
            [a, f2Max] = max(Ymax);
            f2Max =(intervalo2(f2Max)-1)*fs/N;
        else
            Ymin = abs(Y(intervalo1,m+1));
            [a, f1Max] = max(Ymin);
            f1Max = (intervalo1(f1Max)-1)*fs/N;
        
            %frequências de 1100 a 1500 hz
            Ymax = abs(Y(intervalo2,m+1));
            [a, f2Max] = max(Ymax);
            f2Max =(intervalo2(f2Max)-1)*fs/N;            
        end
        
        %analisando se esse valor deve ou não ser guardado
        if (m > 20 && pot(1,m) < potMax*0.3) %antes de um pulso
            num(:,cont) = [f1Max; f2Max];
            cont = cont+1;
        end
    end
end

figure(2)
plot(0:M,pot,0:M,potAux), title('Potencia do sinal em cada janela'),xlabel('indice da janela')


% ==========================|| Função para identificar digitos ||================================
digitos=zeros(1,length(num));

for m=1:1:length(num)
    digitos(m) = showDigit(num(1,m),num(2,m));
end

%Exibindo digitos
digitos
