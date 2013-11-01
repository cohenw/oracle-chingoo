<%@ page language="java" 
	import="java.util.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <title>Genie</title>

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'> 
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
  </head>
  
  <body>
		Log.jsp from <%= request.getHeader("referer") %>  
  </body>
</html>

<%
System.out.println("log.jsp " + Util.getIpAddress(request) + " " + (new java.util.Date()) + " " + request.getHeader("referer"));
%>