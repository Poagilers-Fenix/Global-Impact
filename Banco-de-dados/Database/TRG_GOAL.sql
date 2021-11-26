
/* 
Nome dos integrantes:

85109 - Daniel Sanchez Melero                                      
86405 - Eric Luiz Campos Pessoa                                    
85817 - Giovanna de Mello Leiva                                   
84549 - Henrique Neves Lago                                          
85707 - Kaue Augusto Miranda Santos                         
86351 - Larissa Alves da Silva   
*/


------------------------------------------------------------------------------------------------------

--Cria Tabela De Auditoria Conforme Instruções Pdf

DROP TABLE SDG_INDICATORS_AUDIT;

CREATE TABLE sdg_indicators_audit (
    username                 VARCHAR(130),
    osuser                   VARCHAR(130),
    date_hour                DATE,
    operation                CHAR(1),
    goal_old                 VARCHAR2(1000),
    goal_new                 VARCHAR2(1000),
    target_old               VARCHAR2(100),
    target_new               VARCHAR2(100),
    indicator_old            VARCHAR2(10),
    indicator_new            VARCHAR2(10),
    series_code_old          VARCHAR2(500),
    series_code_new          VARCHAR2(500),
    series_description_old   VARCHAR2(500),
    series_description_new   VARCHAR2(500),
    geo_area_name_old        VARCHAR2(500),
    geo_area_name_new        VARCHAR2(500),
    time_period_old          VARCHAR2(500),
    time_period_new          VARCHAR2(500),
    value_old                VARCHAR2(100),
    value_new                VARCHAR2(100)
);
--------------------------------------------------------------------
--------------------------------------------------------------------

--Criar Tabela Conforme Instruções Pdf

DROP TABLE SDG_INDICATORS;

CREATE TABLE SDG_INDICATORS
AS SELECT * FROM PF0645.SDG_INDICATORS
FETCH FIRST 10 ROWS ONLY;

--------------------------------------------------------------------

--Criação do Trigger TRG_SDG_INDICATORS
CREATE OR REPLACE TRIGGER TRG_SDG_INDICATORS 
BEFORE INSERT OR UPDATE OR DELETE ON SDG_INDICATORS
FOR EACH ROW
DECLARE
    TYPE LIST IS VARRAY(8) OF VARCHAR2(500);
    oldList List := List();
    newList List := List();
    v_count PLS_INTEGER:=1;
    v_operation SDG_INDICATORS_AUDIT.OPERATION%TYPE;
BEGIN
    --Criação de vArrays de tipo new e old para atender os requisitos de UPDATE, DELETE e INSERT
    newList.EXTEND(8);
    newList(1):= :NEW.GOAL;
    newList(2):= :NEW.TARGET;
    newList(3):= :NEW.INDICATOR;
    newList(4):= :NEW.SERIES_CODE;
    newList(5):= :NEW.SERIES_DESCRIPTION;
    newList(6):= :NEW.GEO_AREA_NAME;
    newList(7):= :NEW.TIME_PERIOD;
    newList(8):= :NEW.VALUE;
    
    oldList.EXTEND(8);
    oldList(1):= :OLD.GOAL;
    oldList(2):= :OLD.TARGET;
    oldList(3):= :OLD.INDICATOR;
    oldList(4):= :OLD.SERIES_CODE;
    oldList(5):= :OLD.SERIES_DESCRIPTION;
    oldList(6):= :OLD.GEO_AREA_NAME;
    oldList(7):= :OLD.TIME_PERIOD;
    oldList(8):= :OLD.VALUE;
    
    --Condicional para INSERT: novos dados registrados, dados antigos = NULL
    IF INSERTING  THEN
        v_operation:= 'I';
        FOR v_count in 1..8 LOOP
            oldList(v_count) := NULL;
        END LOOP;
     --Condicional para DELETE: dados antigos registrados, dados novos = NULL
    ELSIF DELETING THEN
        v_operation:= 'D';
        FOR v_count in 1..8 LOOP
            newList(v_count) := NULL;
        END LOOP;
    --Condicional para UPDATE: dados antigos e novos registrados
    ELSE
        v_operation:= 'U';
    END IF;
       --Inserção de dados na tabela SDG_INDICATORS_AUDIT conforme descrição dos requisitos
        INSERT INTO
            SDG_INDICATORS_AUDIT(
            username,
            osuser,
            date_hour,
            operation,
            goal_old,
            goal_new,
            target_old,
            target_new,
            indicator_old,
            indicator_new,
            series_code_old,
            series_code_new,
            series_description_old,
            series_description_new,
            geo_area_name_old,
            geo_area_name_new,
            time_period_old,
            time_period_new,
            value_old,
            value_new)
        VALUES(
            USER,
            SYS_CONTEXT('USERENV','OS_USER'),
            SYSDATE,
            v_operation,
            oldList(1),
            newList(1),
            oldList(2),
            newList(2),
            oldList(3),
            newList(3),
            oldList(4),
            newList(4),
            oldList(5),
            newList(5),
            oldList(6),
            newList(6),
            oldList(7),
            newList(7),
            oldList(8),
            newList(8));
END;
/
        
        
-- TESTE INSERT   
INSERT INTO
    SDG_INDICATORS
SELECT 
    * 
FROM 
    PF0645.SDG_INDICATORS 
WHERE 
    INDICATOR = '17.1.1' AND 
    TIME_PERIOD='2013' AND 
    GEO_AREA_NAME = 'Europe' AND 
    Value = '39.0143019326021';
    
--TESTE UPDATE
UPDATE  
    SDG_INDICATORS
SET 
    SERIES_DESCRIPTION = 'TESTE UPDATE', GEO_AREA_NAME = 'Brazil', TIME_PERIOD = '2021', VALUE = 60.7255877495904
WHERE 
    INDICATOR = '17.1.1' AND 
    TIME_PERIOD='2019' AND 
    GEO_AREA_NAME = 'Oceania' AND 
    Value = '46.1348335029003';
    
--TESTE DELETE
DELETE FROM 
    SDG_INDICATORS 
WHERE 
    INDICATOR = '17.1.1' AND 
    TIME_PERIOD='2017' AND 
    GEO_AREA_NAME = 'Oceania' AND 
    Value = '49.6520640378954';


/*
ATIVAR/DESATIVAR TRIGGER

ALTER TRIGGER TRG_SDG_INDICATORS DISABLE;
ALTER TRIGGER TRG_SDG_INDICATORS ENABLE;
*/

--CONFERIR TABELAS
SELECT * FROM SDG_INDICATORS;
SELECT * FROM SDG_INDICATORS_AUDIT;


COMMIT;    
    
        

