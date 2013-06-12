<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.Connect" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");

	String type = request.getParameter("type");
	String name = request.getParameter("name");

	if (name != null) cn.addQuickLink(type, name);
	System.out.println("type=" + type + " name=" + name);
	out.println(cn.getQuickLinks());
%>
