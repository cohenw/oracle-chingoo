<%@ page language="java" import="java.util.*" import="java.sql.*"
	import="spencer.genie.*" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<%
	Connect cn = (Connect) session.getAttribute("CN");

	String qry = "SELECT RULETYPE, NAME, CAPTION, STYPE FROM EXPOSE_RULE A ORDER BY NAME, CAPTION";
	Query q = new Query(cn, qry, false);
	q.rewind(1000, 1);
	int rowCnt = 0;
%>
<b>Exposed Rules</b>
<br/>
<table id="dataTable" border=1 class="gridBody">
<tr>
	<th class="headerRow">Rule Type</th>
	<th class="headerRow">Name</th>
	<th class="headerRow">Caption</th>
	<th class="headerRow">Stype</th>
</tr>
<%
	while (q.next()) {
		String ruleType = q.getValue("RULETYPE");
		String name = q.getValue("NAME");
		String caption = q.getValue("CAPTION");
		String stype = q.getValue("STYPE");
		
%>
<tr>
<td><%= name %></td>
<td><a href="Javascript:searchExposedRule('<%= ruleType %>')"><b><%= ruleType %></b></a></td>
<td><%= caption %></td>
<td><%= stype %></td>
</tr>
<%
	}
%>
</table>