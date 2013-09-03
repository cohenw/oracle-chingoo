<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.oracle.*" 
	import="org.apache.commons.lang3.StringEscapeUtils" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	String name = request.getParameter("name");
	String owner = request.getParameter("owner");
	
	Connect cn = (Connect) session.getAttribute("CN");
		
	String catalog = cn.getSchemaName();

	if (owner==null && cn.isSynonym(name)) {
		String tmp = cn.getSynonym(name);
		System.out.println(tmp);
		int idx = tmp.indexOf('.');
		if (idx > 0) {
			owner = tmp.substring(0,idx);
			name = tmp.substring(idx+1);
		}
	}
	
	String q = "SELECT DISTINCT TYPE FROM USER_SOURCE WHERE NAME='" + name +"'  ORDER BY TYPE";
	if (owner != null) q = "SELECT DISTINCT TYPE FROM ALL_SOURCE WHERE OWNER='" + owner + "' AND NAME='" + name +"' ORDER BY TYPE";

	List<String[]> types = cn.query(q, false);
	int lines_pkg = 0;
	int lines_pkgbody = 0;
	int lines_procedure = 0;
	int lines_function = 0;
%>
<html>
<head>
	<title>Source for <%= name %></title>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 

	<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
	<script src="script/main.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <link href="css/style.css?<%= Util.getScriptionVersion() %>" rel="stylesheet" type="text/css" />
	<link rel="icon" type="image/png" href="image/chingoo-icon.png">
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>
	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>

<style>
  .highlight { background:yellow; }
</style>

<script type="text/javascript">
var hi_v = "";
function hi_on(v) {
	if (hi_v != "") hi_off(hi_v);
	$("." + v).addClass("highlight");
	hi_v = v;
}
function hi_off(v) {
	$("." + v).removeClass("highlight");
}

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
//	alert(oname);
	$("#popKey").val(oname);
	$("#FormPop").submit();
}


</script>
</head>
<body>

<div style="background-color: #EEEEEE; padding: 6px; border:1px solid #888888; border-radius:10px;">
<img src="image/sourcecode.gif" width=20 height=20 align="top"/>
<span style="color: blue; font-family: Arial; font-size:16px; font-weight:bold;">&nbsp;</span>
<b><%= cn.getUrlString() %></b>
&nbsp;&nbsp;&nbsp;&nbsp;

<a href="index.jsp" target="_blank">Home</a> |
<a href="query.jsp" target="_blank">Query</a>

<span style="float:right;">
Search <input id="globalSearch" style="width: 200px;" placeholder="table or view name"/>
</span>
</div>

<br/>

<h2><%= name %></h2>

<%
for (int k=0;k<types.size();k++) {
	String type = types.get(k)[1];

	String qry = "SELECT TYPE, LINE, TEXT FROM USER_SOURCE WHERE NAME='" + name +"' AND TYPE = '" + type + "' ORDER BY TYPE, LINE";
	if (owner != null) qry = "SELECT TYPE, LINE, TEXT FROM ALL_SOURCE WHERE OWNER='" + owner + "' AND NAME='" + name +"' AND TYPE = '" + type + "' ORDER BY TYPE, LINE";

	List<String[]> list = cn.query(qry, 10000, false);
	
	String text = "";
	int line = 0;
	for (int i=0;i<list.size();i++) {
		String ln = list.get(i)[3];
		line = Integer.parseInt(list.get(i)[2]);
		if (!ln.endsWith("\n")) ln += "\n";
		//text += Util.escapeHtml(ln);
		text += ln;
		
	}

	if (type.equals("PACKAGE")||type.equals("TYPE"))
		lines_pkg = line;
	else if (type.equals("PACKAGE BODY")||type.equals("TYPE BODY"))
		lines_pkgbody =  line;
	else if (type.equals("PROCEDURE"))
		lines_procedure = line;
	else if (type.equals("FUNCTION"))
		lines_function =  line;
	
	HyperSyntax hs = new HyperSyntax();
	String syntax = hs.getHyperSyntax(cn, text, type, name);
//	HashSet<String> packageProc = hs.getPackageProcedure();
//	System.out.println(packageProc);
%>
<br/>
<b><a href="javascript:tDiv('div-<%=k%>')"><%= type %></a></b><br/>
<div id="div-<%=k%>" style="display: block;">
<table>
<td valign=top align=right><pre style="font-family: Consolas; color: gray;"><span id="column_<%=type.replace(" ","")%>" ></span></pre></td>
<td bgcolor="green"></td>
<td valign=top><pre style="font-family: Consolas;"><%=  syntax %></pre></td>
</table>

</div>
<br/>
<%
}
%>


<br/></br/>
<a href="javascript:window.close()">Close</a>

<form id="FormPop" name="FormPop" target="_blank" method="post" action="pop.jsp">
<input id="popType" name="type" type="hidden" value="OBJECT">
<input id="popKey" name="key" type="hidden">
</form>


</body>
</html>

<script type="text/javascript">
  function tDiv(id) {
	  $("#"+id).toggle();
  }

  function lineIE() {
	  lines="";
	  for (var i=1;i <= <%=lines_pkg%>;i++)
		  lines += i + "\n";
	  $("#column_PACKAGE").html('<pre>' + lines + '</pre>');
	  
	  lines="";
	  for (var i=1;i <= <%=lines_pkgbody%>;i++)
		  lines += i + "\n";
	  $("#column_PACKAGEBODY").html('<pre>' + lines + '</pre>');

	  lines="";
	  for (var i=1;i <= <%=lines_pkg%>;i++)
		  lines += i + "\n";
	  $("#column_TYPE").html('<pre>' + lines + '</pre>');
	  
	  lines="";
	  for (var i=1;i <= <%=lines_pkgbody%>;i++)
		  lines += i + "\n";
	  $("#column_TYPE").html('<pre>' + lines + '</pre>');

	  lines="";
	  for (var i=1;i <= <%=lines_procedure%>;i++)
		  lines += i + "\n";
	  $("#column_PROCEDURE").html('<pre>' + lines + '</pre>');

	  lines="";
	  for (var i=1;i <= <%=lines_function%>;i++)
		  lines += i + "\n";
	  $("#column_FUNCTION").html('<pre>' + lines + '</pre>');
  }
  
$(document).ready(function() {
  if (navigator.userAgent.indexOf("MSIE") > 0) {
	  //alert(navigator.userAgent.indexOf("MSIE"));
	  lineIE();
	  return;
  }

/*
  if ($.browser.msie && !$.browser.webkit) {
	  return;
  }
*/
  lines="";
  for (var i=1;i <= <%=lines_pkg%>;i++)
	  lines += i + "\n";
  $("#column_PACKAGE").html('   ' + lines);
  
  lines="";
  for (var i=1;i <= <%=lines_pkgbody%>;i++)
	  lines += i + "\n";
  $("#column_PACKAGEBODY").html('   ' + lines);

  lines="";
  for (var i=1;i <= <%=lines_pkg%>;i++)
	  lines += i + "\n";
  $("#column_TYPE").html('   ' + lines);
  
  lines="";
  for (var i=1;i <= <%=lines_pkgbody%>;i++)
	  lines += i + "\n";
  $("#column_TYPEBODY").html('   ' + lines);

  lines="";
  for (var i=1;i <= <%=lines_procedure%>;i++)
	  lines += i + "\n";
  $("#column_PROCEDURE").html('   ' + lines);

  lines="";
  for (var i=1;i <= <%=lines_function%>;i++)
	  lines += i + "\n";
  $("#column_FUNCTION").html('   ' + lines);
});

</script>

<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '<%= Util.trackingId() %>']);
  _gaq.push(['_setDomainName', 'none']);
  _gaq.push(['_trackPageview']);

  _gaq.push(['_trackEvent', 'Src', 'Src <%= name %>']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
  
//  alert(navigator.userAgent);
</script>
