La función fun_grabar_estatus_factura.sql debe actualizar el estatus de una factura.
	- keyx
	- Estatus
	- Usuario
	
Parámetros:
    INTEGER, identificador único de la factura en la tabla mov_facturas_colegiaturas
    INTEGER, identificador del estatus (debe existir en la tabla cat_estatus_facturas)
    INTEGER, identificador del usuario que modificó el estatus
    
Resultado:
La función no devuelve un resultado, simplemente cambia el estatus.
	
Los campos que afecta esta función son los siguientes:
	mov_facturas_colegiaturas.idu_estatus
	mov_facturas_colegiaturas.emp_marco_estatus
	mov_facturas_colegiaturas.fec_marco_estatus (now())
Instalación
Servidor: 10.44.2.29
Base de datos: administracion
