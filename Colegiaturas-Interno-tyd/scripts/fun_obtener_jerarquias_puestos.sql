CREATE OR REPLACE FUNCTION fun_obtener_jerarquias_puestos(OUT idu_puesto integer, OUT nom_puesto character varying, OUT nivel_jerarquico integer)
  RETURNS SETOF record AS
$BODY$
DECLARE
	/*
	Fecha                          : 11/04/2018
	Número empleado                : 95194185
	Nombre del empleado            : Paimi
	Base de datos                  : administracion
	Descripción del funcionamiento : Obtiene listado de jerarquías de puestos
	Ejemplo                        : 
		select * from fun_obtener_jerarquias_puestos()
	------------------------------------------------------------------------------------------------------ */
	rec RECORD;
BEGIN
    create temp table tmp_jerarquias_puestos (idu_puesto integer
        , nom_puesto varchar
        , nivel_jerarquico integer
    ) on commit drop;

    insert into tmp_jerarquias_puestos (idu_puesto, nom_puesto, nivel_jerarquico)
        select jer.idu_puesto
            , '' as nom_puesto
            , jer.nivel_jerarquico
        from cat_jerarquias_puestos as jer
        ORDER BY jer.nivel_jerarquico, jer.idu_puesto;
    
    update tmp_jerarquias_puestos set nom_puesto = pst.nom_puesto
    from cat_puestos_gx as pst
    where pst.idu_puesto = tmp_jerarquias_puestos.idu_puesto;
    
    FOR rec IN (
        select tmp.idu_puesto
            , tmp.nom_puesto
            , tmp.nivel_jerarquico
        from tmp_jerarquias_puestos as tmp
        order by tmp.nivel_jerarquico, tmp.idu_puesto
    ) LOOP
        idu_puesto := rec.idu_puesto;
        nom_puesto := rec.nom_puesto;
        nivel_jerarquico := rec.nivel_jerarquico;
        RETURN NEXT;
    END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_obtener_jerarquias_puestos() TO sysgenexus;
GRANT EXECUTE ON FUNCTION fun_obtener_jerarquias_puestos() TO sysmesaayuda;
GRANT EXECUTE ON FUNCTION fun_obtener_jerarquias_puestos() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_jerarquias_puestos() TO postgres;
COMMENT ON FUNCTION fun_obtener_jerarquias_puestos()  IS 'La función obtiene las jerarquías de algunos puestos gerenciales';