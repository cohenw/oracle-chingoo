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
function startSearchTrigger() {
	var key = $("#searchKey").val();
	if ($.trim(key) == "") {
		alert("Please enter search keyword");
		return;
	}
	
	$("#startButton").attr("disabled", true);
	$("#cancelButton").attr("disabled", false);
	
	$("#searchResult").html("Searching...");
	$("#searchResult").append("<div id='wait'><img src='image/loading.gif'/></div>");
	$("#progressDiv").show();
	
	$.ajax({
		type: 'POST',
		url: "ajax/search-trigger.jsp",
		data: $("#form0").serialize(),
		success: function(data){
			$("#searchResult").html(data);
			$("#wait").remove();
			checkProgressTrigger();
			readySearchTrigger();
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
	setTimeout('checkProgressTrigger()', 1000);
}

function checkProgressTrigger() {
	clearTimeout(to2);
	var current = $("#searchProgress").html();
	$.ajax({
		type: 'POST',
		url: "ajax/search-progress-trigger.jsp",
		success: function(data){
			if (current != data) {
    			$("#searchProgress").html(data);
			}
			var idx = data.indexOf("Finished ");
			if (data.indexOf("Finished ") < 0) {
				to2 = setTimeout("checkProgressTrigger()",1000);
			}
			
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	    	
}	

function cancelSearchTrigger() {
	clearTimeout(to2);
	$.ajax({
		type: 'POST',
		url: "ajax/cancel-search-trigger.jsp",
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

function readySearchTrigger() {
	$("#startButton").attr("disabled", false);
	$("#cancelButton").attr("disabled", true);
	clearTimeout(to2);
}

</script>

<form id="form0" name="form0">
<table>
<tr>
	<td>Search For</td>
	<td><input id="searchKey" name="searchKey" size="30"> (in trigger body)</td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td>
		<input id="startButton" type="button" value="Start Search" onclick="startSearchTrigger()">
		<input id="cancelButton" type="button" disabled=true value="Stop" onclick="cancelSearchTrigger()">
	</td>
</tr>
</table>

</form>

<div id="progressDiv" style="display: none; margin-left: 40px; border: 1px solid #D9D9D9; width: 400px; height: 200px; overflow: auto;">
	<div id="searchProgress"></div>
</div>

<br/><br/>
<div id="searchResult">
</div>


<br clear=all>

<form id="form_qry" target=_blank method="post" action="query.jsp">
<input id="sql" name="sql" value="" style="display: none;">
</form>
