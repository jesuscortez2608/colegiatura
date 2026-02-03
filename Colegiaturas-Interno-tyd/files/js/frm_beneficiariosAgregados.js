$(function(){
	setTimeout(function(){
		inicio();
	}, 0);
	
	function inicio() {
		jQuery("#gridBeneficiariosAgregados-table").jqGrid({
			url:'ajax/json/',
			datatype: 'json',
			mtype: 'POST',
			colNames:LengStr.idMSG7,
					colModel:[
					{name:'Beneficiario',index:'Beneficiario', width:90, sortable: false,align:"center",fixed: true},
					{name:'Parentesco',index:'Parentesco', width:100, sortable: false,align:"left",fixed: true},
					{name:'Escolaridad',index:'Escolaridad', width:120, sortable: false,align:"left",fixed: true},
					{name:'Tipo Pago',index:'Tipo Pago', width:100, sortable: false,align:"left",fixed: true},
					{name:'Periodo',index:'Periodo', width:120, sortable: false,align:"left",fixed: true},
					],
			scrollrows : true,
			viewrecords : false,
			rowNum:-1,
			hidegrid: false,
			rowList:[],
			width: null,
			shrinkToFit: false,
			height: 200,
			//----------------------------------------------------------------------------------------------------------
			caption: 'Beneficiarios Agregados',
			pgbuttons: false,
			pgtext: null,
			postData:{session_name:Session},
			loadComplete: function (Data) {
			},
			onSelectRow: function(Numemp)
			{			
				var Data = jQuery("#gridBeneficiariosAgregados-table").jqGrid('getRowData',Numemp);
				Numemp =Data.Numemp;
			},					
		});
	}	
});