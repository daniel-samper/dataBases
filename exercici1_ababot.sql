/*8.2.8 Exercicis 1 */
/*█ 1. Sobre una base de pruebas “test” cree un procedimiento para mostrar el año actual. */
DELIMITER $$
CREATE PROCEDURE test.mostraAny()
	BEGIN
		SELECT YEAR(CURDATE()) as anyActual;
	END$$
delimiter ;

/*█ 2. Cree y muestre una variable de usuario con SET. */
SET @var = 5;
SELECT @var AS variable;

/*█ 3. Use un procedimiento que sume uno a la variable anterior cada vez que se ejecute. (En este caso la
variable es de entrada/salida ya que necesitamos su valor para incrementarlo y además necesitamos
usarlo después de la función para comprobarlo). */
DELIMITER $$
DROP PROCEDURE IF EXISTS incrementa$$
CREATE PROCEDURE incrementa()
	BEGIN
		SET @var=@var+1;
	END$$
delimiter ;

CALL incrementa;
SELECT @var AS variable;

/*█ 4. Cree un procedimiento que muestre las tres primeras letras de una cadena pasada como parámetro en
mayúsculas. */
DELIMITER $$
DROP PROCEDURE IF EXISTS mostra$$
CREATE PROCEDURE mostra(IN cad varchar(10))
	BEGIN
		SELECT UPPER(LEFT(cad,3))AS mostra;
	END$$
delimiter ;

CALL mostra('hola');

/*█ 5. Cree un procedimiento que muestre dos cadenas pasadas como parámetros concatenadas y en
mayúscula. */
DELIMITER $$
DROP PROCEDURE IF EXISTS junta$$
CREATE PROCEDURE junta(IN cad1 varchar(10),IN cad2 varchar(10))
	BEGIN
		SELECT LOWER(CONCAT(cad1,cad2))AS mostra;
	END$$
delimiter ;

CALL junta('hola', ' QUE TAL');

/*█ 6. Cree una función que devuelva el valor de la hipotenusa de un triángulo a partir de los valores de sus
lados */
delimiter $$
DROP FUNCTION IF EXISTS hipo$$
CREATE FUNCTION hipo(c1 INT, c2 INT) RETURNS double
	RETURN SQRT(POW(c1,2)+POW(c2,2));$$
delimiter ;

SELECT hipo(5,2);

/*█ 7. Cree una función que calcule el total (suma) de puntos en un partido tomando como entrada el
resultado en formato „xxx-xxx‟. Usar funciones SUBSTR y INSTR. */
delimiter $$
DROP FUNCTION IF EXISTS puntsTotal$$
CREATE FUNCTION puntsTotal(cad VARCHAR(7)) RETURNS INT
	BEGIN
    
		DECLARE tmp1 VARCHAR(3);
		DECLARE tmp2 VARCHAR(3);
        SET tmp1 = SUBSTR(cad,1,3);
        SET tmp2 = SUBSTR(cad,5,3);
        
		RETURN CAST(tmp1 AS SIGNED)+CAST(tmp2 AS SIGNED);
	END $$
delimiter ;

SELECT puntsTotal('005-011');




