<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	String sql = request.getParameter("sql");
	
	String ep = cn.getExplainPlan(sql);
%>
<hr noshade color="green">
<b>PLAN_TABLE_OUTPUT</b>
<pre style='font-family: Consolas;'><%= ep %></pre>