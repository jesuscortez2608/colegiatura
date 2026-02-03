$(function(){
	setTimeout(function(){
		
		/** La carga de config
		-------------------------------------------------- */
		cargar_configuracion_inicial(function(){
			/** Cargar conceptos del sat
			 *  Esta carga de conceptos alimenta los archivos
			 *      - files/values/strval_<num_catalogo>.json
			-------------------------------------------------- */
			cargar_conceptos_sat();
			
			/** 
			 *  Carga los parámetros de la tabla 
			 *  ctl_parametros_colegiaturas
			 *  Y los deposita en el archivo
			 *      - files/values/parametros_colegiaturas.js
			 *  el cual tiene el siguiente formato,
			 *      var oParametrosColegiaturas = {
			 *          "PERMITIR_DESCUENTOS_DIFERENTES" : "0",
			 *          "URL_SERVICIO_FACTURACION" : "http://10.44.15.35/WsReceptorFacturacion/WsReceptorFacturacion.php?wsdl",
			 *          "URL_SERVICIO_COLEGIATURAS" : "http://10.44.15.183:8080/WsColegiaturas/rest"
			 *      };
			-------------------------------------------------- */
			cargar_parametros_colegiaturas(function(dataJson){
				/** 
				 *  Carga la tabla cat_area_seccion desde SQLServer
				 *  Utiliza el servicio http://10.44.15.183:8080/WsColegiaturas/rest de modo que antes de invocar esta función debemos asegurarnos de que exista el archivo de parámetros
				-------------------------------------------------- */
				for(var i in dataJson.datos){
					if (dataJson.datos[i].snomparametro == 'URL_SERVICIO_COLEGIATURAS') {
						cargar_catalogo_area_seccion(dataJson.datos[i].svalorparametro);
						break;
					}
				}
			});
		});
		
	}, 0);
	
	function cargar_configuracion_inicial(callback) {
		$.ajax({type:'POST',
			url:'ajax/proc/proc_cargar_configuracion.php',
			data:{},
			beforeSend:function(){
				waitwindow('Cargando configuración inicial', 'open');
			},
			success:function(data){
				var dataJson = JSON.parse(data);
				
				if (dataJson.debug_mode) {
					$("#cnt_configuracion").show();
				}
				
				if (callback != undefined) {
					callback();
				}
			},
			error:function onError(){
				waitwindow('', 'close');
			},
			complete:function(){
				waitwindow('', 'close');
			},
			timeout: function(){
				waitwindow('', 'close');
			},
			abort: function(){
				waitwindow('', 'close');
			}
		});
	}
	
	function cargar_conceptos_sat() {
		$.ajax({type:'POST',
			url:'ajax/proc/proc_cargar_conceptos_sat.php',
			data:{},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				// for(var i in dataJson) {
					// console.log(dataJson[i].resultado);
				// }
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	
	function cargar_parametros_colegiaturas(callback) {
		$.ajax({type:'POST',
			url:'ajax/proc/proc_cargar_parametros_colegiaturas.php',
			data:{},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				//console.log(dataJson);
				if (callback != undefined) {
					callback(dataJson);
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	
	function cargar_catalogo_area_seccion(sUrlServicioColegiaturas) {
		console.log(sUrlServicioColegiaturas);
		$.ajax({type:'POST',
			url:'ajax/proc/proc_cargar_catalogo_area_seccion.php',
			data:{'url_servicio_colegiaturas':sUrlServicioColegiaturas},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				for(var i in dataJson){
					console.log(dataJson[i].resultado);
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	
});