<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	String key=request.getParameter("key");
	String val=request.getParameter("val");
	
	session.setAttribute(key, val);
	Util.p("key,val=" + key + "," + val);
%>
