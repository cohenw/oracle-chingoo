<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	String key = request.getParameter("key");

	String qry = "SELECT * FROM CPAS_PROCESS WHERE SECLABEL = '"+key +"' ORDER BY type, position"; 
	
	Query q = new Query(cn, qry, false);
	
%>

<html>
<head>
<title>CPAS Security Label - <%= key %></title>

<meta name="description"
	content="Genie is an open-source, web based oracle database schema navigator." />
<meta name="keywords" content="Oracle Web Database OpenSource JDBC" />
<meta name="author" content="Spencer Hwang" />

<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
<script src="script/jquery-ui-1.8.18.custom.min.js"
	type="text/javascript"></script>
<script src="script/genie.js?<%=Util.getScriptionVersion()%>"
	type="text/javascript"></script>

<link rel="icon" type="image/png" href="image/Genie-icon.png">
<link rel="stylesheet"
	href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css" />
<link rel='stylesheet' type='text/css'
	href='css/style.css?<%=Util.getScriptionVersion()%>'>

<style>
</style>


<script type="text/javascript">
$(document).ready(function(){
	setHighlight();
})
</script>

</head>

<body>

	<table border=0>
		<td><img src="image/cpas.jpg"
			title="Version <%=Util.getVersionDate()%>" /></td>
		<td><h2 style="color: blue;"><%= key %></h2></td>
		<td>&nbsp;</td>

		<td align=left><h3><%=cn.getUrlString()%></h3></td>
		<td>
		<a href="index.jsp">Home</a> |
		<a href="query.jsp" target="_blank">Query</a>
		</td>
	</table>
	
<b><%= key %></b>
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
	<td class="<%= rowClass%>" nowrap><a target="_blank" href="cpas-process.jsp?id=<%=type%>&process=<%=process%>"><%= name %></a></td>
	<td class="<%= rowClass%>" nowrap><%= seclabel %></td>
</tr>
<%
	} 
%>
</table>
<br/>

<%
	String qry2 = "SELECT A.*, (SELECT TYPE FROM CPAS_PROCESS WHERE process=A.process) TYPE FROM CPAS_PROCESS_EVENT A WHERE SECLABEL = '"+key +"' ORDER BY process, position"; 
	
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
	<td class="<%= rowClass%>" nowrap><a target="_blank" href="cpas-process.jsp?id=<%=type%>&process=<%=process%>&event=<%=event%>"><%= name %></a></td>
	<td class="<%= rowClass%>" nowrap><%= seclabel %></td>
	<td class="<%= rowClass%>" nowrap><%= action %><br/><span class='cpas'><%= actionName %></span></td>
</tr>
<%
	} 
%>
</table>

<br/>

<%
	qry = "SELECT * FROM TREEVIEW WHERE (SDI, SCHEMA, ACTIONID) IN (SELECT SDI, SCHEMA, ACTIONID FROM " +
		" TREEACTION_STMT WHERE ACTIONTYPE IN ('AW','MN','ME','MR','DN','DE','DR') AND ACTIONSTMT = '" + key + "') ORDER BY sdi, caption"; 
//System.out.println(qry);	
	Query q3 = new Query(cn, qry, false);
	
%>
<b>Tree View</b>
<br/>

<table id="dataTable" border=1 class="gridBody">
<tr>
	<th class="headerRow">SDI</th>
	<th class="headerRow">Caption</th>
	<th class="headerRow">Treekey</th>
 </tr>

<%
	rowCnt = 0;
	q3.rewind(1000, 1);
	while (q3.next() && rowCnt < 1000) {
		String sdi = q3.getValue("sdi");
		String caption = q3.getValue("caption");
		String treekey = q3.getValue("treekey");

		rowCnt ++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";	
		
		String sdiName = cn.queryOne("SELECT NAME FROM CPAS_SDI WHERE SDI='" + sdi + "'");
%>
<tr class="simplehighlight">
	<td class="<%= rowClass%>" nowrap><%= sdi %></a><br/><span class='cpas'><%= sdiName %></span></td>
	<td class="<%= rowClass%>" nowrap><a target="_blank" href="cpas-treeview.jsp?sdi=<%=sdi%>&treekey=<%=treekey%>"><%= caption %></a></td>
	<td class="<%= rowClass%>" nowrap><%= treekey %></td>
</tr>
<%
	} 
%>
</table>
<br/>


</body>
</html>