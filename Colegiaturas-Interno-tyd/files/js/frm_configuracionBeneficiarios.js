$(function(){
	ConsultaClaveHCM()
	$.fn.modal.Constructor.prototype.enforceFocus = function () {};
	SessionIs();

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
	
	//VARIABLES
	iFactura=0;
	sel_idu_configuracion=0;
	sel_idbeneficiario=0;
	sel_idu_escuela=0;
	sel_rfc_escuela='';
	sel_idu_escolaridad=0;
	sel_idu_gradoescolar=0;	
	sel_idu_cicloescolar=0;
	sel_nom_beneficiario='';
	sel_tipo_beneficiario=0;
	sel_idu_carrera=0;
	primer_ciclo_escolar=0;
	bEditar=false;
	$("#cbo_Carrera").prop("disabled",true);
	iCarrera=0;
	sRazonSocial='';
	
	//iEscolaridadB=0;
	$("#txt_idconfig").val(0);
	$("#txt_clv_ben").val(0);
	$("#txt_tipo_ben").val(0);
	$("#txt_iOpcion").val(1);
	
	//--VARIABLES PARA AGREGAR ESCUELA
	iEstadoAgregar=0;
	iCiudadAgregar=0;
	iLocalidadAgregar=0;
	var iAccesoSistema = 0;
	
	nombre=''; 
	sNombre= ''; 
	fnConsultarPermisosSistema(function() {
		//if ( iAccesoSistema > 0 ) {
		if	( 1 > 0 ) {
			ObtenerDatosUsuario();
			CargarCiclosEscolares();
			Cargargrid();
			setTimeout(		
				ConsultaEmpleado(function()
				{
					// $("#btn_Cargar").hide();
					//fnEmpleadoBloqueado( function()
					//{
						//CargarDatosGenerales();
						//MostrarGridEscuelas();
						//fnConsultaAvisos(1);
						// CargarEstados( function()
						// {
							// CargarCiudades();
						// });
					//});					
				})		
			,0);
		} else {
			loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:'De momento no esta disponible la opcion.'}});
		}
	});
	
	function fnConsultarPermisosSistema(callback){
		$.ajax({
			type:'POST',
			url:'ajax/json/json_fun_obtener_permisos_sistema.php?',
			data:{'session_name':Session
					, 'iSistema' : 13
				},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				if (dataJson != null) {
					// console.log(dataJson.estado);
					if ( dataJson.estado > 0 ) {
						iAccesoSistema = dataJson.respuesta;
					}
					//console.log(dataJson.mensaje);
				}
				if (callback != undefined){
					callback();
				}
				//console.log("Acceso Sistema = "+iAccesoSistema);
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	
//--VALIDAR EMAIL
	function isValidEmailAddress(emailAddress) {
		var pattern = /^([a-z\d!#$%&'*+\-\/=?^_`{|}~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+(\.[a-z\d!#$%&'*+\-\/=?^_`{|}~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+)*|"((([ \t]*\r\n)?[ \t]+)?([\x01-\x08\x0b\x0c\x0e-\x1f\x7f\x21\x23-\x5b\x5d-\x7e\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|\\[\x01-\x09\x0b\x0c\x0d-\x7f\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))*(([ \t]*\r\n)?[ \t]+)?")@(([a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|[a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF][a-z\d\-._~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]*[a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])\.)+([a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|[a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF][a-z\d\-._~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]*[a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])\.?$/i;
		return pattern.test(emailAddress);
	}
	
//--VALIDAR TELEFONO
	function isValidPhoneNumber(phone_number) {
		var pattern = /([0-9]{10})|(\([0-9]{3}\)\s+[0-9]{3}\-[0-9]{4})/; 
		return pattern.test(phone_number);
	}
	
//--TELEFONO
	$('#txt_telefono')
		.keydown(function (e) {
			var key = e.which || e.charCode || e.keyCode || 0;
			$phone = $(this);
			
			// Don't let them remove the starting '('
			if ($phone.val().length === 1 && (key === 8 || key === 46)) {
				$phone.val('('); 
				return false;
			} 
			// Reset if they highlight and type over first char.
			else if ($phone.val().charAt(0) !== '(') {
					$phone.val('('+String.fromCharCode(e.keyCode)+''); 
			}
			
			// Auto-format- do not expose the mask as the user begins to type
			if (key !== 8 && key !== 9) {
				if ($phone.val().length === 4) {
					$phone.val($phone.val() + ')');
				}
				if ($phone.val().length === 5) {
					$phone.val($phone.val() + ' ');
				}			
				if ($phone.val().length === 9) {
					$phone.val($phone.val() + '-');
				}
			}
			
			// Allow numeric (and tab, backspace, delete) keys only
			return (key == 8 || 
					key == 9 ||
					key == 46 ||
					(key >= 48 && key <= 57) ||
					(key >= 96 && key <= 105));	
		})
		
		.on('focus click', function () {
			$phone = $(this);
			
			if ($phone.val().length === 0) {
				$phone.val('(');
			}
			else {
				var val = $phone.val();
				$phone.val('').val(val); // Ensure cursor remains at the end
			}
		})
		
		.blur(function () {
			$phone = $(this);
			
			if ($phone.val() === '(') {
				//$phone.val('');
				$("#hlp_telefono").html("<i style=\"color: rgb(255,0,0);\">Número a 10 dígitos con clave Lada</i>");
			} else if ( !isValidPhoneNumber($phone.val()) ) {
				//$phone.val('');
				$("#hlp_telefono").html("<i style=\"color: rgb(255,0,0);\">Número a 10 dígitos con clave Lada</i>");
			} else {
				$("#hlp_telefono").html("");
			}
		});
	
//--EMAIL
	$('#txt_email_contacto')
		.blur(function () {
			$mail = $(this);
			
			if ($mail.val() === '(') {
				//$mail.val('');
				$("#hlp_correo").html("<i style=\"color: rgb(255,0,0);\">Proporcione un correo válido</i>");
			} else if ( !isValidEmailAddress($mail.val()) ) {
				//$mail.val('');
				$("#hlp_correo").html("<i style=\"color: rgb(255,0,0);\">Proporcione un correo válido</i>");
			} else {
				$("#hlp_correo").html("");
			}
		});
	
//Valida si el empleado esta bloqueado / Limitado
	// setTimeout(		
		// ConsultaEmpleado(function()
		// {
			// $("#btn_Cargar").hide();
			//fnEmpleadoBloqueado( function()
			//{
				//CargarDatosGenerales();
				//MostrarGridEscuelas();
				//fnConsultaAvisos(1);
				// CargarEstados( function()
				// {
					// CargarCiudades();
				// });
			//});					
		// })		
	// ,0);
	


//--CONSULTA EMPLEADO
	function ConsultaEmpleado(callback)
	{	
		$.ajax({type:'POST',
			url: "ajax/json/json_proc_obtener_datos_colaborador_colegiaturas.php?",
			data:{'session_name' : Session},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				if(dataJson != 0)
				{
					Sueldo=accounting.unformat(dataJson[0].sueldo);
					$("#txt_SueldoMensual").val(dataJson[0].sueldo);
					//$("#txt_TopeProp").val(dataJson[0].topeproporcion);
					//nAntiguedad=dataJson[0].antiguedad;
					//dFechaValida=formatearFecha2(1,dataJson[0].fec_alta);
					$("#txt_Rfc_Emp").val(dataJson[0].rfc);
				}
				else
				{
				}
			},
			error:function onError(){callback();},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}
		});
	}

/*----------------------------------------------------------------------------------------------
	X	M	L
----------------------------------------------------------------------------------------------**/
	//--XML
	$('#fileXml').ace_file_input({
		no_file:'XML...',
		btn_choose:'Examinar',
		btn_change:'Cambiar',
		droppable:false,
		thumbnail:false, 
		whitelist:'xml',
		blacklist:'exe|php|gif|png|jpg|jpeg'
	});
	
	$("#fileXml").change(function(event){		
		validarXml(function(){
			if($("#txt_RFC").val()!='')
				//console.log('Carga Escuelas');
				CargarEscuelas();
		});
		event.preventDefault();
	});
	
	//--VALIDAR XML
	function validarXml(callback){		
		var sExt = ($('#fileXml').val().substring($('#fileXml').val().lastIndexOf("."))).toLowerCase();
		$("#txt_ImporFact").val();
		$("#txt_RFC").val();
		$("#txt_FechaCap").val();
		$("#txt_Folio").val();
		$("#txt_config_ben").val();
		if(sExt != '.xml')
		{
			$( '#fileXml' ).ace_file_input('reset_input');
			$("#txt_RFC").val('');
			//message('El archivo seleccionado no es un xml, favor de verificar');
			showalert(LengStrMSG.idMSG390, "", "gritter-info");
			return; 
		}
		var opciones= {
			beforeSubmit: function(){
				//	alert('antes de subir');
				//console.log('antes de subir');
			}, 
			uploadProgress: function(){
				//console.log('subiendo');
			},
			success: function(data) 
			{
				var dataJson = JSON.parse(data);
				//console.log('resultado='+dataJson[0].resultado+'='+dataJson[0].json.rfc_emisor);
				if (dataJson[0].resultado != 0)
				{
					//message(dataJson[0].json.mensaje);
					//console.log(dataJson[0].json.mensaje);
					if(dataJson[0].resultado==-1)
					{
						$( '#fileXml' ).ace_file_input('reset_input');
						$('#txt_RFC' ).val('');
						showalert(dataJson[0].mensaje, "", "gritter-warning");
					}
					else
					{
						//showalert(dataJson[0].json.mensaje, "", "gritter-info");	

						$("#txt_RFC").val(dataJson[0].json.rfc_emisor);					
						$("#txt_NomEscuela").val(dataJson[0].json.emisor);	
						sRazonSocial=dataJson[0].json.emisor;
						// var option='';
						// for(var i=0;i<dataJson[0].importes.length; i++)
						// {
							// option = option + "<option value='" + dataJson[0].importes[i].value + "'>" + dataJson[0].importes[i].value + "</option>";
						// }
						// $("#cbo_Importes").html(option);
						// $("#cbo_Importes").trigger("chosen:updated");
						
					}	
					
					// if (dataJson[0].resultado != 2)
					// {
						//$('#dlg_AyudaEscuelas').modal('show');
					// }	
					//LimpiarBeneficiarios();
				}
				else
				{					
					$("#txt_RFC").val(dataJson[0].json.rfc_emisor);					
					$("#txt_NomEscuela").val(dataJson[0].json.emisor);	
					sRazonSocial=dataJson[0].json.emisor;
				}
				callback();
			}
		};
		$( '#session_name1' ).val(Session);
		$( '#xmlupload' ).attr("action", "ajax/json/json_leer_Rfc_XML.php") ;
		$( '#xmlupload' ).ajaxForm(opciones) ;
		$( '#xmlupload' ).submit();
	}
/**----------------------------------------------------------------------------------------------
	D	A	T	O	S 		U	S	U	A	R	I	O
----------------------------------------------------------------------------------------------*/
//--OBTENER DATOS DEL USUARIO
	function ObtenerDatosUsuario(){
		$.ajax({type: "POST", 
			url:'ajax/json/json_ObtenerDatosUsuario.php',
			data: { 				
				'session_name': Session
			}
		})
		.done(function(data){
			var dataJson = JSON.parse(data);			
			$("#txt_idColaborador").val(dataJson.usuario);			
			$("#cbo_Beneficiario").html("");
			ActualizarBeneficiariosHojaAzul(function(){
				CargarBeneficiariosCapturados()
			});
		});		
	}
/**----------------------------------------------------------------------------------------------
	B	E	N	E	F	I	C	I	A	R	I	O	S
----------------------------------------------------------------------------------------------*/
//--BENEFICIARIOS	
	
	
	//ACTUALIZAMOS BENEFICIARIOS DE LA HOJA AZUL
	function ActualizarBeneficiariosHojaAzul(callback)
	{	
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_contactos_hoja_azul.php",
			data: { 
				//'iEmpleado':$("#txt_idColaborador").val(),
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
	
	var Beneficiarios="";	
	//BENEFICIARIOS HOJA AZUL Y CAPTURADOS  
	function CargarBeneficiariosCapturados()
	{	
		Beneficiarios="";
		Beneficiarios="<option parentesco='0' value='0'>SELECCIONE</option>";
		$("#cbo_Beneficiario").html(Beneficiarios);
		
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_beneficiarios_colegiaturas_combo.php",
			data: { 
				//'iEmpleado':$("#txt_idColaborador").val(),
				'iEmpleado':DOMPurify.sanitize($("#txt_idColaborador").val()),
				//session_name:Session
			},
			beforeSend:function(){},
			success:function(data){		
				var sanitizedData = limpiarCadena(data);	
				var dataJson = JSON.parse(sanitizedData);	
				if(dataJson.estado == 0)
				{					
					for(var i=0;i<dataJson.datos.length; i++)
					{
						//Beneficiarios = Beneficiarios + "<option parentesco='"+ dataJson.datos[i].parentesco +"' value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>"; 
						Beneficiarios+="<option parentesco='"+ dataJson.datos[i].parentesco+"' value='" + dataJson.datos[i].value + "'  tipo_beneficiario='" + dataJson.datos[i].tipo_beneficiario + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_Beneficiario").html(Beneficiarios);
					$("#cbo_Beneficiario" ).val($("#cbo_Beneficiario option").first().val());					
					$("#cbo_Beneficiario").trigger("chosen:updated");					
				}
				
				// Mostrar beneficiarios configurados en grid
				Cargargrid();
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});	
	}
	
	//
	$("#cbo_Beneficiario").change(function(event){		
		$("#txt_tipo_ben").val($("#cbo_Beneficiario").children(":selected").attr("tipo_beneficiario"));
		$("#txt_clv_ben").val($("#cbo_Beneficiario").val());
		//console.log();
		//event.preventDefault();
	});
/**----------------------------------------------------------------------------------------------
	E	S	C	U	E	L	A	S
----------------------------------------------------------------------------------------------*/
//--COMBO CARGAR ESCUELAS 
	function CargarEscuelas(){	
		//console.log('Carga de escuelas--------------');
		var Escuela="";
		$.ajax({type: "POST",
			//url: "ajax/json/json_fun_consultar_escuela_rfc.php?",
			url: "ajax/json/json_fun_consultar_escuelas_distintas_por_rfc.php",
			data: { 
				session_name:Session,				
				//'cRFCescuela':$('#txt_RFC').val(),
				'cRFCescuela':DOMPurify.sanitize($('#txt_RFC').val()),
				'iEscuela': sel_idu_escuela
			},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);	
				var bloqueda=0;
				//console.log('Carga '+dataJson.estado > 0);
				if(dataJson.estado > 0){
					if (dataJson.estado == 1 ){ //Si trae datos 
						
						$("#cbo_Escuela").html("");
						Escuela="<option value='0' >SELECCIONE ESCUELA</option>"					
						for(var i=0;i<dataJson.datos.length; i++)
						{
							iLimpiar=1;
							if(dataJson.datos[i].value != 0)
							//if(dataJson.datos[i].escuela != '')
							
							{
								//Escuela = Escuela + "<option value='" + dataJson.datos[i].value + "'  pdf='" + dataJson.datos[i].pdf + "'>" + dataJson.datos[i].nombre + "</option>";	
								//Escuela = Escuela + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";							
								//Escuela = Escuela + "<option value='" + dataJson.datos[i].value + "' escuela='" + dataJson.datos[i].escuela + "'>" + dataJson.datos[i].nombre + "</option>";							
								//Escuela = Escuela + "<option value='" + dataJson.datos[i].value + "' escuela='" + dataJson.datos[i].escuela + "'>" + dataJson.datos[i].nombre + "</option>";
								Escuela = Escuela + "<option value='" + dataJson.datos[i].value + "' iestado='" + dataJson.datos[i].iestado + "' imunicipio='" + dataJson.datos[i].imunicipio + "' ilocalidad='" + dataJson.datos[i].ilocalidad + "' escuela='" + dataJson.datos[i].escuela + "'>" + dataJson.datos[i].nombre + "</option>";
								
							}else{
								bloqueda=1;
							}	
							
						}
						
						if(bloqueda==1 && dataJson.datos.length==1)
						{
							//message('No se puede subir la factura, porque la escuela está bloqueada');
							showalert(LengStrMSG.idMSG402, "", "gritter-info");
							Limpiar();
						}
						else
						{
							$("#cbo_Escuela").html(Escuela);
							$("#cbo_Escuela").val($("#cbo_Escuela option").first().val());
							// $("#cbo_Escuela").val(PrimerOpcion);
							$("#cbo_Escuela").trigger("chosen:updated");
							/*
							if(iEscuelaFac!=0)
							{
								$( "#cbo_Escuela" ).val(iEscuelaFac);							
								CargarEscolaridades();
							}*/
						}
						
						if (sel_idbeneficiario>0){
							//console.log('Editar')
							$("#cbo_Escuela").val(sel_idu_escuela);							
							$("#cbo_Escuela").trigger("chosen:updated");
							CargarEscolaridades();
						}
					}else{		
						Escuela="<option value='0' >SELECCIONE ESCUELA</option>";
						$("#cbo_Escuela").html(Escuela);
						$("#cbo_Escuela").val($("#cbo_Escuela option").first().val());
						$("#cbo_Escuela").trigger("chosen:updated");
						
						Escolaridad="<option value='0' >SELECCIONE </option>";
						$("#cbo_Escolaridad").html(Escuela);
						$("#cbo_Escolaridad").val($("#cbo_Escolaridad option").first().val());
						$("#cbo_Escolaridad").trigger("chosen:updated");
						
						$('#btn_AgregarEscuela').click();
					}
				}else{
					iLimpiar=0;
					showalert(LengStrMSG.idMSG403, "", "gritter-warning");
					//$('#dlg_AyudaEscuelas').modal('show');
					//Limpiar();
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});	
	}
	
	//COMBO ESCUELAS
	$("#cbo_Escuela").change(function(event){
		//console.log($("#cbo_Escuela").children(":selected").attr("nombre"));
		//console.log($("#cbo_Escuela").children());
		sel_idbeneficiario=0;
		//return;
		if ($("#cbo_Escuela").children(":selected").attr("value")!=0){
			CargarEscolaridades(function(){
				CargarGrados();
			});
		}else{			
			//$("#cbo_Escolaridad").trigger("chosen:updated");
			Escolaridad="<option value='0' >SELECCIONE </option>";
			$("#cbo_Escolaridad").html(Escolaridad);
			$("#cbo_Escolaridad").val($("#cbo_Escolaridad option").first().val());
			$("#cbo_Escolaridad").trigger("chosen:updated");
			
			Grados="<option value='0' >SELECCIONE </option>";
			$("#cbo_Grado").html(Grados);
			$("#cbo_Grado").val($("#cbo_Grado option").first().val());
			$("#cbo_Grado").trigger("chosen:updated");		
		}
		
		iCarrera=0;
		$("#cbo_Carrera").val(iCarrera);
		$("#cbo_Carrera").prop("disabled",true);	
		$("#cbo_Carrera").trigger("chosen:updated");
		//showalert($("#cbo_Escuela").children(":selected").attr("iestado"), "", "gritter-info");
		//$("#txt_escuela").val($("#cbo_Escuela").children(":selected").attr("escuela"));
		event.preventDefault();
	});
/**----------------------------------------------------------------------------------------------
	E	S	C	O	L	A	R	I	D	A	D	E	S	
-----------------------------------------------------------------------------------------------*/	

	//CARGA LAS ESCOLARIDADES DE LA ESCUELA
	function CargarEscolaridades(){
		//showalert($("#cbo_Escuela").children(":selected").attr("iestado"), "", "gritter-info");
		//var nombre = $("#cbo_Escuela").text().split('|');
		//var sNombre = nombre[0] ;
		//console.log('valor='+$("#cbo_Escuela").children(":selected").attr("value"));
		//console.log($("#cbo_Escuela").htm());
		//console.log('sNombre='+sNombre);
		nombre=$( "#cbo_Escuela option:selected" ).text().split('|');
		sNombre = DOMPurify.sanitize(nombre[0]).replace('/^\s+|\s+$/g', '');
		//sNombre= sNombre.replace('/^\s+|\s+$/g', '');
		//var sNombre= 'INSTITUTO TECNOLOGICO DE MONTERREY';
		//console.log('sNombre='+sNombre);		
		
		$("#cbo_Escolaridad").html("");
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_escolaridades_por_rfc_escuela.php",
			data: {
				//'iEscuela':$("#cbo_Escuela").val(), 
				/*'cRFCescuela':$('#txt_RFC').val(),
				'iestado':$("#cbo_Escuela").children(":selected").attr("iestado"),
				'imunicipio':$("#cbo_Escuela").children(":selected").attr("imunicipio"),
				'ilocalidad':$("#cbo_Escuela").children(":selected").attr("ilocalidad"),*/

				'cRFCescuela':DOMPurify.sanitize($('#txt_RFC').val()),
				'iestado':DOMPurify.sanitize($("#cbo_Escuela").children(":selected").attr("iestado")),
				'imunicipio':DOMPurify.sanitize($("#cbo_Escuela").children(":selected").attr("imunicipio")),
				'ilocalidad':DOMPurify.sanitize($("#cbo_Escuela").children(":selected").attr("ilocalidad")),

				'sNombre':sNombre.toUpperCase()
			},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0 || dataJson.estado == 1)
				{
					var option = "<option opc_carrera='0' value='0'>SELECCIONE</option>";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						//option = option + "<option ='" + dataJson.datos[i].idu_escolaridad + "'>" + dataJson.datos[i].nom_escolaridad + "</option>";
						//option = option + "<option opc_carrera='" + dataJson.datos[i].opc_carrera + "' value='" + dataJson.datos[i].idu_escolaridad + "'>" + dataJson.datos[i].nom_escolaridad + "</option>";
						option = option + "<option opc_carrera='" + dataJson.datos[i].opc_carrera + "' value='" + dataJson.datos[i].value +  "' iescuela='" + dataJson.datos[i].iescuela + "'>" + dataJson.datos[i].sescolaridad + "</option>";						
					}
					
					if (dataJson.estado == 0){
						option = option + "<option opc_carrera='-1' value='99'>AGREGAR ESCOLARIDAD</option>";
					}
					
					//console.log('sel_idbeneficiario='+sel_idbeneficiario);
					//console.log('sel_idu_escolaridad='+sel_idu_escolaridad);
					
					//var iEscolar=$("#cbo_Escuela").children(":selected").attr("iescuela");
					//console.log('iEscolar='+iEscolar);
					$("#cbo_Escolaridad").html(option);
					if (sel_idbeneficiario>0){						
						$("#cbo_Escolaridad").val(sel_idu_escolaridad);	
						
						if ($("#cbo_Escolaridad").children(":selected").attr("opc_carrera")==1){
							CargarCarreras();
							$("#cbo_Carrera").prop("disabled",false);	
						}else{							
							$("#cbo_Carrera").prop("disabled",true);
							$("#cbo_Carrera").val(0);
							$("#cbo_Carrera").trigger("chosen:updated");
						}
					}
					
					$("#cbo_Escolaridad").trigger("chosen:updated");
					
					CargarGrados();
				}
				else
				{					
					showalert(LengStrMSG.idMSG88+" las escolaridades", "", "gritter-warning");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}	
		});
	}
	
	//COMBO ESCOLARIDAD
	$("#cbo_Escolaridad").change(function(event){
		sel_idbeneficiario=0;
		//console.log ('opc_carrera='+$("#cbo_Escolaridad").children(":selected").attr("opc_carrera"));
		$("#cbo_Carrera").prop("disabled",true);
		if ($("#cbo_Escolaridad").children(":selected").attr("opc_carrera")==-1){
			CargarEscolaridadesAgregar(function()
			{
				CargarCarrerasAgregar();
				
			});	
			$("#cbo_Agrega_Carrera").prop("disabled",true);	
			$("#dlg_AgregarEscolaridad").modal('show');			
		}else{
			CargarGrados();		
			
			if ($("#cbo_Escolaridad").children(":selected").attr("opc_carrera")==1){
				CargarCarreras();
				$("#cbo_Carrera").prop("disabled",false);
				//console.log('Si se cargan las carreras');
			}else{
				iCarrera=0;
				$("#cbo_Carrera").val(iCarrera);
				$("#cbo_Carrera").prop("disabled",true);	
				$("#cbo_Carrera").trigger("chosen:updated");
				//console.log('No se cargan las carreras');
			}
		}
		event.preventDefault();
	});	
	
	$("#cbo_Carrera").val(0);
	$("#cbo_Carrera").trigger("chosen:updated");

	//CARGA TODAS LAS ESCOLARIDADES DEL AGREGAR ESCOLARIDAD	 (MODAL AGREGAR ESCOLARIDAD)
	$("#cbo_Agrega_Escolaridad").trigger("chosen:updated");
	function CargarEscolaridadesAgregar(callback){
		$("#cbo_Agrega_Escolaridad").html("");
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_escolaridades_combo.php",
			data: {
				'iEscuela':0, //$("#txt_idEscuela").val(),
			},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0)
				{
					var option = "<option value='0'>SELECCIONE</option>";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						//option = option + "<option value='" + dataJson.datos[i].idu_escolaridad + "'>" + dataJson.datos[i].nom_escolaridad + "</option>";
						option = option + "<option opc_carrera='" + dataJson.datos[i].opc_carrera + "' value='" + dataJson.datos[i].idu_escolaridad + "'>" + dataJson.datos[i].nom_escolaridad + "</option>";
					}
					$("#cbo_Agrega_Escolaridad").html(option);
					$("#cbo_Agrega_Escolaridad").trigger("chosen:updated");
				}
				else
				{					
					showalert(LengStrMSG.idMSG88+" las escolaridades", "", "gritter-warning");
				}
			},
			error:function onError(){callback();},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}	
		});
	}
	
	//--(MODAL)
	$("#cbo_Agrega_Escolaridad").change(function(event){
		sel_idbeneficiario=0;
		//console.log ('opc_carrera='+$("#cbo_Agrega_Escolaridad").children(":selected").attr("opc_carrera"));
		//$("#cbo_Agrega_Carrera").prop("disabled",true);
		//$("#cbo_Agrega_Carrera").trigger("chosen:updated");
		
		if ($("#cbo_Agrega_Escolaridad").children(":selected").attr("opc_carrera")==1){
			CargarCarrerasAgregar();			
			$("#cbo_Agrega_Carrera").prop("disabled",false);			
		
		}else{
			$("#cbo_Agrega_Carrera").val(0)	;
			$("#cbo_Agrega_Carrera").prop("disabled",true);
			/*if ($("#cbo_Agrega_Escolaridad").children(":selected").attr("opc_carrera")==1){
				CargarCarreras();
				$("#cbo_Agrega_Carrera").prop("disabled",false);
				console.log('Si se cargan las carreras');
			}else{
				iCarrera=0;
				$("#cbo_Agrega_Carrera").val(iCarrera);
				$("#cbo_Agrega_Carrera").prop("disabled",true);	
				$("#cbo_Agrega_Carrera").trigger("chosen:updated");
				console.log('No se cargan las carreras');
			}
			*/
		}
		$("#cbo_Agrega_Carrera").trigger("chosen:updated");
		event.preventDefault();
	});	
		
	
	//--CARGAR CARRERAS PARA ESCUELA NUEVA (MODAL AGREGAR ESCOLARIDAD)
	$("#cbo_Agrega_Carrera").chosen({no_results_text: 'NO SE ENCUENTRA',width: '100%'});
	function CargarCarrerasAgregar()
	{
		Carrera="";
		Carrera="<option value='0'>SELECCIONE</option>";
		$("#cbo_Agrega_Carrera").html(Carrera);
		
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_carreras.php",
			data: { 
				'icarrera' : 0,				
			},
			beforeSend:function(){},
			success:function(data){	
				var sanitizedData = limpiarCadena(data);		
				var dataJson = JSON.parse(sanitizedData);	
				if(dataJson.estado == 0)
				{					
					for(var i=0;i<dataJson.datos.length; i++)
					{						
						Carrera = Carrera + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_Agrega_Carrera").html(Carrera);
					$("#cbo_Agrega_Carrera" ).val($("#cbo_Agrega_Carrera option").first().val());					
					//$("#cbo_Carrera").trigger("chosen:updated");
					
					if (sel_idbeneficiario>0){					
						$("#cbo_Agrega_Carrera").val(sel_idu_carrera);																					
					}
					$("#cbo_Agrega_Carrera").trigger("chosen:updated");
						
				}				
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});	
	}
/**----------------------------------------------------------------------------------------------
	C	A	R	R	E	R	A	S
-----------------------------------------------------------------------------------------------*/		
//--COMBO CARRERAS
	$("#cbo_Carrera").chosen({no_results_text: 'NO SE ENCUENTRA',width: '100%'});
	function CargarCarreras()
	{
		Carrera="";
		Carrera="<option value='0'>SELECCIONE</option>";
		$("#cbo_Carrera").html(Carrera);
		
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_carreras.php",
			data: { 
				'icarrera' : 0,				
			},
			beforeSend:function(){},
			success:function(data){	
				var sanitizedData = limpiarCadena(data);		
				var dataJson = JSON.parse(sanitizedData);	
				if(dataJson.estado == 0)
				{					
					for(var i=0;i<dataJson.datos.length; i++)
					{						
						Carrera = Carrera + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_Carrera").html(Carrera);
					$("#cbo_Carrera" ).val($("#cbo_Carrera option").first().val());					
					//$("#cbo_Carrera").trigger("chosen:updated");
					
					if (sel_idbeneficiario>0){					
						$("#cbo_Carrera").val(sel_idu_carrera);																					
					}
					$("#cbo_Carrera").trigger("chosen:updated");
						
				}				
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});	
	}
	
	/*
	function CargarCarreras()
	{
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_datos_por_escuela_empleado.php?",
			data: {
				'session_name':Session,
				'iopcion': 6,
				'crfc': $("#txt_RFC").val(),
				'ibeneficiario':$("#cbo_Escuela").children(":selected").attr("iestado"),
				'itipobeneficiario':$("#cbo_Escuela").children(":selected").attr("imunicipio"),
				'iescolaridad':$("#cbo_Escuela").children(":selected").attr("ilocalidad"),
			},
			beforeSend:function(){},
			success:function(data){			
				var dataJson = JSON.parse(data);	
				if(dataJson.estado == 0) {
					//if ( iEditarB > 0 ){
						Carrera="";
						Carrera="<option value='0'>SELECCIONE</option>";
						$("#cbo_Carrera").html(Carrera);
					//} else {
					//	Carrera = ""
					//}
					if(dataJson.datos != null) {	
						for(var i=0;i<dataJson.datos.length; i++) {
							Carrera = Carrera + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
						}
					}
					$("#cbo_Carrera").html(Carrera);
					//if ( iCarrera > 0 ) {
						$("#cbo_Carrera").val( iCarrera );
					//} else {
					//	$("#cbo_Carrera").val( $("#cbo_Carrera option").first().val() );
					//}
					// $("#cbo_Carrera").val(Carrera);
					$("#cbo_Carrera").trigger("chosen:updated");
				}				
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});	
	}*/
	
	//CHANGE
	$("#cbo_Carrera").change(function(event){
		iCarrera=$("#cbo_Carrera").val();	
	});
/**----------------------------------------------------------------------------------------------
	C	I	C	L	O	S		E	S	C	O	L	A	R	E	S
-----------------------------------------------------------------------------------------------*/		
//--COMBO CICLOS ESCOLARES
	function CargarCiclosEscolares(){
		$("#cbo_CicloEscolar").html("");
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_ciclos_escolares.php",
			data: {},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);	
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0)
				{
					var option = "";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						if(i==0){
							primer_ciclo_escolar=dataJson.datos[i].value;
						}
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_CicloEscolar").html(option);
					$("#cbo_CicloEscolar").trigger("chosen:updated");
				}
				else if(dataJson.estado == 0)
				{
					//message(LengStr.idMSG11);
					//showalert(LengStr.idMSG11, "", "gritter-warning");
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
/**----------------------------------------------------------------------------------------------
	G	R	A	D	O	S		E	S	C	O	L	A	R	E	S
-----------------------------------------------------------------------------------------------*/			
	//--COMBO GRADOS ESCOLARES
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
					var sanitizedData = limpiarCadena(data);
					var dataJson = JSON.parse(sanitizedData);
					if(dataJson.estado == 0)
					{
						var option = "";
						option = option + "<option value='-1'>" +"SELECCIONE" + "</option>";
						for(var i=0;i<dataJson.datos.length; i++)
						{
							option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>"; 
						}
						$("#cbo_Grado").html(option);
						$( "#cbo_Grado" ).val($("#cbo_Grado option").first().val());
						if($("#cbo_Escolaridad").val()== 1)//Maternidad
						{
							$( "#cbo_Grado" ).val(0);
							$( "#cbo_Grado" ).prop('disabled',true);
						}
						else
						{
							$( "#cbo_Grado" ).prop('disabled',false);
						}
						/*if(iEscolaridadB!=0)
						{
							$( "#cbo_Grado" ).val(iGradoB);
						}*/
						//console.log('sel_idbeneficiario='+sel_idbeneficiario);
						if (sel_idbeneficiario>0){
							//console.log('Editar en Grados Escolares')
							$("#cbo_Grado").val(sel_idu_gradoescolar);																					
						}
						$("#cbo_Grado").trigger("chosen:updated");
					}
					else
					{
						//showmessage(dataJson.mensaje, '', undefined, undefined, function onclose(){});
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
			$("#cbo_Grado" ).val($("#cbo_Grado option").first().val());
		}
	}
	
/**----------------------------------------------------------------------------------------------
	B	O	T	O	N	E	S
-----------------------------------------------------------------------------------------------*/		
//--BOTON NUEVO
	$('#btn_Nuevo').click(function(event){	
		 LimpiarBeneficiarios();
	});
	
	//--BOTON GUARDAR ESTUDIO BENEFICIARIO	
	$('#btn_GuardarEstudio').click(function(event){	
		//var sExt = ($('#fileXml').val().substring($('#fileXml').val().lastIndexOf("."))).toLowerCase();
		var nCarrera=$("#cbo_Escolaridad").children(":selected").attr("opc_carrera");
		
		if($("#txt_clv_ben").val()==0){
			showalert("Favor de seleccionar beneficiario", "", "gritter-info");
		}else if (($("#fileXml").val()=="") && ($("#txt_idconfig").val()==0)){
			//message("Seleccione el xml de la factura, por favor...");
			showalert(LengStrMSG.idMSG398, "", "gritter-info");		
		}else if($("#cbo_Escuela").val()==0){			
			showalert(LengStrMSG.idMSG98, "", "gritter-info");
		}else if($("#cbo_Escolaridad").val()==0){			
			showalert(LengStrMSG.idMSG202, "", "gritter-info");
		}else if ((nCarrera==1) && ($("#cbo_Carrera").val()==0)) {
			showalert("Favor de seleccionar carrera", "", "gritter-info");
		}else if($("#cbo_Grado").val()==-1){			
			showalert(LengStrMSG.idMSG203, "", "gritter-info");
		}else{	
			//showalert("Listo para Guardar", "", "gritter-info");
			GuardarEstudio();
		}
		event.preventDefault();		
	});
	
//--GUARDAR ESTUDIO BENEFICIARIO
	function GuardarEstudio()
	{		
		$.ajax({type: "POST", 
			url:'ajax/json/json_fun_grabar_beneficiario_escuela_escolaridad.php?',
			data: { 
				'iconfig': $("#txt_idconfig").val(),
				'iEmpleado':$('#txt_idColaborador').val(),
				'iBeneficiario' : $("#txt_clv_ben").val(),
				'iEscuela': $("#cbo_Escolaridad").children(":selected").attr("iescuela"), //$("#cbo_Escuela").val(),
				'iEscolaridad':$("#cbo_Escolaridad").val(),
				'iCicloEscolar':$("#cbo_CicloEscolar").val(),
				'iGrado':$("#cbo_Grado").val(),
				'iTipoBeneficiario': $("#txt_tipo_ben").val(), //$("#cbo_Beneficiario").children(":selected").attr("tipo_beneficiario"), //0 hoja azul, 1 cat_beneficiarios
				'iCarrera': iCarrera, //$("#cbo_Carrera").val(),
				'session_name': Session
			}
		})
		.done(function(data){
			var dataJson = JSON.parse(data);	
			if(dataJson.estado == 0)
			{
				if(dataJson.mensaje == 1)
				{
					//showmessage('Beneficiario guardado correctamente...', '', undefined, undefined, function onclose(){
						showalert(LengStrMSG.idMSG209, "","gritter-success");						
						Cargargrid();
						LimpiarBeneficiarios();						
					// });
				}
				else if(dataJson.mensaje == 0)
				{
					//showmessage('El estudio para este beneficiario ya existe, favor de verificar...', '', undefined, undefined, function onclose(){});
					showalert(LengStrMSG.idMSG216, "", "gritter-info");
				}
				else
				{
					showalert(LengStrMSG.idMSG217, "", "gritter-info");
				}
			}
			else
			{
				//showmessage(dataJson.mensaje, '', undefined, undefined, function onclose(){});
				showalert(LengStrMSG.idMSG230+" el estudio del beneficiario", "", "gritter-warning");
			}
		});
	}
	
	//--LIMPIAR DATOS BENEFICIARIOS
	function LimpiarBeneficiarios(){
		$( '#fileXml' ).ace_file_input('reset_input');

		//--
		CargarEstadosAgregar(function()
		{
			CargarCiudadesAgregar(function(){
				CargarLocalidadesAgregar();
			});
		});
		
		//--ocultos
		$("#txt_RFC").val('');
		$("#txt_NomEscuela").val('');
		
		
		$("#cbo_Beneficiario").prop('disabled',false);
		$("#cbo_Beneficiario").html("");
		
		$("#txt_idconfig").val(0);
		$("#txt_clv_ben").val(0);
		$("#txt_tipo_ben").val(0);
		
		CargarBeneficiariosCapturados();
		
		var Seleccione="<option seleccione='0' value='0'>SELECCIONE</option>";
		//$("#cbo_Beneficiario").html(Seleccione);
				
		$("#cbo_Escuela").html(Seleccione);		
		$("#cbo_Escuela").trigger("chosen:updated");
		
		$("#cbo_Escolaridad").html(Seleccione);
		$("#cbo_Escolaridad").trigger("chosen:updated");		
		
		$("#cbo_CicloEscolar").val();
		$("#cbo_CicloEscolar").trigger("chosen:updated");
		
		$("#cbo_Grado").html(Seleccione);		
		$("#cbo_Grado").trigger("chosen:updated");
		
		$("#cbo_Carrera").val(0);
		$("#cbo_Carrera").trigger("chosen:updated");
		
		iFactura=0;
		sel_idu_configuracion=0;
		sel_idbeneficiario=0;
		sel_idu_escuela=0;
		sel_rfc_escuela='';
		sel_idu_escolaridad=0;
		sel_idu_gradoescolar=0;	
		sel_idu_cicloescolar=0;
		sel_nom_beneficiario='';
		sel_tipo_beneficiario=0;
		sel_idu_carrera=0;
		iCarrera=0;
		$("#cbo_Carrera").prop("disabled",true);
		
		iEstadoAgregar=0;
		iCiudadAgregar=0;
		iLocalidadAgregar=0;
		limpiarDatosModal_AgregarEscuela();
	}	
	
	//--GRID BENEFICIARIOS	
	function Cargargrid(){	
		jQuery("#gd_EstudiosBeneficiarios").GridUnload(); 
		jQuery("#gd_EstudiosBeneficiarios").jqGrid({			
			url:'ajax/json/json_fun_listado_beneficiarios_estudios.php?session_name='+Session,
			datatype: 'json',
			mtype: 'POST',
			colNames: LengStr.idMSG83,
			colModel:[			
					{name:'idu_configuracion',	index:'idu_configuracion', 	width:30, 	sortable: false,	align:"center",	fixed: true, hidden:true},
					{name:'idu_beneficiario',	index:'idu_beneficiario', 	width:30, 	sortable: false,	align:"center",	fixed: true, hidden:true},
					{name:'nom_beneficiario',	index:'nom_beneficiario', 	width:300, 	sortable: false,	align:"left",	fixed: true},
					{name:'idu_parentesco',		index:'idu_parentesco', 	width:40, 	sortable: false,	align:"left",	fixed: true, hidden:true},
					{name:'nom_parentesco',		index:'nom_parentesco', 	width:120, 	sortable: false,	align:"left",	fixed: true},
					{name:'idu_escuela',		index:'idu_escuela', 		width:100, 	sortable: false,	align:"left",	fixed: true, hidden:true},
					{name:'rfc_escuela',		index:'rfc_escuela', 		width:100, 	sortable: false,	align:"left",	fixed: true, hidden:true},
					{name:'nom_escuela',		index:'nom_escuela', 		width:450, 	sortable: false,	align:"left",	fixed: true},
					{name:'idu_escolaridad',	index:'idu_escolaridad', 	width:50, 	sortable: false,	align:"left",	fixed: true, hidden:true},
					{name:'nom_escolaridad',	index:'nom_escolaridad', 	width:150, 	sortable: false,	align:"left",	fixed: true},
					{name:'idu_carrera',		index:'idu_carrera', 		width:50, 	sortable: false,	align:"left",	fixed: true, hidden:true},
					{name:'nom_carrera',		index:'nom_carrera', 		width:150, 	sortable: false,	align:"left",	fixed: true},
					{name:'idu_cicloescolar',	index:'idu_cicloescolar', 	width:50, 	sortable: false,	align:"left",	fixed: true, hidden:true},
					{name:'nom_cicloescolar',	index:'nom_cicloescolar', 	width:150, 	sortable: false,	align:"left",	fixed: true},
					{name:'idu_gradoescolar',	index:'idu_gradoescolar', 	width:50, 	sortable: false,	align:"left",	fixed: true, hidden:true},
					{name:'nom_gradoescolar',	index:'nom_gradoescolar', 	width:280, 	sortable: false,	align:"left",	fixed: true},
					{name:'fecharegistro',		index:'fecharegistro', 		width:150, 	sortable: false,	align:"center",	fixed: true},
					{name:'tipo_beneficiario',	index:'tipo_beneficiario', 	width:150, 	sortable: false,	align:"center",	fixed: true, hidden:true},
					],		
			viewrecords : false,
			rowNum:-1,
			hidegrid: false,
			rowList:[],
			pager : "#gd_EstudiosBeneficiarios_pager",
			multiselect: false,
			width: null,
			shrinkToFit: false,
			height: 250,//null,//--> sepuede poner fijo si el alto no se quiere automatico  
			//----------------------------------------------------------------------------------------------------------
			caption: "Beneficiarios",
			pgbuttons: false,
			pgtext: null,
			postData:{},
			loadComplete: function (data) {
				
			},
			onSelectRow: function(id){
				var ret = jQuery("#gd_EstudiosBeneficiarios").jqGrid('getRowData',id);				
				sel_idu_configuracion=ret.idu_configuracion;
				sel_idbeneficiario=ret.idu_beneficiario;
				sel_idu_escuela=ret.idu_escuela;
				sel_rfc_escuela=ret.rfc_escuela;
				sel_idu_escolaridad=ret.idu_escolaridad;
				sel_idu_gradoescolar=ret.idu_gradoescolar;				
				sel_idu_cicloescolar=ret.idu_cicloescolar;
				sel_nom_beneficiario=ret.nom_beneficiario;
				sel_tipo_beneficiario=ret.tipo_beneficiario;
				sel_idu_carrera=ret.idu_carrera;
			},
			/*
			ondblClickRow: function(id){
				
			}
			*/
		});	
		
		barButtongrid({
		pagId:"#gd_EstudiosBeneficiarios_pager",
		position:"left",//center rigth
			Buttons:[
					{
						icon:"icon-remove red bigger-140",
						title:'Eliminar Beneficiario',
						click: function(event)
						{
							//sjson = recorrerGrid();
							//var dataJson = JSON.parse(sjson);
							if(sel_idbeneficiario>0)
							{
								bootbox.confirm(LengStr.idMSG106, 
								function(result)
								{
									if (result)
									{						
										Eliminar_Beneficiario();
									}	
								});
							}
							else
							{
								//showmessage('Deberá de marcar los registros a eliminar', '', undefined, undefined, function onclose(){});
								showalert(LengStr.idMSG105, "", "gritter-info");
							}
							event.preventDefault();
						}
					},
					{
						icon:"icon-edit orange bigger-140",	
						title:'Editar Beneficiario',
						click: function(event)
						{
							if(sel_idbeneficiario==0){
								showalert(LengStr.idMSG104, "", "gritter-info");
							}else{
								Editar_Beneficiario();
							}
							event.preventDefault();
						}
					}			
			]
		});
		setSizeBtnGrid('id_button0',35);
		setSizeBtnGrid('id_button1',35);
		
		function setSizeBtnGrid(id,tamanio){
		  $("#"+id).attr('width',tamanio+'px');
		  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
		}
	}
	
//--ELIMINAR BENEFICIARIO
	function Eliminar_Beneficiario(){
		$.ajax({
			type: "POST", 
			url:'ajax/json/json_fun_eliminar_beneficiarios_estudios.php?',
			data: { 
				'iconfig':sel_idu_configuracion,
				'session_name': Session
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);	
				if(dataJson.estado == 0){
					Cargargrid();
					LimpiarBeneficiarios();	
					showalert(dataJson.mensaje, "", "gritter-info");				
				}
			},
				error:function onError(){},
				complete:function(){},
				timeout: function(){},
				abort: function(){}		
		});
	}
	
//--EDITAR BENEFICIARIO
	function Editar_Beneficiario(){
		//showalert(sel_rfc_escuela, "", "gritter-info");
		$("#txt_RFC").val(sel_rfc_escuela);
		$("#txt_idconfig").val(sel_idu_configuracion);
		$("#txt_clv_ben").val(sel_idbeneficiario);
		$("#txt_tipo_ben").val(sel_tipo_beneficiario);
		//$("#cbo_Beneficiario").val(sel_idbeneficiario);
		var Beneficiario="<option parentesco='0' value='0'>"+sel_nom_beneficiario+"</option>";
		$("#cbo_Beneficiario").html(Beneficiario);
		$("#cbo_Beneficiario").prop('disabled',true);		
		iCarrera=sel_idu_carrera;
		CargarEscuelas();
		/*CargarEscuelas( function()
		{
			CargarEscolaridades(function(){
				CargarLocalidadesAgregar();
			});
		});*/
	}
	
//--BOTON AGREGAR ESCUELA		
	$('#btn_AgregarEscuela').click(function(event){	
		//$("#txt_NombreBusqueda").val("");
		/*CargarEstadosAgregar(function()
		{
			CargarCiudadesAgregar(function(){
				CargarLocalidadesAgregar();
			});
		});*/
		if ($("#fileXml").val() == '') {
			showalert("Proporcione un archivo XML", "", "gritter-info");
			$("#fileXml").focus();
			$( '#fileXml' ).ace_file_input('reset_input');
			$("#txt_RFC").val('');
			return;
		}
		$("#dlg_AgregarEscuelas").modal('show');
		$("#dlg_AgregarEscuelas").draggable();
		limpiarDatosModal_AgregarEscuela();
		$("#txt_rfc_escuela").val($("#txt_RFC").val());
		//$("#txt_razon_social").val($("#txt_NomEscuela").val());
		sRazonSocial=sRazonSocial.replace('/^\s+|\s+$/g', '');
		if(sRazonSocial=='') {			
			$("#txt_nombre_escuela").prop("disabled", false);
			$("#txt_razon_social").prop("disabled", false);
		}else{
			$("#txt_nombre_escuela").val(sRazonSocial);
			$("#txt_nombre_escuela").prop("disabled", true);		
			$("#txt_razon_social").prop("disabled", true);
		}
		$("#txt_razon_social").val(sRazonSocial);
		CargarEstadosAgregar(function()
		{
			CargarCiudadesAgregar(function(){
				CargarLocalidadesAgregar();
			});
		});
		CargarEscolaridadesEscuelaNueva();
		
		//
		$("#cbo_Ciudad_Agregar").prop("disabled", true);
		$("#cbo_Localidad_Agregar").prop("disabled", true);
		event.preventDefault();	
	});
	
//--BOTON GUARDAR ESCOLARIDAD
	$('#btn_GuardarEscolaridad').click(function(event){	
		a=$("#cbo_Agrega_Escolaridad").val();
		if 	(a==0){
			showalert("Favor de seleccionar escolaridad", "", "gritter-info");
		}else{
			GuardarNuevaEscolaridad()	
		}
		
		event.preventDefault();	
	});		
	
	//--GUARDAR ESCOLARIDAD NUEVA
	function GuardarNuevaEscolaridad()
	{		
		//console.log('escuela');		
		$.ajax({
		type: "POST",
			data: {
				'session_name':	Session, 
				'cRFCescuela':$('#txt_RFC').val(),
				'iestado':$("#cbo_Escuela").children(":selected").attr("iestado"),
				'imunicipio':$("#cbo_Escuela").children(":selected").attr("imunicipio"),
				'ilocalidad':$("#cbo_Escuela").children(":selected").attr("ilocalidad"),
				'iescolaridad':$("#cbo_Agrega_Escolaridad").val(),
				'snombre': sNombre.toUpperCase(),
				//'icarrera':$("#cbo_Agrega_Carrera").val(),
				'iescuela': 0
			},
		url: 'ajax/json/json_fun_grabar_escolaridad_nueva_escuela.php'
		})
		.done(function(data){
			json = json_decode(data);
			//estado =0 'registro guardado', =1'La escuela ya existe'
			if(json.estado==0)
			{		
				$("#dlg_AgregarEscolaridad").modal('hide');
				CargarEscolaridades();
			}
			else if(json.estado==1)	
			{
				showalert(json.mensaje, "", "gritter-success");
			}						
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG230+" la escuela", "", "gritter-error");
		})
		.always(function() {});			
	}
	
	$('#dlg_AgregarEscolaridad').on('hide.bs.modal', function (event) {		
		$("#cbo_Escolaridad").val(0);
		$("#cbo_Escolaridad").trigger("chosen:updated");		
		// event.preventDefault();	
	});
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--AGREGAR ESCUELA
	/*CargarEstadosAgregar(function()
	{
		CargarCiudadesAgregar(function(){
			CargarLocalidadesAgregar();
		});
	});*/
	
	
	//ESTADOS AGREGAR ESCUELA
	$("#cbo_Estado_Agregar").trigger("chosen:updated");
	function CargarEstadosAgregar(callback)
	{	
		$("#cbo_Estado_Agregar").html("");
		$.ajax({
			type: "POST", 
			url: "ajax/json/json_fun_obtener_estados_escolares.php",
			data: {
			},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0)
				{
					var option = "<option value='0'>SELECCIONE</option>";
					for(var i=1;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].numero + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					$("#cbo_Estado_Agregar").html(option);
					$("#cbo_Estado_Agregar").chosen({no_results_text:"NO SE ENCUENTRA: ", width:'220px'});
					$("#cbo_Estado_Agregar").trigger("chosen:updated");			
				}else{
					showalert(LengStrMSG.idMSG88+" los estados", "", "gritter-warning");
				}
			},
			error:function onError(){callback();},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}
		});
	}
	
	//CIUDADES AGREGAR ESCUELA
	$("#cbo_Ciudad_Agregar").trigger("chosen:updated");
	function CargarCiudadesAgregar(callback)
	{
		$("#cbo_Ciudad_Agregar").html("");
		$.ajax({
			type: "POST", 
			url: "ajax/json/json_fun_obtener_municipios_escolares.php?",
			data: {
				'iEstado':iEstadoAgregar //$("#cbo_Estado_Agregar").val()
			},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);	
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0)
				{
					var option = "<option value='0'>SELECCIONE</option>";
					val_estado=$("#cbo_Estado_Agregar").val();
					if (val_estado>0) {
						for(var i=0;i<dataJson.datos.length; i++)
						{
							option = option + "<option value='" + dataJson.datos[i].numero + "'>" + dataJson.datos[i].nombre + "</option>"; 
						}
					}else{
						for(var i=1;i<dataJson.datos.length; i++)
						{
							option = option + "<option value='" + dataJson.datos[i].numero + "'>" + dataJson.datos[i].nombre + "</option>"; 
						}
					}
						$("#cbo_Ciudad_Agregar").html(option);
						$("#cbo_Ciudad_Agregar").chosen({no_results_text:"NO SE ENCUENTRA: ", width:'220px'});
						$("#cbo_Ciudad_Agregar").trigger("chosen:updated");					
				}
				else
				{
					showalert(LengStrMSG.idMSG88+" las ciudades", "", "gritter-warning");
				}
			},
			error:function onError(){callback();},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}
		});		
	}
	
	//COMBO LOCALIDAD
	$("#cbo_Localidad_Agregar").trigger("chosen:updated");
	function CargarLocalidadesAgregar(){
		$("#cbo_Localidad_Agregar").html("");
		 $.ajax({
			type: "POST",
			url: "ajax/json/json_fun_obtener_localidades_escolares.php?",
			data:{
				'iMunicipio' : iCiudadAgregar, //$("#cbo_Ciudad_Agregar").val(),
				'iEstado' : iEstadoAgregar //$("#cbo_Estado_Agregar").val()
			},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0) {
					var option = "<option value='0'>SELECCIONE</option>";
					val_estado=$("#cbo_Estado_Agregar").val();
					if (val_estado>0) {
						for(var i=0;i<dataJson.datos.length; i++){
							option = option + "<option value='" + dataJson.datos[i].numero + "'>" + dataJson.datos[i].nombre + "</option>";
						}
					}else{
						for(var i=1;i<dataJson.datos.length; i++){
							option = option + "<option value='" + dataJson.datos[i].numero + "'>" + dataJson.datos[i].numero + " " + dataJson.datos[i].nombre + "</option>";
						}
					}
					$("#cbo_Localidad_Agregar").html(option);
					$("#cbo_Localidad_Agregar").chosen({no_results_text:"NO SE ENCUENTRA: ", width:'220px'});
					$("#cbo_Localidad_Agregar").trigger("chosen:updated");
				}else{
					showalert(LengStrMSG.idMSG88+ " las localidades", "", "gritter-error");
				}
			},
			error:function onError(){},
			complete: function(){},
			timeout: function(){},
			abort: function(){}
		 });
	}
	
	//ESTADO AGREGAR ESCUELA
	$("#cbo_Estado_Agregar").change(function(){
		//$("#cbo_Ciudad").val(0);		
		$("#cbo_Ciudad_Agregar").val($("#cbo_Ciudad option").first().val());
		$("#cbo_Ciudad_Agregar").trigger("chosen:selected");
		$("#cbo_Localidad_Agregar").val($("#cbo_Localidad option").first().val());
		$("#cbo_Localidad_Agregar").trigger("chosen:selected");
		iEstadoAgregar=DOMPurify.sanitize($("#cbo_Estado_Agregar").val());
		iCiudadAgregar=0;
		CargarCiudadesAgregar(function(){
			CargarLocalidadesAgregar();
		});
		
		$("#cbo_Ciudad_Agregar").prop("disabled", false);
		
		
	});
	
	//CIUDAD AGREGAR ESCUELA
	$("#cbo_Ciudad_Agregar").change(function(){
		iCiudadAgregar=DOMPurify.sanitize($("#cbo_Ciudad_Agregar").val());
		CargarLocalidadesAgregar();
		$("#cbo_Localidad_Agregar").prop("disabled", false);
	});
	
	//ESCOLARIDAD
	$("#cbo_Escolaridad_Agregar").trigger("chosen:updated");
	function CargarEscolaridadesEscuelaNueva(){
		$("#cbo_Escolaridad_Agregar").html("");
		 $.ajax({
			type: "POST",			
			url: "ajax/json/json_fun_obtener_listado_escolaridades_combo.php",
			data:{
				'iEscuela':0,
			},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0) {
					var option = "<option value='0'>SELECCIONE</option>";					
					
					for(var i=0;i<dataJson.datos.length; i++){
						option = option + "<option opc_carrera='" + dataJson.datos[i].opc_carrera + "' value='" + dataJson.datos[i].idu_escolaridad + "'>" + dataJson.datos[i].nom_escolaridad + "</option>";
					}
					
					$("#cbo_Escolaridad_Agregar").html(option);
					$("#cbo_Escolaridad_Agregar").chosen({no_results_text:"NO SE ENCUENTRA: ", width:'220px'});
					$("#cbo_Escolaridad_Agregar").trigger("chosen:updated");
				}else{
					showalert(LengStrMSG.idMSG88+ " las escolaridades", "", "gritter-error");
				}
			},
			error:function onError(){},
			complete: function(){},
			timeout: function(){},
			abort: function(){}
		 });
	}

	//BOTON GUARDAR ESCUELA
	$('#btn_GuardarEscuela').click(function(event){
		//alert ('guarda datos');
		Valida_GuardarActualizar();
	});
	
	//VALIDA GUARDAR ESCUELA
	function Valida_GuardarActualizar(){		
		nom_escuela=$('#txt_nombre_escuela').val();
		nom_escuela=nom_escuela.replace('/^\s+|\s+$/g', '');
		razon_social = $("#txt_razon_social").val().replace('/^\s+|\s+$/g', '');
		clave_sep = $("#txt_clave_sep").val().replace('/^\s+|\s+$/g', '');
		// var quitar = /"|'|*/g;
		var quitar = /~|[|\|\|\|\|/|:|*|?|"|<|>|]|~|'|,|¿|/g;
		nom_escuela = nom_escuela.replace(quitar,'');
		razon_social = razon_social.replace(quitar,'');
		clave_sep = clave_sep.replace(quitar,'');
		// console.log(nom_escuela);
		// return;
		
		rfc=$('#txt_rfc_escuela').val();
		rfc=rfc.replace('/^\s+|\s+$/g', '');
		// console.log('Escuela: '+nom_escuela.toUpperCase());
		// return;
		if ( $("#cbo_Estado_Agregar").val() == 0 ) {	
			showalert(LengStrMSG.idMSG146, "", "gritter-info");			
			$("#cbo_Estado_Agregar").focus();
			return false;			
		} else if ( $("#cbo_Ciudad_Agregar").val() == 0 ) {	
			showalert(LengStrMSG.idMSG147, "", "gritter-info");
			$("#cbo_Ciudad_Agregar").focus();
			return false;			
		} else if($("#cbo_Localidad_Agregar").val() == 0){			
			showalert("Seleccione la localidad a la que corresponde la Escuela","","gritter-info");
			$("#cbo_Localidad_Agregar").focus();
			return false;		
		}else if (nom_escuela.length == 0){			
			showalert(LengStrMSG.idMSG149, "", "gritter-info");	
			return false;
		}else if (rfc.length == 0){			
			showalert(LengStrMSG.idMSG148, "", "gritter-info");	
			return false;
		} else if($("#cbo_Escolaridad_Agregar").val() == 0){			
			showalert("Seleccione escolaridad de la Escuela","","gritter-info");
			$("#cbo_Escolaridad_Agregar").focus();
			return false;		
		} else if ( !isValidPhoneNumber( $("#txt_telefono").val() ) ) {
			showalert("Proporcione un teléfono a 10 dígitos con clave Lada", "", "gritter-info");
			return false;
		} else if ( !isValidEmailAddress( $("#txt_email_contacto").val()) ) {
			showalert("Proporcione correo válido", "", "gritter-info");
			return false;
		}else{		
			$.ajax({
			type: "POST",
				data: {
					'session_name':		Session, 
					'opc_tipo': 		2,
					// 'nombre_escuela':	$('#txt_nombre_escuela').val().replace('/^\s+|\s+$/g', '').toUpperCase(),
					'nombre_escuela' :  nom_escuela.toUpperCase(),
					// 'razon_social':		$('#txt_razon_social').val().replace('/^\s+|\s+$/g', '').toUpperCase(),
					'razon_social':		razon_social.replace('/^\s+|\s+$/g', '').toUpperCase(),
					'rfc_clv_sep':		$('#txt_rfc_escuela').val().toUpperCase(),
					// 'clave_sep':		$('#txt_clave_sep').val().replace('/^\s+|\s+$/g', '').toUpperCase(),
					'clave_sep':		clave_sep.replace('/^\s+|\s+$/g', '').toUpperCase(),
					'iEstado':			$("#cbo_Estado_Agregar").val(),
					'iMunicipio': 		$("#cbo_Ciudad_Agregar").val(), 
					'iLocalidad':		$("#cbo_Localidad_Agregar").val(),
					'nombre_contacto':	$('#txt_contacto').val().replace('/^\s+|\s+$/g', '').toUpperCase(),  	
					'email_contacto':	$('#txt_email_contacto').val().replace('/^\s+|\s+$/g', '').toUpperCase(),
					'iEscolaridad':     $("#cbo_Escolaridad_Agregar").val(), 
					'telefono':			$('#txt_telefono').val().replace('/^\s+|\s+$/g', ''), 
					'extension':		$('#txt_extension').val().replace('/^\s+|\s+$/g', '').toUpperCase(),  
					'area_contacto':	$('#txt_area').val().replace('/^\s+|\s+$/g', '').toUpperCase()
				},
			url: 'ajax/json/json_fun_grabar_escuelas_colegiaturas.php'
			})
			.done(function(data){
				json = json_decode(data);
				//estado =0 'registro guardado', =1'La escuela ya existe'
				if(json.estado==0)
				{							
					showalert(json.mensaje, "", "gritter-success");
					$("#txt_idEscuela").val(json.id_escuela);
					$("#txt_escuelaSeleccion").val($('#txt_nombre_escuela').val().toUpperCase());
					$("#txt_NomEscuela").val($("#txt_nombre_escuela").val());
					$("#dlg_AgregarEscuelas").modal('hide');
					//CargarEscolaridadesEscuelaNueva();					
					//CargarEscolaridades(0);
					//CargarEscolaridadesEscuelaNueva();
					limpiarDatosModal_AgregarEscuela();
					CargarEscuelas();
				}
				else if(json.estado==1)	
				{
					showalert(json.mensaje, "", "gritter-success");
				}						
			})
			.fail(function(s) {
				showalert(LengStrMSG.idMSG230+" la escuela", "", "gritter-error");
			})
			.always(function() {});
		}	
	}
	
	//--LIMPIAR DATOS MODAL	
	function limpiarDatosModal_AgregarEscuela(){
		//console.log('estado cambia a cero');		
		$("#cbo_Estado_Agregar").val('');
		$("#cbo_Ciudad_Agregar").val('');
		$("#cbo_Localidad_Agregar").val('');	
		$("#cbo_Escolaridad_Agregar").val('');
		$("#txt_nombre_escuela").val('');
		$("#txt_telefono").val('');
		$("#txt_email_contacto").val('');
		$("#txt_contacto").val('');
		$("#txt_area").val('');
		$("#txt_extension").val('');
		$("#txt_clave_sep").val('');
		$("#txt_razon_social").val('');		
	}
	
	$("#dlg_AgregarEscuelas").on("show.bs.modal", function () {
		var top = $("body").scrollTop(); $("body").css('position','fixed').css('overflow','hidden').css('top',-top).css('width','100%').css('height',top+5000);
	}).on("hide.bs.modal", function () {
		var top = $("body").position().top; $("body").css('position','relative').css('overflow','auto').css('top',0).scrollTop(-top);
	});

	function ConsultaClaveHCM(){
        $.ajax({type: "POST", 
            url:'ajax/json/json_proc_consultaropcionesapagado_hcm.php',
            data: {                 
                'iOpcion': 389
            }
        })
        .done(function(data){
            var dataS = limpiarCadena(data)
			var dataJson = JSON.parse(dataS);
            FlagHCM = dataJson.clvApagado;
            MensajeHCM = dataJson.mensaje;

            if(FlagHCM == 1){
                loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:MensajeHCM}});
            }
        }); 
        
        
    }
	
});	