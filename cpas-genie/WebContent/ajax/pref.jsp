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
	<td>Tab to Space</td>
	<td><input id="tabToSpace" name="tabToSpace" size="10" value="<%= cn.tabToSpace %>"></td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td>
		<input id="saveButton" type="button" value="Save" onclick="savePref()">
	</td>
</tr>
</table>

</form>

<script type="text/javascript">
<!--
function savePref() {
	var val = $("#qry_rows").val();
	//alert(val);

	$.ajax({
		type: 'POST',
		url: "ajax/save-pref.jsp",
		data: $("#form0").serialize(),
		success: function(data){
			//$("#qry_rows").val('200');
		},
        error:function (jqXHR, textStatus, errorThrown){
            alert(jqXHR.status + " " + errorThrown);
        }  
	});	
	
	
}
//-->
</script>
