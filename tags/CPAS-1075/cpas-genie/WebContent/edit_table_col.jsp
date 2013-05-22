<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
String table = request.getParameter("table");
String owner = request.getParameter("owner");
String submit = request.getParameter("submit");

// incase owner is null & table has owner info
if (owner==null && table!=null && table.indexOf(".")>0) {
	int idx = table.indexOf(".");
	owner = table.substring(0, idx);
	table = table.substring(idx+1);
}

	Connect cn = (Connect) session.getAttribute("CN");

	if (!table.startsWith("\"")) table = table.toUpperCase();
	
	String catalog = null;
	String tname = table;
	
	int idx = table.indexOf(".");
	if (idx>0) {
		catalog = table.substring(0, idx);
		tname = table.substring(idx+1);
	}
	
//	if (catalog==null) catalog=""; //cn.getSchemaName();
	
	if (table==null) { 
%>

Please select a Table to see the detail. ?table=TABLE_NAME

<%
		return;
	}
	
	String title ="Caption/Looup for " + table;

	List<TableCol> list = cn.getTableDetail(owner, tname);
			
	String error = null;
	String message = null;
	if (submit != null) {
		// delete 
		
		// for each col, get caption and lookup_sql
		try {
			cn.getConnection().setReadOnly(false);
			String sql = "DELETE FROM GENIE_TABLE_COL WHERE TNAME='" + Util.escapeQuote(table) + "'";
			Statement stmt = cn.getConnection().createStatement();
			stmt.executeUpdate(sql);
			stmt.close();
			
			String caption;
			String lookupSql;
			int rowCnt = 0;
			for (int i=0;i<list.size();i++) {
				TableCol rec = list.get(i);
				String colName = rec.getName().toUpperCase();
				
				caption = request.getParameter("CAPT_" + colName);
				lookupSql = request.getParameter("LOOKUP_" + colName);
				
				if (caption == null) caption = "";
				if (lookupSql == null) lookupSql = "";
				
				if (caption.length() > 0 || lookupSql.length() > 0) {
					sql = "INSERT INTO GENIE_TABLE_COL (TNAME, CNAME, CAPT, LOOKUP_SQL) VALUES (?,?,?,?)";
					PreparedStatement pstmt = cn.getConnection().prepareStatement(sql);
					pstmt.setString(1, table);
					pstmt.setString(2, colName);
					pstmt.setString(3, caption);
					pstmt.setString(4, lookupSql);
					pstmt.executeUpdate();
					pstmt.close();
				}
			}
			
			message = "Successfully updated.";
		} catch (SQLException e) {
			error = e.getMessage();
		} finally {
			cn.getConnection().setReadOnly(true);
		}
		
	}
%>

<html>
<head> 
	<title><%= title %></title>
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>

    <script src="script/data-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <script src="script/query-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>
    
    <script type="text/javascript">
    $(document).ready(function(){
    	setHighlight();
      });
    </script>
</head> 

<body>

<img src="image/icon_query.png" align="middle"/> <b>Caption / Lookup</b>
&nbsp;&nbsp;
<%= cn.getUrlString() %>

&nbsp;&nbsp;&nbsp;
<a href="query.jsp" target="_blank">Query</a> |
<a href="q.jsp" target="_blank">Q</a> |
<a href="erd_svg.jsp?tname=<%= table %>" target="_blank">ERD</a> |
<a href="worksheet.jsp" target="_blank">Work Sheet</a>

<br/><br/>
<% if (error != null) { %>

<h3 style="color: red;"><%= error %></h3>

<% } %>

<% if (message != null) { %>

<h3 style="color: green;"><%= message %></h3>

<% } %>

<b><%= table %></b>

<form id="form1" method="POST">
<input name="table" type="hidden" value="<%= table.toUpperCase() %>"/>
<table id="dataTable" border=1 class="gridBody" style="margin-left: 10px;">
<tr>
	<th class="headerRow">Column Name</th>
	<th class="headerRow">Type</th>
	<th class="headerRow">Null</th>
	<th class="headerRow">Default</th>
	<th class="headerRow">Comments</th>
	<th class="headerRow">Caption</th>
	<th class="headerRow">Lookup SQL statement</th>
</tr>

<%	
	//List<TableCol> list = cn.getTableDetail(owner, tname);
	int rowCnt = 0;
	for (int i=0;i<list.size();i++) {
		TableCol rec = list.get(i);
		
		// check if primary key
		String col_name = rec.getName().toUpperCase();
		String col_disp = rec.getName();
		if (rec.isPrimaryKey()) col_disp = "<span class='primary-key'>" + col_disp + "</span>";
		
		String capt = cn.getCpasCodeCapt(tname, rec.getName());
		if (capt == null) capt = "";
		
		String grup = cn.getCpasCodeGrup(tname, rec.getName());
		if (grup == null || grup.equals("_")) grup = "";
		
		if (grup != null && !grup.equals("")) {
			String codeTable = cn.getCpasUtil().getCpasCodeTable();
			grup = " -&gt; <a href=\"javascript:showDialog('" + codeTable + "','"+grup+"')\">" + grup + "</a>";
		}
		
		rowCnt++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";		
		
		String caption = cn.queryOne("SELECT CAPT FROM GENIE_TABLE_COL WHERE TNAME='" + table +"' AND CNAME='" + col_name +"'", false);
		String lookupSql = cn.queryOne("SELECT LOOKUP_SQL FROM GENIE_TABLE_COL WHERE TNAME='" + table +"' AND CNAME='" + col_name +"'", false);
//System.out.println("SELECT CAPT FROM GENIE_TABLE_COL WHERE TNAME='" + table +"' AND CNAME='" + col_name +"'");
//System.out.println("caption=" + caption);

		if (caption == null) caption = "";
		if (lookupSql == null) lookupSql = "";
		
%>
<tr class="simplehighlight">
	<td class="<%= rowClass%>"><%= col_disp.toUpperCase() %></td>
	<td class="<%= rowClass%>"><%= rec.getTypeName() %></td>
	<td class="<%= rowClass%>"><%= rec.getNullable()==0?"N":"" %></td>
	<td class="<%= rowClass%>"><%= rec.getDefaults() %></td>
	<td class="<%= rowClass%>"><%= owner==null?cn.getComment(tname, rec.getName()):cn.getSynColumnComment(owner, tname, rec.getName()) %></td>
	<td><input name="CAPT_<%= col_name %>" value="<%= caption %>" size=20 maxlength=30></td>
	<td><textarea name="LOOKUP_<%= col_name %>" rows="2" cols="50"><%= lookupSql %></textarea></td>
</tr>

<%
	}
%>
</table>

<input name="submit" value="Submit" type="Submit">

</form>

</body>
</html>