<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%!
/*
CREATE TABLE GENIE_TABLE_COL (
	TNAME			VARCHAR2(30),
	CNAME			VARCHAR2(30),
	CAPT			VARCHAR2(100),
	CPAS_CODE		VARCHAR2(30),
	LINK_TO			VARCHAR2(100)
	PRIMARY KEY (TNAME, CNAME)
)
*/
public void createTable(Connection conn ) throws SQLException {
    conn.setReadOnly(false);
	String stmt1 = 
			"CREATE TABLE GENIE_TABLE_COL (	"+
			"TNAME			VARCHAR2(30),  "+
			"CNAME			VARCHAR2(30),  "+
			"CAPT			VARCHAR2(100), "+
			"CPAS_CODE		VARCHAR2(30),  "+
			"LINK_TO		VARCHAR2(100), "+
			"PRIMARY KEY (TNAME, CNAME) )";
	Statement stmt = null;
	try {
		stmt = conn.createStatement();
		stmt.execute(stmt1);
		stmt.close();
	} catch (Exception e) {
		if (stmt != null) {
			stmt.close();
		}
	}
    conn.setReadOnly(true);
}
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
	if (!cn.isTVS("CPAS_TABLE_COL"))
		createTable(cn.getConnection());
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
	
	String title ="CPAS Table/Col for " + table;

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
			
			int rowCnt = 0;
			for (int i=0;i<list.size();i++) {
				TableCol rec = list.get(i);
				String colName = rec.getName().toUpperCase();
				
				String capt = request.getParameter("CAPT_" + colName);
				String cpasCode = request.getParameter("CODE_" + colName);
				String linkTo = request.getParameter("LINK_" + colName);
				
				if (capt == null) capt = "";
				if (cpasCode == null) cpasCode = "";
				if (linkTo == null) linkTo = "";
				
				if (capt.length() > 0 || cpasCode.length() > 0 || linkTo.length() > 0) {
					sql = "INSERT INTO GENIE_TABLE_COL (TNAME, CNAME, CAPT, CPAS_CODE, LINK_TO) VALUES (?,?,?,?,?)";
					PreparedStatement pstmt = cn.getConnection().prepareStatement(sql);
					pstmt.setString(1, table);
					pstmt.setString(2, colName);
					pstmt.setString(3, capt.trim());
					pstmt.setString(4, cpasCode.toUpperCase().trim());
					pstmt.setString(5, linkTo.toUpperCase().trim());
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
	<style>
	.ui-autocomplete-loading { background: white url('image/ui-anim_basic_16x16.gif') right center no-repeat; }
.ui-autocomplete {
		max-height: 500px;
		overflow-y: auto;
		/* prevent horizontal scrollbar */
		overflow-x: hidden;
		/* add padding to account for vertical scrollbar */
		padding-right: 20px;
	}
	/* IE 6 doesn't support max-height
	 * we use height instead, but this forces the menu to always be this tall
	 */
	* html .ui-autocomplete {
		height: 500px;
	}	
	</style>
    
    <script type="text/javascript">
    $(document).ready(function(){
    	setHighlight();
      });
    
	$(function() {
		$( "#globalSearch" ).autocomplete({
			source: "ajax/auto-complete2.jsp",
			minLength: 2,
			select: function( event, ui ) {
				popObject( ui.item ?
					ui.item.value: "" );
			}
		}).data( "autocomplete" )._renderItem = function( ul, item ) {
			return $( "<li></li>" )
			.data( "item.autocomplete", item )
			.append( "<a>" + item.label + " <span class='rowcountstyle'>" + item.desc + "</span></a>" )
			.appendTo( ul );
		};
		
		$( ".codeSearch" ).autocomplete({
			source: "ajax/auto-complete-code.jsp",
			minLength: 2,
			select: function( event, ui ) {
				searchBy3( ui.item ?
					ui.item.value: "" );
			}
		}).data( "autocomplete" )._renderItem = function( ul, item ) {
			return $( "<li></li>" )
			.data( "item.autocomplete", item )
			.append( "<a>" + item.label + " <span class='rowcountstyle'>" + item.desc + "</span></a>" )
			.appendTo( ul );
		};
	
		$( ".linkTo" ).autocomplete({
			source: "ajax/auto-complete-table.jsp",
			minLength: 2,
			select: function( event, ui ) {
				searchBy3( ui.item ?
					ui.item.value: "" );
			}
		}).data( "autocomplete" )._renderItem = function( ul, item ) {
			return $( "<li></li>" )
			.data( "item.autocomplete", item )
			.append( "<a>" + item.label + " <span class='rowcountstyle'>" + item.desc + "</span></a>" )
			.appendTo( ul );
		};
	});	

	function searchBy3(key) {
//		alert(key);
/*
		$("#key1").val(key);
		$("#key2").val('');
		$("#formCode").submit();
*/		
	}
    </script>
</head> 

<body>

<div style="background-color: #EEEEEE; padding: 6px; border:1px solid #888888; border-radius:10px;">
<img src="image/file_edit.png" align="middle"/>
<span style="color: blue; font-family: Arial; font-size:16px; font-weight:bold;">CPAS Table</span>
<b><%= cn.getUrlString() %></b>
&nbsp;&nbsp;&nbsp;&nbsp;

<a href="index.jsp" target="_blank">Home</a> |
<a href="query.jsp" target="_blank">Query</a>

<span style="float:right;">
Search <input id="globalSearch" style="width: 200px;" placeholder="table or view name"/>
</span>
</div>

<br/>
<% if (error != null) { %>

<h3 style="color: red;"><%= error %></h3>

<% } %>

<% if (message != null) { %>

<h3 style="color: green;"><%= message %></h3>

<% } %>

<h2><%= table %> &nbsp;&nbsp;<span class="rowcountstyle"><%= cn.getTableRowCount(owner, table) %></span>
</h2>

<form id="form1" method="POST">
<input name="table" type="hidden" value="<%= table.toUpperCase() %>"/>
<table id="dataTable" border=1 class="gridBody" style="margin-left: 10px;">
<tr>
	<th class="headerRow">Column Name</th>
	<th class="headerRow">Type</th>
	<th class="headerRow">Null</th>
	<th class="headerRow">Default</th>
	<th class="headerRow">Caption</th>
	<th class="headerRow">CPAS Code</th>
	<th class="headerRow">Link To</th>
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
		
		capt = cn.queryOne("SELECT CAPT FROM GENIE_TABLE_COL WHERE TNAME='" + table +"' AND CNAME='" + col_name +"'", false);
		String cpasCode = cn.queryOne("SELECT CPAS_CODE FROM GENIE_TABLE_COL WHERE TNAME='" + table +"' AND CNAME='" + col_name +"'", false);
		String linkTo = cn.queryOne("SELECT LINK_TO FROM GENIE_TABLE_COL WHERE TNAME='" + table +"' AND CNAME='" + col_name +"'", false);
//System.out.println("SELECT CAPT FROM GENIE_TABLE_COL WHERE TNAME='" + table +"' AND CNAME='" + col_name +"'");
//System.out.println("caption=" + caption);

		if (capt == null) capt = "";
		if (cpasCode == null) cpasCode = "";
		if (linkTo == null) linkTo = "";
		
%>
<tr class="simplehighlight">
	<td class="<%= rowClass%>"><%= col_disp.toLowerCase()%></td>
	<td class="<%= rowClass%>"><%= rec.getTypeName() %></td>
	<td class="<%= rowClass%>"><%= rec.getNullable()==0?"N":"" %></td>
	<td class="<%= rowClass%>"><%= rec.getDefaults() %></td>
	<td><input name="CAPT_<%= col_name %>" value="<%= capt %>" style="width: 200px;" maxlength=100></td>
	<td><input class="codeSearch" name="CODE_<%= col_name %>" style="width: 200px;" value="<%= cpasCode %>"></td>
	<td><input class="linkTo" name="LINK_<%= col_name %>" value="<%= linkTo %>" style="width: 200px;" maxlength=30></td>
</tr>

<%
	}
%>
</table>

<input name="submit" value="Submit" type="Submit">

</form>

</body>
</html>