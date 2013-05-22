<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.Connect" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	
	String qry = "SELECT TAB, NAME FROM CPAS_TAB ORDER BY ORDERBY";
	if (cn.getCpasType()==2) qry = "SELECT TYPE, NAME FROM CPAS_PROCESSTYPE ORDER BY ORDERBY";
	//String qry = "SELECT TAB, NAME FROM CPAS_TAB ORDER BY ORDERBY"; 	
	List<String[]> list = cn.query(qry);

	if (list.size()==0) {
		qry = "SELECT DISTINCT TYPE, (SELECT NAME FROM CPAS_CODE_VALUE WHERE GRUP='CCV' AND VALU=A.TYPE) FROM CPAS_PROCESS A ORDER BY 1"; 	
		list = cn.query(qry);
	}
	
	int totalCnt = list.size();
%>
<b>Process Type</b>
<%
	for (int i=0; i<list.size();i++) {
%>
	<li><a id="pt-<%=list.get(i)[1]%>" href="javascript:loadProcess('<%=list.get(i)[1]%>');"><%=list.get(i)[2]%></a> <span class="nullstyle"><%=list.get(i)[1]%></span></li>
<% 
	} 
%>
