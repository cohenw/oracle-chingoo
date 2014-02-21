<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<script type="text/javascript">
	function getMember() {
		var clnt = $("#clnt").val();
		var mkey = $("#mkey").val();
		
		$("#cloneResult").html("");
		$("#memberArea").html();
		$("#mkeyArea").hide();
		$("#down_button").hide();
		
//		$("#memberArea").html(clnt+" " + mkey);
		
		// AJAX load
		$.ajax({
			url: "ajax/get-member.jsp?clnt=" + clnt + "&mkey=" + mkey + "&t=" + (new Date().getTime()),
			success: function(data){
				$("#memberArea").html(data);
				$("#mkeyArea").show();
				$("#down_button").show();
			},
            error:function (jqXHR, textStatus, errorThrown){
                alert(jqXHR.status + " " + errorThrown);
            }  
		});

		
	}

	function getMemberScript() {
		var clnt = $("#clnt").val();
		var mkey = $("#mkey").val();
		var eid = clnt + "_" + mkey;
		var fname = "C" + clnt + "_M" + mkey + ".member";
		
		$("#eid").val(eid);
		$("#fname").val(fname);
		$("#form_down").submit();
	}

	function cloneMember() {
		var clnt = $("#clnt").val();
		var mkey = $("#mkey").val();
		var newmkey = $("#newmkey").val();
		
		$("#cloneResult").html("<img src='image/waiting_big.gif'>");
		// AJAX load
		$.ajax({
			url: "ajax/clone-member-job.jsp?clnt=" + clnt + "&mkey=" + mkey + "&newmkey=" + newmkey +"&t=" + (new Date().getTime()),
			success: function(data){
				$("#cloneResult").html(data);
			},
            error:function (jqXHR, textStatus, errorThrown){
                alert(jqXHR.status + " " + errorThrown);
            }  
		});

		
	}
	
</script>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	String q = "SELECT CLNT, MKEY FROM CALC WHERE CALCID=(SELECT MAX(CALCID) FROM CALC)";
	List<String[]> lst = cn.query(q);
	String clnt = "";
	String mkey = "";
	
	if (lst.size()>0) {
		clnt = lst.get(0)[1];
		mkey = lst.get(0)[2];
	}
%>


<form>
<b>CLNT</b> <input name="clnt" id="clnt" value="<%= clnt %>" size=4>
<b>MKEY</b> <input name="mkey" id="mkey" value="<%= mkey %>" size=10>
<input type="button" value="Get Member" onClick="getMember()">
<input id="down_button" type="button" value="Download Script" onClick="getMemberScript()" style="display:none;">

<br/>
<div id="memberArea" style="margin-left: 20px;"></div>

<br/>
<div id="mkeyArea" style="display: none;">
<b>NEW MKEY</b> <input name="newmkey" id="newmkey" size=10>
<input type="button" value="Clone Member" onClick="cloneMember()">
</div>
</form>
<div id="cloneResult" style="margin-left: 20px;"></div>

<form id="form_down" target="_blank" action="cpas-extract.jsp">
<input name="id" id="eid" type="hidden">
<input name="fname" id="fname" type="hidden">
<input name="type" value="MEMBER" type="hidden">
</form>