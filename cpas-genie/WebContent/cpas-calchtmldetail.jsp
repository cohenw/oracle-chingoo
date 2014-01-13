<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	String calcid = request.getParameter("calcid");
/*
	String old_tabs[][] = {
			
			{"XX", "Options", ""},
			{"CC", "General", ""},
			{"DD", "Service", ""},
			{"EE", "Contributions", ""},
			{"FF", "Earnings", ""},
			{"GA", "Pension", ""},
			{"GG", "Operational Service", ""},
			{"HH", "Non-Operational Service", ""},
			{"QQ", "Factors", ""},
			{"PB", "415 Limits", ""},
			{"PS", "Purchase", ""},
			{"FN", "Funds", ""},
			{"PR", "Historical PAs", ""},
			{"RR", "RR", ""},
			{"TP", "TP", ""},
			{"LL", "Summary", ""}
	};
*/	
	String mkey = cn.queryOne("SELECT MKEY FROM CALC WHERE CALCID='" + calcid +"'");
	//String qry = "SELECT * FROM CALC_HTMLDETAIL WHERE CALCID='"+calcid +"' ORDER BY PAGE";
	String qry = "SELECT a.page, a.htmlitem, b.name	FROM CALC_HTMLDETAIL a "+
			"LEFT JOIN CPAS_CODE_VALUE b ON b.GRUP='PG' AND b.VALU=a.page " +
			"WHERE a.calcid=" + calcid + " AND page != 'TESTDOC' ORDER BY b.orderby";
	
	Query q = new Query(cn, qry, false);

	q.rewind(1000, 1);
	String id = Util.getId();
%>

<html>
<head>
<title>CPAS Calc Detail - <%= calcid %></title>

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

<link rel='stylesheet' type='text/css' href='css/doc.css?<%=Util.getScriptionVersion()%>'>
<link rel='stylesheet' type='text/css' href='css/newdoc.css?<%=Util.getScriptionVersion()%>'>

<script type="text/javascript">
$(document).ready(function(){
	setHighlight();
})
    $(function() {
        $( "#ctabs" ).tabs();
    });
</script>

</head>

<body>

<div id="topline" style="background-color: #EEEEEE; padding: 0px; border:1px solid #888888; border-radius:10px;">
<table width=100% border=0 cellpadding=0 cellspacing=0>
<td width="44">
<img align=top src="image/lamp.png" alt="Ver. <%= Util.getVersionDate() %>" title="<%= Util.getBuildNo() %>"/>
</td>
<td>
<span style="font-family: Arial; font-size:18px;"><span style="background-color:black; color: white;">C</span><span style="background-color:#FF9900; color: white;">PAS</span> <span style="color: blue; font-family: Arial; font-size:18px; font-weight:bold;">CALC</span></span>
</td>
<!-- <td nowrap><h2 style="color: blue;">Genie</h2></td> -->
<td><b><%= cn.getUrlString() %></b></td>
<td nowrap>

<a href="index.jsp">Home</a> |
<a href="query.jsp" target="_blank">Query</a> |

</td>
<td align=right nowrap>
<!-- <b>Search</b> <input id="globalSearch" style="width: 200px;" placeholder="process, event or table/view"/>
<input type="button" value="Find" onClick="Javascript:processSearch($('#globalSearch').val())" />
 --></td>
</table>
</div>

<%-- <h2 style="color: blue;">CalcId <%= calcid %> / Mkey <%= mkey %></h2>	
 --%>
<% if (!calcid.equals("")) {
	id = Util.getId();
	String sql= "SELECT * FROM CALC WHERE CALCID="+calcid; 
%>
<div style="display: none;" id="sql-<%=id%>"><%= sql%></div>
<div style="display: none;" id="mode-<%=id%>">hide</div>
<div style="display: none;" id="ori-<%=id%>">H</div>
<div style="display: none;" id="hide-<%=id%>"></div>
<div id="div-<%=id%>">
<jsp:include page='ajax/qry-simple.jsp'>
	<jsp:param value='<%= sql %>' name="sql"/>
	<jsp:param value="1" name="dataLink"/>
	<jsp:param value="<%= id %>" name="id"/>
</jsp:include>
</div>
<br/>
<% } %>	
	
<div id="ctabs">
    <ul>
<%
	q.rewind(1000, 1);
	while (q.next()) {
		String pg = q.getValue("page");
		String tabname = q.getValue("name");
%>    
	<li><a href="#tabs-<%=pg%>"><%=tabname%></a></li>
<% } %>
    </ul>

<%
	q.rewind(1000, 1);
	while (q.next()) {
		String pg = q.getValue("page");
		String text = q.getValue("htmlitem");
%>   
    <div id="tabs-<%=pg%>" style="background-color: white;">
		<pre><%=text%></pre>
    </div>
<% } %>

</div>

</div>
	
</body>
</html>