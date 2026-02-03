CREATE OR REPLACE FUNCTION fun_consultar_bitacora_proceso_colegiaturas(
IN iRowsPerPage INTEGER
, IN iCurrentPage INTEGER
, IN sOrderColumn CHARACTER VARYING
, IN sOrderType CHARACTER VARYING
, IN sColumns CHARACTER VARYING
, OUT records INTEGER
, OUT page INTEGER
, OUT pages INTEGER
, OUT id INTEGER
, OUT idu_movimiento INTEGER
, OUT nom_movimiento CHARACTER VARYING
, OUT fec_movimiento TIMESTAMP WITHOUT TIME ZONE
, OUT icant_facturas BIGINT
, OUT icant_colaboradores BIGINT
, OUT fec_quincena DATE
, OUT idu_usuario BIGINT
, OUT nom_usuario CHARACTER VARYING
)
RETURNS SETOF RECORD AS
$BODY$
DECLARE
	/*** ========================================================
	No.Petición:		16559.1
	Fecha:				30/05/2018
	Numero Empleado: 	98439677
	Nombre Empleado: 	Rafael Ramos
	BD:				    PERSONAL    
	Servidor Prod:		10.44.2.183
	Servidor Prue:      10.28.114.75
	Sistema:			Colegiaturas
	Modulo: 			Catalogo de Carreras
	Ejemplo:
        SELECT  * 
        FROM    fun_consultar_bitacora_proceso_colegiaturas(
            100::INTEGER
            , 1::INTEGER
            , 'fec_movimiento'::VARCHAR
            , 'ASC'::VARCHAR
            , 'idu_movimiento, nom_movimiento
                , fec_movimiento, icant_facturas
                , icant_colaboradores, fec_quincena
                , idu_usuario, nom_usuario'::VARCHAR
        )
	=============================================================*/

	/**Variables de Paginado*/
	iStart integer;
	iRecords integer;
	iTotalPages integer;

	valor record;
	sConsulta varchar(3000);
BEGIN
	IF iRowsPerPage = -1 THEN
		iRowsPerPage := NULL;
	END IF;
	IF iCurrentPage = -1 THEN
		iCurrentPage := NULL;
	END IF;

	CREATE TEMPORARY TABLE tmp_bitacora(
		records INTEGER
		, page INTEGER
		, pages INTEGER
		, id INTEGER
		, idu_movimiento INTEGER NOT NULL DEFAULT 0
		, nom_movimiento CHARACTER VARYING(150) NOT NULL DEFAULT ''
		, fec_movimiento TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT '19000101'
		, icant_facturas BIGINT NOT NULL DEFAULT 0
		, icant_colaboradores BIGINT NOT NULL DEFAULT 0
		, fec_quincena DATE NOT NULL DEFAULT '19000101'
		, idu_usuario BIGINT NOT NULL DEFAULT 0
		, nom_usuario CHARACTER VARYING(250) NOT NULL DEFAULT ''
	)ON COMMIT DROP;

	INSERT	INTO tmp_bitacora(idu_movimiento
				, fec_movimiento
				, icant_facturas
				, icant_colaboradores
				, fec_quincena
				, idu_usuario)
		SELECT	bita.id_movimiento
			, bita.fec_movimiento
			, bita.num_facturas
			, bita.num_colaboradores
			, bita.fec_quincena
			, bita.id_usuario
		FROM	bit_proceso_colegiaturas AS bita
		ORDER	BY bita.id_movimiento;

	UPDATE	tmp_bitacora
    SET     nom_movimiento = UPPER(RTRIM(LTRIM(cat.nom_movimiento)))
	FROM	cat_movimientos_proceso_colegiaturas AS cat
	WHERE	tmp_bitacora.idu_movimiento = cat.id_movimiento;

	UPDATE	tmp_bitacora
	SET	nom_usuario = UPPER(RTRIM(LTRIM(sap.nombre))) || ' ' || UPPER(RTRIM(LTRIM(sap.apellidopaterno))) || ' ' || UPPER(RTRIM(LTRIM(sap.apellidomaterno)))
	FROM	sapCatalogoEmpleados AS sap
	WHERE	tmp_bitacora.idu_usuario = sap.numempn;

	iRecords := (SELECT COUNT(*) FROM tmp_bitacora);
	IF ( iRowsPerPage IS NOT NULL AND iCurrentPage IS NOT NULL ) THEN
		iStart := (iRowsPerPage * iCurrentPage) - iRowsPerPage + 1;
		iTotalPages := CEILING(iRecords / (iRowsPerPage * 1.0));

		sConsulta := '
			SELECT  ' || CAST(iRecords AS VARCHAR) || ' AS records
			      , ' || CAST(iCurrentPage AS VARCHAR)  || ' AS page
			      , ' || CAST(iTotalPages AS VARCHAR) || ' AS pages
			      , id
			      , ' || sColumns || '
			FROM (
			    SELECT ROW_NUMBER() OVER(ORDER BY ' || sOrderColumn || ' ' || sOrderType || ') AS id, ' || sColumns || '
			    FROM tmp_bitacora
			    ) as t
			WHERE t.id BETWEEN ' || CAST(iStart AS VARCHAR) || ' AND ' || CAST(((iStart + iRowsPerPage) - 1) AS VARCHAR) || ' ';
	ELSE
		sConsulta := 'SELECT ' || iRecords::VARCHAR || ' AS records, 0 as page, 0 as pages, 0 as id,' || sColumns || ' FROM tmp_bitacora ';
	END IF;

	sConsulta := sConsulta || ' ORDER BY ' || sOrderColumn || ' ' || sOrderType;

	FOR valor IN EXECUTE(sConsulta)
	LOOP
	    records		        := valor.records;
	    page		        := valor.page;
	    pages		        := valor.pages;
	    id			        := valor.id;
	    idu_movimiento	    := valor.idu_movimiento;
	    nom_movimiento	    := valor.nom_movimiento;
	    fec_movimiento	    := valor.fec_movimiento;
	    icant_facturas	    := valor.icant_facturas;
	    icant_colaboradores	:= valor.icant_colaboradores;
	    fec_quincena	    := valor.fec_quincena;
	    idu_usuario		    := valor.idu_usuario;
	    nom_usuario		    := valor.nom_usuario;
	    RETURN NEXT;
	END LOOP;
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_consultar_bitacora_proceso_colegiaturas(integer, integer, character varying, character varying, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_consultar_bitacora_proceso_colegiaturas(integer, integer, character varying, character varying, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_consultar_bitacora_proceso_colegiaturas(integer, integer, character varying, character varying, character varying) TO sysetl;
COMMENT ON FUNCTION fun_consultar_bitacora_proceso_colegiaturas(integer, integer, character varying, character varying, character varying) IS 'La función consulta la tabla bit_proceso_colegiaturas';