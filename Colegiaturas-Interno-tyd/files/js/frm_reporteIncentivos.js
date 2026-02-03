 $(function(){
	SessionIs();
	var iEmpleado = 0
		, sNomEmpleado = '';
	
	setTimeout(function(){
		CargarGridIncentivos();
		CargarQuincenas();
		CargarEmpresas();
	}, 0);
	
	/** Eventos
	-------------------------------------------------- */
	$("#btn_Consultar").click(function(event){
		$("#gridIncentivos-table").jqGrid('clearGridData');
		if ($("#txt_Numemp".trim()).val() != '') {
			if ($("#txt_Numemp").val().length == 8) {
				iEmpleado = $("#txt_Numemp".trim()).val();
				sNomEmpleado = $("#txt_NomEmp".trim()).val().toUpperCase();
				ActualizarGrid();
			} else {
				showalert("Proporcione un numero de colaborador valido", "", "gritter-info");
				$("#txt_Numemp").focus();
			}
		} else {
			iEmpleado = 0;
			sNomEmpleado = '';
			
			ActualizarGrid();
		}
		event.preventDefault();
	});
	
	$("#txt_Numemp").on('input propertychange paste', function(event){
		if($("#txt_Numemp").val().length != 8)
		{			
			$("#txt_NomEmp").val('');
		}	
		else 
		{
			ConsultaEmpleado();
		}
	});
	
	$("#txt_Numemp").on('paste', function(event){
		var element = this;
		setTimeout(function(){
			var text = $(element).val();
			//if($(element).val().length == 8 && NumberisNumeric(text)){
				if($(element).val().length == 8 && (Number.isInteger(parseInt(text)))){ // se cambia funcion por vulnerabilidad
				$(element).val(text);
				ConsultaEmpleado();
			}else{
				$("#txt_NomEmp").val("");
				event.preventDefault();
			}
		}, 0);
	});
	
	$("#txt_Numemp").keypress(function(e){
		var keycode = e.which;
		if(keycode == 13 || keycode == 9){
			if($("#txt_Numemp").val().length != 8){
				showalert(LengStrMSG.idMSG133, "", "gritter-warning");				
				$("#txt_NomEmp").val("");
			}else{
				ConsultaEmpleado();
			}
		}else if (keycode==8){
			LimpiarDatos();
		}
	});
	
	$("#cbo_quincena").on("change", function(event){
		LimpiarDatos();
		event.preventDefault();
	});
	
	/** Métodos
	-------------------------------------------------- */
	//CONSULTA EMPLEADOS 
	function ConsultaEmpleado()
	{	
		// console.log('consulta empleado');
		iNumEmp=$("#txt_Numemp".trim()).val();
		
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
				var dataJson = JSON.parse(data);
				if(dataJson != null){
					if(dataJson.cancelado=='1'){
						showalert(LengStrMSG.idMSG135, "", "gritter-warning");							
					}else{
						$("#txt_NomEmp").val(dataJson.nom_empleado);
					}					
				}else{
					showalert("No existe el colaborador", "", "gritter-warning");
					$("#txt_NomEmp").val("");
				}
			});
		}else{
			showalert("Proporcione un numero de colaborador", "", "gritter-info");
			$("#txt_Numemp").focus();
		}
	}
	
	function LimpiarDatos(){
		$("#txt_NomEmp").val('');
		$("#gridIncentivos-table").jqGrid('clearGridData');
		ActualizarGrid(1);
	}
	
	function ActualizarGrid(inicializar) {
		sUrl = 'ajax/json/json_fun_reporte_incentivos.php?&session_name=' + Session + '&';
		sUrl += 'iEmpleado=' + iEmpleado + '&';
		sUrl += 'iEmpresa=' + $("#cbo_empresa").val() + '&';
		sUrl += 'dQuincena=' + $("#cbo_quincena").val() + '&';
		
		if (inicializar == 1) {
			sUrl = '';
		}
		
		$("#gridIncentivos-table").jqGrid('setGridParam', {
			url: sUrl,
		}).trigger("reloadGrid");
	}
	
	function CargarGridIncentivos(){
		$("#gridIncentivos-table").jqGrid("GridUnload");
		$("#gridIncentivos-table").jqGrid({
			url:'',
			datatype:'json',
			colNames:LengStr.idMSG108,
			colModel:[
				{name:'idu_empresa',	index:'idu_empresa',	width:10,	sortable:false,	align:"right",	fixed:true,	hidden:true},
				{name:'empresa', 		index:'empresa',		width:150,	sortable:false,	align:"left",	fixed:true},
				{name:'idu_empleado',	index:'idu_empleado',	width:10,	sortable:false,	align:"left",	fixed:true, hidden:true},
				{name:'colaborador',	index:'colaborador',	width:270,	sortable:false,	align:"left",	fixed:true},
				{name:'idu_centro',		index:'idu_centro',		width:10,	sortable:false,	align:"left",	fixed:true, hidden:true},
				{name:'centro',			index:'centro',			width:270,	sortable:false,	align:"left",	fixed:true},
				{name:'folfactura',		index:'folfactura',		width:250,	sortable:false,	align:"left",	fixed:true},
				{name:'importetotal',	index:'importetotal',	width:100,	sortable:false,	align:"right",	fixed:true},
				{name:'importepagado',	index:'importepagado',	width:100,	sortable:false,	align:"right",	fixed:true},
				{name:'importeisr',		index:'importeisr',		width:100,	sortable:false,	align:"right",	fixed:true},
				{name:'importeisrincen',index:'importeisrincen',width:100,	sortable:false,	align:"right",	fixed:true}
			],
			scrollrows:true,
			width:null,
			loadonce:false,
			shrinkToFit:false,
			viewrecords:true,
			height:'auto',
			rowNum:-1,
			//rowList:[10, 20, 30],
			pager:'#gridIncentivos-pager',
			align:'center',
			sortname:'idu_empresa, idu_empleado, tipo',
			sortorder:'asc',
			viewrecords:true,
			hidegrid:false,
			pgbuttons:false,
			pgtext:false,
			caption:'Reporte de Incentivos',
			loadComplete:function(data){
				var table=this;
				setTimeout(function(){
					updatePagerIcons(table);
				},0);
			},
		});
		
		barButtongrid({
			pagId:'#gridIncentivos-pager',
			position:'left',
			Buttons:[
			{
				icon:'icon-print',
				title:'Imprimir',
				click:function(event){
					if(($("#gridIncentivos-table").find("tr").length - 1) == 0){
						showalert(LengStrMSG.idMSG87, "", "gritter-info");
					}else{
						GenerarPdf();
					}
					event.preventDefault();
				}
			}]
		});
		setSizeBtnGrid("id_button0", 35);
	}
	
	function setSizeBtnGrid(id,tamanio) {
		$("#"+id).attr('width',tamanio+'px');
		$($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}
	//////////////////////////////////////////// Sanitizar Variables
	function limpiarCadena(cadena) {
		var listaElementos = [];
		var returnList = [];
		var entity = {};
		entity.properti = "";
		listaElementos.push(entity);
		listaElementos.forEach(function (item) {
		item.properti = cadena;
		returnList.push(item);
			});
		return returnList[0].properti;
	}
	function CargarEmpresas(){
		$.ajax({
			type:'POST',
			url:'ajax/json/json_fun_obtener_listado_empresas_colegiaturas_cc.php',
			data:{},
			beforeSend:function(){},
			
			success:function(data){
				var dataS = limpiarCadena(data);
				dataJson = json_decode(dataS);
				if(dataJson.estado == 0){
					var option = "<option value='0'>TODAS</option>";
					for(var i=0;i<dataJson.datos.length;i++){
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_empresa").html(option);
					//var Sel = $("#cbo_empresa option:first").val();
					$($("#cbo_empresa").children()[0]).prop('selected', 'selected'); // se cambia a esta forma para seleccionar la primera opcion del select
					//$("#cbo_empresa").val(Sel);
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	
	function CargarQuincenas() {
		$.ajax({
			type:'POST',
			url:'ajax/json/json_fun_obtener_quincenas_colegiaturas.php',
			data:{},
			beforeSend:function(){},
			success:function(data){
				var dataS = limpiarCadena(data);
				dataJson = json_decode(dataS);
				if(dataJson.estado == 0){
					var option = "";
					for(var i=0;i<dataJson.datos.length;i++){
						option = option + "<option value='" + dataJson.datos[i].fec_quincena + "'>" + dataJson.datos[i].fec_mostrar + "</option>";
					}
					$("#cbo_quincena").html(option);
					$($("#cbo_quincena").children()[0]).prop('selected', 'selected'); // se cambia a esta forma para seleccionar la primera opcion del select
					//var Sel = $("#cbo_quincena option:first").val();
					//$("#cbo_quincena").val(Sel);
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	
	function GenerarPdf(){
		// Paimi Arizmendi López
		// 28/08/2018
		// Código para mostrar un mensaje de espera mientras se descarga 
		// un archivo
		// ---------------------------------------------------------------
		
		// Parámetros del reporte
		// ---------------------------------------------------------------
		var sNombreReporte = 'rpt_incentivos_colegiaturas',
			iIdConexion = '190',
			sFormatoReporte = 'pdf';
		
		var params = "nombre_reporte=" + sNombreReporte + "&";
		params += "id_conexion=" + iIdConexion + "&";
		params += "dbms=postgres&";
		params += "formato_reporte=" + sFormatoReporte + "&";
		params += "quincena=" + $("#cbo_quincena").val() + "&";
		params += "empresa=" + $("#cbo_empresa").val() + "&";
		params += "colaborador=" + iEmpleado;
		
		var xhr = new XMLHttpRequest();
		var report_url = oParametrosColegiaturas.URL_SERVICIO_COLEGIATURAS + '/reportes';
		//var report_url = "http://dev-javappadmon.coppel.io:8080/WsColegiaturas/rest/reportes"
		//console.log (report_url);
		//	params = 'acceso/97270661/13/0';
		//console.log(report_url)
		
		//return;
		xhr.open("POST", report_url, true);
		xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		
		xhr.addEventListener("progress", (event) =>{ (evt) => {
			console.log(evt.total)
			if(evt.lengthComputable) {
				var percentComplete = evt.loaded / evt.total;
				console.log(percentComplete);
			}
		}, false
	});
		
		xhr.responseType = "blob";
		xhr.onreadystatechange = function() {
			waitwindow('', 'close');
	
			if(this.readyState == XMLHttpRequest.DONE && this.status == 200) {
				var filename = sNombreReporte + "." + sFormatoReporte;
				
				var link = document.createElement('a');
				link.href = window.URL.createObjectURL(xhr.response);
				link.download = filename;
				link.style.display = 'none';
				
				document.body.appendChild(link);
				
				link.click();
				
				document.body.removeChild(link);
			}
		}
		
		waitwindow('Obteniendo reporte, por favor espere...', 'open');
		
		xhr.send(params);

	}
});