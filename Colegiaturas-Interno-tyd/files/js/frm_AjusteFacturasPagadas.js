$(function() {
	ConsultaClaveHCM()
	fnCargarGrid();
	
	//VARIABLES
	Folio='';
	iNumEmp=0;
	iFactura=0;
	pct=0;
	idAjuste=0;
	//fnCargarGridDetalle();
	
	$("#txt_NomEmp").prop("disabled", true);
	soloNumero('txt_porcentaje');
	//EMPLEADO
	$("#txt_NumEmp").on('input propertychange paste', function(){		
		if($("#txt_NumEmp").val().length != 8)
		{			
			LimpiarDatos();
		}	
		else 
		{
			ConsultaEmpleado();
		}
	});
	
//función para hacer un Trim y evitar vulnerabilidades :) 
 
String.prototype.makeTrim = function (characters) {

	let result = this;

	for (let i = 0; i < characters.length; i++) {
		while (result.charAt(0) === characters[i]) {
			result = result.substring(1);
		}

		while (result.charAt(result.length - 1) === characters[i]) {
			result = result.substring(0, result.length - 1);
		}
	}
	return result;
}

	//EMPLEADO
	$("#txt_NumEmp").keypress(function(e){
		var keycode = e.which;
		//console.log(keycode);
		if(keycode == 13 || keycode == 9 /*|| keycode == 0*/)
		{
			if($("#txt_NumEmp").val().length != 8)
			{
				showalert(LengStrMSG.idMSG133, "", "gritter-warning");				
				$("#txt_NomEmp").val("");
			}
			else
			{		
				//2, function(){}
				ConsultaEmpleado();				
			}	
		}else if (keycode==0 || keycode==8){
			LimpiarDatos();
		}
	});
	
	//CONSULTA EMPLEADOS 
	function ConsultaEmpleado()
	{	
		//console.log('consulta empleado');
		iNumEmp=$("#txt_NumEmp").val();
		
		if(iNumEmp!='')
		{
			$.ajax({
				type: "POST", 
				url: "ajax/json/json_fun_consulta_empleado_co.php?",
			data: { 
					'iNumEmp':iNumEmp,
					'session_name': Session
				}
			})
			.done(function(data){				
				//console.log(2);
				var dataJson = JSON.parse(data);
				if(dataJson != null)
				{
					if(dataJson.cancelado=='1')
					{
						showalert(LengStrMSG.idMSG135, "", "gritter-warning");							
					}else{
						$("#txt_NomEmp").val(dataJson.nom_empleado);
					}					
				}else{
					showalert(LengStr.idMSG115, "", "gritter-warning");							
				}
			});
		}
	}
	
	//LIMPIAR DATOS
	function LimpiarDatos(){
		$("#txt_NomEmp").val('');
		jQuery("#gd_FacturasDetalle").GridUnload();
		fnCargarGrid();
		//$("#txt_Folio").val('');
	}
	
	//CARGAR GRID
	function fnCargarGrid()
	{	
		//console.log('Cargar Grid');
		jQuery("#gd_Facturas").GridUnload();
		jQuery("#gd_Facturas").jqGrid({
			//url:'ajax/json_fun_obtener_facturas_para_ajustes.php?cFolio=' +cFolio+'&iNumEmp='+iNumEmp+'&session_name='+ Session,
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG94,
				colModel:[				
				{name:'id',index:'id', width:70, sortable: false,align:"left",fixed: true, hidden:true},
				{name:'fecha_factura',index:'fecha_factura', width:80, sortable: false,align:"center",fixed: true},				
				{name:'foliofiscal',index:'foliofiscal', width:300, sortable: false,salign:"left",fixed: true},
				{name:'numemp',index:'numemp', width:50, sortable: false,align:"right",fixed: true, hidden:true},
				{name:'empleado',index:'empleado', width:250, sortable: false,align:"left",fixed: true},
				{name:'fecha_registro',index:'fecha_registro', width:75, sortable: false,align:"right",fixed: true},
				{name:'importe_pagado',index:'importe_factura', width:100, sortable: false,align:"right",fixed: true},
				{name:'importe_pagado',index:'importe_pagado', width:100, sortable: false,align:"right",fixed: true},
				{name:'fechapago',index:'fechapago', width:80, sortable: false,align:"right",fixed: true},
				{name:'porcentajepagado',index:'porcentajepagado', width:100, sortable: false,align:"center",fixed: true},
				{name:'becado',index:'becado', width:50, sortable: false,align:"right",fixed: true, hidden:true},
				{name:'nombecado',index:'nombecado', width:300, sortable: false,align:"left",fixed: true},
				{name:'parentesco',index:'parentesco', width:50, sortable: false,align:"right",fixed: true, hidden:true},
				{name:'nomparentesco',index:'nomparentesco', width:100, sortable: false,align:"left",fixed: true},
				{name:'factura',index:'factura', width:100, sortable: false,align:"right",fixed: true, hidden:true},				
				{name:'idestatus',index:'idestatus', width:100, sortable: false,align:"right",fixed: true, hidden:true},
				{name:'estatus',index:'estatus', width:100, sortable: false,align:"right",fixed: true/*, hidden:true*/}	
			],
			caption:'Facturas Pagadas',
			scrollrows : true,
			width: null,
			loadonce: false,
			shrinkToFit: false,
			height: 200, 
			rowNum:10,
			rowList:[10, 20, 30],
			pager: '#gd_Facturas_pager',
			sortname: 'FechaFactura',
			sortorder: "asc",
			viewrecords: true,
			hidegrid:false,			
			loadComplete: function (datos) {
				var registros = jQuery("#gd_Facturas").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
			},
			onSelectRow: function(id) {
				//if(id >= 0){				
					var fila = jQuery("#gd_Facturas").getRowData(id); 
					iFactura=fila['factura'];
					fnCargarGridDetalle();
				//}
				
				
			}
		});	
		
		//setSizeBtnGrid('id_button0',35);
		//setSizeBtnGrid('id_button1',35);
	}
	
	//ACTUALIZAR GRID
	function ActulizarGrid(){		
		$("#gd_Facturas").jqGrid('setGridParam', {url:'ajax/json/json_fun_obtener_facturas_para_ajustes.php?cFolio=' +cFolio+'&iNumEmp='+iNumEmp+'&session_name='+ Session,}).trigger("reloadGrid");
	}
	
	//BOTON CONSULTAR		
	$('#btn_Consultar').click(function(event){
		//console.log('CONSULTAR DATOS');
		jQuery("#gd_FacturasDetalle").GridUnload();	
		iFactura=0;
		cFolio=$('#txt_Folio').val();		
		iNumEmp=$('#txt_NumEmp').val();
		
		if ((cFolio=='') && (iNumEmp=='')){
			showalert(LengStr.idMSG96, "", "gritter-info");
		//}else if (iNumEmp==''){
		//	showalert(LengStrMSG.idMSG97, "", "gritter-info");
		}else{
			//cFolio=$('#txt_Folio').val();
			//iNumEmp=$('#txt_NumEmp').val();
			if (iNumEmp=='') {
				iNumEmp=0;
			}
			
			ActulizarGrid();
			//fnCargarGrid();
		}
		//event.preventDefault();		
	});	
	
	//BOTON GUARDAR
	$('#btn_Guardar').click(function(event){
		pct=$('#txt_porcentaje').val();
		if (iFactura==0){
			showalert(LengStr.idMSG100, "", "gritter-info");
		}else if ((pct=='') || (pct==0) || (pct>100)){
			showalert(LengStr.idMSG99, "", "gritter-info");
		}else{
			$('#txt_Justificacion').val('');
			$("#dlg_GuardarAjuste").modal('show');
		}
	});
	
	//BOTON GRABAR
	$('#btn_Grabar').click(function(event){
		justificaion=$('#txt_Justificacion').val().makeTrim(" ");
		
		if (justificaion==''){
			showalert(LengStr.idMSG97, "", "gritter-info");
		}else{
			GuardarAjuste();
		}
	});
	
	//FUNCION GUARDAR
	function GuardarAjuste(){
		$.ajax({
				type: "POST", 
				url: "ajax/json/json_fun_grabar_ajuste_por_factura.php?",
			data: { 
					'iPorcentaje':pct,
					'session_name': Session,
					'iFactura' : iFactura,
					'sObservaciones': $('#txt_Justificacion').val().toUpperCase()				
				}
		})
		.done(function(data){				
			//console.log(2);
			var dataJson = JSON.parse(data);
				showalert(dataJson.mensaje, "", "gritter-warning");							
				if(dataJson.estado>0)
				{
					$("#dlg_GuardarAjuste").modal('hide');
					ActulizarGridDetalle();					
					$('#txt_porcentaje').val('');				
					//iFactura=0;
				}					
		});
	}
	
	//CARGAR GRID DETALLE
	function fnCargarGridDetalle()
	{	
		//console.log('Cargar Grid');
		jQuery("#gd_FacturasDetalle").GridUnload();	
		jQuery("#gd_FacturasDetalle").jqGrid({
			url:'ajax/json/json_fun_obtener_ajustes_por_factura.php?iFactura=' +iFactura+'&session_name='+ Session,
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG98,					
				colModel:[				
				{name:'idajuste',index:'idajuste', width:70, sortable: false,align:"left",fixed: true, hidden:true},
				{name:'idfactura',index:'idfactura', width:120, sortable: false,align:"center",fixed: true, hidden:true},				
				{name:'importe_factura',index:'importe_factura', width:100, sortable: false,align:"right",fixed: true},
				{name:'importe_pagado',index:'importe_pagado', width:100, sortable: false,align:"right",fixed: true},
				{name:'porcentaje_ajuste',index:'porcentaje_ajuste', width:75, sortable: false,align:"center",fixed: true},
				{name:'importe_ajuste',index:'importe_ajuste', width:100, sortable: false,align:"right",fixed: true},
				{name:'observaciones',index:'observaciones', width:300, sortable: false,align:"left",fixed: true},
				{name:'usuariotraspaso',index:'usuariotraspaso', width:200, sortable: false,align:"right",fixed: true/*, hidden:true*/},
				{name:'fecha_traspaso',index:'fecha_traspaso', width:100, sortable: false,align:"center",fixed: true},
				{name:'usuario_registro',index:'usuario_registro', width:200, sortable: false,align:"right",fixed: true /*, hidden:true*/},
				{name:'fecha_registro',index:'fecha_registro', width:100, sortable: false,align:"left",fixed: true},
				{name:'usuario_cierre',index:'usuario_cierre', width:200, sortable: false,align:"right",fixed: true/*, hidden:true*/},
				{name:'fecha_cierre',index:'fecha_cierre', width:100, sortable: false,align:"left",fixed: true}				
			],
			caption:'Detalle Facturas Pagadas',
			scrollrows : true,
			width: null,
			loadonce: false,
			shrinkToFit: false,
			height: 200, 
			rowNum:10,
			rowList:[10, 20, 30],
			pager: '#gd_FacturasDetalle_pager',
			//sortname: 'FechaFactura',
			sortorder: "asc",
			viewrecords: true,
			hidegrid:false,			
			loadComplete: function (datos) {
				
			},
			onSelectRow: function(id) {
				var filaDetalle = jQuery("#gd_FacturasDetalle").getRowData(id); 
				idAjuste=filaDetalle['idajuste'];				
			}
		});			
		//setSizeBtnGrid('id_button0',35);
		//setSizeBtnGrid('id_button1',35);
		barButtongrid({
			pagId:"#gd_FacturasDetalle_pager",
			position:"left",//center rigth
			Buttons:[{
				icon:"icon-trash red",
				click:function (event){
					//console.log();
					if(idAjuste > 0){
						BorrarAjuste();
					}else{
						showalert("Seleccione un registro", "", "gritter-info");
					}
				},
				title:"Borrar Ajuste",
			},
			]
		});
		setSizeBtnGrid('id_button0',35);
		
		function setSizeBtnGrid(id,tamanio)
		{
		  $("#"+id).attr('width',tamanio+'px');
		  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
		}
	}
	
	//BORRAR AJUSTE
	function BorrarAjuste(){
		$.ajax({
				type: "POST", 
				url: "ajax/json/json_fun_borrar_ajuste_por_factura.php?",
			data: { 
					'idAjuste':idAjuste,
					'session_name': Session									
				}
		})
		.done(function(data){				
			//console.log(2);
			var dataJson = JSON.parse(data);
				showalert(dataJson.mensaje, "", "gritter-warning");							
				if(dataJson.estado>0)
				{		
					idAjuste=0;
					ActulizarGridDetalle();					
					$('#txt_porcentaje').val('');				
					//iFactura=0;
				}					
		});
	}
	function sanitize(string) { //función para sanitizar variables en JS
		var listaElementos = [];
		var returnList = [];
		var entity = {};
		entity.properti = "";
		listaElementos.push(entity);
		listaElementos.forEach(function (item) {
		item.properti = string;
		returnList.push(item);
		});
	return returnList[0].properti;
	  }
	//ACTUALIZAR GRID DETALLE
	function ActulizarGridDetalle(){		
		$("#gd_FacturasDetalle").jqGrid('setGridParam', {url:'ajax/json/json_fun_obtener_ajustes_por_factura.php?iFactura=' +iFactura+'&session_name='+ Session,}).trigger("reloadGrid");
	}	

	function ConsultaClaveHCM(){
        $.ajax({type: "POST", 
            url:'ajax/json/json_proc_consultaropcionesapagado_hcm.php',
            data: {                 
                'iOpcion': 386
            }
        })
        .done(function(data){
            var dataS = sanitize(data)
			var dataJson = JSON.parse(dataS);
            FlagHCM = dataJson.clvApagado;
            MensajeHCM = dataJson.mensaje;

            if(FlagHCM == 1){
                loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:MensajeHCM}});
            }
        }); 
        
        
    }
});

