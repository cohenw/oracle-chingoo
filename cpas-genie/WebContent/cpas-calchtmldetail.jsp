<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	String calcid = request.getParameter("calcid");

	String tabs[][] = {
			{"XX", "Options", ""},
			{"CC", "General", ""},
			{"DD", "Service", ""},
			{"EE", "Contributions", ""},
			{"FF", "Earnings", ""},
			{"GA", "Pension", ""},
			{"GG", "Operational Service", ""},
			{"HH", "Non-Operational Service", ""},
			{"QQ", "Factors", ""},
			{"PS", "Purchase", ""},
			{"FN", "Funds", ""},
			{"PR", "Historical PAs", ""},
			{"RR", "RR", ""},
			{"TP", "TP", ""},
			{"LL", "Summary", ""}
	};
	
	String mkey = cn.queryOne("SELECT MKEY FROM CALC WHERE CALCID='" + calcid +"'");
	String qry = "SELECT * FROM CALC_HTMLDETAIL WHERE CALCID='"+calcid +"' ORDER BY PAGE"; 
	Query q = new Query(cn, qry, false);

	q.rewind(1000, 1);
	while (q.next()) {
		String pg = q.getValue("page");
		String text = q.getValue("htmlitem");
		
		int idx = -1;
		for (int i=0;i<tabs.length;i++) if (pg.equals(tabs[i][0])) idx = i;
		
		if (idx >= 0) {
			tabs[idx][2] += text;
		}
	}
	
	String id = Util.getId();
%>

<html>
<head>
<title>CPAS Calc Detail - <%= calcid %></title>

<meta name="description"
	content="Genie is an open-source, web based oracle database schema navigator." />
<meta name="keywords" content="Oracle Web Database OpenSource JDBC" />
<meta name="author" content="Spencer Hwang" />

<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
<script src="script/jquery-ui-1.8.18.custom.min.js"
	type="text/javascript"></script>
<script src="script/genie.js?<%=Util.getScriptionVersion()%>"
	type="text/javascript"></script>

<link rel="icon" type="image/png" href="image/Genie-icon.png">
<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
<link rel='stylesheet' type='text/css' href='css/style.css?<%=Util.getScriptionVersion()%>'>

<link rel='stylesheet' type='text/css' href='css/doc.css?<%=Util.getScriptionVersion()%>'>
<link rel='stylesheet' type='text/css' href='css/newdoc.css?<%=Util.getScriptionVersion()%>'>

<script type="text/javascript">
$(document).ready(function(){
	setHighlight();
})
    $(function() {
        $( "#ctabs" ).tabs();
    });
</script>

</head>

<body>

	<table border=0>
		<td><img src="image/cpas.jpg"
			title="Version <%=Util.getVersionDate()%>" /></td>
		<td><h2 style="color: blue;">CALC <%= calcid %> / MKEY <%= mkey %></h2></td>
		<td>&nbsp;</td>

		<td align=left><h3><%=cn.getUrlString()%></h3></td>
		<td>
		<a href="index.jsp">Home</a> |
		<a href="query.jsp" target="_blank">Query</a>
		</td>
	</table>
	
	
	
<div id="ctabs">
    <ul>
<% for (int i=0;i<tabs.length;i++) 
	if (tabs[i][2].length() > 0) { 
%>    
        <li><a href="#tabs-<%=tabs[i][0]%>"><%=tabs[i][1]%></a></li>
<% } %>

    </ul>

<% for (int i=0;i<tabs.length;i++) 
	if (tabs[i][2].length() > 0) { 
%>    
    <div id="tabs-<%=tabs[i][0]%>" style="background-color: white;">
		<pre><%=tabs[i][2]%></pre>
    </div>
<% } %>

</div>
	
</body>
</html>