CREATE OR REPLACE FUNCTION fun_consultar_escuela(IN ifactura integer, OUT iescuela integer, OUT sescuela character varying, OUT iestado integer, OUT sestado character varying, OUT imunicipio integer, OUT smunicipio character varying, OUT srfc character varying, OUT srazon_social character varying, OUT sclave_sep character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE		
	valor record;	
	
	/*--------------------------------------------------------------------------------     
	No.Petición: 16559
	Fecha: 04/06/2018
	Numero Empleado: 94827443
	Nombre Empleado: Omar Alejandro Lizarraga Hernandez
	BD: Personal
	Servidor: 10.28.114.75
	Modulo: Colegiaturas
	Repositorio: 
	Descripción: Consulta las escuelas que coincidan con el RFC que se manda como parametro,
	la escuela no debe ser en linea ó extranjero es decir, idu_estado>0 
	Ejemplo: select * from fun_consultar_escuela(422)
	--------------------------------------------------------------------------------*/	
	BEGIN	
		--
		CREATE LOCAL TEMP TABLE tmpDatos (			
			idescuela integer,
			nom_escuela VARCHAR(100), 
			idestado INTEGER, 
			nom_estado VARCHAR (100),  
			idmunicipio integer, 
			nom_municipio VARCHAR(150), 
			idlocalidad integer, 
			nom_localidad VARCHAR(150),
			rfc VARCHAR(20),
			razon_social VARCHAR(150),
			clave_sep VARCHAR(20)	
		)
		ON COMMIT DROP;

		
				
		--
		insert 	into tmpDatos (idescuela)
		select 	idu_escuela 
		from 	MOV_FACTURAS_COLEGIATURAS 
		where 	idfactura=ifactura;

		--ESCUELA
		update 	tmpDatos set nom_escuela=B.nom_escuela			
			,idestado=B.idu_estado
			,idmunicipio=B.idu_municipio
			,idlocalidad=B.idu_localidad 
			,rfc=B.rfc_clave_Sep
			,razon_social=B.razon_social
			,clave_sep=B.clave_sep			
		from	CAT_ESCUELAS_COLEGIATURAS B
		where	tmpDatos.idescuela=B.idu_escuela;
		
		--ESTADOS
		UPDATE	tmpDatos SET nom_estado=B.nom_estado
		FROM	CAT_ESTADOS_COLEGIATURAS B
		WHERE	tmpDatos.idestado=B.idu_estado
			and B.idu_estado>0;

		--MUNICIPIO
		UPDATE	tmpDatos SET nom_municipio=B.nom_municipio
		FROM	CAT_MUNICIPIOS_COLEGIATURAS B
		WHERE	tmpDatos.iDestado=B.idu_estado 
			and tmpDatos.idmunicipio=B.idu_municipio
			and B.idu_municipio>0;			

		--LOCALIDAD
		UPDATE	tmpDatos SET nom_localidad=B.nom_localidad
		FROM	CAT_LOCALIDADES_COLEGIATURAS B
		WHERE	tmpDatos.idestado=B.idu_estado 
			and tmpDatos.idmunicipio=B.idu_municipio 
			and tmpDatos.idlocalidad=B.idu_localidad
			and B.idu_localidad>0;
		
		
		FOR valor IN (SELECT 
				idescuela,
				nom_escuela,
				idestado,
				nom_estado,
				idmunicipio,
				nom_municipio,
				--idlocalidad, 
				--nom_localidad 
				rfc,
				razon_social,
				clave_sep
			FROM tmpDatos)
		LOOP	
			iescuela:=valor.idescuela;
			sescuela:=valor.nom_escuela;
			iestado:=valor.idestado; 
			sestado:=valor. nom_estado; 
			imunicipio:=valor.idmunicipio;
			smunicipio:=valor.nom_municipio; 
			--ilocalidad integer, 
			srfc:=valor.rfc;
			srazon_social:=valor.razon_social;
			sclave_sep:=valor.clave_sep;
			
			
		RETURN NEXT;
		END LOOP;
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
