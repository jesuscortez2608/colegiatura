CREATE OR REPLACE FUNCTION fun_grabar_estatus_revisar_factura(integer, integer, integer, text, integer)
  RETURNS integer AS
$BODY$
declare

	id_factura		ALIAS FOR $1;
	nFolioDeduccion		ALIAS FOR $2;
	nEmpleadoRegistro	ALIAS for $3;
	cObservaciones		ALIAS FOR $4;
	iRevision		ALIAS FOR $5;

	idEscuela integer;

	/*
		No. peticion APS		: 16559.1
		Fecha				: 12/03/2018
		Numero empleado			: 98439677
		Nombre del empleado            	: Rafael Ramos
		Base de datos                  	: personal
		Servidor de desarrollo         	: 
		Descripción del funcionamiento 	: actualiza el estatus de la factura (IDU_ESTATUS) de la tabla MOV_FACTURAS_COLEGIATURAS
		Descripción del cambio         	: NA
		Sistema                        	: Colegiaturas
		Módulo                         	: Aceptar / Rechazar Facturas
		Ejemplo                        	: 
		Modifica 			: Omar Alejandro Lizárraga Hernández
		Descripcion			: Se agrega parametro iRevisiion para mandar a la tabla mov_revision
	*/
begin

	update	MOV_FACTURAS_COLEGIATURAS
	SET	IDU_ESTATUS = 5,
		EMP_MARCO_ESTATUS = nEmpleadoRegistro,
		idu_tipo_deduccion = nFolioDeduccion,
		FEC_MARCO_ESTATUS = now(),
		des_observaciones = trim(cObservaciones)
	where	IDFACTURA = id_factura;

	idEscuela:=(select idu_escuela from MOV_FACTURAS_COLEGIATURAS where idfactura=id_factura);

	/*
	CREATE temp TABLE stmpRevision
	(
	  idEscuela integer,
	  idMotivoRevision integer,
	  idEstatusRevision integer
	  
	)on commit drop;

	insert 	into stmpRevision (idEscuela, idMotivoRevision, idEstatusRevision)
	select 	idu_escuela, idu_motivo_revision, idu_estatus_revision 
	from 	MOV_REVISION_COLEGIATURAS
	where	idu_escuela=idEscuela 
		and idu_estatus_revision<2;
	*/	
	
	if exists (select idu_revision from MOV_REVISION_COLEGIATURAS where idu_escuela=idEscuela) then
		update 	MOV_REVISION_COLEGIATURAS set idu_estatus_revision=1, idu_motivo_revision=iRevision, fec_revision='19000101', fec_conclusion='19000101', usuario_revision=0 
		where 	idu_escuela=idEscuela;
	else
		insert 	into MOV_REVISION_COLEGIATURAS (idu_escuela, idu_motivo_revision, idu_estatus_revision, idu_usuario_captura, fec_captura)
		select 	idu_escuela, iRevision, 1, nEmpleadoRegistro, now() 
		from 	MOV_FACTURAS_COLEGIATURAS 
		where 	idfactura=id_factura; 
	end if; 	

	return 1;
end
$BODY$  
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_grabar_estatus_revisar_factura(integer, integer, integer, text, integer)   TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_estatus_revisar_factura(integer, integer, integer, text, integer)   TO sysinternet;
COMMENT ON FUNCTION fun_grabar_estatus_revisar_factura(integer, integer, integer, text, integer)  IS 'La función modifca el estatus de la factura';