/*█ 8.6.8 Exercicis 4 █*/

/*█1. Crea una nueva tabla nrojos asociada a la base de datos ebanca. Debe contener los campos cuenta,
fecha y saldo, que son del mismo tipo que los que se encuentran en tabla cuenta. Crear un disparador
que cree un registro en la tabla nrojos cada vez que una cuenta se quede en números rojos. Verificar
antes de insertar que el registro ya exista. En ese caso, hacer modificación en lugar de inserción.*/
DROP TABLE IF EXISTS nrojos;
CREATE TABLE nrojos (
	njcuenta int(11) Primary Key NOT NULL,
    njfecha date,
	njsaldo int(11)
);

DELIMITER $$
	CREATE TRIGGER arruinado AFTER UPDATE ON cuenta
	FOR EACH ROW BEGIN
		IF(NEW.saldo<0) THEN
			IF (SELECT COUNT(njcuenta) FROM nrojos WHERE njCuenta=OLD.cod_cuenta)=1 THEN
				UPDATE nrojos set njfecha=now() where njcuenta=OLD.cod_cuenta;
				UPDATE nrojos set njsaldo=NEW.saldo where njcuenta=OLD.cod_cuenta;
			ELSE
				INSERT INTO nrojos values(NEW.cod_cuenta,now(),NEW.saldo);
			END IF;
		END IF;
	END$$
DELIMITER ;

select * from nrojos;
select * from cuenta;
update cuenta set saldo=-10 where cod_cuenta=0;

/*█2. Cree un disparador para que cada vez que se registre un partido, se actualice el atributo puntos de la
tabla equipo, el equipo que ha ganado el partido. Usar función creada en ejercicios anteriores.*/

DROP TRIGGER IF EXISTS sumaPuntos;
DELIMITER $$
	CREATE TRIGGER sumaPuntos AFTER INSERT ON partido
	FOR EACH ROW BEGIN
		IF(guanyador(NEW.resultado)=1) THEN
				UPDATE equipo set puntos=puntos+1 where id_equipo=NEW.local;
		ELSE
			UPDATE equipo set puntos=puntos+1 where id_equipo=NEW.visitante;
		END IF;
	END$$
DELIMITER ;

INSERT INTO partido values(15,1,2,'75-88','2018-11-11',2);

/*█3. Cree un disparador que cada vez que se borre una noticia de la base de datos motorblog, registre en una
tabla log_borrados el titulo de la noticia, el usuario y la fecha y hora.*/

DROP TABLE IF EXISTS log_borrados;
CREATE TABLE log_borrados (
	log_titulo varchar(40) Primary Key NOT NULL,
    log_usuario varchar(40),
	log_fecha datetime
);
DROP TRIGGER IF EXISTS logBorradoNoticias;
DELIMITER $$
	CREATE TRIGGER logBorradoNoticias AFTER DELETE ON noticias
	FOR EACH ROW BEGIN
		INSERT INTO log_borrados values(OLD.titulo,current_user(),now());
	END$$
DELIMITER ;

delete from noticias where id=5;
select * from log_borrados;


/*█4. Haga lo necesario para que cada vez que se produzca un movimiento de ebanca, de un ingreso de más
de 1.000 euros se le bonifique con 100 (añadir 100 euros al importe del movimiento). Solo se le
aplicará a clientes con cuentas que superen tres años de antigüedad y durante el periodo comprendido
entre hoy menos un mes y hoy más un mes.*/

DROP TRIGGER IF EXISTS bonificacion;
DELIMITER $$
	CREATE TRIGGER bonificacion BEFORE INSERT ON movimiento
    FOR EACH ROW BEGIN
    
    DECLARE antiguedad bool default false;
    DECLARE periodo bool default false;
    DECLARE fechaPromo date default '2018-05-10'; -- selecciona la data d'on restarem i sumarem 30 dies
    
    DECLARE difPeriodo int default datediff(NEW.fecha,fechaPromo);
    
    IF(datediff(NEW.fecha,(SELECT fecha_creacion from cuenta where cuenta.cod_cuenta = NEW.cod_cuenta))>1095) THEN
		set antiguedad = true;
	END IF;
    
    IF(difPeriodo<=30 and difPeriodo>=-30) THEN
		set periodo = true;
	END IF;
	
    if(antiguedad and periodo and NEW.cantidad>1000) THEN
		set NEW.cantidad = NEW.cantidad+100;
	END IF;
    
	END$$
DELIMITER ;

insert into movimiento values('2018-04-30 00:00:00', '2500', '117', '5', '16');

/*█5. Crea una nueva tabla de nombre posición. La tabla contendrá los atributos: idequipo, nombreequipo,
posición y puntos. Crea un trigger de manera que cada vez que se actualice el campo puntos de un
registro de la tabla equipo de la base liga se borre el contenido de la tabla posición y se inserten todos
los registros de nuevo calculando la posición de cada equipo. Usar un cursor y un order by. (opcional).*/
DROP TABLE IF EXISTS posicion;
CREATE TABLE posicion (
	p_posicion int AUTO_INCREMENT Primary Key NOT NULL,
	p_idequipo int(11) NOT NULL,
    p_nombreequipo varchar(30),
	p_puntos int
);
    
DROP TRIGGER IF EXISTS actPuntuacion;
DELIMITER $$
	CREATE TRIGGER actPuntuacion AFTER UPDATE ON equipo
    FOR EACH ROW BEGIN
		
        DECLARE eof BOOL default false;
        DECLARE id int default 0;
        DECLARE nom varchar(30);
        DECLARE punts int default 0;
        
        DECLARE equipo_cursor cursor FOR SELECT id_equipo,nombre,puntos FROM equipo order by puntos desc;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eof=true;
        
       delete from posicion;
        
        open equipo_cursor;
		cursor1: LOOP
			FETCH equipo_cursor INTO id,nom,punts;
            IF eof THEN
				LEAVE cursor1;
			END IF;
            INSERT INTO posicion values(null,id,nom,punts);
		END LOOP cursor1;
        close equipo_cursor;
   
	END$$
DELIMITER ;

update equipo set puntos=25 where id_equipo=1;