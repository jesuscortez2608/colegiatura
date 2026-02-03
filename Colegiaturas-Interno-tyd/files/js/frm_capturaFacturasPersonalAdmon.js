$(function (){
	ConsultaClaveHCM()
	$.fn.modal.Constructor.prototype.enforceFocus = function () {};
	ObtenerEscuelasLinea();
	CargarTiposPagos();
	CargarCiclosEscolares();
	iEscolaridadB=0;
	sPeriodos=''; 
	var iOpcion = 0
		, iFactura = 0
		, iMod = 0;
	$("#cbo_Parentesco").prop('disabled',true);
	
	var Sueldo = 0;
	var Nom_Archivo = '';
	
	//PRUEBA

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
	
	
//--VALORES INICIALES
	$("#cbo_Escolaridad").prop('disabled',true);
	$("#cbo_Periodo").prop('disabled',true);
	$("#cbo_Grado").prop('disabled',true);
	$("#cbo_escuelaLinea").prop('disabled', true);
	$("#cbo_Escolaridad").prop('disabled', true);
	
//--PDF
	$('#filePdf').ace_file_input({
		no_file:'PDF...',
		btn_choose:'Examinar',
		btn_change:'Cambiar',
		droppable:false,
		onchange:null,
		thumbnail:false 
	});	
	
	$("#filePdf").change(function(event){
		var sExt = ($('#filePdf').val().substring($('#filePdf').val().lastIndexOf("."))).toLowerCase();
		//console.log(sExt);
		if((sExt != '.pdf') && (sExt != '.jpg') && (sExt != '.png') &&  (sExt != '.jpeg') /*&&  (sExt != '.bmp')*/)
		{
			$( '#filePdf' ).ace_file_input('reset_input');
			$( '#filePdf' ).focus();
			// showalert(LengStrMSG.idMSG389, "", "gritter-info");
			showalert("El archivo seleccionado no es válido, favor de seleccionar un pdf ó imagen", "", "gritter-info");
			return;
		}
		event.preventDefault();
	});
	
//--COLABORADOR
	//
	$("#txt_NumEmp").on('input propertychange', function(){		
		if($("#txt_NumEmp").val().length != 8 || (Number.isInteger(parseInt($("#txt_NumEmp").val()))) == false){
			LimpiarDatos();
		}	
		else if($("#txt_NumEmp").val().length == 8 && Number.isInteger(parseInt($("#txt_NumEmp").val())) ){
			fnObtenerDatosEmpleado();
			// ConsultaEmpleado(
				// function(){
					// if($("#txt_NomEmp").val().trim() != ''){
						// fnObtenerDatosEmpleado();
					// }
			// });
		}
	});
	
	//EVITAR COPIAR PEGAR
	$('#txt_NumEmp').on("cut copy paste",function(e) {
      e.preventDefault();
   });
	
	//
	$("#txt_NumEmp").keypress(function(e){
		var keycode = e.which;
		// console.log(keycode);
		if(keycode == 13 || keycode == 9 /*|| keycode == 0*/){
			if($("#txt_NumEmp").val().length != 8){
				showalert(LengStrMSG.idMSG133, "", "gritter-warning");				
				$("#txt_NomEmp").val("");
				LimpiarDatos();
			}
			else{
				fnObtenerDatosEmpleado();
			// ConsultaEmpleado(
				// function(){
					// if($("#txt_NomEmp").val().trim() != ''){
						// fnObtenerDatosEmpleado();
					// }
				// });
			}
		}else if (keycode==0 || keycode==8){
			LimpiarDatos();
		}
	});

$("#cbo_Periodo").chosen({width:'250px', height:'70px', resize:'none'});
$("ul.chosen-choices").css({'overflow': 'auto', 'max-height': '70px'});

//--CONSULTA EMPLEADOS
	function ConsultaEmpleado(){
		var numEmp = $("#txt_NumEmp").val().makeTrim(" ");
		
		$.ajax({
			type:"POST",
			url:"ajax/json/json_proc_obtener_datos_colaborador_colegiaturas.php?",
			data:{
				'iEmpleado' : numEmp,
				'session_name' : Session
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				if(dataJson != null){
					if(dataJson != 0){
						if(dataJson[0].cancelado == 1){
							showalert(LengStrMSG.idMSG212, "", "gritter-info");
							LimpiarDatos();
							$("#txt_NumEmp").val('');
							$("#txt_NumEmp").focus();
							
						}else{
							$("#txt_NomEmp").val(dataJson[0].nombre+' '+dataJson[0].appat+' '+dataJson[0].apmat);
							$("#txt_Centro").val(dataJson[0].centro);
							$("#txt_NombreCentro").val(dataJson[0].nombrecentro);
							$("#txt_fechaIngreso").val(dataJson[0].fec_alta);
							Sueldo = accounting.unformat(dataJson[0].sueldo);
							$("#txt_SueldoMensual").val(dataJson[0].sueldo);
							$("#txt_TopeAnual").val(dataJson[0].topeproporcion);
							$("#txt_RutaPago").val(dataJson[0].nombrerutapago);
							$("#txt_Empresa").val(dataJson[0].empresa);
							CalcularTopes();
						}
					}else{
						showalert(LengStrMSG.idMSG213, "", "gritter-info");
						LimpiarDatos();
						$("#txt_NumEmp").focus();
					}
				}else{
					showalert(LengStrMSG.idMSG214, "", "gritter-info");
					LimpiarDatos();
					$("#txt_NumEmp").focus();
				}
			},
			error:function onError(){callback();},
			complete: function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}
		});
	}
	function CalcularTopes(){
		var iEmpleado = 0;
		iEmpleado = $("#txt_NumEmp").val();
		$.ajax({
			type:"POST",
			url: "ajax/json/json_fun_calcular_topes_colegiaturas.php?",
			data:{
				'iSueldo' : Sueldo,
				'iEmpleado' : iEmpleado,
				'session_name' : Session
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				if (dataJson != 0){
					var ImporteFormato = accounting.formatMoney((Sueldo/2), "", 2);
					$("#txt_TopeMensual").val(ImporteFormato);
					ImporteFormato = accounting.formatMoney(dataJson.acumulado, "", 2);
					$("#txt_AcumFactPagadas").val(ImporteFormato);
					// ImporteFormato = accounting.unformat($("#txt_TopePropRestante").val()) - accounting.unformat($("#txt_AcumFactPagadas").val());
					// ImporteFormato = accounting.formatMoney(dataJson.restante, "", 2);
					ImporteFormato=accounting.unformat($("#txt_TopeAnual").val())-accounting.unformat($("#txt_AcumFactPagadas").val());
					ImporteFormato=accounting.formatMoney(ImporteFormato, "", 2);
					// $("#txt_TopeRest").val(ImporteFormato);
					$("#txt_TopePropRestante").val(ImporteFormato);
				}
			},
			error: function onError(){},
			complete: function(){},
			timeout: function(){},
			abort: function(){}
		});
	}	
	function fnObtenerDatosEmpleado(callback){
		var numEmp = $("#txt_NumEmp").val().makeTrim(" ");
		
		$.ajax({
			type:"POST",
			url: "ajax/json/json_fun_consulta_empleado_colegiatura.php?",
			data:{
				'iEmpleado' : numEmp,
				'session_name' : Session
			}
		})
		.done(function(data){
			var dataJson = JSON.parse(data);
			if(dataJson != null){
				if(dataJson.ESPECIAL != 1){
					showalert("El colaborador no tiene permiso", "", "gritter-info");
					LimpiarDatos();
				}else if(dataJson.BLOQUEADO != 0){
					showalert("El colaborador esta bloqueado", "", "gritter-info");
					LimpiarDatos();
				}else{
					ConsultaEmpleado();
					$("#cbo_Beneficiario").html("");
					// ObtenerBeneficiariosHojaAzul(function(){
						ActualizarBeneficiariosHojaAzul(function(){
							CargarBeneficiariosCapturados(function(){				
								$("#cbo_Beneficiario").html(Beneficiarios);
								$("#cbo_Beneficiario" ).val($("#cbo_Beneficiario").first().val());			
							});							
						});
					// });	
				}				
			}else{
				showalert("El colaborador no cuenta con la prestación de colegiaturas", "", "gritter-info");
				LimpiarDatos();
			}
			// callback();
		})
	}
	function ActualizarBeneficiariosHojaAzul(callback) {
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_contactos_hoja_azul.php",
			data: { 
				'iColaborador':$("#txt_NumEmp").val().makeTrim(" "),
				'iOpcion' : 1,
				'session_name': Session				
			},
			beforeSend:function(){},
			success:function(data){			
				var dataJson = JSON.parse(data);
				//console.log('estado='+dataJson.estado);					
			},
			error:function onError(){callback();},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}
		});	
	}
//--IMPORTE	
	$("#txt_Importe").focusin(function(event){
		if (  $( this ).val().makeTrim(" ") != "" ) {
			if($( this ).val().makeTrim(" ") ==0)
			{
				$( this ).val( "");
			}
			else{
				$( this ).val( accounting.unformat( $( this ).val()) );
			}	
		}
		event.preventDefault()
	});
	
	$( '#txt_Importe' ).focusout(function(event){
		$( this ).val( accounting.formatMoney( $( this ).val() , "", 2) );
		event.preventDefault();
	});

	$('#txt_Importe').keypress(function(event){
		const charCode = event.which ? event.which : event.keyCode;
		const inputVal = $(this).val();

		// Permitir números (0-9)
		if (charCode >= 48 && charCode <= 57) {
			return true;
		}

		// Permitir un solo punto decimal
		if (charCode === 46) {
			if (inputVal.indexOf('.') === -1) {
				return true;
			} else {
				return false;
			}
		}

		// Bloquear cualquier otra entrada
		return false;
	});

//FECHA
	$("#txt_Fecha").datepicker({
		// showOn: 'both',
		dateFormat: 'dd/mm/yy',
		buttonImageOnly: true,
		numberOfMonths: 1,
		maxDate: "0D",
		readOnly: true,
		changeYear: true,
		changeMonth: true,
		monthNames: ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'],
		monthNamesShort: ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'],
		dayNames: ['Domingo','Lunes','Martes','Mi&eacute;rcoles','Jueves','Viernes','S&aacute;bado'],
		dayNamesShort: ['Dom','Lun','Mar','Mi&eacute;','Juv','Vie','S&aacute;b'],
		dayNamesMin: ['Do','Lu','Ma','Mi','Ju','Vi','S&aacute;'],
		 onSelect: function( selectedDate ) {
			// $( "#txt_FechaFin" ).datepicker( "option", "minDate", selectedDate );
		}
	}).next().on(ace.click_event, function(selectedDate){
			$( this ).prev().focus();
	});
	$("#txt_Fecha" ).datepicker("setDate",new Date());
	
//--BENEFICIARIOS
	//$("#cbo_Beneficiario").trigger("chosen:updated");		
	var Beneficiarios="<option parentesco='0' value='0'>SELECCIONE</option>";
	$("#cbo_Beneficiario").html(Beneficiarios);
	$("#cbo_Beneficiario" ).val($("#cbo_Beneficiario").first().val());	
	
		
	//BENEFICIARIOS HOJA AZUL Y CAPTURADOS  
	function CargarBeneficiariosCapturados(callbackB)
	{	
		Beneficiarios="";
		Beneficiarios="<option parentesco='0' value='0'>SELECCIONE</option>";
		$("#cbo_Beneficiario").html(Beneficiarios);
		
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_beneficiarios_colegiaturas_combo.php",
			data: { 
				//'iEmpleado':$("#txt_NumEmp").val(),
				'iEmpleado':DOMPurify.sanitize($("#txt_NumEmp").val()),
				//session_name:Session
			},
			beforeSend:function(){},
			success:function(data){
				var dataS = sanitize(data);			
				var dataJson = JSON.parse(dataS);	
				if(dataJson.estado == 0)
				{					
					for(var i=0;i<dataJson.datos.length; i++)
					{
						//Beneficiarios = Beneficiarios + "<option parentesco='"+ dataJson.datos[i].parentesco +"' value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>"; 
						Beneficiarios+="<option parentesco='"+ dataJson.datos[i].parentesco+"' value='" + dataJson.datos[i].value + "'  tipo_beneficiario='" + dataJson.datos[i].tipo_beneficiario + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_Beneficiario").html(Beneficiarios);
					$("#cbo_Beneficiario" ).val($("#cbo_Beneficiario").first().val());					
					$("#cbo_Beneficiario").trigger("chosen:updated");					
				}				
			},
			error:function onError(){callbackB();},
			complete:function(){callbackB();},
			timeout: function(){callbackB();},
			abort: function(){callbackB();}
		});	
	}
	
	//CHANGE
	$("#cbo_Beneficiario").change(function(){		
		// console.log($("#cbo_Beneficiario").children(":selected").attr("parentesco"));
		//$("#cbo_Beneficiario").children(":selected").attr("parentesco")
		CargarParentescos();
		// fnGuardarFacturaInicial();
	});
	
	
//--PARENTESCO
	function CargarParentescos(callback)
	{
		$("#cbo_Parentesco").html("");
		$.ajax({type: "POST", 
			url: "ajax/json/json_fun_obtener_parentescos.php?",			
			data: { 
				'iTipo':0			
			},
			beforeSend:function(){},
			success:function(data){
				var dataS = sanitize(data);
				var dataJson = JSON.parse(dataS);	
				if(dataJson.estado == 0)
				{
					var option = "";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					var nParentesco=$("#cbo_Beneficiario").children(":selected").attr("parentesco");
					$("#cbo_Parentesco").html(option);
					//$("#cbo_Parentesco").val($("#cbo_Parentesco option:first").val());
					$("#cbo_Parentesco").val(nParentesco);
					$("#cbo_Parentesco").trigger("chosen:updated");
				}
				else
				{
					//showmessage(dataJson.mensaje, '', undefined, undefined, function onclose(){callback();});
					showalert(LengStrMSG.idMSG88+" los parentescos", "", "gritter-error");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});	
	}
//--TIPOS PERIODOS PAGO
	//
	function CargarTiposPagos(){
		$("#cbo_TipoPago").html("");
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_tipos_pagos.php",
			data: {},
			beforeSend:function(){},
			success:function(data){
				var dataS = sanitize(data);
				var dataJson = JSON.parse(dataS);
				if(dataJson.estado == 0)
				{
					var option = "<option value='0'>SELECCIONE</option>";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_TipoPago").html(option);
					$("#cbo_TipoPago").trigger("chosen:updated");
				}
				else if(dataJson.estado == 0)
				{					
					$("#cbo_TipoPago").addClass("chosen-select").chosen({no_results_text: "Sin resultado!"});
					
					$("#cbo_TipoPago").trigger("chosen:updated");
				}
				else
				{					
					showalert(LengStrMSG.idMSG88+" los tipos de pagos", "", "gritter-error");
				}
			},
			error:function onError(){				
				showalert(LengStrMSG.idMSG88+" los tipos de pagos", "", "gritter-error");
				$('#cbo_TipoPago').fadeOut();
			},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	
	//
	$("#cbo_TipoPago").change(function(){		
		if ($("#cbo_TipoPago").val()>0) {
			$("#cbo_Periodo").prop('disabled',false);
			$("#cbo_escuelaLinea").prop('disabled', false);
			$("#cbo_Escolaridad").prop('disabled', false);
		}else{
			$("#cbo_Periodo").prop('disabled',true);
		}
		CargarPeriodos();
	});
	
//PERIODOS
	function CargarPeriodos()
	{
		var option="";
		if($("#cbo_TipoPago").val()==0)
		{
			$("#cbo_Periodo").html("");
			$("#cbo_Periodo").trigger("chosen:updated");
		}
		else
		{
			$.ajax({type: "POST",
				url: "ajax/json/json_fun_obtener_periodos_pagos.php",
				data: { 
					//'iTipoPago':$("#cbo_TipoPago").val()
					'iTipoPago':DOMPurify.sanitize($("#cbo_TipoPago").val())
				},
				beforeSend:function(){},
				success:function(data){
					var dataS = sanitize(data);
					var dataJson = JSON.parse(dataS);
					if(dataJson.estado == 0)
					{
						// var option = "<option value='0'>SELECCIONE</option>";
						var option = "";
						for(var i=0;i<dataJson.datos.length; i++)
						{
							option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
						}
						$("#cbo_Periodo").trigger("chosen:updated").html(option);
						$("#cbo_Periodo").trigger("chosen:updated");
						if(sPeriodos!="")//Carga el perido
						{
							aPeriodos = sPeriodos.split(",");
							$('#cbo_Periodo').val(aPeriodos).trigger("chosen:updated");
							$("#cbo_Periodo").trigger("chosen:updated");
						}
					}
					else
					{
						//message(dataJson.mensaje);
						showalert(LengStrMSG.idMSG88+" los periodos de pago", "", "gritter-error");
						//$("#cbo_Periodo").addClass("chosen-select").chosen({no_results_text: "Sin resultado!"});
						$("#cbo_Periodo").trigger("chosen:updated").html(option);
						$("#cbo_Periodo").trigger("chosen:updated");
					}					
					//Si la opcion es de inscripción se debe de seleccionar automaticamente la inscripción.
					if($("#cbo_TipoPago").val().toString().makeTrim(" ") == "1")
					{
						$("#cbo_Periodo").val("1");
						$("#cbo_Periodo").trigger("chosen:updated");
					}
					if($("#cbo_TipoPago").val().toString().makeTrim(" ") == "8") {
						$("#cbo_Periodo").val("1");
						$("#cbo_Periodo").trigger("chosen:updated");
					}
					
				},
				error:function onError(){
					//message("Error al cargar " + url );
					showalert(LengStrMSG.idMSG88+" los periodos de pago" , "", "gritter-error");
					$('#cbo_Periodo').fadeOut();
				},
				complete:function(){},
				timeout: function(){},
				abort: function(){}
			});
		}	
	}
	
//--ESCUELAS	
	function ObtenerEscuelasLinea(){		
		var Escuela="";
		$("#cbo_escuelaLinea").html("");
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_escuelas_linea.php",
			data: { 				
			},
			beforeSend:function(){},
			success:function(data){
				var dataS = sanitize(data);
				var dataJson = JSON.parse(dataS);	
				var bloqueda=0;
				
				if(dataJson.estado == 0){
				
					Escuela="<option value='0' rfc=''>SELECCIONE</option>"
					
					for(var i=0;i<dataJson.datos.length; i++)
					{					
						Escuela = Escuela + "<option value='" + dataJson.datos[i].value + "'  rfc='" + dataJson.datos[i].rfc + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					$("#cbo_escuelaLinea").trigger("chosen:updated").html(Escuela);
					$("#cbo_escuelaLinea").trigger("chosen:updated");					
				}				
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});	
	}
	
	//CHANGE ESCUELA LINEA
	$("#cbo_escuelaLinea").change(function(){
		$("#txt_RFC").val("");
		$('#txt_RFC').val($("#cbo_escuelaLinea").children(":selected").attr("rfc"));		
		if ($("#cbo_escuelaLinea").val()>0) {
			CargarEscolaridades();
			$("#cbo_Escolaridad").prop('disabled',false);
			// fnGuardarFacturaInicial()
			// fnGuardarFactura();
		}else{		
			$("#cbo_Escolaridad").val(0);
			$("#cbo_Escolaridad").prop('disabled',true);
			$("#cbo_Escolaridad").trigger("chosen:updated");
			
			$("#cbo_Grado").val(0);			
			$("#cbo_Grado").prop('disabled',true);
			$("#cbo_Grado").trigger("chosen:updated");
		}
	});
	
	
//--ESCOLARIDAD	
	function CargarEscolaridades(){
		//$("#cbo_Escolaridad").html("");
		var option="";
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_consultar_escuela_rfc.php?",
			data: { 
				session_name:Session,
				'nOpcion':3,
				//'cRFCescuela':$('#txt_RFC').val(),
				//'cNomEscuela':$("#cbo_escuelaLinea option:selected").text() //$('#txt_NombreEscuela').val()
				'cRFCescuela':DOMPurify.sanitize($('#txt_RFC').val()),
				'cNomEscuela':DOMPurify.sanitize($("#cbo_escuelaLinea option:selected").text()) //$('#txt_NombreEscuela').val()
			},
			beforeSend:function(){},
			success:function(data){
				var dataS = sanitize(data);
				var dataJson = JSON.parse(dataS);
				if(dataJson.estado > 0) {
					var option = "<option value='0'>SELECCIONE</option>";
					for(var i=0;i<dataJson.datos.length; i++) {
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_Escolaridad").html(option);
					$("#cbo_Escolaridad").trigger("chosen:updated");
				} else if(dataJson.estado == 0) {					
					//$("#cbo_Escolaridad").addClass("chosen-select").chosen({no_results_text: "Sin resultado!"});
					//$("#cbo_Escolaridad").trigger("chosen:updated");
					$("#cbo_Escolaridad").trigger("chosen:updated").html(option);
					$("#cbo_Escolaridad").trigger("chosen:updated");
				} else {
					//message(dataJson.mensaje);
					showalert(LengStrMSG.idMSG88+" las escolaridades", "", "gritter-error");
				}
			},
			error:function onError(){ 
				// message("Error al cargar " + url );
				showalert(LengStrMSG.idMSG88+" las escolaridades", "", "gritter-error");
				$('#cbo_Escolaridad').fadeOut();
			},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	
	//	
	$("#cbo_Escolaridad").change(function(){
		//console.log('change');
		CargarGrados();
	});
	
//--GRADO ESCOLAR
	function CargarGrados()
	{
		if($("#cbo_Escolaridad").val() != 0)
		{
			$("#cbo_Escolaridad").val();
			$("#cbo_Grado").html("");
			$.ajax({
				type: "POST", 
				url: "ajax/json/json_fun_obtener_grados_escolares.php?",
				data: {
					//'iEscolaridad':$("#cbo_Escolaridad").val()
					'iEscolaridad':DOMPurify.sanitize($("#cbo_Escolaridad").val())
				},
				beforeSend:function(){},
				success:function(data){
					var dataS = sanitize(data);
					var dataJson = JSON.parse(dataS);
					if(dataJson.estado == 0)
					{
						var option = "";
						option = option + "<option value='-1'>" +"SELECCIONE" + "</option>";
						for(var i=0;i<dataJson.datos.length; i++)
						{
							option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>"; 
						}
						$("#cbo_Grado").html(option);
						$( "#cbo_Grado" ).val($("#cbo_Grado").first().val());
						if($("#cbo_Escolaridad").val()== 1)//Maternidad
						{
							$( "#cbo_Grado" ).val(0);
							$( "#cbo_Grado" ).prop('disabled',true);
						}
						else
						{
							$( "#cbo_Grado" ).prop('disabled',false);
						}
						if(iEscolaridadB!=0)
						{
							$( "#cbo_Grado" ).val(iGradoB);
						}
					}
					else
					{
						// showmessage(dataJson.mensaje, '', undefined, undefined, function onclose(){});
						showalert(dataJson.mensaje, "", "gritter-warning");
					}
				},
				error:function onError(){},
				complete:function(){},
				timeout: function(){},
				abort: function(){}
			});
		}	
		else
		{
			var option = "";
			option = option + "<option value='-1'>" +"SELECCIONE" + "</option>"; 	
			$("#cbo_Grado").html(option);
			$( "#cbo_Grado" ).val($("#cbo_Grado").first().val());
		}
	}
	
//--CICLO ESCOLAR	
	function CargarCiclosEscolares(){
		$("#cbo_CicloEscolar").html("");
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_ciclos_escolares.php",
			data: {},
			beforeSend:function(){},
			success:function(data){
				var dataS = sanitize(data);
				var dataJson = JSON.parse(dataS);
				if(dataJson.estado == 0)
				{
					var option = "<option value='0'>SELECCIONE</option>";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_CicloEscolar").html(option);
					$("#cbo_CicloEscolar").trigger("chosen:updated");
				}
				else if(dataJson.estado == 0)
				{
					//message(LengStr.idMSG11);
					// showalert(LengStr.idMSG11, "", "gritter-warning");
					$("#cbo_CicloEscolar").addClass("chosen-select").chosen({no_results_text: "Sin resultado!"});
					$("#cbo_CicloEscolar").trigger("chosen:updated");
				}
				else
				{
					//message(dataJson.mensaje);
					showalert(LengStrMSG.idMSG88+" los ciclos escolares", "", "gritter-error");
				}
			},
			error:function onError(){
				//message("Error al cargar " + url);
				showalert(LengStrMSG.idMSG88+" los ciclos escoles" , "", "gritter-error");
				$('#cbo_CicloEscolar').fadeOut();
			},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
//--BOTON GUARDAR	
	$('#btn_guardar').click(function(event){
		// if($("#txt_NomEmp").val().trim() == ''){
			// showalert("Favor de ingresar número de colaborador", "", "gritter-info");
			// $("#txt_NumEmp").focus();
			// return;
		// } else if($("#txt_NomEmp").val().trim() == '' && $("#txt_NumEmp").val() < 8){
			// showalert("Favor de ingresar un número de colaborador valido", "", "gritter-info");
			// $("#txt_NumEmp").focus();
			// return;
		// }
		// LimpiarDatos();
		$("#txt_Rfc_fac").val($("#txt_RFC").val());
		
		// var fecha = $("#txt_Fecha").val().split('/');
		// fecha= fecha[2]+fecha[1]+fecha[0];
		var fecha = formatearFecha($("#txt_Fecha").val());
		
		$("#txt_FechaFactura").val(fecha);
		
		//-------------------------------------------------------------------------
		str=$("#txt_NumEmp").val();		
		lon=str.length;
		if (lon==0) {
			showalert("Favor de ingresar número de colaborador", "", "gritter-info");
			$("#txt_NumEmp").focus();
			return;
		}else if (lon<8) {
			showalert("Favor de ingresar un número de colaborador valido", "", "gritter-info");
			LimpiarDatos();
			$("#txt_NumEmp").focus();
			return;
		}else if($("#filePdf").val()==""){
			//message("Favor de seleccionar un pdf");
			showalert("Favor de seleccionar un archivo PDF/imagen", "", "gritter-info");
			$("#filePdf").focus();
			return;	
		}else if ($("#txt_FolioFactura").val()=='') {
			showalert("Favor de agregar folio de la factura", "", "gritter-info");
			$("#txt_FolioFactura").focus();
			return;
		}else if ($("#txt_Importe").val()=='' || $("#txt_Importe").val() == 0) {
			showalert("Favor de agregar importe factura", "", "gritter-info");
			$("#txt_Importe").focus();
			return;		
		}else if($("#cbo_Beneficiario").val() == 0){
			showalert("Seleccione un beneficiario", "", "gritter-info");
			$("#cbo_Beneficiario").focus();
			return;
		}else if($("#cbo_TipoPago").val() == 0){
			showalert("Seleccione un tipo de pago", "", "gritter-info");
			$("#cbo_TipoPago").focus();
			return;
		}else if($("#cbo_Periodo").val() == 0){
			showalert("Seleccione el periodo", "", "gritter-info");
			$("#cbo_Periodo").focus();
			return;
		}else if($("#cbo_escuelaLinea").val() == 0){
			showalert("Seleccione la escuela", "", "gritter-info");
			$("#cbo_escuelaLinea").focus();
			return;
		}else if($("#cbo_Escolaridad").val() == 0){
			showalert("Seleccione la escolaridad", "", "gritter-info");
			$("#cbo_Escolaridad").focus();
			return;
		}else if($("#cbo_Grado").val() == -1){
			showalert("Seleccione un grado", "", "gritter-info");
			$("#cbo_Grado").focus();
			return;
		}else if($("#cbo_CicloEscolar").val() == 0){
			showalert("Seleccione un ciclo escolar", "", "gritter-info");
			$("#cbo_CicloEscolar").focus();
			return;
		}
		else{
			$("#btn_guardar").prop('disabled', true);
			bootbox.confirm('¿Está seguro que la información de la factura es correcta?', 
			function(result){
				$("#btn_guardar").prop('disabled', false);
				//abrir dialogo de aclaracion
				if (result){
					// GuardarFacturas();
					// fnsubirPdf();
					ValidarFactura();
				}
				 
			});
		}
		event.preventDefault();
		
	});	
	
	
	//
	function ValidarFactura(){
		$.ajax({type:'POST',
			url:'ajax/json/json_fun_existe_folio_fiscal_colegiaturas.php',
			data:{
				'sFolioFiscal' : $("#txt_FolioFactura").val().toUpperCase(),
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				if(dataJson.estado == 0){
					fnGuardarFacturaInicial();
					// GuardarFacturasSTMP();
					// fnsubirPdf()
				}else{
					showalert(dataJson.mensaje+" Estatus: <b>"+dataJson.estatus+"</b>", "", "gritter-warning");
					LimpiarFactura()
					return;
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	function GuardarFacturasSTMP(){
		var periodos = "";
		for (var i = 0; i < $("#cbo_Periodo").val().length; i++){
			periodos += (i != 0)?',':'';
			periodos += $("#cbo_Periodo").val()[i];
		}
		iFactura = $("#txt_ifactura").val();
		if (iFactura == ''){
			iFactura = 0;
		}
		$.ajax({
			type:'POST',
			url:'ajax/json/json_fun_grabar_stmp_detalle_facturas_colegiaturas.php',
			data:{
				session_name: Session,
				'cFolioFiscal': $("#txt_FolioFactura").val().toUpperCase().makeTrim(" "),
				'iBeneficiario' : $("#cbo_Beneficiario").val(),
				'iParentesco' : $("#cbo_Parentesco").val(),
				'iTipoPago' : $("#cbo_TipoPago").val(),
				'cPeriodo' : periodos,
				'iEscuela' : $("#cbo_escuelaLinea").val(),
				// 'iEscolaridad' : $("#cbo_Escolaridad").children(":selected").attr("escolaridad"),
				'iEscolaridad' : $("#cbo_Escolaridad").val(),
				'iGrado' : $("#cbo_Grado").val(),
				'iCiclo' : $("#cbo_CicloEscolar").val(),
				'iImporte' : accounting.unformat($("#txt_Importe").val()),
				'iFactura' : iFactura,
				'iFacturasEspeciales' : 1,
				'iUsuario' : $("#txt_NumEmp").val().makeTrim(" ")
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				for(var i in dataJson){
					//console.log(dataJson[i].resultado);
				}
				
				fnsubirPdf();
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	function GuardarFacturas(){
		// fnsubirPdf();
		/*
		$.ajax({type: "POST",
		url: "ajax/json/json_fun_grabar_facturas_especiales.php",
			data: 
			{ 
				session_name:Session,
				'iempresa': 1,
				'sfoliofiscal':$("#txt_FolioFactura").val().toUpperCase(),
				'iidu_empleado': $("#txt_NumEmp").val(),				
				'dfec_factura': formatearFecha($("#txt_Fecha").val()),
				'iidu_centro': $("#txt_Centro").val(),
				'iidu_escuela': $("#cbo_escuelaLinea").val(),
				'srfc_clave': $("#txt_RFC").val().toUpperCase(),
				'iimporte_factura': accounting.unformat($("#txt_Importe").val()),
				'iidu_tipo_documento': 4,				
				// 'snom_pdf_carta': $("#filePdf").val(),				
				'snom_pdf_carta': Nom_Archivo,				
				'iidu_beneficiario': $("#cbo_Beneficiario").val(),
				'ibeneficiario_hoja_azul': 0, 
				'iidu_parentesco': $("#cbo_Parentesco").val(),
				'iidu_tipopago': $("#cbo_TipoPago").val(),
				'speriodo': $("#cbo_Periodo").val(), 
				'iidu_escolaridad': $("#cbo_Escolaridad").val(), 
				'iidu_grado_escolar': $("#cbo_Grado").val(), 
				'idu_ciclo_escolar': $("#cbo_CicloEscolar").val()				
			},
			beforeSend:function(){
				//fnsubirPdf();
			},
			success:function(data){		
				var dataJson = JSON.parse(data);	
				if(dataJson.estado == 0){					
					showalert(dataJson.mensaje, "", "gritter-info");
					LimpiarFactura();
				}else{				
					showalert("Ocurrio un problema al grabar la factura <b>"+dataJson.mensaje+"</b>", "", "gritter-error");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}		
		});	*/	
	}

	//SUBIR PDF
	function fnsubirPdf(){
		$("#txt_idu_empleado").val($("#txt_NumEmp").val());
		$("#txt_idu_Centro").val($("#txt_Centro").val());
		var sExt = ($('#filePdf').val().substring($('#filePdf').val().lastIndexOf("."))).toLowerCase();
		$("#txt_filePdf").val(sExt)
		//console.log('sExt='+sExt);
		if(sExt != '.pdf' && sExt != '.jpg' && sExt != '.jpeg' && sExt != '.pjpeg' && sExt != '.gif' && sExt != '.png' && sExt != '.x-png')
		{			
			$('#filePdf').ace_file_input('reset_input');				
			showalert("El archivo seleccionado no es un PDF", "", "gritter-info");
		} else {
			var opciones = {
				//console.log('opciones');
				beforeSubmit: function(){
					waitwindow('Guardando Factura ... ','open');
				}, 
				uploadProgress: function(){	},
				success: function(data)
				{
					waitwindow('Guardando Factura ... ','close');
					var dataJson = JSON.parse(data);
					//console.log(dataJson.estado+'='+dataJson.mensaje);				
					//alert('estado='+dataJson.estado+' mensaje='+dataJson.mensaje);
					if ((dataJson.estado > 0)) {
						// if (dataJson.estado == 1) {
							// console.log('Se subio a alfresco');
							Nom_Archivo = dataJson.nom_archivo;
							
							showalert(dataJson.mensaje, "", "gritter-success");
							LimpiarFactura();
							// GuardarFacturas();
							// showalert(dataJson.mensaje, "", "gritter-info");
						// }
						// else
						// {
							// showalert(dataJson.mensaje, "", "gritter-warning");
							// return;
						// }	
						// Regresa a pantalla seguimiento de factuas por colaborador
						// if(iRegresa == 1)
						// {
							// loadContent('ajax/frm/frm_seguimientoFacturasElectronicasColaboradores.php','');
						// }
						// else
						// {
							// LimpiarDatos();
						// }
					}
					else
					{
						if(dataJson.estado < 0)
						{
							showalert('Ocurrio un problema al subir la factura: ' + dataJson.mensaje, "", "gritter-error");
						}
					}
				},
				error:function()
				{
					waitwindow('Cargando','close');
					showalert("Ocurrio un problema al subir la factura", "", "gritter-error");
				}
			};
			$( '#session_name1' ).val(Session);
			
			$( '#xmlupload' ).attr("action", "ajax/proc/proc_subir_PDF_Colegiaturas.php") ;
			$( '#xmlupload' ).ajaxForm(opciones) ;
			$( '#xmlupload' ).submit();		
		}
	}
	function fnGuardarFacturaInicial(){
		var sFecha=formatearFecha($('#txt_Fecha').val());
		
		$.ajax({type: "POST", 
			url: "ajax/json/json_fun_grabar_stmp_facturas_colegiaturas.php?",
			data: { 
				session_name:Session,
				'iOpcion':0,
				'iFacturasEspeciales' : 1,
				'iUsuario' : $("#txt_NumEmp").val().makeTrim(" "),
				'cFolioFiscal':$("#txt_FolioFactura").val().toUpperCase(),
				'iPdf' : 1,
				'importe' : accounting.unformat($("#txt_Importe").val()),
				'cRfc' : $("#txt_RFC").val().toUpperCase().makeTrim(" "),
				// 'iEscuela':$("#cbo_escuelaLinea").val(),
				'fecha':sFecha
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);	
				//console.log(dataJson);
				if(dataJson.estado == 0){
					$("#txt_ifactura").val(dataJson.factura);
					fnGuardarFactura();
				} else {
					//showmessage('Ocurrio un ploblema al capturar la factura, favor de comunicarse a mesa de ayuda', '', undefined, undefined, function onclose(){});
					// showalert("Ocurrio un ploblema al capturar la factura, favor de comunicarse a mesa de ayuda", "", "gritter-error");
					showalert(dataJson.mensaje, "", "gritter-warning");
					LimpiarFactura();
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});	
	}	
	function fnGuardarFactura(){
		var sFecha=formatearFecha($('#txt_Fecha').val());
		
		$.ajax({type: "POST", 
			url: "ajax/json/json_fun_grabar_stmp_facturas_colegiaturas.php?",
			data: { 
				session_name:Session,
				'iOpcion':1,
				'iFacturasEspeciales' : 1,
				'iUsuario' : $("#txt_NumEmp").val().makeTrim(" "),
				'cFolioFiscal':$("#txt_FolioFactura").val().toUpperCase(),
				'iEscuela':$("#cbo_escuelaLinea").val(),
				// 'cRfc' : $("#txt_RFC").val().trim().toUpperCase(),
				'fecha':sFecha
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);	
				//console.log(dataJson);
				if(dataJson.estado == 0){
					$("#txt_ifactura").val(dataJson.factura);
					GuardarFacturasSTMP();
				} else {
					//showmessage('Ocurrio un ploblema al capturar la factura, favor de comunicarse a mesa de ayuda', '', undefined, undefined, function onclose(){});
					showalert("Ocurrio un ploblema al capturar la factura, favor de comunicarse a mesa de ayuda", "", "gritter-error");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});	
	}	
//--LIMPIAR DATOS
	function LimpiarDatos(){
		$("#txt_NomEmp").val('');
		$("#txt_Centro").val('');
		$("#txt_NombreCentro").val('');
		$("#txt_fechaIngreso").val('');
		$("#txt_SueldoMensual").val('');

		$("#txt_AcumFactPagadas").val('');
		$("#txt_TopeAnual").val('');
		$("#txt_TopePropRestante").val('');
		$("#txt_TopeMensual").val('');
		$("#txt_RutaPago").val('');
		
		$('#filePdf').ace_file_input('reset_input');
		$("#txt_FolioFactura").val('');
		$("#txt_Importe").val('');
		$("#txt_Empresa").val('');
		//$("#txt_Fecha").val('');
		Beneficiarios="";
		Beneficiarios="<option parentesco='0' value='0'>SELECCIONE</option>";
		$("#cbo_Beneficiario").html(Beneficiarios);
		$("#cbo_Beneficiario" ).val($("#cbo_Beneficiario").first().val());
		// $("#cbo_Beneficiario").html("");
		// $("#cbo_Beneficiario").val(0);
		$("#cbo_Beneficiario").trigger("chosen:updated");

		$("#cbo_escuelaLinea").val(0);
		$("#cbo_escuelaLinea").trigger("chosen:updated");

		$("#cbo_TipoPago").val(0);
		$("#cbo_TipoPago").trigger("chosen:updated");

		$("#cbo_Escolaridad").prop('disabled',true);
		$("#cbo_Escolaridad").val(0);
		$("#cbo_Escolaridad").trigger("chosen:updated");

		$("#cbo_Grado").prop('disabled',true);
		$("#cbo_Grado").val(0);
		$("#cbo_Grado").trigger("chosen:updated");
		// CargarGrados();

		$("#cbo_Periodo").prop('disabled',true);
		$("#cbo_Periodo").val(0);
		$("#cbo_Periodo").trigger("chosen:updated");

		$("#cbo_Parentesco").html("");
		$("#cbo_Parentesco").trigger("chosen:updated");

		$("#cbo_CicloEscolar").val(0);
		$("#cbo_CicloEscolar").trigger("chosen:updated");
		//$("#txt_parentesco").val('');
		$("#txt_RFC").val('');
	}
	function LimpiarFactura(){
		$("#txt_ifactura").val("");
		$("#txt_ifactura").val(0);
		$('#filePdf').ace_file_input('reset_input');
		$("#txt_FolioFactura").val('');
		$("#txt_Importe").val('');
		//$("#txt_Fecha").val('');
		// Beneficiarios="";
		// Beneficiarios="<option parentesco='0' value='0'>SELECCIONE</option>";
		// $("#cbo_Beneficiario").html(Beneficiarios);
		// $("#cbo_Beneficiario" ).val($("#cbo_Beneficiario option:first").val());
		// $("#cbo_Beneficiario").trigger("chosen:updated");
		/*--------------------
		// $("#cbo_Beneficiario").html("");
		// $("#cbo_Beneficiario").val(0);
		--------------------------*/
		$("#cbo_Beneficiario").val(0);
		$("#cbo_escuelaLinea").val(0);
		$("#cbo_escuelaLinea").trigger("chosen:updated");

		$("#cbo_TipoPago").val(0);
		$("#cbo_TipoPago").trigger("chosen:updated");

		$("#cbo_Escolaridad").prop('disabled',true);
		// $("#cbo_Escolaridad").val(0);
		$("#cbo_Escolaridad").val("");
		$("#cbo_Escolaridad").trigger("chosen:updated");

		$("#cbo_Grado").prop('disabled',true);
		// $("#cbo_Grado").val(0);
		$("#cbo_Grado").val("");
		$("#cbo_Grado").trigger("chosen:updated");
		// CargarGrados();

		$("#cbo_Periodo").prop('disabled',true);
		$("#cbo_Periodo").val("");
		$("#cbo_Periodo").trigger("chosen:updated");

		$("#cbo_Parentesco").html("");
		$("#cbo_Parentesco").trigger("chosen:updated");

		$("#cbo_CicloEscolar").val(0);
		$("#cbo_CicloEscolar").trigger("chosen:updated");
		//$("#txt_parentesco").val('');
		$("#txt_RFC").val('');		
		$("#txt_Rfc_fac").val('');
	}	
	function ConsultaClaveHCM(){
        $.ajax({type: "POST", 
            url:'ajax/json/json_proc_consultaropcionesapagado_hcm.php',
            data: {                 
                'iOpcion': 387
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