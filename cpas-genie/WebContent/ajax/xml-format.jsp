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

<form id="form0" name="form0">
<table>
<tr>
	<td><textarea id="xml" name="xml" cols=80 rows=10></textarea></td>
</tr>
<tr>
	<td>
		<input id="saveButton" type="button" value="Format" onclick="formatXml()">
	</td>
</tr>
</table>

</form>


<form id="form0" name="form0">
<table>
<tr>
<td><textarea id="formattedXml" name="formattedXml" cols=80 rows=10></textarea></td>
</tr>
</table>

</form>


<script type="text/javascript">
<!--
function formatXml() {
	$.ajax({
		type: 'POST',
		url: "ajax/format-xml.jsp",
		data: $("#form0").serialize(),
		success: function(data){
			$("#formattedXml").html(data);
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
	
	
}
//-->
</script>
