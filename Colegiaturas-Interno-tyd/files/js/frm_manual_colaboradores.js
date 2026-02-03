
setTimeout(function(){
	ConsultaClaveHCM();
	generarPdf();
}, 50);

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

function generarPdf(){
	// Par�metros del reporte
	// Se agrega ?1500 para que se obtenga siempre la �ltima versi�n
	// ---------------------------------------------------------------
	var sNombreArchivo = 'ManualColegiaturasColaboradores.pdf';	
	var report_url = "files/manuales/" + sNombreArchivo;
	var params = "?1500";
	
	var xhr = new XMLHttpRequest();
	xhr.responseType = "blob";
	
	
	xhr.open("POST", report_url, true);
	xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	
	xhr.addEventListener("progress", function (evt) {
		if(evt.lengthComputable) {
			var percentComplete = evt.loaded / evt.total;
			console.log(percentComplete);
		}
	}, false);
	
	xhr.onreadystatechange = function() {
		if(this.readyState == XMLHttpRequest.DONE && this.status == 200) {
			var filename = sNombreArchivo;
			
			var link = document.createElement('a');
			link.href = window.URL.createObjectURL(xhr.response);
			link.download = filename;
			link.style.display = 'none';
			
			document.body.appendChild(link);
			
			link.click();
			
			document.body.removeChild(link);
			
			document.getElementsByClassName("page-content").innerHTML = "";
			document.getElementsByClassName("breadcrumbs").innerHTML = "";
		}
	}
	
	xhr.send(params);
}

function ConsultaClaveHCM(){
    $.ajax({type: "POST", 
        url:'ajax/json/json_proc_consultaropcionesapagado_hcm.php',
        data: {                 
            'iOpcion': 399
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