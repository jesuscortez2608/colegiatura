DROP FUNCTION IF EXISTS fun_obtener_facturas_escuela_revision(integer);

CREATE OR REPLACE FUNCTION fun_obtener_facturas_escuela_revision(
IN iescuela integer, 
OUT iidfactura integer, 
OUT dfec_factura character, 
OUT sfol_fiscal character, 
OUT sserie character, 
OUT iidu_empleado integer, 
OUT snom_empleado character, 
OUT iidu_centro integer, 
OUT snom_centro character, 
OUT iblog integer, 
OUT iidu_estatus integer, 
OUT snom_estatus character, 
OUT snom_archivo_xml character, 
OUT snom_archivo_pdf character, 
OUT sfecha_captura character, 
OUT iciclo_escolar integer, 
OUT sciclo_escolar character, 
OUT iimportefactura numeric)
  RETURNS SETOF record AS
$BODY$
DECLARE	
	valor record;
	sRFCEscuela VARCHAR(20);
	
	/* --------------------------------------------------------------------------------     
	No.Petición: 16559
	Fecha: 14/06/2018
	Numero Empleado: 94827443
	Nombre Empleado: Omar Alejandro Lizarraga Hernandez 
	BD: personal    
	Servidor Desarrollo: 10.44.114.75
	Servidor Productivo: 10.44.2.183
	Modulo: Colegiaturas
	Repositorio: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
        select * from fun_obtener_facturas_escuela_revision(12888)
	--------------------------------------------------------------------------------*/	
	BEGIN
        --sRFCEscuela := (SELECT rfc_clave_sep FROM CAT_ESCUELAS_COLEGIATURAS WHERE idu_escuela = iescuela LIMIT 1);
        
        CREATE TEMP TABLE tmpIDEscuelas(idu_escuela integer, rfc_clave_sep varchar(20)) on commit drop;
        
        INSERT 	INTO tmpIDEscuelas(idu_escuela, rfc_clave_sep)
        SELECT 	idu_escuela
				,rfc_clave_sep 
        FROM 	CAT_ESCUELAS_COLEGIATURAS 
        WHERE 	idu_escuela=iescuela;
				--rfc_clave_sep = sRFCEscuela;
        
		--TABLAS TEMPORALES
		CREATE TEMP TABLE tmpDatos(
			idfactura integer,
			fec_factura varchar(10), 
			fol_fiscal varchar(100), 
			serie varchar(20), 
			idu_empleado integer, 
			nom_empleado varchar(50), 
			idu_centro integer,
			nom_centro varchar(50), 
			blog integer,
			idu_estatus integer,
			nom_estatus varchar(30),
			--fec_registro timestamp without time zone,
			nom_archivo1 varchar(60), 
			nom_archivo2 varchar(60), 
			fec_registro varchar(10),
			ciclo_escolar integer,
			nom_ciclo_escolar varchar(30),
			importe_factura numeric
		) ON COMMIT DROP;

		--FACTURAS
		INSERT 	INTO tmpDatos (idfactura, fec_factura, fol_fiscal, serie, idu_empleado, idu_centro, blog, idu_estatus,nom_archivo1,nom_archivo2,ciclo_escolar,fec_registro, importe_factura)		
		SELECT 	DISTINCT A.idfactura, to_char(A.fec_factura,'dd-mm-yyyy'), A.fol_fiscal, A.serie, A.idu_empleado, A.idu_centro, 0, A.idu_estatus,A.nom_xml_recibo, A.nom_pdf_carta,B.idu_ciclo_escolar,to_char(A.fec_registro,'dd-mm-yyyy'),A.importe_factura
		FROM	MOV_FACTURAS_COLEGIATURAS A
		INNER	JOIN MOV_DETALLE_FACTURAS_COLEGIATURAS B on A.idfactura=B.idfactura
        INNER	JOIN tmpIDEscuelas C on A.idu_escuela=C.idu_escuela;
        
        --EMPLEADO
		UPDATE 	tmpDatos SET nom_empleado = B.nombre || ' ' || B.apellidopaterno || ' ' || apellidomaterno
		FROM	SAPCATALOGOEMPLEADOS B
		WHERE	tmpDatos.idu_empleado=B.numempn;

		--CENTRO
		UPDATE 	tmpDatos SET nom_centro = B.nombrecentro
		FROM	SAPCATALOGOCENTROS B
		WHERE	tmpDatos.idu_centro=B.centron;

		--BLOG
		UPDATE	tmpDatos SET blog=1
		FROM	MOV_BLOG_REVISION B
		WHERE	tmpDatos.idfactura=B.id_factura;

		--ESTATUS FACTURAS
		UPDATE 	tmpDatos SET nom_estatus=B.nom_estatus
		FROM	CAT_ESTATUS_FACTURAS B		
		WHERE	tmpDatos.idu_estatus=B.idu_estatus;

		--CICLO ESCOLAR
		UPDATE 	tmpDatos SET nom_ciclo_escolar=B.des_ciclo_escolar
		FROM	CAT_CICLOS_ESCOLARES B
		where	tmpDatos.ciclo_escolar=B.idu_ciclo_escolar;		
		
		FOR valor IN (	SELECT 	idfactura, fec_factura, fol_fiscal, serie, idu_empleado, nom_empleado, idu_centro, nom_centro, blog, idu_estatus, nom_estatus, nom_archivo1, nom_archivo2, 
					fec_registro, ciclo_escolar,nom_ciclo_escolar, importe_factura 
				FROM 	tmpDatos ORDER BY fec_registro)
		LOOP
			 iidfactura:=valor.idfactura;
			 dfec_factura:=valor.fec_factura;
			 sfol_fiscal:=valor.fol_fiscal ;
			 sserie:=valor.serie;
			 iidu_empleado:=valor.idu_empleado;
			 snom_empleado:=valor.nom_empleado;
			 iidu_centro:=valor.idu_centro;
			 snom_centro:=valor.nom_centro;
			 iblog:=valor.blog;
			 iidu_estatus:=valor.idu_estatus;
			 snom_estatus:=valor.nom_estatus;
			 snom_archivo_xml:=valor.nom_archivo1;
			 snom_archivo_pdf:=valor.nom_archivo2;
			 sfecha_captura:=valor.fec_registro;
			 iciclo_escolar:=valor.ciclo_escolar;			 
			 sciclo_escolar:=valor.nom_ciclo_escolar;
			 iimportefactura:=valor.importe_factura;
			
		RETURN NEXT;
		END LOOP;
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_facturas_escuela_revision(integer)  TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_facturas_escuela_revision(integer)  TO syspersonal;

COMMENT ON FUNCTION fun_obtener_facturas_escuela_revision(integer)  IS 'La función obtiene las facturas de las escuelas que se encuentran en revisión';