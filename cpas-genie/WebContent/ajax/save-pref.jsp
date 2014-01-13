<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	String tabeToSpace = request.getParameter("tabToSpace");
	Connect cn = (Connect) session.getAttribute("CN");

	if (tabeToSpace != null) {
		int cnt = Integer.parseInt(tabeToSpace);

		if (cnt <= 10 && cnt > 0) {
			cn.tabToSpace = cnt;
		}
	}
%>
