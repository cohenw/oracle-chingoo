<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.oracle.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	String name = request.getParameter("name");

	int counter = 0;
	
	String q1 = "SELECT DISTINCT PROCEDURE_NAME FROM user_procedures where object_name='" + name +  "' and PROCEDURE_NAME is not null ORDER BY 1";
	List<String[]> list1 = cn.query(q1, false);
	
	String q = "SELECT DISTINCT PROCEDURE_NAME FROM CHINGOO_PA_PROCEDURE WHERE PACKAGE_NAME='" + name + "' ORDER BY 1";
//	System.out.println(q);
	List<String[]> list = cn.query(q, false);
%>
<b>Procedures</b><br/>
<%
	for (int i=0;i<list1.size();i++) {
		String pname = list1.get(i)[1];
%>
	<a id="prc-<%=pname %>" href="javascript:loadProc('<%= name + "','" + pname %>')"><%= cn.getProcedureLabel(name, pname) %></a></br/>
<%		
	}
%>

<br/>
<hr>

<%
	for (int i=0;i<list.size();i++) {
		String pname = list.get(i)[1];
		boolean isPublic = false;
		for (int j=0;j<list1.size();j++) {
			String pname1 = list1.get(j)[1];
			if (pname.equals(pname1))  {
				isPublic = true;
				break;
			}
		}
		
		if (isPublic) continue;
%>
	<a id="prc-<%=pname %>" href="javascript:loadProc('<%= name + "','" + pname %>')"><%= cn.getProcedureLabel(name, pname) %></a></br/>
<%		
	}
%>

