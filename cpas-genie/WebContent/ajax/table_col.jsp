<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	String table = request.getParameter("table");
	Connect cn = (Connect) session.getAttribute("CN");

	if (!table.startsWith("\"")) table = table.toUpperCase();
	
	String catalog = null;
	String tname = table;
	
//	if (cn.getTargetSchema() != null) catalog = cn.getTargetSchema();
	if (cn.isPublicSynonym(tname)) catalog = "SYS";
	
	int idx = table.indexOf(".");
	if (idx>0) {
		catalog = table.substring(0, idx);
		tname = table.substring(idx+1);
	}
	
//	if (catalog==null) catalog=""; //cn.getSchemaName();
	
	if (table==null) { 
%>

Please select a Table to see the detail.

<%
		return;
	}
	
	String divId="div_" + table;
	divId = divId.replaceAll("\\.","-");
//System.out.println("catalog=" + catalog);
	ArrayList<String> pk = cn.getPrimaryKeys(catalog, tname);
	List<TableCol> cols = cn.getTableDetail(catalog, tname);

	if (cols.size()==0) return;
%>
<div id="<%= divId %>">
<a href="Javascript:copyPaste('<%=table %>');"><b><%= table %></b></a> <span class="rowcountstyle"><%= cn.getTableRowCount(table) %></span> <a href="Javascript:removeDiv('<%= divId %>')">x</a> 
<a href="Javascript:toggleSort('<%= divId %>')"><img border=0 src="image/a.gif"></a>
&nbsp;&nbsp;&nbsp;<a href="pop.jsp?key=<%= table %>" target="_blank" title="view detail"><img border=0 src="image/detail.png"></a>
<a href="erd2.jsp?tname=<%= table %>" target="_blank" title="ERD"><img border=0 src="image/erd-s.gif"></a>
<br/>

<div id="<%= divId %>-a">
<table border=0 width=780>
<tr>
	<td width=20%></td>
	<td width=20%></td>
	<td width=20%></td>
	<td width=20%></td>
	<td width=20%></td>
</tr>
<tr>
<%	

	for (int i=0; i<cols.size();i++) {
		TableCol col = cols.get(i);
		String colName = col.getName();
		String colDisp = col.getName().toLowerCase();
		if (pk.contains(colName)) colDisp = "<span class='pk'>" + colDisp + "</span>";

		String tooltip = col.getTypeName();
		String comment = cn.getComment(tname, colName);
		if (comment != null && comment.length() > 0) tooltip += " " + comment;
%>
<td>&nbsp;<a href="Javascript:copyPaste('<%=colName%>');" title="<%= Util.escapeHtml(tooltip) %>"><%= colDisp%></a></td>
<%
		if ((i+1)%5==0) out.println("</tr><tr>");
	}
	
%>

</tr></table>
</div>
<%
	List<TableCol> cols2 = new ArrayList<TableCol>();
	cols2.addAll(cols);

	Collections.sort(cols2, new Comparator<TableCol>() {
	    public int compare(TableCol col1, TableCol col2) {
	        return col1.getName().compareTo(col2.getName());
	    }
	});
%>
<div id="<%= divId %>-b" style="display:none;">
<table border=0 width=780>
<tr>
	<td width=20%></td>
	<td width=20%></td>
	<td width=20%></td>
	<td width=20%></td>
	<td width=20%></td>
</tr>
<tr>
<%	

	for (int i=0; i<cols2.size();i++) {
		TableCol col = cols2.get(i);
		String colName = col.getName();
		String colDisp = col.getName().toLowerCase();
		if (pk.contains(colName)) colDisp = "<span class='pk'>" + colDisp + "</span>";

		String tooltip = col.getTypeName();
		String comment = cn.getComment(tname, colName);
		if (comment != null && comment.length() > 0) tooltip += " " + comment;
%>
<td>&nbsp;<a href="Javascript:copyPaste('<%=colName%>');" title="<%= Util.escapeHtml(tooltip) %>"><%= colDisp%></a></td>
<%
		if ((i+1)%5==0) out.println("</tr><tr>");
	}
	
%>

</tr></table>
</div>

<br/>
</div>
