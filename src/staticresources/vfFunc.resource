function next(){
   var start = $(".startVariable").val();
   var end = $(".endVariable").val();
   
   var newStart = parseInt(start) + 20;
   var newEnd = parseInt(end) + 20;
   
   $(".startVariable").val(newStart);
   $(".endVariable").val(newEnd);
   
   showRecords();
}

function resetVariables(){
   $(".startVariable").val('0');
   $(".endVariable").val('20');
}

function previous(){
   var start = $(".startVariable").val();
   var end = $(".endVariable").val();
   
   var newStart = parseInt(start) - 20;
   var newEnd = parseInt(end) - 20;
   
   $(".startVariable").val(newStart);
   $(".endVariable").val(newEnd);
   
   showRecords();
}

function startRow(x){
   var letter = x;
   var bool = 'false';
   
   $( ".rowrow" ).each(function() {
	   if($( this ).attr("id") == letter && bool == 'false'){
		   $(".startVariable").val($( this ).data("rowno"));
		   bool = 'true';
		   var newEnd = parseInt($( this ).data("rowno")) + 20;
		   $(".endVariable").val(newEnd);
	   }
   });
}

function showRecords(){
   var start = $(".startVariable").val();
   var end = $(".endVariable").val();
   
   $( ".rowrow" ).each(function() {
	   if($( this ).data("rowno") >= start && $( this ).data("rowno") <= end){
		   $( this ).show();
	   }else{
		   $( this ).hide();
	   }
   });
   
   if({!opps.size} <= 20){
	   $(".nextBtn").hide();
	   $(".previousBtn").hide();
   }else if(start == '0'){
	   $(".previousBtn").hide();
	   $(".nextBtn").show();
   }else if(end >= {!opps.size}){
	   $(".nextBtn").hide();
	   $(".previousBtn").show();
   }else{
	   $(".nextBtn").show();
	   $(".previousBtn").show();
   }
}
function afterListView(){
   resetVariables();
   showRecords();
   init();
}