<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	String view = request.getParameter("view");
	String owner = request.getParameter("owner");
	
	Connect cn = (Connect) session.getAttribute("CN");

	// incase owner is null & table has owner info
	if (owner==null && view!=null && view.indexOf(".")>0) {
		int idx = view.indexOf(".");
		owner = view.substring(0, idx);
		view = view.substring(idx+1);
	}
//	System.out.println(cn.getUrlString() + " " + Util.getIpAddress(request) + " " + (new java.util.Date()) + "\nView: " + view);
	
	String catalog = cn.getSchemaName();
	if (cn.getTargetSchema() != null) owner = cn.getTargetSchema();

	String qry = "SELECT TEXT FROM USER_VIEWS WHERE VIEW_NAME='" + view +"'";
	if (owner != null) 
		qry = "SELECT TEXT FROM ALL_VIEWS WHERE OWNER='" + owner + "' AND VIEW_NAME='" + view +"'"; 
	
	boolean hasCpas = cn.hasCpas(view);
	String cpasComment = cn.getCpasComment(view);
	List<String> refProc = cn.getReferencedProc(view);
%>
<div id="objectTitle" style="display:none">VIEW: <%= view %></div>
<h2>VIEW: <%= view %> &nbsp;&nbsp;<a href="Javascript:runQuery('<%=catalog%>','<%=view%>')"><img border=0 src="image/icon_query.png" title="query"></a>
<a href="pop.jsp?type=VIEW&key=<%=view%>" target="_blank"><img title="Pop Out" border=0 src="image/popout.png"></a>
</h2>

<%= owner==null?cn.getComment(view):cn.getSynTableComment(owner, view) %> <span class="cpas"><%= cpasComment %></span><br/>

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
	List<TableCol> list = cn.getTableDetail(owner, view);
	int rowCnt = 0;
	for (int i=0;i<list.size();i++) {
		TableCol rec = list.get(i);
		
		// check if primary key
		String col_disp = rec.getName().toLowerCase();
		if (rec.isPrimaryKey()) col_disp = "<span class='primary-key'>" + col_disp + "</span>";
		
		String capt = cn.getCpasCodeCapt(view, rec.getName());
		if (capt == null) capt = "";
		
		String grup = cn.getCpasCodeGrup(view, rec.getName());
		if (grup == null || grup.equals("_")) grup = "";
		
		if (grup != null && !grup.equals("")) {
			String codeTable = cn.getCpasUtil().getCpasCodeTable();
			//grup = " -&gt; <a href=\"javascript:showDialog('" + codeTable + "','"+grup+"')\">" + grup + "</a>";
			grup = " -&gt; <a href=\"javascript:showCpasCode('"+grup+"')\">" + grup + "</a>";
		}

		rowCnt++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";		
%>
<tr class="simplehighlight">
	<td align=right class="<%= rowClass%>"><%= i+1 %></td>
	<td class="<%= rowClass%>"><%= col_disp %></td>
	<td class="<%= rowClass%>"><%= rec.getTypeName() %></td>
	<td class="<%= rowClass%>"><%= rec.getNullable()==0?"N":"" %></td>
	<td class="<%= rowClass%>"><%= rec.getDefaults() %></td>
 	<td class="<%= rowClass%>"><%= owner==null?cn.getComment(view, rec.getName()):cn.getSynColumnComment(owner, view, rec.getName()) %></td>
<% if (hasCpas) { %>	
	<td class="<%= rowClass%>"><span class="cpas"><%= capt %></span> <%= grup %></td>
<% } %>	
</tr>

<%
	}
%>
</table>

<hr>

<%
	String text = cn.queryOne(qry, false);
%>
<b>Definition</b> 
<a href="Javascript:toggleDiv('imgDef','divDef')"><img id="imgDef" src="image/minus.gif"></a>
<div id="divDef" style="margin-left: 20px;">
<pre style="font-family: Consolas;">
<%=new HyperSyntax().getHyperSyntax(cn, text, "VIEW")%>
</pre>
</div>
 
<hr>

<br/>
<%

	List<String> refTrgs = cn.getReferencedTriggers(view);

	if (refTrgs.size()>0) { 
%>
<b>Related Trigger</b>
<a href="Javascript:toggleDiv('imgTrg','divTrg')"><img id="imgTrg" src="image/minus.gif"></a>
<div id="divTrg">
<table border=0>
<td width=10>&nbsp;</td>
<td valign=top>
<%
	int listSize = (refTrgs.size() / 3) + 1;
	int cnt = 0;
	for (int i=0; i<refTrgs.size(); i++) {
		String refTrg = refTrgs.get(i);
		cnt++;
%>

<% if ((cnt-1)>=listSize) { %>
		</td><td valign=top>
<%
		cnt = 1;
	} 
%>

		<a href="Javascript:loadPackage('<%= refTrg %>')"><%= refTrg %></a>&nbsp;&nbsp;<br/>		
<% }
%>
</td>
</table>
</div>
<%
}
%>

<b>Dependencies</b>

<table>
<tr>
	<td>&nbsp;</td>
	<td bgcolor=#ccccff>Program</td>
	<td bgcolor=#ccccff>Table</td>
	<td bgcolor=#ccccff>View</td>
	<td bgcolor=#ccccff>Synonym</td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td valign=top><%= cn.getDependencyPackage(owner, view) %></td>
	<td valign=top><%= cn.getDependencyTable(owner, view) %></td>
	<td valign=top><%= cn.getDependencyView(owner, view) %></td>
	<td valign=top><%= cn.getDependencySynonym(owner, view) %></td>
</tr>
</table>
<br/>

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
		String temp[] = refPrc.split("\\.");
		cnt++;
%>

<% if ((cnt-1)>=listSize) { %>
		</td><td valign=top width=50%>
<%
		cnt = 1;
		cols ++;
	} 
%>

		<a target=_blank href="package-browser.jsp?name=<%= refPrc %>"><%= refPrc %></a>&nbsp;&nbsp;<%= cn.getCRUD(temp[0],temp[1].toUpperCase(), view) %><br/>		
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

