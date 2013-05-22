<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");

	String tname = request.getParameter("tname");
	
	String actionType = request.getParameter("actionType");
	String sqlStmt = request.getParameter("sqlStmt");
	String submit = request.getParameter("submit");
	
	String error = null;
	
	if (submit != null) {
		cn.saveLink(tname, sqlStmt);
	}
	
	String stmt = cn.queryOne("SELECT SQL_STMTS FROM GENIE_LINK WHERE TNAME ='" + tname + "'", false);
	if (stmt==null) stmt = "";
%>

<html>
<head> 
	<title>Custom Link for <%= tname %></title>
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>

    <script src="script/data-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <script src="script/query-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">
	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>

<script type="text/javascript">
	$(document).ready(function() {
		showTable('<%=tname%>');
	});

	$(function() {
		function addTable( tname ) {
			if (tname == "") return;
			showTable(tname);
		}

		$( "#tablesearch" ).autocomplete({
			source: "ajax/auto-complete.jsp",
			minLength: 2,
			select: function( event, ui ) {
				addTable( ui.item ?
					ui.item.value: "" );
			}
		}).data( "autocomplete" )._renderItem = function( ul, item ) {
			return $( "<li></li>" )
			.data( "item.autocomplete", item )
			.append( "<a>" + item.label + " <span class='rowcountstyle'>" + item.desc + "</span></a>" )
			.appendTo( ul );
		};
	
	});
	
</script>

    
</head> 

<body>

<img src="image/data-link.png" align="middle"/>
<%= cn.getUrlString() %>

<% if (error != null) { %>

<h3 style="color: red;"><%= error %></h3>

<% } %>

<h3>Custom Link for <span style="color: blue;"><%= tname %></span></h3>

<div class="ui-widget">
	<label for="tablesearch">Table/View: </label>
	<input id="tablesearch" style="width: 200px;"/>
</div>

<div id="table-detail"></div>

<br/>
You can have multiple SQL statements.<br/>
EX:<br/>
<div style="margin-left: 20px;">
SELECT * FROM TABLE1 WHERE COL1='[MKEY]';<br/>
SELECT * FROM TABLE2 WHERE COL1='[CLNT]' AND COL2='[CALCID]';<br/>
</div>

<form method="post">
<input name="tname" type="hidden" value="<%= tname %>"/>
<textarea id="sql1" name="sqlStmt" rows="10" cols="100"><%=stmt%></textarea>
</br>
<input name="submit" type="Submit"/>
</form>

</body>
</html>