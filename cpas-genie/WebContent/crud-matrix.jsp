<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%!
	String getInsertPackage(Connect cn, List<String[]> ql, String col) {
		String res = "";
		for (String[] row : ql) {
			String colv = row[3];
			if (colv != null && colv.contains("|" + col +"|")) {
				String key =	row[1] + "." + row[2];
				String label = row[1] + "." + cn.getProcedureLabel(key); 
				String url = "<a href='package-tree.jsp?name=" + label + "' target=_blank>" + label + "</a>";
				res +=  url + "<br/>";
			}
		}
		return res;
	}

	String getUpdatePackage(Connect cn, List<String[]> ql, String col) {
		String res = "";
		for (String[] row : ql) {
			String colv = row[4];
			if (colv != null && colv.contains("|" + col +"|")) {
				String key =	row[1] + "." + row[2];
				String label = row[1] + "." + cn.getProcedureLabel(key); 
				String url = "<a href='package-tree.jsp?name=" + label + "' target=_blank>" + label + "</a>";
				res +=  url + "<br/>";
			}
		}
		return res;
	}

	String getDeletePackage(Connect cn, List<String[]> ql, String col) {
		String res = "";
		for (String[] row : ql) {
			String colv = row[5];
			if (colv != null && colv.contains("|" + col +"|")) {
				String key =	row[1] + "." + row[2];
				String label = row[1] + "." + cn.getProcedureLabel(key); 
				String url = "<a href='package-tree.jsp?name=" + label + "' target=_blank>" + label + "</a>";
				res +=  url + "<br/>";
			}
		}
		return res;
	}
	String getInsertTrigger(Connect cn, List<String[]> ql, String col) {
		String res = "";
		for (String[] row : ql) {
			String colv = row[2];
			if (colv != null && colv.contains("|" + col +"|")) {
				String trg =	row[1];
				String url = "<a href='pop.jsp?type=PACKAGE&key=" + trg + "' target=_blank>" + trg + "</a>";
				res +=  url + "<br/>";
			}
		}
		return res;
	}

	String getUpdateTrigger(Connect cn, List<String[]> ql, String col) {
		String res = "";
		for (String[] row : ql) {
			String colv = row[3];
			if (colv != null && colv.contains("|" + col +"|")) {
				String trg =	row[1];
				String url = "<a href='pop.jsp?type=PACKAGE&key=" + trg + "' target=_blank>" + trg + "</a>";
				res +=  url + "<br/>";
			}
		}
		return res;
	}

	String getDeleteTrigger(Connect cn, List<String[]> ql, String col) {
		String res = "";
		for (String[] row : ql) {
			String colv = row[4];
			if (colv != null && colv.contains("|" + col +"|")) {
				String trg =	row[1];
				String url = "<a href='pop.jsp?type=PACKAGE&key=" + trg + "' target=_blank>" + trg + "</a>";
				res +=  url + "<br/>";
			}
		}
		return res;
	}
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	cn.createPkg();
	cn.createTrg();
	
	String table = request.getParameter("table");
	String owner = request.getParameter("owner");

	String q1 = "SELECT object_name FROM user_objects A where object_type='PACKAGE BODY' AND object_name IN (SELECT NAME FROM USER_DEPENDENCIES WHERE REFERENCED_NAME='" + table + "' AND TYPE in ('PACKAGE BODY')) AND NOT EXISTS (SELECT 1 FROM GENIE_PA WHERE PACKAGE_NAME=A.OBJECT_NAME AND CREATED > A.LAST_DDL_TIME) ORDER BY 1";

	List<String[]> pkgs = cn.query(q1, false);

	String q2 = "SELECT object_name FROM user_objects A where object_type='TRIGGER' AND object_name IN (SELECT NAME FROM USER_DEPENDENCIES WHERE REFERENCED_NAME='" + table + "' AND TYPE in ('TRIGGER')) AND NOT EXISTS (SELECT 1 FROM GENIE_TR WHERE TRIGGER_NAME=A.OBJECT_NAME AND CREATED > A.LAST_DDL_TIME) ORDER BY 1";

	List<String[]> trgs = cn.query(q2, false);

	
	if (pkgs.size() > 0 || trgs.size() > 0) {
		response.sendRedirect("analyze-table.jsp?name="+table);
		return;
	}
	
	// incase owner is null & table has owner info
	if (owner==null && table!=null && table.indexOf(".")>0) {
		int idx = table.indexOf(".");
		owner = table.substring(0, idx);
		table = table.substring(idx+1);
	}
	
	String catalog = null;
	String tname = table;
	int idx = table.indexOf(".");
	if (idx>0) {
		catalog = table.substring(0, idx);
		tname = table.substring(idx+1);
	}
	if (catalog==null) catalog = cn.getSchemaName();
	boolean isTempTable = cn.isTempTable(table);
	String cpasComment = cn.getCpasComment(table);
	
	String qry = "SELECT PACKAGE_NAME, PROCEDURE_NAME, COLS_INSERT, COLS_UPDATE, COLS_DELETE FROM GENIE_PA_TABLE WHERE TABLE_NAME='" +  tname + "' order by 1, 2";
	List<String[]> ql = cn.query(qry, false);

	String qry2 = "SELECT TRIGGER_NAME, COLS_INSERT, COLS_UPDATE, COLS_DELETE FROM GENIE_TR_TABLE WHERE TABLE_NAME='" +  tname + "' order by 1";
	List<String[]> ql2 = cn.query(qry2, false);

%>

<html>
<head> 
	<title><%= tname %> - CRUD Matrix</title>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 

	<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>
    <script src="script/genie.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <script src="script/data-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>

	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'> 

    <link href='css/shCore.css' rel='stylesheet' type='text/css' > 
    <link href="css/shThemeDefault.css" rel="stylesheet" type="text/css" />

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

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

</head> 

<body>

<img align=top src="image/lamp.png" alt="Ver. <%= Util.getVersionDate() %>"/>
<b><%= cn.getUrlString() %></b>
&nbsp;&nbsp;&nbsp;&nbsp;

<a href="query.jsp" target="_blank">Query</a>

<h2><span style="color: blue;">CRUD Matrix:</span> <%= table %> &nbsp;&nbsp;<span class="rowcountstyle"><%= cn.getTableRowCount(owner, table) %></span>
<a href="Javascript:runQuery('','<%=tname%>')"><img border=0 src="image/icon_query.png" title="query"></a></h2>
<a target="_blank" href="analyze-table.jsp?name=<%= tname %>">Analyze</a><br/>

<%= owner==null?cn.getComment(tname):cn.getSynTableComment(owner, tname) %> <span class="cpas"><%= cpasComment %></span><br/>


<table id="dataTable" border=1 class="gridBody" style="margin-left: 10px;">
<tr>
	<th class="headerRow">Idx</th>
	<th class="headerRow">Column Name</th>
	<th class="headerRow">Type</th>
	<th class="headerRow">Null</th>
	<th class="headerRow">Default</th>
	<th class="headerRow">INSERT BY</th>
	<th class="headerRow">UPDATE BY</th>
	<th class="headerRow">DELETE BY</th>
</tr>

<%	
	List<TableCol> list = cn.getTableDetail(owner, tname);
	int rowCnt = 0;
	for (int i=0;i<list.size();i++) {
		TableCol rec = list.get(i);
		
		// check if primary key
		String col = rec.getName();
		String col_disp = rec.getName();
		if (rec.isPrimaryKey()) col_disp = "<span class='primary-key'>" + col_disp + "</span>";
		
		rowCnt++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";	
		
		String insBy = getInsertPackage(cn, ql, col);
		String updBy = getUpdatePackage(cn, ql, col);
		String delBy = getDeletePackage(cn, ql, col);
		String insByTrg = getInsertTrigger(cn, ql2, col);
		String updByTrg = getUpdateTrigger(cn, ql2, col);
		String delByTrg = getDeleteTrigger(cn, ql2, col);

		if (!insBy.equals("") && !insByTrg.equals("")) insBy += "<br/>";
		if (!updBy.equals("") && !updByTrg.equals("")) updBy += "<br/>";
		if (!delBy.equals("") && !delByTrg.equals("")) delBy += "<br/>";
		

%>
<tr class="simplehighlight">
	<td valign=top align=right class="<%= rowClass%>"><%= i+1 %></td>
	<td valign=top class="<%= rowClass%>"><span style="font-size: 18px;" title="<%= owner==null?cn.getComment(tname, rec.getName()):cn.getSynColumnComment(owner, tname, rec.getName()) %>"><%= col_disp.toLowerCase() %></span>
	</td>
	<td valign=top class="<%= rowClass%>"><%= rec.getTypeName() %></td>
	<td valign=top class="<%= rowClass%>"><%= rec.getNullable()==0?"N":"" %></td>
	<td valign=top class="<%= rowClass%>"><%= rec.getDefaults() %></td>
	<td valign=top class="<%= rowClass%>"><%= insBy %><%= insByTrg %></td>
	<td valign=top class="<%= rowClass%>"><%= updBy %><%= updByTrg %></td>
	<td valign=top class="<%= rowClass%>"><%= delBy %><%= delByTrg %></td>
</tr>

<%
	}
%>
</table>

<br/><br/>
<% 
List<String> refProc = cn.getReferencedProc(tname);

	if (refProc.size() > 0) { 
%>
<img src="image/Genie-icon.png"> <b>Referenced By</b>
<a href="Javascript:toggleDiv('imgRef','divRef')"><img id="imgRef" border=0 src="image/minus.gif"></a>
<div id="divRef">
<table border=0 width=800>
<td width=4%>&nbsp;</td>
<td valign=top width=32%>
<%
	int listSize = (refProc.size() / 2) + 1;
	int cnt = 0;
	int cols = 1;
	for (int i=0; i<refProc.size(); i++) {
		String refPrc = refProc.get(i);
		//refPrc = cn.getProcedureLabel(refPrc);
		String temp[] = refPrc.split("\\.");
		cnt++;
		refPrc = temp[0] + "." + cn.getProcedureLabel(refPrc.toUpperCase());
%>

<% if ((cnt-1)>=listSize) { %>
		</td><td valign=top width=50%>
<%
		cnt = 1;
		cols ++;
	} 
%>
		<a target=_blank href="package-tree.jsp?name=<%= refPrc %>"><%= refPrc %></a>&nbsp;&nbsp;<%= cn.getCRUD(temp[0],temp[1].toUpperCase(), table) %><br/>		
<% }
	for (; cols<=2; cols++) {
%>
	</td><td valign=top width=50%>
<% } %>

</td>
</table>
</div>

<%
}
%>


</div>



<form id="FORM_query" name="FORM_query" action="query.jsp" target="_blank" method="post">
<input id="sql-query" name="sql" type="hidden"/>
<input name="norun" type="hidden" value="YES"/>
</form>


</body>
</html>