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

	String qry = "SELECT * FROM CPAS_PROCESS_EVENT WHERE PROCESS = '" + process + "' AND SECLABEL != 'SC_NEVER' ORDER BY POSITION"; 
	
	Query q = new Query(cn, qry, false);
	
	String pname = cn.queryOne("SELECT NAME FROM CPAS_PROCESS WHERE PROCESS='" + process+"'");
	String id = Util.getId();
%>
<b>Event</b> - <%= pname %></b> - [<%= process %>]
<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" border=0 align=middle  title="<%=qry%>"/></a>
<div style="display: none;" id="sql-<%=id%>"><%= qry%></div>

<br/>

<table id="dataTable" border=1 class="gridBody">
<tr>
	<th class="headerRow">Event Name</th>
	<th class="headerRow">Event</th>
	<th class="headerRow">PEvent</th>
	<th class="headerRow">Position</th>
	<th class="headerRow">Action</th>
	<th class="headerRow">Privilege</th>
	<th class="headerRow">Uparam</th>
<!--
 	<th class="headerRow">Log</th>
	<th class="headerRow">RKey</th>
 -->
 </tr>

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
%>
<tr class="simplehighlight">
	<td class="<%= rowClass%>" nowrap><%= pevent==null?"":"&nbsp;&nbsp;&nbsp;&nbsp;" %><a id="ev-<%= event %>" href="javascript:loadEventView('<%= process %>','<%= event %>');"><%= name %></a></td>
	<td class="<%= rowClass%>" nowrap><%= event==null?"":event %></td>
	<td class="<%= rowClass%>" nowrap><%= pevent==null?"":pevent %></td>
	<td class="<%= rowClass%>" nowrap><%= position==null?"":position %></td>
	<td class="<%= rowClass%>" nowrap><%= action==null?"":action + " <span class='cpas'>" + actionName + "</span>"%></td>
	<td class="<%= rowClass%>" nowrap><%= seclabel==null?"":seclabel + " <span class='cpas'>" + secName + "</span>"%></td>
	<td class="<%= rowClass%>" nowrap><%= uparam==null?"":uparam %></td>
<%--
 	<td class="<%= rowClass%>" nowrap><%= log==null?"":log %></td>
	<td class="<%= rowClass%>" nowrap><%= rkey==null?"":rkey %></td>
 --%>
</tr>
<%
	} 
%>
</table>
