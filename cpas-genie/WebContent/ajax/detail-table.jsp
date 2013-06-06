<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
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
	
	//System.out.println(cn.getUrlString() + " " + Util.getIpAddress(request) + " " + (new java.util.Date()) + "\nTable: " + table);
	//System.out.println("owner=" + owner);
	
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
	
	boolean hasCpas = cn.hasCpas(tname);
//System.out.println("hasCpas=" +hasCpas);
	String cpasComment = cn.getCpasComment(table);
	boolean isTempTable = cn.isTempTable(table);
%>

<div id="objectTitle" style="display:none"><%=(isTempTable?"TEMPORARY TABLE":"TABLE")%>: <%= table %></div>
<h2><%=(isTempTable?"TEMPORARY TABLE":"TABLE")%>: <%= table %> &nbsp;&nbsp;<span class="rowcountstyle"><%= cn.getTableRowCount(owner, table) %></span>
<a href="Javascript:runQuery('','<%=tname%>')"><img border=0 src="image/icon_query.png" title="query"></a>
<a href="erd.jsp?tname=<%=tname%>" target="_blank"><img title="ERD" border=0 src="image/erd.gif"></a>
<a href="erd_svg.jsp?tname=<%=tname%>" target="_blank"><img title="Simple ERD" border=0 src="image/simple-erd.png"></a>
<a href="pop.jsp?type=TABLE&key=<%=tname%>" target="_blank"><img title="Pop Out" border=0 src="image/popout.png"></a>
</h2>
<%= owner==null?cn.getComment(tname):cn.getSynTableComment(owner, tname) %> <span class="cpas"><%= cpasComment %></span><br/>

<div id="<%= divName %>">
<form id="<%= formName %>">
<input name="table" type="hidden" value="<%= table %>"/>
<input name="query" type="hidden" value=""/>
<table id="dataTable" border=1 class="gridBody" style="margin-left: 10px;">
<tr>
	<th class="headerRow">Idx</th>
	<th class="headerRow">Column Name</th>
	<th class="headerRow">Type</th>
	<th class="headerRow">Null</th>
	<th class="headerRow">Default</th>
	<th class="headerRow">Comments</th>
<% if (hasCpas) { %>	
	<th class="headerRow">CPAS</th>
<% } %>	
</tr>

<%	
	List<TableCol> list = cn.getTableDetail(owner, tname);
	int rowCnt = 0;
	for (int i=0;i<list.size();i++) {
		TableCol rec = list.get(i);
		
		// check if primary key
		String col_disp = rec.getName();
		if (rec.isPrimaryKey()) col_disp = "<span class='primary-key'>" + col_disp + "</span>";
		
		String capt = cn.getCpasCodeCapt(tname, rec.getName());
		if (capt == null) capt = "";
//System.out.println("tname"+tname + " " + rec.getName() + " : " + capt);		
		String grup = cn.getCpasCodeGrup(tname, rec.getName());
		if (grup == null || grup.equals("_")) grup = "";
		
		if (grup != null && !grup.equals("")) {
			String codeTable = cn.getCpasUtil().getCpasCodeTable();
//			grup = " -&gt; <a href=\"javascript:showDialog('" + codeTable + "','"+grup+"')\">" + grup + "</a>";
			grup = " -&gt; <a href=\"javascript:showCpasCode('"+grup+"')\">" + grup + "</a>";
		}
		
		rowCnt++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";		
%>
<tr class="simplehighlight">
	<td align=right class="<%= rowClass%>"><%= i+1 %></td>
	<td class="<%= rowClass%>"><%= col_disp.toLowerCase() %></td>
	<td class="<%= rowClass%>"><%= rec.getTypeName() %></td>
	<td class="<%= rowClass%>"><%= rec.getNullable()==0?"N":"" %></td>
	<td class="<%= rowClass%>"><%= rec.getDefaults() %></td>
	<td class="<%= rowClass%>"><%= owner==null?cn.getComment(tname, rec.getName()):cn.getSynColumnComment(owner, tname, rec.getName()) %></td>
<% if (hasCpas) { %>	
	<td class="<%= rowClass%>"><span class="cpas"><%= capt %></span> <%= grup %></td>
<% } %>	

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

	List<String> refProc = cn.getReferencedProc(tname);
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

		<a href="Javascript:loadPackage('<%= refTrg %>')"><%= refTrg %></a>&nbsp;&nbsp;<%= cn.getTriggerCRUD(refTrg, table) %><br/>		
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

		<a href="Javascript:loadPackage('<%= refPkg %>')"><%= refPkg %></a>&nbsp;&nbsp;<%= cn.getCRUD(refPkg, table) %><br/>		
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


<% 
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
		<a target=_blank href="package-browser.jsp?name=<%= refPrc %>"><%= refPrc %></a>&nbsp;&nbsp;<%= cn.getCRUD(temp[0],temp[1].toUpperCase(), table) %><br/>		
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

<div style="display: none;">
<form name="form0" id="form0" action="query.jsp" target="_blank">
<input id="sql" name="sql" type="hidden" value=""/>
<input id="dataLink" name="dataLink" type="hidden" value="1"/>
<input id="id" name="id" type="hidden" value=""/>
<input id="showFK" name="showFK" type="hidden" value="0"/>
<input type="hidden" id="sortColumn" name="sortColumn" value="">
<input type="hidden" id="sortDirection" name="sortDirection" value="0">
<input type="hidden" id="hideColumn" name="hideColumn" value="">
<input type="hidden" id="filterColumn" name="filterColumn" value="">
<input type="hidden" id="filterValue" name="filterValue" value="">
<input type="hidden" id="searchValue" name="searchValue" value="">
<input type="hidden" id="pageNo" name="pageNo" value="1">
<input type="hidden" id="rowsPerPage" name="rowsPerPage" value="20">
</form>
</div>

