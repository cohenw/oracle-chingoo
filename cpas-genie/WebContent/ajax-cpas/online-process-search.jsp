<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	String keyword = request.getParameter("keyword");
	String key = keyword.toUpperCase().trim();

	String qry = "SELECT * FROM CPAS_PROCESS WHERE (UPPER(NAME) LIKE '%" + key + "%' OR SECLABEL = '"+key +"') AND SECLABEL !='SC_NEVER' ORDER BY type, position"; 
	
	Query q = new Query(cn, qry, false);
	
%>
<b>CPAS Process search for "<%= keyword %>"</b>
<br/><br/>

<b>Process</b>
<br/>

<table id="dataTable" border=1 class="gridBody">
<tr>
	<th class="headerRow">SDI</th>
	<th class="headerRow">Process</th>
	<th class="headerRow">Process Name</th>
	<th class="headerRow">Privilege</th>
 </tr>

<%
	int rowCnt = 0;
	q.rewind(1000, 1);
	while (q.next() && rowCnt < 1000) {
		String process = q.getValue("process");
		String name = q.getValue("name");
		String seclabel = q.getValue("seclabel");
		String type = q.getValue("type");

		rowCnt ++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";	
		
//		String typeName = cn.queryOne("SELECT name FROM CPAS_PROCESSTYPE WHERE TYPE='" + type + "'");

		String qry2 = "SELECT NAME FROM CPAS_TAB WHERE TAB='" + type+"'";
		if (cn.getCpasType()==2) qry2 = "SELECT name FROM CPAS_PROCESSTYPE WHERE TYPE='" + type + "'";
		String typeName= cn.queryOne(qry2);
%>
<tr class="simplehighlight">
	<td class="<%= rowClass%>" nowrap><%= type %><br/><span class='cpas'><%= typeName %></span></td>
	<td class="<%= rowClass%>" nowrap><%= process %></td>
	<td class="<%= rowClass%>" nowrap><a href="Javascript:setProcess('<%=type%>','<%=process%>')"><%= name %></a></td>
	<td class="<%= rowClass%>" nowrap><%= seclabel %></td>
</tr>
<%
	} 
%>
</table>
<br/>

<%
	String qry2 = "SELECT A.*, (SELECT TYPE FROM CPAS_PROCESS WHERE process=A.process) TYPE FROM CPAS_PROCESS_EVENT A WHERE " +
		"(UPPER(NAME) LIKE '%" + key + "%' OR SECLABEL = '"+key +"') AND SECLABEL != 'SC_NEVER' ORDER BY process, position"; 
	
	Query q2 = new Query(cn, qry2, false);
	
%>
<b>Event</b>
<br/>

<table id="dataTable" border=1 class="gridBody">
<tr>
	<th class="headerRow">SDI</th>
	<th class="headerRow">Process</th>
	<th class="headerRow">Event</th>
	<th class="headerRow">Event Name</th>
	<th class="headerRow">Privilege</th>
	<th class="headerRow">Action</th>
 </tr>

<%
	rowCnt = 0;
	q2.rewind(1000, 1);
	while (q2.next() && rowCnt < 1000) {
		String type = q2.getValue("type");
		String process = q2.getValue("process");
		String event = q2.getValue("event");
		String name = q2.getValue("name");
		String seclabel = q2.getValue("seclabel");
		String action = q2.getValue("action");

		rowCnt ++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";		

		//String typeName = cn.queryOne("SELECT name FROM CPAS_PROCESSTYPE WHERE TYPE='" + type + "'");
		qry2 = "SELECT NAME FROM CPAS_TAB WHERE TAB='" + type+"'";
		if (cn.getCpasType()==2) qry2 = "SELECT name FROM CPAS_PROCESSTYPE WHERE TYPE='" + type + "'";
		
		String typeName = cn.queryOne(qry2);
		
		String processName = cn.queryOne("SELECT name FROM CPAS_PROCESS WHERE TYPE='" + type + "' AND PROCESS='"+process+"'");
		String actionName = cn.queryOne("SELECT name FROM CPAS_ACTION WHERE ACTION='" + action + "'");
%>
<tr class="simplehighlight">
	<td class="<%= rowClass%>" nowrap><%= type %><br/><span class='cpas'><%= typeName %></span></td>
	<td class="<%= rowClass%>" nowrap><%= process %><br/><span class='cpas'><%= processName %></span></td>
	<td class="<%= rowClass%>" nowrap><%= event %></td>
	<td class="<%= rowClass%>" nowrap><a href="Javascript:setEvent('<%=type%>','<%=process%>','<%=event%>')"><%= name %></a></td>
	<td class="<%= rowClass%>" nowrap><%= seclabel %></td>
	<td class="<%= rowClass%>" nowrap><%= action %><br/><span class='cpas'><%= actionName %></span></td>
</tr>
<%
	} 
%>
</table>
