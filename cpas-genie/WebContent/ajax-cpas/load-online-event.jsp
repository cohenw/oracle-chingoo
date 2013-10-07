<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	String process = request.getParameter("process");

	String qry = "SELECT * FROM CPAS_PROCESS_EVENT WHERE PROCESS = '" + process + "' AND UPPER(SECLABEL) != 'SC_NEVER' AND PEVENT IS NULL ORDER BY POSITION"; 
	
	Query q = new Query(cn, qry, false);
	
	String pname = cn.queryOne("SELECT NAME FROM CPAS_PROCESS WHERE PROCESS='" + process+"'");
	String id = Util.getId();
%>
<b>Event</b>
<%--  - <%= pname %></b> - [<%= process %>]
 --%>
 <a href="javascript:openQuery('<%=id%>')"><img src="image/linkout.png" border=0 title="<%=qry%>"/></a>
<div style="display: none;" id="sql-<%=id%>"><%= qry%></div>

<br/>


<%
	int rowCnt = 0;
	q.rewind(1000, 1);
	while (q.next() && rowCnt < 1000) {
		String event = q.getValue("event");
		String pevent = q.getValue("pevent");
		String name = q.getValue("name");
		String position = q.getValue("position");
		String action = q.getValue("action");
		String uparam = q.getValue("uparam");
		String seclabel = q.getValue("seclabel");
		String log = q.getValue("log");
		String rkey = q.getValue("rkey");

		rowCnt ++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";		
		String actionName = cn.queryOne("SELECT NAME FROM CPAS_ACTION WHERE ACTION ='" + action + "'");
		String secName = cn.queryOne("SELECT CAPTION FROM SECSWITCH WHERE LABEL ='" + seclabel + "'");

		if (action==null || action.equals("NN")) actionName = "";
		String indent = "";
		if (position.contains(".")) indent =  "&nbsp;&nbsp;&nbsp;-";
		if (pevent!=null) indent =  "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
	
%>

<%= indent %>
<a id="ev-<%= event %>" href="javascript:loadEventView('<%= process %>','<%= event %>');" title="<%= process + "," + event %>  <%= actionName %>"><%= name %></a>

<br/>
<%
	} 
%>
