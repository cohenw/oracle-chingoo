<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.oracle.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	String table = request.getParameter("table");
	String owner = request.getParameter("owner");
	
	// incase owner is null & table has owner info
	if (owner==null && table!=null && table.indexOf(".")>0) {
		int idx = table.indexOf(".");
		owner = table.substring(0, idx);
		table = table.substring(idx+1);
	}
	
	System.out.println(cn.getUrlString() + " " + Util.getIpAddress(request) + " " + (new java.util.Date()) + "\nTable: " + table);
	
	String catalog = null;
	String tname = table;
	int idx = table.indexOf(".");
	if (idx>0) {
		catalog = table.substring(0, idx);
		tname = table.substring(idx+1);
	}
	if (catalog==null) catalog = cn.getSchemaName();
	
	String formName = "FORM_" + tname;
	String divName = "DIV_" + tname;
	if (table==null) { 
%>

Please select a Table to see the detail.

<%
		return;
	}
%>

<div id="objectTitle" style="display:none"><%= table %></div>

<h2>TABLE: <%= table %> &nbsp;&nbsp;<span class="rowcountstyle"><%= cn.getTableRowCount(owner, table) %></span>
<a href="Javascript:runQuery('','<%=tname%>')"><img border=0 src="image/icon_query.png" title="query"></a>
<a href="erd.jsp?tname=<%=tname%>" target="_blank"><img title="ERD" border=0 src="image/erd.gif"></a>
<a href="erd_svg.jsp?tname=<%=tname%>" target="_blank"><img title="Simple ERD" border=0 src="image/simple-erd.png"></a>
<a href="pop.jsp?type=TABLE&key=<%=tname%>" target="_blank"><img title="Pop Out" border=0 src="image/popout.png"></a>
</h2>

<%= owner==null?cn.getComment(tname):cn.getSynTableComment(owner, tname) %><br/>

<div id="<%= divName %>">
<form id="<%= formName %>">
<input name="table" type="hidden" value="<%= table %>"/>
<input name="query" type="hidden" value=""/>
<table id="dataTable" border=1 class="gridBody" style="margin-left: 10px;">
<tr>
	<th class="headerRow">Column Name</th>
	<th class="headerRow">Type</th>
	<th class="headerRow">Null</th>
	<th class="headerRow">Default</th>
	<th class="headerRow">Comments</th>
</tr>

<%	
	List<TableCol> list = cn.getTableDetail(owner, tname);
	int rowCnt = 0;
	for (int i=0;i<list.size();i++) {
		TableCol rec = list.get(i);
		
		// check if primary key
		String col_disp = rec.getName();
		if (rec.isPrimaryKey()) col_disp = "<span class='primary-key'>" + col_disp + "</span>";
		
		rowCnt++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";		
%>
<tr class="simplehighlight">
	<td class="<%= rowClass%>"><%= col_disp.toLowerCase() %></td>
	<td class="<%= rowClass%>"><%= rec.getTypeName() %></td>
	<td class="<%= rowClass%>"><%= rec.getNullable()==0?"N":"" %></td>
	<td class="<%= rowClass%>"><%= rec.getDefaults() %></td>
	<td class="<%= rowClass%>"><%= owner==null?cn.getComment(tname, rec.getName()):cn.getSynColumnComment(owner, tname, rec.getName()) %></td>
</tr>

<%
	}
%>
</table>
</form>

<%
	String pkName = cn.getPrimaryKeyName(tname);
	if (pkName == null && owner != null) pkName = cn.getPrimaryKeyName(owner, tname);

	String pkCols = cn.getConstraintCols(pkName);
	if (pkName != null && pkCols.equals(""))
		pkCols = cn.getConstraintCols(owner, pkName);
	
	List<ForeignKey> fks = cn.getForeignKeys(tname);
	if (owner != null) fks = cn.getForeignKeys(owner, tname);
	
	List<String> refTabs = cn.getReferencedTables(owner, tname);
	List<String> refPkgs = cn.getReferencedPackages(tname);
	List<String> refViews = cn.getReferencedViews(tname);
	List<String> refTrgs = cn.getReferencedTriggers(tname);
	List<String[]> refIdx = cn.getIndexes(owner, tname);
	List<String> refConst = cn.getConstraints(owner, tname);
%>
<hr>


<% if (pkName != null)  {%>
<b>Primary Key</b><br/>
&nbsp;&nbsp;&nbsp;&nbsp;<%= pkName %> (<%= pkCols.toLowerCase() %>) 

<br/><br/>
<% } %>


<% 
	if (fks.size()>0) { 
%>
<b>Foreign Key</b><br/>
<%

	for (int i=0; i<fks.size(); i++) {
		ForeignKey rec = fks.get(i);
		String rTable = rec.rTableName; //cn.getTableNameByPrimaryKey(rec.rConstraintName);
		boolean tabLink = true;
		if (rTable == null) {
//			rTable = rec.rOwner + "." + rec.rConstraintName;

			rTable = cn.getTableNameByPrimaryKey(rec.rOwner, rec.rConstraintName);
			
//			rTable = rec.rOwner + "." + rec.tableName;
			tabLink = false;
			tabLink = true;
		}
		if (!rec.rOwner.equalsIgnoreCase(cn.getSchemaName())) rTable = rec.rOwner + "." + rTable;
%>
&nbsp;&nbsp;&nbsp;&nbsp;<%= rec.constraintName %>
	(<%= cn.getConstraintCols(rec.owner, rec.constraintName).toLowerCase() %>)
	->
<%
	if (tabLink) {
%>
	<a href="Javascript:loadTable('<%= rTable %>')"><%= rTable %></a> <span class="rowcountstyle"><%= cn.getTableRowCount(rTable) %></span>
<%
	} else {
%>	
	<%= rTable %>
<%
	}
%>
	(<%= cn.getConstraintCols(rec.rOwner, rec.rConstraintName).toLowerCase() %>)
	
	On delete <%= rec.deleteRule %>
	<br/>
<%
 }
%>
	<br/>
<%
} 
%>

<% 
	if (refConst.size()>0) { 
%>
<b>Constraints</b><br/>
<%

	for (int i=0; i<refConst.size(); i++) {
		String constName = refConst.get(i);
%>
	&nbsp;&nbsp;&nbsp;&nbsp;<%= constName %> 
	<br/>
<%
	}
%>
<br/>
<%
	}
%>

<% 
	if (refIdx.size()>0) { 
%>
<b>Index</b><br/>
<%

	for (int i=0; i<refIdx.size(); i++) {
		String indexName = refIdx.get(i)[0];
		String indexType = refIdx.get(i)[1];
		if (indexType.equals("NONUNIQUE")) indexType= "";
%>
	&nbsp;&nbsp;&nbsp;&nbsp;<%= indexName %> 
	<%= cn.getIndexColumns(owner, indexName).toLowerCase() %>
	<%= indexType %> 
	<br/>
<%
	}
%>
<br/>
<%
}
%>


<% 
	if (refTabs.size()>0) { 
%>

<b>Related Table</b>
<a href="Javascript:toggleDiv('imgTable','divTable')"><img id="imgTable" border=0 src="image/minus.gif"></a>
<div id="divTable">
<table border=0 width=800>
<td width=4%>&nbsp;</td>
<td valign=top width=32%>
<%
	int listSize = (refTabs.size() / 3) + 1;
	int cnt = 0;
	int cols =1;
	for (int i=0; i<refTabs.size(); i++) {
		String refTab = refTabs.get(i);
		cnt++;
%>

<% if ((cnt-1)>=listSize) { %>
		</td><td valign=top width=32%>
<%
		cols ++;
		cnt = 1;
	}
%>

		<a href="Javascript:loadTable('<%= refTab %>')"><%= refTab %></a> <span class="rowcountstyle"><%= cn.getTableRowCount(refTab) %></span>&nbsp;&nbsp;<br/>		
<% }

	for (; cols<=3; cols++) {
%>
	</td><td valign=top width=32%>
<% } %>


</td>
</table>
</div>
<br/>
<% }
%>

<% 
	if (refViews.size()>0) { 
%>
<b>Related View</b>
<a href="Javascript:toggleDiv('imgView','divView')"><img id="imgView" border=0 src="image/minus.gif"></a>
<div id="divView">
<table border=0 width=800>
<td width=4%>&nbsp;</td>
<td valign=top width=32%>
<%
	int listSize = (refViews.size() / 3) + 1;
	int cnt = 0;
	int cols = 1;
	for (int i=0; i<refViews.size(); i++) {
		String refView = refViews.get(i);
		cnt++;
%>

<% if ((cnt-1)>=listSize) { %>
		</td><td valign=top width=32%>
<%
		cnt = 1;
		cols++;
	} 
%>

		<a href="Javascript:loadView('<%= refView %>')"><%= refView %></a>&nbsp;&nbsp;<br/>		
<% }
	for (; cols<=3; cols++) {
%>
	</td><td valign=top width=32%>
<% } %>

</td>
</table>
</div>
<br/>
<%
	}
%>


<% 
	if (refTrgs.size()>0) { 
%>
<b>Related Trigger</b>
<a href="Javascript:toggleDiv('imgTrg','divTrg')"><img id="imgTrg" border=0 src="image/minus.gif"></a>
<div id="divTrg">
<table border=0 width=800>
<td width=4%>&nbsp;</td>
<td valign=top width=32%>
<%
	int listSize = ((refTrgs.size()-1) / 3) + 1;
	int cnt = 0;
	int cols = 1;
	for (int i=0; i<refTrgs.size(); i++) {
		String refTrg = refTrgs.get(i);
		cnt++;
%>

<% if ((cnt-1)>=listSize) { %>
		</td><td valign=top width=32%>
<%
		cnt = 1;
		cols ++;
	} 
%>

		<a href="Javascript:loadPackage('<%= refTrg %>')"><%= refTrg %></a>&nbsp;&nbsp;<br/>		
<% }
	for (; cols<=3; cols++) {
%>
	</td><td valign=top width=32%>
<% } %>

</td>
</table>
</div>
<br/>
<%
}
%>

<% 
	if (refPkgs.size()>0) { 
%>
<b>Related Program</b>
<a href="Javascript:toggleDiv('imgPgm','divPgm')"><img id="imgPgm" border=0 src="image/minus.gif"></a>
<div id="divPgm">
<table border=0 width=800>
<td width=4%>&nbsp;</td>
<td valign=top width=32%>
<%
	int listSize = (refPkgs.size() / 3) + 1;
	int cnt = 0;
	int cols = 1;
	for (int i=0; i<refPkgs.size(); i++) {
		String refPkg = refPkgs.get(i);
		cnt++;
%>

<% if ((cnt-1)>=listSize) { %>
		</td><td valign=top width=32%>
<%
		cnt = 1;
		cols ++;
	} 
%>

		<a href="Javascript:loadPackage('<%= refPkg %>')"><%= refPkg %></a>&nbsp;&nbsp;<br/>		
<% }
	for (; cols<=3; cols++) {
%>
	</td><td valign=top width=32%>
<% } %>

</td>
</table>
</div>

<%
}
%>


</div>
