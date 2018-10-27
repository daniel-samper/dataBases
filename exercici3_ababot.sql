/*8.5.1 Exercicis 3

/*1. Cree un procedimiento en la base liga que compruebe si los partidos ganados por un equipo pasado
como nombre como parámetro de entrada coinciden con el campo puntos en la tabla equipo. Mostrar
como resultado final el nombre del equipo, los partidos ganados y los puntos de la tabla equipo.*/
delimiter $$
DROP FUNCTION IF EXISTS guanyador$$
CREATE FUNCTION guanyador(cad varchar(7)) RETURNS varchar(10)
	BEGIN
		declare llargada int;
		declare separador int;
		declare tmp1 int;
		declare tmp2 int;
        declare guanyador int;
        declare pos1 int;
        declare pos2 int;
                
        set llargada = CHAR_LENGTH(cad);
        set separador = INSTR(cad,'-');
        set pos2=llargada-separador;
        set pos1=llargada-pos2-1;
		SET tmp1 = left(cad,pos1);
        SET tmp2 = right(cad,pos2);
        
        if tmp1>tmp2 then set guanyador=1;
        else set guanyador=0;
        end if;
        return guanyador;
	END $$
delimiter ;

select guanyador('90-91');

delimiter $$
DROP PROCEDURE IF EXISTS partitsGuanyats$$
CREATE PROCEDURE partitsGuanyats (IN equip varchar(20))
	BEGIN
		DECLARE numEquip INT;
        DECLARE eof BOOL default false;
        DECLARE tmp varchar(7);
        DECLARE pGuanyats int default 0;
		
        DECLARE local_cursor cursor FOR SELECT resultado FROM partido where local=numEquip;
		DECLARE visitante_cursor cursor FOR SELECT resultado FROM partido where visitante=numEquip;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eof=true;
        
        set numEquip = (select id_equipo from equipo where nombre=equip);
        
        open local_cursor;
		cursor1: LOOP
			FETCH local_cursor INTO tmp;
            IF eof THEN
				LEAVE cursor1;
			END IF;
            IF guanyador(tmp)=1 THEN
				set pGuanyats=pGuanyats+1;
                END IF;
		END LOOP cursor1;
        close local_cursor;
        
        open visitante_cursor;
		cursor2: LOOP
			FETCH visitante_cursor INTO tmp;
            IF eof THEN
				LEAVE cursor2;
			END IF;
            IF guanyador(tmp)=0 THEN
				set pGuanyats=pGuanyats+1;
                END IF;
		END LOOP cursor2;
        close visitante_cursor;
	
        SELECT CONCAT('El equipo ', equip, ' ha ganado ',pGuanyats, ' partido/s .') as Partits_guanyats;
	END;$$
delimiter ;

call partitsGuanyats('CAI Zaragoza');


/*2. Cree un procedimiento en la base liga que compruebe si los partidos ganados por cada equipo
coinciden con el campo puntos en la tabla equipo. Mostrar como resultado final los nombres de los
equipos, los partidos ganados y los puntos de cada uno.*/

delimiter $$
DROP FUNCTION IF EXISTS partitsGuanyatsAdaptat$$
CREATE FUNCTION  partitsGuanyatsAdaptat (equip varchar(20)) RETURNS int
	BEGIN
		DECLARE numEquip INT;
        DECLARE eof BOOL default false;
        DECLARE tmp varchar(7);
        DECLARE pGuanyats int default 0;
		
        DECLARE local_cursor cursor FOR SELECT resultado FROM partido where local=numEquip;
		DECLARE visitante_cursor cursor FOR SELECT resultado FROM partido where visitante=numEquip;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eof=true;
        
        set numEquip = (select id_equipo from equipo where nombre=equip);
        
        open local_cursor;
		cursor1: LOOP
			FETCH local_cursor INTO tmp;
            IF eof THEN
				LEAVE cursor1;
			END IF;
            IF guanyador(tmp)=1 THEN
				set pGuanyats=pGuanyats+1;
                END IF;
		END LOOP cursor1;
        close local_cursor;
        
        open visitante_cursor;
		cursor2: LOOP
			FETCH visitante_cursor INTO tmp;
            IF eof THEN
				LEAVE cursor2;
			END IF;
            IF guanyador(tmp)=0 THEN
				set pGuanyats=pGuanyats+1;
                END IF;
		END LOOP cursor2;
        close visitante_cursor;
	
        RETURN pGuanyats;
	END;$$
delimiter ;

delimiter $$
DROP PROCEDURE IF EXISTS comparaGuanyats$$
CREATE PROCEDURE comparaGuanyats (IN equip varchar(20))
	BEGIN
    DECLARE eof BOOL default false;
    DECLARE tmp varchar(50);
        
	DECLARE equips_cursor cursor FOR SELECT nombre FROM equipo;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET eof=true;
	
     open equips_cursor;
		cursor1: LOOP
			FETCH equips_cursor INTO tmp;
            IF eof THEN
				LEAVE cursor1;
			END IF;
			SELECT CONCAT('El equipo ', tmp, ' ha ganado ',partitsGuanyatsAdaptat(tmp) , ' partido/s y tiene ',(select puntos from equipo where nombre=tmp)) as Punts_equip;
		END LOOP cursor1;
        close equips_cursor;
        
	END $$
delimiter ;

call comparaGuanyats('Regal Barcelona');


/*3. Cree un procedimiento que muestre el número máximo de partidos seguidos ganados por un equipo
en casa.*/


delimiter $$
DROP PROCEDURE IF EXISTS partitsGuanyatsSeguits$$
CREATE PROCEDURE partitsGuanyatsSeguits (IN equip varchar(20))
	BEGIN
		DECLARE numEquip INT;
        DECLARE eof BOOL default false;
        DECLARE tmp varchar(7);
        DECLARE pGuanyats int default 0;
        DECLARE pGuanyatsMax int default 0;
		
        DECLARE local_cursor cursor FOR SELECT resultado FROM partido where local=numEquip order by fecha;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eof=true;
        
        set numEquip = (select id_equipo from equipo where nombre=equip);
        
        open local_cursor;
		cursor1: LOOP
			FETCH local_cursor INTO tmp;
            IF eof THEN
				LEAVE cursor1;
			END IF;
            IF guanyador(tmp)=1 THEN
				set pGuanyats=pGuanyats+1;
			else
				set pGuanyats=0;
			END IF;
			IF pGuanyats>pGuanyatsMax THEN
				set pGuanyatsMAx=pGuanyats;
			END IF;
		END LOOP cursor1;
		
        close local_cursor;
	
        SELECT CONCAT('El equipo ', equip, ' ha tenido una racha de victorias en casa de ',pGuanyatsMax, ' partido/s.') as Partits_guanyats;
	END;$$
delimiter ;


call partitsGuanyatsSeguits('Real Madrid');

/*4. Desarrolle usando cursores un procedimiento que muestre los datos del cliente, la cuenta y el saldo
de los clientes con saldo negativo en alguna de sus cuentas.*/

delimiter $$
DROP PROCEDURE IF EXISTS cuentasNegativo$$
CREATE PROCEDURE cuentasNegativo()
	BEGIN
		DECLARE eof BOOL default false;

        DECLARE ccuenta 		INT;
        DECLARE saldo 			double;
        DECLARE dni				varchar(10);
  
        DECLARE cursor1 cursor FOR SELECT cod_cuenta FROM cuenta where cuenta.saldo<0;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eof=true;
               
		DROP TABLE IF EXISTS clientesNegativo;
		CREATE TABLE clientesNegativo (
            codigo_cuenta	varchar(10),
            saldo			double,
			codigo_cliente 	int,
			dni 	  		int,
			nombre       	varchar(20),
			apellido1      	varchar(20),
			apellido2     	varchar(20),
			direccion      	varchar(50),

			PRIMARY KEY (codigo_cuenta)
		);  
        
        open cursor1;
		loop1: LOOP
			FETCH cursor1 INTO ccuenta;
            IF eof THEN
				LEAVE loop1;
			END IF;
            
		    set dni = ( SELECT tiene.dni from tiene where cod_cuenta=ccuenta );
            
           insert into clientesNegativo values(
           (select tiene.cod_cuenta from tiene where ccuenta = tiene.cod_cuenta),
           (select cuenta.saldo from cuenta JOIN tiene ON tiene.cod_cuenta=cuenta.cod_cuenta where ccuenta = cuenta.cod_cuenta),
           (select cliente.codigo_cliente from cliente where dni=cliente.dni),
           (select cliente.dni from cliente where dni=cliente.dni),
           (select cliente.nombre from cliente where dni=cliente.dni),
           (select cliente.apellido1 from cliente where dni=cliente.dni),
           (select cliente.apellido2 from cliente where dni=cliente.dni),
           (select cliente.direccion from cliente where dni=cliente.dni)
           );

            /*    SELECT cuenta.cod_cuenta, cuenta.saldo, codigo_cliente, cliente.dni, nombre, apellido1, apellido2, direccion
            FROM cliente JOIN tiene ON tiene.dni=cliente.dni JOIN cuenta ON tiene.cod_cuenta=cuenta.cod_cuenta
					WHERE ccuenta = cuenta.cod_cuenta; */
			
		END LOOP loop1;
        close cursor1;
        select * from clientesNegativo;
	END;$$
delimiter ;
call cuentasNegativo();


/*5. Calcule con un procedimiento la suma de todos los ingresos y cargos (por separado) en todas las
cuentas de ebanca.*/
delimiter $$
DROP PROCEDURE IF EXISTS calculoMovimientos$$
CREATE PROCEDURE calculoMovimientos()
	BEGIN
		DECLARE eof BOOL default false;
		
        DECLARE cargos int default 0;
        DECLARE ingresos int default 0;
        DECLARE temp0 int default 0;
        DECLARE temp1 int default 0;
  
        DECLARE cursor0 cursor FOR SELECT cod_cuenta FROM cuenta;
        DECLARE cursor1 cursor FOR SELECT cantidad FROM movimiento where cod_cuenta=temp0;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eof=true;
		
        DROP TABLE IF EXISTS move;
		CREATE TABLE move (
            codigo_cuenta	varchar(10),
            cargos			int,
			ingresos	 	int
		);  
        open cursor0;
		loop0: LOOP
			FETCH cursor0 INTO temp0;
            IF eof THEN
				LEAVE loop0;
			END IF;
            
			open cursor1;
			loop1: LOOP
				FETCH cursor1 INTO temp1;
				IF eof THEN
					LEAVE loop1;
				END IF;
				
				IF temp1 > 0 THEN
					set ingresos = ingresos+temp1;
				ELSE 
					set cargos = cargos+temp1;
				END IF;
				
			END LOOP loop1;
			close cursor1;
			set eof=false;
			
			insert into move values(temp0, cargos,ingresos);
			set ingresos=0;
			set cargos=0;
			
        END LOOP loop0;
        close cursor0;
        select * from move;
	END;$$
delimiter ;
call calculoMovimientos();
