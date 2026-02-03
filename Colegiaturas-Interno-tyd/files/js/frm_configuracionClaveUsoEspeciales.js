$(function(){
	Cargargrid();
	inhabilitarCampos()
	$("#txt_FechaIni").datepicker({
		// showOn: 'both',
		dateFormat: 'dd/mm/yy',
		buttonImageOnly: true,
		numberOfMonths: 1,
		minDate: "0D",
		readOnly: true,
		changeYear: true,
		changeMonth: true,
		monthNames: ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'],
		monthNamesShort: ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'],
		dayNames: ['Domingo','Lunes','Martes','Mi&eacute;rcoles','Jueves','Viernes','S&aacute;bado'],
		dayNamesShort: ['Dom','Lun','Mar','Mi&eacute;','Juv','Vie','S&aacute;b'],
		dayNamesMin: ['Do','Lu','Ma','Mi','Ju','Vi','S&aacute;'],
		 onSelect: function( selectedDate ) {
			$( "#txt_FechaFin" ).datepicker( "option", "minDate", selectedDate );
		}
	}).next().on(ace.click_event, function(selectedDate){
			$( this ).prev().focus();
		});
	$("#txt_FechaFin").datepicker({
		// showOn: 'both',
		dateFormat: 'dd/mm/yy',
		buttonImageOnly: true,
		numberOfMonths: 1,
		minDate: "0D",
		readOnly: true,
		changeYear: true,
		changeMonth: true,
		monthNames: ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'],
		monthNamesShort: ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'],
		dayNames: ['Domingo','Lunes','Martes','Mi&eacute;rcoles','Jueves','Viernes','S&aacute;bado'],
		dayNamesShort: ['Dom','Lun','Mar','Mi&eacute;','Juv','Vie','S&aacute;b'],
		dayNamesMin: ['Do','Lu','Ma','Mi','Ju','Vi','S&aacute;'],
		onSelect: function( selectedDate ) {
			$( "#txt_FechaIni" ).datepicker( "option", "maxDate", selectedDate );
		}
	}).next().on(ace.click_event, function(selectedDate){
			$( this ).prev().focus();
		});	
	$("#txt_FechaIni").prop('disabled',true);
	$("#txt_FechaFin").prop('disabled',true);
	$("#chkbx_indefinido").change(function(){
		if($('#chkbx_indefinido').is(":checked"))//si esta seleccionado
		{//Bloquea las fechas
			
			//$("#txt_FechaIni").prop('disabled',true);
			$("#txt_FechaFin").prop('disabled',true);
			LimpiarFechas();
			
		}else
		{
			//$("#txt_FechaIni").prop('disabled',false);
			$("#txt_FechaFin").prop('disabled',false);
		}
	});
	function LimpiarFechas()
	{
		$("#txt_FechaIni" ).datepicker("setDate",new Date());
		//$("#txt_FechaFin" ).datepicker("setDate",new Date());
		$("#txt_FechaFin" ).val($("#txt_FechaIni").val())
		
	}
});
function Cargargrid(){
	jQuery("#gd_Claves").GridUnload();

	jQuery("#gd_Claves").jqGrid({
		url: 'ajax/json/json_fun_obtener_claves_uso_especiales.php?',
		datatype: 'json',
		mtype: 'POST',
		colNames:LengStr.idMSG135,
		// ["Clave", "Descripción"],
		colModel:[
			{name:'num_Colaborador', 			index:'Num',		width:200, 	sortable: false,	align:"left",	fixed: true},
			{name:'num_Centro',					index:'num_Centro',		width:200, 	sortable: false,	align:"left",	fixed: true},
			{name:'puesto',						index:'puesto',		width:200,  sortable: false,	align:"left",	fixed: true},
			{name:'claveUso', 					index:'claveUso',	width:100, 	sortable: false,	align:"left",	fixed: true},
			{name:'opt_Indefinido',				index:'opt_Indefinido',width:50,	sortable: false,	align:"left",	fixed: true},
			{name:'opt_Bloqueado', 				index:'Fecopt_Bloqueado', 		width:50, 	sortable: false,	align:"left",	fixed: true},
			{name:'fecha_inicial', 				index:'fecha_inicial', 		width:100, 	sortable: false,	align:"left",	fixed: true},
			{name:'fecha_final', 				index:'fecha_final', 		width:100, 	sortable: false,	align:"left",	fixed: true},
			{name:'nom_colaboradorRegistro',	index:'nom_colaboradorRegistro', 		width:200, 	sortable: false,	align:"left",	fixed: true},
			{name:'fecha_registro', 			index:'fecha_registro', 		width:200, 	sortable: false,	align:"left",	fixed: true}
	
		],
		
		rowNum:-1,
		hidegrid: false,
		rowList:[],
		multiselect: false,
		width: 1550,
		shrinkToFit: true,
		height: 250,//null,//--> sepuede poner fijo si el alto no se quiere automatico  ,
		pager: '#gd_Claves_pager',
		viewrecords: false,
		//----------------------------------------------------------------------------------------------------------
		caption: 'Colaboradores',
		pgbuttons: false,
		pgtext: null,
		postData:{},
		loadComplete: function (data) {
			/*var tamGrid = $("#gd-grid").getGridParam('reccount');
			for(var i = 0; i <= tamGrid; i++ ){
				var ret = jQuery("#gd-grid").jqGrid('getRowData',i);
				if(ret.idestatus == 0){
					$("#"+i).css('background-color','#e2dede');
				}
			}*/
		},
		onSelectRow: function(id){
			if(id >= 0){
				var ret = jQuery("#gd_Claves").jqGrid('getRowData',id);
				sel_clv = ret.Clave;
			}else{
				sel_clv = "";
			}
		}	
	});
	// fixGrid({position:true,grid:'#gd_Claves', stretch: true,/* width: '%',*/ctrlbuttons:true, scroll:true});
	barButtongrid({
		pagId:'#gd_Claves_pager',
		position:'left',
		Buttons:[{
			icon:'icon-lock red',
			click:function (event){				
				var selr = jQuery('#gd_Claves').jqGrid('getGridParam','selrow');

				// if (($("#gd_Claves").find("tr").length - 1) != 0 )
				var rowData = jQuery("#gd_Claves").getRowData(selr);
				console.log(rowData.claveUso)
				if(rowData.claveUso != ""){	
					numEmpleado = (rowData.num_Colaborador).split(" - ");			
					$("#txt_clave").val(rowData.claveUso);

					if(rowData.opt_Bloqueado == 1){
						iBloqueado = 0;
						palabra = "desbloquear";
					}else{
						iBloqueado = 1;
						palabra = "bloquear";
					}
					
						bootbox.confirm("Desea "+palabra+" esta clave de uso?", 
						function(result)
						{
							if (result)
							{
								$.ajax({type: "POST", 
									url: "ajax/json/json_fun_bloquear_desbloquear_clave_uso_especial.php?",
									data: { 
											'sClave_Uso': rowData.claveUso,
											'iNumEmp': numEmpleado[0],
											'iBloqueado': iBloqueado,
											'session_name':Session
										}
								})
								.done(function(data){
									var dataJson = JSON.parse(data);
									if(dataJson != null)
									{	
										var dataJson = JSON.parse(data);
										if(dataJson.estado == 2){
											showalert('Registro modificado',"", "gritter-success");
											LimpiarControles();
											Cargargrid();
										} else {
											showalert(dataJson.mensaje, "","gritter-info");
											$("#txt_clave").focus();
										}		
									}
									else
									{
										showalert(LengStrMSG.idMSG136, "", "gritter-warning");
										LimpiarControles();
									}
								});	
							}	
						});
				}else{
					showalert("Seleccione el registro a editar", "", "gritter-info");
				}
				
			},
			title:'Bloquear',
		}]
		
	});
	setSizeBtnGrid('id_button0',35);
	//setSizeBtnGrid('id_button1',35);		
}
function setSizeBtnGrid(id,tamanio)
	{//setSizeBtnGrid('id_button0',35);
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}

$("#btn_guardar").click(function(){
	
	iNumEmp=$("#txt_iduempleado").val();	
	sFechaIni=formatearFecha($('#txt_FechaIni').val());
	sFechaFin=formatearFecha($('#txt_FechaFin').val());
	txt_clave= $('#txt_clave').val();
	iIndefinido = $("#chkbx_indefinido").is(":checked") ? 1 : 0;

	if(iNumEmp!=''){
		$.ajax({type: "POST", 
			url: "ajax/json/json_fun_guardar_clave_uso_especial.php?",
			data: { 
					'iNumEmp':iNumEmp,
					'sClave_Uso': txt_clave,
					'sFechaIni': sFechaIni,
					'sFechaFin': sFechaFin,
					'iIndefinido': iIndefinido,
					'session_name':Session
				}
		})
		.done(function(data){
			var dataJson = JSON.parse(data);
			if(dataJson != null)
			{	
				var dataJson = JSON.parse(data);
				if(dataJson.estado == -1){
					showalert("La clave ya existe, favor de verificar", "","gritter-info");
					$("#txt_clave").focus();
				}else {
					showalert('Clave registrada',"", "gritter-success");
					LimpiarControles();
					Cargargrid();
				}		
			}
			else
			{
				showalert(LengStrMSG.idMSG136, "", "gritter-warning");
				LimpiarControles();
			}
		});
	}
});

$("#btn_Otro").click(function(){
	$('#txt_iduempleado').val('');
	LimpiarControles();
	inhabilitarCampos();
	$("#txt_iduempleado").focus;
});

$('#txt_iduempleado').on('input', function(event) {
	var valor = $(this).val();
	
	// Verificar si la longitud del valor es menor o igual a 8
	if (valor.length <= 8) {
		
		$("#txt_nomempleado").val("");
		$("#txt_iducentro").val("");
		$("#txt_nomcentro").val("");
		$("#txt_idupuesto").val("");
		$("#txt_nompuesto").val("");
		$("#txt_clave").val("");
		inhabilitarCampos();
	}
});

$('#txt_clave').on('input', function(event){
	$(this).val($(this).val().toUpperCase().replace(/[^A-Z0-9]/g, '').substr(0, 5));
});



$('#txt_iduempleado').on('keypress paste', function(event){
	if ((event.type === 'keypress' && event.which === 13 ) || event.type === 'paste' || event.type === 'blur'){
		iNumEmp=$("#txt_iduempleado").val();
		$.ajax({type: "POST", 
			url: "ajax/json/json_fun_consulta_empleado_co.php?",
			data: { 
					'iNumEmp':iNumEmp,
					'session_name': Session
				}
		})
		.done(function(data){				
			var dataJson = JSON.parse(data);
			if(dataJson != null)
			{
				if(dataJson.cancelado=='1')
				{
					showalert(LengStrMSG.idMSG135, "", "gritter-warning");
					$("#txt_iduempleado").val("");
					$("#txt_nomempleado").val("");
					$("#txt_iducentro").val("");
					$("#txt_nomcentro").val("");
					$("#txt_idupuesto").val("");
					$("#txt_nompuesto").val("");
					$("#txt_iduempleado").focus();
					
					inhabilitarCampos();
				}
				else
				{
					habilitarCampos();
					$("#txt_nomempleado").val(dataJson.nom_empleado);
					$("#txt_iducentro").val(dataJson.idu_centro);
					$("#txt_nomcentro").val(dataJson.nom_centro);
					$("#txt_idupuesto").val(dataJson.idu_puesto);
					$("#txt_nompuesto").val(dataJson.nom_puesto);
						
					$("#txt_iduempleado2").prop("disabled", false);
					$("#txt_iduempleado2").focus();		
								
				}		
			}
			else
			{
				showalert(LengStrMSG.idMSG136, "", "gritter-warning");
				$("#txt_iduempleado").val("");
				$("#txt_nomempleado").val("");
				$("#txt_iducentro").val("");
				$("#txt_nomcentro").val("");
				$("#txt_idupuesto").val("");
				$("#txt_nompuesto").val("");
				$("#txt_iduempleado").focus();
				inhabilitarCampos();
			}
		});
	}
});

function LimpiarControles(){
	$("#txt_iduempleado").val("");
	$("#txt_nomempleado").val("");
	$("#txt_iducentro").val("");
	$("#txt_nomcentro").val("");
	$("#txt_idupuesto").val("");
	$("#txt_nompuesto").val("");
	$("#txt_clave").val("");
	$("#txt_iduempleado").focus();
}

function inhabilitarCampos(){
	$("#txt_clave").prop('disabled', true);
	$("#trt_fechafin").prop('disabled', true);
	$("#chkbx_indefinido").prop('disabled', true);
	$("#chkbx_indefinido").prop('checked', true);
	$("#btn_guardar").prop('disabled', true);
	$("#btn_Otro").prop('disabled', true);
	$("#txt_FechaFin").prop('disabled',true);
	
}
function habilitarCampos(){
	$("#txt_clave").prop('disabled', false);
	$("#trt_fechafin").prop('disabled', false);
	$("#chkbx_indefinido").prop('disabled', false);
	$("#chkbx_indefinido").prop('checked', true);
	$("#btn_guardar").prop('disabled', false);
	$("#btn_Otro").prop('disabled', false);
	//$("#txt_FechaFin").prop('disabled',false);
}


function setSizeBtnGrid(id,tamanio)
{//setSizeBtnGrid('id_button0',35);
  $("#"+id).attr('width',tamanio+'px');
  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
}
