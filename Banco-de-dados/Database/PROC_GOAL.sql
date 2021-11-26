/*
85109 - Daniel Sanchez Melero                                      
86405 - Eric Luiz Campos Pessoa                                    
85817 - Giovanna de Mello Leiva                                   
84549 - Henrique Neves Lago                                          
85707 - Kaue Augusto Miranda Santos                         
86351 - Larissa Alves da Silva   
*/

--Cria��o da PROCEDURE PROC_GOAL
CREATE OR REPLACE PROCEDURE PROC_GOAL (
    pGoal IN PF0645.SDG_INDICATORS.GOAL%TYPE DEFAULT 2,
    pGeo IN PF0645.SDG_INDICATORS.GEO_AREA_NAME%TYPE DEFAULT 'Brazil',
    pTimeIni IN PF0645.SDG_INDICATORS.TIME_PERIOD%TYPE,
    pTimeFin IN PF0645.SDG_INDICATORS.TIME_PERIOD%TYPE) IS
    CURSOR cur_rel IS
        SELECT 
            IND.GOAL, IND.TARGET, IND.INDICATOR, IND.SERIES_CODE, IND.SERIES_DESCRIPTION, IND.GEO_AREA_NAME, IND.TIME_PERIOD, IND.VALUE
        FROM
            PF0645.SDG_INDICATORS IND
        WHERE
            IND.Goal = pGoal AND
            IND.GEO_AREA_NAME = pGeo AND
            IND.TIME_PERIOD BETWEEN pTimeIni AND pTimeFin
        ORDER BY
            IND.GOAL,
            IND.GEO_AREA_NAME,
            IND.TIME_PERIOD;
    
    v_val_goal PF0645.SDG_INDICATORS.GOAL%TYPE;
    v_val_geo PF0645.SDG_INDICATORS.GEO_AREA_NAME%TYPE;
    v_max PLS_INTEGER;
    v_min PLS_INTEGER;
    e_period EXCEPTION;
    e_max EXCEPTION;
    e_min EXCEPTION;
    e_no_data EXCEPTION;
    
    
    BEGIN    
    --Valida��o para valores GOAL e GEO_AREA_NAME existentes. Se inv�lido chama cursor impl�cito NO_DATA_FOUND
      SELECT DISTINCT
        IND.GOAL, IND.GEO_AREA_NAME
      INTO
        v_val_goal, v_val_geo
      FROM 
        PF0645.SDG_INDICATORS IND
      WHERE 
      IND.GOAL = pGoal AND 
      IND.GEO_AREA_NAME = pGeo;
        
    --Consulta para valida��o para valores m�ximos de TIME_PERIOD encontrados na tabela
        SELECT 
            MAX(IND.TIME_PERIOD) 
        INTO
            v_max
        FROM 
            PF0645.SDG_INDICATORS IND;
  --Consulta para valida��o para valores m�ximos de TIME_PERIOD encontrados na tabela          
         SELECT 
            MIN(IND.TIME_PERIOD) 
        INTO
            v_min
        FROM 
            PF0645.SDG_INDICATORS IND;
            
  --Condicionais para chamar Exceptions de acordo com  os par�metros TIME_PERIOD
        IF pTimeIni > pTimeFin OR pTimeFin < pTimeIni THEN
            RAISE e_period;
        ELSIF pTimeIni < v_min OR pTimeFin < v_min THEN
            RAISE e_min;
        ELSIF pTimeIni > v_max OR pTimeFin > v_max THEN
            RAISE e_max;
        END IF;
        
        --Impress�o de objetivo, pa�s e per�odo
         DBMS_OUTPUT.PUT_LINE(
                'GOAL:  ' || pGoal || '  -  COUNTRY:   ' || pGeo|| ' -  PERIOD:   '|| pTimeIni || ' and '|| pTimeFin);
                DBMS_OUTPUT.NEW_LINE();
        -- La�o para percorrer o cursor e imprimir os resultados de acordo com os par�metros de entrada da PROCEDURE
        FOR reg_rel in cur_rel LOOP
            DBMS_OUTPUT.PUT_LINE(
               'Indicator:  '|| reg_rel.indicator ||'   Series Code:   '|| reg_rel.series_code ||'   Description:   '||reg_rel.series_description||'    Value:  '||reg_rel.value);
        END LOOP;
        --Tratamento das exceptions retornando as mensagens de aviso
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             DBMS_OUTPUT.PUT_LINE('ERRO: A consulta n�o retornou resultados com os par�metros colocados na PROCEDURE.');
        WHEN e_period THEN
            DBMS_OUTPUT.PUT_LINE('ERRO: N�o � poss�vel colocar ano inicial maior que ano final ou ano final menor que ano inicial.');
        WHEN e_min THEN
            DBMS_OUTPUT.PUT_LINE('ERRO: O ano colocado no par�metro da PROCEDURE � menor do que o ano m�nimo encontrado nos dados.');
        WHEN e_max THEN
            DBMS_OUTPUT.PUT_LINE('ERRO: O ano colocado no par�metro da PROCEDURE supera o maior ano encontrado nos dados.');
         WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERRO desconhecido.');
            DBMS_OUTPUT.PUT_LINE('C�digo:' ||SQLCODE);
            DBMS_OUTPUT.PUT_LINE('Mensagem Oracle:' ||SQLERRM);
END PROC_GOAL;
/
    
SET SERVEROUT ON

--TESTE PROCEDURE
CL SCR;
EXECUTE PROC_GOAL(2, 'Africa', 2010, 2015);
EXECUTE PROC_GOAL(pTimeIni => 2011, pTimeFin=>2013);
        
SET SERVEROUT OFF
        
        
