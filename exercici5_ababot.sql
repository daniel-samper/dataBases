/*8.7.4 Exercicis 5*/

/*█1. Cree un evento que cargue una comisión del 2% sobre las cuentas en números rojos cada primero de
mes comenzando el 1 del próximo mes. Para esto deberá mirarse que cuentas hay en la tabla nrojos
y hacer un update en el saldo de la cuenta de la tabla cuenta. Para probarlo, crealo para que empiece
en 2 o tres minutos y se repita cada 20 segundos. (Mírate como se puede parar la ejecución del
evento antes de hacerlo).*/

DELIMITER $$
DROP EVENT IF EXISTS comisiones$$
CREATE EVENT comisiones
ON SCHEDULE EVERY 1 MONTH
STARTS "2018-07-01" ENABLE
DO BEGIN
	DECLARE eof BOOL default false;
	DECLARE tmp int;

	DECLARE cursor_1 cursor FOR SELECT njcuenta FROM nrojos;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET eof=true;
	
	open cursor_1;
	cursor1: LOOP
		FETCH cursor_1 INTO tmp;
		IF eof THEN
			LEAVE cursor1;
		END IF;
		UPDATE cuenta set saldo=saldo*1.02 where cod_cuenta=tmp;
	END LOOP cursor1;
	close cursor_1;
END; $$

/*█2. Cree un evento que registre diariamente los movimientos superiores a 1.000 euros en una tabla temp.
Créelo deshabilitado.*/

DROP TABLE IF EXISTS temp;
CREATE TABLE temp (
	temp_fecha datetime,
	temp_cantidad decimal(4,0),
	temp_dni int,
	temp_cod_cuenta int,
	temp_id_movimiento int(11) NOT NULL PRIMARY KEY
);

delimiter $$
DROP EVENT IF EXISTS bigMoves$$
CREATE EVENT bigMoves
ON SCHEDULE EVERY 1 DAY
DISABLE
DO BEGIN
	DECLARE eof BOOL default false;
	DECLARE tfecha datetime;
	DECLARE tcantidad decimal(4,0);
	DECLARE tdni int;
	DECLARE tcod_cuenta int;
	DECLARE tid_movimiento int;

	DECLARE cursor_1 cursor FOR SELECT fecha,cantidad,dni,cod_cuenta,id_movimiento from movimiento where date(fecha)=curdate() and cantidad>1000;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET eof=true;

	open cursor_1;
	loop1: LOOP
		FETCH cursor_1 INTO tfecha,tcantidad,tdni,tcod_cuenta,tid_movimiento;
		IF eof THEN
			LEAVE loop1;
		END IF;
		INSERT INTO temp VALUES(tfecha,tcantidad,tdni,tcod_cuenta,tid_movimiento);
	END LOOP loop1;
	close cursor_1;
END$$
delimiter ;


/*█3. Programe un evento que cuatro veces al año elimine los usuarios del blog que no publican hace más
de tres meses (puede crear un procedimiento que devuelva el número de noticias de un autor a partir
de una fecha dada).*/

delimiter $$
DROP EVENT IF EXISTS autoresVagos$$
CREATE EVENT autoresVagos
ON SCHEDULE EVERY 1 QUARTER
DO BEGIN
	DECLARE eof BOOL default false;
	DECLARE tmp int default 0;
	DECLARE qnews int default 0;

	DECLARE cursor_1 cursor FOR SELECT id_autor from autores;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET eof=true;

	open cursor_1;
	loop1: LOOP
		FETCH cursor_1 INTO tmp;
		IF eof THEN
			LEAVE loop1;
		END IF;
        INSERT INTO temp values(1,1);
        
        if noticiesData(tmp)=0 THEN
			delete from  autores where id_autor=tmp;
		END IF;
	END LOOP loop1;
	close cursor_1;
END$$
delimiter ;
		
delimiter $$
DROP FUNCTION IF EXISTS noticiesData$$
CREATE FUNCTION noticiesData(autor int ) RETURNS INT
	BEGIN
		return (Select count(id) from noticias where datediff(curdate(),fecha)<=90 and autor_id=autor);
	END;$$
delimiter ;


/*█4. Programe un análisis (ANALYZE) de las tablas de la base liga para el primer día del próximo mes.*/

delimiter $$
DROP EVENT IF EXISTS analisisLiga$$
CREATE EVENT analisisLiga
ON SCHEDULE AT "2018-07-01"
DO BEGIN

ANALYZE TABLE equipo;
ANALYZE TABLE jugador;
ANALYZE TABLE partido;
ANALYZE TABLE posicion;

END$$
delimiter ;

/*No se, no entenc, que s'espera exactament d'aquest event(4).*/

