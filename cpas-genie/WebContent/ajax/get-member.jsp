<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	import="oracle.jdbc.OracleTypes"
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");

	String clnt = request.getParameter("clnt");
	String mkey = request.getParameter("mkey");
	String sql = "SELECT * FROM MEMBER WHERE CLNT='"+clnt+"' AND MKEY='"+mkey+"'";
	String id = Util.getId();
%>

<jsp:include page='qry-simple.jsp'>
	<jsp:param value="<%= sql %>" name="sql"/>
	<jsp:param value="1" name="dataLink"/>
	<jsp:param value="<%= id %>" name="id"/>
	<jsp:param value="0" name="cpas"/>
</jsp:include>