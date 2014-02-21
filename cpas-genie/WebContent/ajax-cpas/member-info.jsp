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

	String memberTables[] = {"MEMBER", "MEMBER_SERVICE", "MEMBER_SALARY", "MEMBER_STATUS", "MEMBER_EMPLOYER_STATUS", 
			"MEMBER_PLAN", "MEMBER_PLAN_SERVICE", "MEMBER_PLAN_STATUS", "MEMBER_PLAN_BENEFICIARY", "CALC"}; 
			
	String id="";
	for (String refTab : memberTables) {

		String refsql = "SELECT * FROM " + refTab + " WHERE CLNT='" + clnt + "' AND MKEY='" + mkey +"'";
		String tmp = "SELECT COUNT(*) FROM " + refTab + " WHERE CLNT='" + clnt + "' AND MKEY='" + mkey +"'";
		int recCount = cn.getQryCount(tmp);

		if (recCount ==0) continue;
		id = Util.getId();
	%>

	<div id="div-lchild-<%=id%>">
	<a style="margin-left: 20px;" href="javascript:loadData('<%=id%>',0)"><b><%= refTab %></b> <img id="img-<%=id%>" border=0 src="image/plus.gif"></a>
	(<span class="rowcountstyle"><%= recCount %></span> / <%= cn.getTableRowCount(refTab) %>)
	<span class="cpas"><%= cn.getCpasComment(refTab) %></span>
	&nbsp;&nbsp;
	<a href="pop.jsp?key=<%= refTab %>" target="_blank" title="Detail"><img border=0 src="image/detail.png"></a>
	<a href="erd2.jsp?tname=<%= refTab %>" target="_blank" title="ERD"><img border=0 src="image/erd-s.gif"></a>
	<a href="javascript:openQuery('<%=id%>')"><img src="image/linkout.png" border=0 title="<%=refsql%>"/></a>
	&nbsp;&nbsp;<a href="javascript:hideDiv('div-child-<%=id%>')"><img src="image/clear.gif" border=0/></a>
	<div style="display: none;" id="sql-<%=id%>"><%= refsql%></div>
	<div style="display: none;" id="hide-<%=id%>"></div>
	<div style="display: none;" id="sort-<%=id%>"></div>
	<div style="display: none;" id="sortdir-<%=id%>">0</div>
	<div style="display: none;" id="mode-<%=id%>">sort</div>
	<div style="display: none;" id="ori-<%=id%>">H</div>
	<div id="div-<%=id%>" style="margin-left: 40px; display: none;"></div>
	<br/>
	</div><br/>
	<%
	}
	%>

