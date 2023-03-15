function out = showDigit(fBaixa,fAlta )
    %Corrigindo frequência alta
    if (999 < fAlta && fAlta < 1274)
        fAlta = 1209;
    elseif (1273 < fAlta && fAlta < 1392)
        fAlta = 1336;

    elseif (1391 < fAlta && fAlta <1510)
        fAlta = 1477;
    else
        fAlta = 1477;
    end

    %Corrigindo frequência baixa
    if (600 < fBaixa && fBaixa < 734)
        fBaixa = 697;
    elseif (733 < fBaixa && fBaixa < 812)
        fBaixa = 770;

    elseif (811 < fBaixa && fBaixa <898)
        fBaixa = 852;
    elseif ( 897 < fBaixa && fBaixa < 1000)
        fBaixa = 941;
    end

    %Combinação de dígitos
   switch fAlta
       case 1209
          switch fBaixa
              case 697
                  out = 1;
              case 770
                  out = 4;
              case 852
                  out = 7;
              otherwise           
                  out = -1;
          end

       case 1336
           switch fBaixa
               case 697
                   out = 2;
               case 770
                   out = 5;
               case 852
                   out = 8;
               case 941
                   out = 0;
               otherwise 
                   out = -1;
           end
       case 1477
           switch fBaixa
               case 697
                  out = 3;
               case 770
                   out = 6;
               case 852
                   out = 9;
               otherwise
                   out = -1;
           end 
   end
          
end
