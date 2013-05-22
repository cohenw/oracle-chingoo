<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	import="org.apache.commons.lang3.StringEscapeUtils" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	String name = request.getParameter("name");
	String owner = request.getParameter("owner");
	
	Connect cn = (Connect) session.getAttribute("CN");
		
	String catalog = cn.getSchemaName();

	String q = "SELECT DISTINCT TYPE FROM USER_SOURCE WHERE NAME='" + name +"' ORDER BY TYPE";
	if (owner != null) q = "SELECT DISTINCT TYPE FROM ALL_SOURCE WHERE OWNER='" + owner + "' AND NAME='" + name +"' ORDER BY TYPE";

	List<String[]> types = cn.query(q, false);
%>
<html>
<head>
	<title>Source for <%= name %></title>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 

	<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
	<script src="script/main.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
	<script type="text/javascript" src="script/shCore.js"></script>
	<script type="text/javascript" src="script/shBrushSql.js"></script>
    <link href='css/shCore.css' rel='stylesheet' type='text/css' > 
    <link href="css/shThemeDefault.css" rel="stylesheet" type="text/css" />
    <link href="css/style.css?<%= Util.getScriptionVersion() %>" rel="stylesheet" type="text/css" />
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
</head>
<body>


<img src="image/icon_query.png" align="middle"/>
<%= cn.getUrlString() %>

<br/>

<h2><%= name %></h2>

<%
for (int k=0;k<types.size();k++) {
	String type = types.get(k)[1];

	String qry = "SELECT TYPE, LINE, TEXT FROM USER_SOURCE WHERE NAME='" + name +"' AND TYPE = '" + type + "' ORDER BY TYPE, LINE";
	if (owner != null) qry = "SELECT TYPE, LINE, TEXT FROM ALL_SOURCE WHERE OWNER='" + owner + "' AND NAME='" + name +"' AND TYPE = '" + type + "' ORDER BY TYPE, LINE";

	List<String[]> list = cn.query(qry, false);
	
	String text = "";
	for (int i=0;i<list.size();i++) {
		String ln = list.get(i)[3];
		if (!ln.endsWith("\n")) ln += "\n";
		text += Util.escapeHtml(ln);
	}

%>
<b><a href="javascript:tDiv('div-<%=k%>')"><%= type %></a></b><br/>
<div id="div-<%=k%>" style="display: block;">
<pre class='brush: sql'>
<%= text %>
</pre>
</div>
<%
}
%>


<br/></br/>
<a href="javascript:window.close()">Close</a>

<script type="text/javascript">
$(document).ready(function(){
     SyntaxHighlighter.all();
});

  function tDiv(id) {
	  $("#"+id).toggle();
  }

</script>

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

</body>
</html>