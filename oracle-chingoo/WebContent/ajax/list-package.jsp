<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.oracle.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	String filter = request.getParameter("filter");
	String schema = request.getParameter("schema");
	if (schema==null) schema = cn.getSchemaName().toUpperCase();
	
	String qry = "SELECT OBJECT_NAME FROM ALL_OBJECTS WHERE OWNER='" + schema +"' AND object_type IN ('PACKAGE','PROCEDURE','FUNCTION','TYPE') order by 1"; 	
	List<String> list = cn.queryMulti(qry);
	int totalCnt = list.size();
	int selectedCnt = 0;
	if (filter !=null) filter = filter.toUpperCase();
	for (int i=0; i<list.size();i++) {
		if (filter != null && !list.get(i).contains(filter)) continue;
		selectedCnt ++;
	}

%>
Found <%= selectedCnt %> program(s).
<br/><br/>
<%	
	if (filter !=null) filter = filter.toUpperCase();
	for (int i=0; i<list.size();i++) {
		if (filter != null && !list.get(i).contains(filter)) continue;
		String ttt = list.get(i);
		if (!schema.equals(cn.getSchemaName().toUpperCase())) ttt = schema + "." + ttt;
%>
	<li><a href="javascript:loadPackage('<%=ttt%>');"><%=list.get(i)%></a></li>
<% 
	} 
%>
