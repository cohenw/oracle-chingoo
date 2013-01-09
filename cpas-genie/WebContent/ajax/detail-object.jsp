<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	String object = request.getParameter("object");
	object = object.toUpperCase();
	System.out.println(cn.getUrlString() + " " + Util.getIpAddress(request) + " " + (new java.util.Date()) + "\nObject: " + object);

	String qry = "SELECT object_type FROM user_objects where object_name='" + object + "'";
//	System.out.println(qry);
	String oType = cn.queryOne(qry);
	
	if (oType.equals("TABLE")) {
		response.sendRedirect("detail-table.jsp?table=" + object);
	} else if (oType.equals("VIEW")) {
		response.sendRedirect("detail-view.jsp?view=" + object);
	} else if (oType.equals("SYNONYM")) {
		response.sendRedirect("detail-synonym.jsp?name=" + object);
	} else if (oType.equals("PACKAGE")||oType.equals("PROCEDURE")||oType.equals("FUNCTION")) {
		response.sendRedirect("detail-package.jsp?name=" + object);
	} else {
		System.out.println("Unknown object: " + object + " " + oType);
	}
	
%>
