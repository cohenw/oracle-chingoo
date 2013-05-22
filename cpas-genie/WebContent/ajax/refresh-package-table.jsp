<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
%>

<script type="text/javascript">
function startWork() {
	$("#startButton").attr("disabled", true);
	$("#cancelButton").attr("disabled", false);

	$("#searchResult").html("Working...");
	$("#searchResult").append("<div id='wait'><img src='image/loading.gif'/></div>");
	$("#progressDiv").show();
	
	$.ajax({
		type: 'POST',
		url: "ajax/package-table.jsp",
		data: $("#form0").serialize(),
		success: function(data){
			$("#searchResult").html(data);
			$("#wait").remove();
			checkProgress();
			readyWork();
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
	setTimeout('checkProgress()', 1000);
}

function checkProgress() {
	clearTimeout(to2);
	var current = $("#workProgress").html();
	$.ajax({
		type: 'POST',
		url: "ajax/package-progress.jsp",
		success: function(data){
			if (current != data) {
    			$("#workProgress").html(data);
			}
			var idx = data.indexOf("Finished ");
			if (data.indexOf("Finished ") < 0) {
				to2 = setTimeout("checkProgress()",1000);
			}
			
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	    	
}	

function cancelWork() {
	clearTimeout(to2);
	$.ajax({
		type: 'POST',
		url: "ajax/cancel-package.jsp",
		data: $("#form0").serialize(),
		success: function(data){
			checkProgressView();
			readySearchView();
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
}    

function readyWork() {
	$("#startButton").attr("disabled", false);
	$("#cancelButton").attr("disabled", true);
	clearTimeout(to2);
}
</script>

<form id="form0" name="form0">
<table>
<tr>
	<td>This process will create Package / Procedure / Table relationship in the following tables.<br>
	GENIE_PA : Package and timestamp<br>
	GENIE_PA_PROCEDURE : Package / Procedure info<br>
	GENIE_PA_TABLE : Package / Procedure / Table CRUD info<br>
	GENIE_PA_DEPENDENCY : Package / Procedure dependencies</td>
</tr>
<tr>
	<td>&nbsp;</td>
</tr>
<tr>
	<td>
		<input id="startButton" type="button" value="Start" onclick="startWork()">
		<input id="cancelButton" type="button" disabled=true value="Stop" onclick="cancelWork()">
	</td>
</tr>
</table>

</form>

<div id="progressDiv" style="display: none; margin-left: 40px; border: 1px solid #D9D9D9; width: 400px; height: 200px; overflow: auto;">
	<div id="workProgress"></div>
</div>

<br/><br/>
<div id="workResult">
</div>


<br clear=all>

<form id="form_qry" target=_blank method="post" action="query.jsp">
<input id="sql" name="sql" value="" style="display: none;">
</form>