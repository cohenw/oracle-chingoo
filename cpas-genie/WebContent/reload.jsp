<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
%>
<html>
<head>
	<title>Schema Reloading</title>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 

	<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
	<script src="script/main.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <link href="css/style.css?<%= Util.getScriptionVersion() %>" rel="stylesheet" type="text/css" />
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

<script type="text/javascript">
$(document).ready(function() {
	$("#wait").html("Schema Reloaded!");
});
</script>
</head>
<body>
Schema Object Loaded : <%= cn.cs.loadDate %>

<div id="wait">
Reloading Schema...<br/>
<img src="image/waiting_big.gif">
</div>

</body>
</html>

<%
	out.flush();
	CacheManager.getInstance().reload(cn, cn.cs);
%>
