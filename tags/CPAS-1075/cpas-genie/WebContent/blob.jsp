<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*"
	import="org.apache.commons.lang3.StringEscapeUtils" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	int counter = 0;
	Connect cn = (Connect) session.getAttribute("CN");

	String table = request.getParameter("table");
	String col = request.getParameter("col");
	String key = request.getParameter("key");
	
	String pkName = cn.getPrimaryKeyName(table);
	String conCols = cn.getConstraintCols(pkName);
	

	String sql = "SELECT " + col + " FROM " + table + " WHERE " + conCols + "='" + key +"'";
	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
	sql = sql.replaceAll("&gt;",">").replace("&lt;","<");
	
	System.out.println(request.getRemoteAddr()+": " + sql +";");
	
	OldQuery q = new OldQuery(cn, sql, request);
	ResultSet rs = q.getResultSet();
	
	// get table name
	String tbl = null;
	//String temp = sql.replaceAll("\n", " ").trim();
	String temp=sql.replaceAll("[\n\r\t]", " ");
	
	int idx = temp.toUpperCase().indexOf(" FROM ");
	if (idx >0) {
		temp = temp.substring(idx + 6);
		idx = temp.indexOf(" ");
		if (idx > 0) temp = temp.substring(0, idx).trim();
		
		tbl = temp.trim();
		
		
		idx = tbl.indexOf(" ");
		if (idx > 0) tbl = tbl.substring(0, idx);
		
	}
//	System.out.println("XXX TBL=" + tbl);
%>

<html>
<head>
	<title>BLOB <%= table + "." + col %> </title>
	<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
	<script src="script/main.js?20120301" type="text/javascript"></script>
	<script type="text/javascript" src="script/shCore.js"></script>
	<script type="text/javascript" src="script/shBrushSql.js"></script>
	<script type="text/javascript" src="script/shBrushXml.js"></script>
    <link href='css/shCore.css' rel='stylesheet' type='text/css' > 
    <link href="css/shThemeDefault.css" rel="stylesheet" type="text/css" />
    <link href="css/style.css" rel="stylesheet" type="text/css" />
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
</head>
<body>


<img src="image/icon_query.png" align="middle"/>
<%= cn.getUrlString() %>

<br/>

<h3><%= sql %></h3>

<%
	boolean numberCol[] = new boolean[500];

	boolean hasData = false;
	if (rs != null) hasData = rs.next();
	int colIdx = 0;
	for  (int i = 1; rs != null && i<= rs.getMetaData().getColumnCount(); i++){
	
		int colType = q.getColumnType(i);
		String val = q.getBlob(i);
		String escaped = Util.escapeHtml(val);
%>
<pre class='brush: xml'>
<%= escaped %>
</pre>
<%
	}	
%>

<a href="javascript:window.close()">Close</a>

<script type="text/javascript">
$(document).ready(function(){
     SyntaxHighlighter.all();
})
</script>

</body>
</html>