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
	Util.p(cn.getCpasUtil().htCapt.toString());
%>

<html>
<head> 
	<title>Genie - Cache</title>
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    <script src="script/data-methods.js?20120302" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
</head>
<body>

<%=cn.getCpasUtil().htCapt.toString() %>

<%
String owner="CLIENT_CAAT_DC";
String tname="PROCESS";

String pkName = cn.getPrimaryKeyName(owner, tname);
pkName = pkName.trim();
Util.p("*** pkName " + pkName);

String qry = "SELECT OWNER||'.'||TABLE_NAME FROM ALL_CONSTRAINTS WHERE " +
		"R_OWNER='" + owner + "' AND R_CONSTRAINT_NAME='" + pkName +"' ORDER BY TABLE_NAME";

Util.p("*** qry " + qry);
%>
</body>
</html>
