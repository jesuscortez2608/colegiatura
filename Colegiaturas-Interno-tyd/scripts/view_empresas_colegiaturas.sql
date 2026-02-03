DROP VIEW IF EXISTS view_empresas_colegiaturas;

CREATE OR REPLACE VIEW view_empresas_colegiaturas AS 
 SELECT DISTINCT empresas.idu_empresa,
    empresas.nom_empresa,
    empresas.nom_legal,
    empresas.rfc
   FROM ( SELECT DISTINCT his.idu_empresa,
            emp.nombre AS nom_empresa,
            emp.nombreempresa AS nom_legal,
            emp.rfc
           FROM his_facturas_colegiaturas his
             JOIN sapempresas emp ON emp.clave = his.idu_empresa
        UNION ALL
         SELECT DISTINCT mov.idu_empresa,
            emp.nombre AS nom_empresa,
            emp.nombreempresa AS nom_legal,
            emp.rfc
           FROM mov_facturas_colegiaturas mov
             JOIN sapempresas emp ON emp.clave = mov.idu_empresa) empresas;