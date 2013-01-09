<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	String owner = request.getParameter("owner");
	String tool = request.getParameter("name");
	Connect cn = (Connect) session.getAttribute("CN");

	String catalog = cn.getSchemaName();

	String qry=null;
	if (tool.equalsIgnoreCase("session"))
		qry = "select  s.sid, s.serial#,p.spid, s.username \"ORACLE USER NAME\", s.osuser \"OS USER NAME\",\n"+
		        "s.schemaname \"CONN TO SCHEMA\", s.status, s.terminal, s.program\n"+
		 " from   v$session s, v$process p\n" +
		 " where  s.paddr = p.addr\n" +
		 "  and  s.username is not NULL\n" +
		 "  and  s.status <> 'KILLED'\n" +
		 " order by s.username, s.program, s.sid";
	else if (tool.equalsIgnoreCase("sequence"))
		qry = "SELECT * FROM USER_SEQUENCES ORDER BY 1";
	else if (tool.equalsIgnoreCase("db link"))
		qry = "SELECT * FROM USER_DB_LINKS ORDER BY 1";
	else if (tool.equalsIgnoreCase("User role priv")) {
		qry = "SELECT * FROM USER_ROLE_PRIVS";
	}
%>
<h2>DBA: <%= tool %> &nbsp;&nbsp;</h2>

<jsp:include page="detail-tool-query.jsp">
	<jsp:param value="<%= qry %>" name="qry"/>
</jsp:include>
