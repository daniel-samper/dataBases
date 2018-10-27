/*8.3.7 Exercicis 2*/
/*1. Cree una función que devuelva 1 ó 0 si un número es o no divisible por otro.*/
delimiter $$
DROP FUNCTION IF EXISTS divisible$$
CREATE FUNCTION divisible(num int,divisor int) RETURNS BOOL
	BEGIN
		if num % divisor = 0 THEN
			RETURN true;
        else
			RETURN false;
        END IF;
	END $$
delimiter ;

SELECT divisible(10,2);



/*2. Use las estructuras condicionales para mostrar el día de la semana según un valor de entrada
numérico, 1 para domingo, 2 lunes, etc.*/
drop table if exists dies;
create table dies(
	ref int,
	dia varchar(9)
);
insert into dies values (1,'dilluns');
insert into dies values (2,'dimarts');
insert into dies values (3,'dimecres');
insert into dies values (4,'dijous');
insert into dies values (5,'divendres');
insert into dies values (6,'dissabte');
insert into dies values (7,'diumenge');

delimiter $$
DROP PROCEDURE IF EXISTS dia$$
CREATE PROCEDURE dia(IN num int) 
	BEGIN
		select dia FROM dies where ref=num;
	END$$
delimiter ;

CALL dia(6);



/*3. Cree una función que devuelva el mayor de tres números pasados como parámetros.*/
delimiter $$
DROP FUNCTION IF EXISTS major$$
CREATE FUNCTION major(num1 int,num2 int,num3 int) RETURNS int
	BEGIN
		DECLARE temp int;
		IF num1>num2 and num1>num3 THEN set temp=num1; 
			ELSEIF num2>num1 and num2>num3 THEN set temp=num2; 
				ELSE set temp=num3; 
		END IF;
        
        Return temp;
	END $$
delimiter ;

SELECT major(4,3,5);



/*4. Sobre la base de datos ríos, cree una función que devuelva true si el rio pasa por alguna ciudad de la
base de datos y false si no es así. El parámetro de entrada es el nombre del rio.*/
delimiter $$
DROP FUNCTION IF EXISTS riuCiutat$$
CREATE FUNCTION riuCiutat(nriu varchar(20)) RETURNS bool
	BEGIN
		declare temp varchar(20);
		if (SELECT riu_ciutat.riu FROM riu_ciutat where riu_ciutat.riu=nriu group by riu_ciutat.riu) is not null then
			return true;
		else 
			return false;
        end if;
	END $$
delimiter ;

select riuCiutat('Ebro');
select riuCiutat('Guadalquivir');
select riuCiutat('Salchicha');




/*5. Cree un procedimiento que diga si una palabra, pasada como parámetro, es palíndroma.*/
delimiter $$
DROP PROCEDURE IF EXISTS pali$$
CREATE PROCEDURE pali(cad1 varchar(15)) 
	BEGIN
		declare cad2 varchar(15);
        set cad2=reverse(cad1);
        if strcmp(cad1,cad2)=0 then select 'palindroma';
			else select 'no palindorma';
        end if;
	END$$
delimiter ;

CALL pali('pep');




/*6. Basada en la base de datos banco, cree una función a partir del nombre de un empleado, devuelva la
cantidad de vendedores a los que dirige.*/
delimiter $$
DROP FUNCTION IF EXISTS subditos$$
CREATE FUNCTION subditos(nom varchar(20)) RETURNS bool
	BEGIN
		declare temp int default 0;
		declare numSub int default 0;
        set temp = (select num_empl from repventas where nombre=nom);
        set numSub =(select count(*) from repventas where director=temp );
        return numSub;
	END $$
delimiter ;

select subditos('Larry Fitch');

SELECT * FROM andersonco.repventas;
select count(*) from repventas 




/*7. Sobre la base test cree un procedimiento que muestre la suma de los primeros n números enteros,
siendo n un parámetro de entrada.*/
delimiter $$
DROP PROCEDURE IF EXISTS sumaEnters$$
CREATE PROCEDURE sumaEnters (IN n int)
	BEGIN
		declare i int default 1;
        declare result int default 0;
        while i<=n DO
			set result=result+i;
            set i=i+1;
		end while;
        select result;
	END;$$
delimiter ;

call sumaEnters(10);




/*8. Sobre la base de datos liga crea una función que devuelva 1si ganó el visitante y 0 en caso contrario.
El parámetro de entrada es el resultado con el formato „xxx-xxx‟.*/
delimiter $$
DROP FUNCTION IF EXISTS guanyador$$
CREATE FUNCTION guanyador(cad varchar(7)) RETURNS varchar(10)
	BEGIN
		declare llargada int;
		declare separador int;
		declare tmp1 int;
		declare tmp2 int;
        declare guanyador varchar(10);
        declare pos1 int;
        declare pos2 int;
                
        set llargada = CHAR_LENGTH(cad);
        set separador = INSTR(cad,'-');
        set pos2=llargada-separador;
        set pos1=llargada-pos2-1;
		SET tmp1 = left(cad,pos1);
        SET tmp2 = right(cad,pos2);
        
        if tmp1=tmp2 then set guanyador='Empat';
        elseif tmp1>tmp2 then set guanyador='Local';
        else set guanyador='Visitante';
        end if;
        return guanyador;
	END $$
delimiter ;

select guanyador('100-111');



