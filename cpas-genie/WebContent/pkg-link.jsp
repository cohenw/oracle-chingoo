<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	int counter = 0;
	Connect cn = (Connect) session.getAttribute("CN");

	String name = request.getParameter("name");
	String pkg=null;
	String prc=null;
	if (name != null && !name.equals("")) {
		int idx = name.indexOf(".");
		pkg = name.substring(0,idx).toUpperCase();
		prc = name.substring(idx+1).toUpperCase();
	}
	
	String q = "SELECT TABLE_NAME, OP_SELECT, OP_INSERT, OP_UPDATE, OP_DELETE FROM GENIE_PA_TABLE WHERE PACKAGE_NAME='" + pkg +"' AND PROCEDURE_NAME='" + prc + "' ORDER BY table_name";
//	System.out.println(q);
	List<String[]> list = cn.query(q, false);

	q = "SELECT TARGET_PKG_NAME, TARGET_PROC_NAME FROM GENIE_PA_DEPENDENCY WHERE PACKAGE_NAME='" + pkg +"' AND PROCEDURE_NAME='" + prc + "' ORDER BY DECODE(TARGET_PKG_NAME,'" + pkg + "','0',TARGET_PKG_NAME), 2";
	System.out.println(q);
	List<String[]> proc1 = cn.query(q, false);

	q = "SELECT PACKAGE_NAME, PROCEDURE_NAME FROM GENIE_PA_DEPENDENCY WHERE TARGET_PKG_NAME='" + pkg +"' AND TARGET_PROC_NAME='" + prc + "' ORDER BY DECODE(PACKAGE_NAME,'" + pkg + "','0',PACKAGE_NAME), 2";
	System.out.println(q);
	List<String[]> proc2 = cn.query(q, false);
%>


<html>
<head> 
	<title><%= name %></title>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 

    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    <script src="script/data-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>

	<style>
	.ui-autocomplete-loading { background: white url('image/ui-anim_basic_16x16.gif') right center no-repeat; }
.ui-autocomplete {
		max-height: 500px;
		overflow-y: auto;
		/* prevent horizontal scrollbar */
		overflow-x: hidden;
		/* add padding to account for vertical scrollbar */
		padding-right: 20px;
	}
	/* IE 6 doesn't support max-height
	 * we use height instead, but this forces the menu to always be this tall
	 */
	* html .ui-autocomplete {
		height: 500px;
	}	
	</style>
	    
    <script>
	$(function() {
		$( "#globalSearch" ).autocomplete({
			source: "ajax/auto-complete2.jsp",
			minLength: 2,
			select: function( event, ui ) {
				popObject( ui.item ?
					ui.item.value: "" );
			}
		}).data( "autocomplete" )._renderItem = function( ul, item ) {
			return $( "<li></li>" )
			.data( "item.autocomplete", item )
			.append( "<a>" + item.label + " <span class='rowcountstyle'>" + item.desc + "</span></a>" )
			.appendTo( ul );
		};
	});	

	function popObject(oname) {
//		alert(oname);
		$("#popKey").val(oname);
    	$("#FormPop").submit();
	}
	    
	function toggleData(id) {
		var key = $("#key-" + id).html();
		var divName = "div-" + id;
		
		var imgSrc = $("#img-" + id).attr("src");
		//alert(imgSrc);
		if (imgSrc.indexOf("plus") > 0) {
			$("#img-" + id).attr("src","image/minus.gif");
		} else {
			$("#img-" + id).attr("src","image/plus.gif");
			$("#" + divName).slideUp();
			return;
		}

		if ($("#" + divName).html().length > 3){
    		$("#" + divName).slideDown();
    		return;
    	}
		
		$("#key").val(key);
		$("#id").val(id);
		$("#" + divName).hide();
		$.ajax({
			type: 'POST',
			url: "ajax-cpas/pkg-proc-detail.jsp",
			data: $("#form0").serialize(),
			success: function(data){
				$("#" + divName).html(data);
				$("#" + divName).slideDown();
				//alert(data);
			},
            error:function (jqXHR, textStatus, errorThrown){
                alert(jqXHR.status + " " + errorThrown);
            }  
		});	
		
	}

    </script>
    
</head> 

<body>
<div style="background-color: #ffffff;">
<img src="image/star-big.png" align="middle"/>

 <b>PACKAGE LINK</b>
&nbsp;&nbsp;
<%= cn.getUrlString() %>

&nbsp;&nbsp;&nbsp;&nbsp;

<a href="Javascript:hideNullColumn()">Hide Null</a> |
<a href="Javascript:showAllColumn()">Show All</a> |
<a href="Javascript:newQry()">Pop Query</a> |
<a href="query.jsp" target="_blank">Query</a> |
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<!-- <a href="Javascript:openWorksheet()">Open Work Sheet</a>
 -->
Search <input id="globalSearch" style="width: 200px;" placeholder="table or view name"/>
</div>

<%
	String id = Util.getId();
%>

<h2><%= name %>
<a target=_blank href="src2.jsp?name=<%= pkg %>#<%= prc.toLowerCase() %>"><img border="0" src="image/sourcecode.gif" title="Source code"></a>
</h2> 
<br/>

<div style="margin-left: 20px;">
<%
	for (int i=0;i<list.size();i++) {
		String tname = list.get(i)[1];
		String op = "";
		String opS = list.get(i)[2];
		String opI = list.get(i)[3];
		String opU = list.get(i)[4];
		String opD = list.get(i)[5];
		
		if (opI.equals("1")) op += "C";
		if (opS.equals("1")) op += "R";
		if (opU.equals("1")) op += "U";
		if (opD.equals("1")) op += "D";
%>
	<a target=_blank href="pop.jsp?key=<%= tname %>"><b><%= tname %></b></a> <span style='color: red; font-weight: bold;'><%= op %></span></br/>
<%		
	}
%>
</div>
<div style="margin-left: 20px;">
<%
	for (int i=0;i<proc1.size();i++) {
		String target = proc1.get(i)[1] + "." + proc1.get(i)[2].toLowerCase();
		String disp = target;
		if (proc1.get(i)[1].equals(pkg)) disp = proc1.get(i)[2].toLowerCase();
		
		id = Util.getId();
%>
	<a href="javascript:toggleData('<%=id%>')"><img id="img-<%=id%>" border=0 align=top src="image/plus.gif"></a>
	<a href="pkg-link.jsp?name=<%=target%>"><%= disp %></a></br/>
	<div id="key-<%= id %>" style="margin-left: 40px; display: none;"><%= target %></div>
	<div id="div-<%=id%>" style="margin-left: 40px; display: none;">XXX</div>
<%		
	}
%>
</div>

<br/>
<b>Called By</b><br/>
<div style="margin-left: 20px;">
<%
	for (int i=0;i<proc2.size();i++) {
		String target = proc2.get(i)[1] + "." + proc2.get(i)[2].toLowerCase();
		String disp = target;
		if (proc2.get(i)[1].equals(pkg)) disp = proc2.get(i)[2].toLowerCase();
%>
	<a href="pkg-link.jsp?name=<%=target%>"><%= disp %></a></br/>
<%		
	}
%>
</div>

<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '<%= Util.trackingId() %>']);
  _gaq.push(['_setDomainName', 'none']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>

<form id="FORM_query" name="FORM_query" action="query.jsp" target="_blank" method="post">
<input id="sql-query" name="sql" type="hidden"/>
</form>

<div style="display: none;">
<form name="form0" id="form0">
<input id="key" name="key" type="hidden" value=""/>
<input id="id" name="id" type="hidden" value=""/>
</form>
</div>
</body>
</html>

