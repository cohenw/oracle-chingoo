<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	
	String qry = "SELECT SDI, NAME FROM CPAS_SDI WHERE ORDERBY > 0 ORDER BY NAME";
	
	List<String[]> list = cn.query(qry);
	
	int totalCnt = list.size();

	if (totalCnt==0) {
//		qry = "SELECT sdi, sdi FROM TREEACTION group by sdi";
		qry = "SELECT sdi, name FROM CPAS_SDI order by orderby, sdi";
		list = cn.query(qry);
		totalCnt = list.size();
	}
String id = Util.getId();
%>
<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" border=0 align=middle  title="<%=qry%>"/></a>
<div style="display: none;" id="sql-<%=id%>"><%= qry %></div>
<br/>



<%	
	for (int i=0; i<list.size();i++) {
%>
	<li><a id="sdi-<%=list.get(i)[1]%>" href="javascript:loadTV('<%=list.get(i)[1]%>');"><%=list.get(i)[2]%></a> <span class="nullstyle"><%=list.get(i)[1]%></span></li>
<% 
	} 
%>
