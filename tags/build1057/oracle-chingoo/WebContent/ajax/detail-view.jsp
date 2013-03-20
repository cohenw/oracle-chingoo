<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.oracle.*" 
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
	System.out.println(cn.getUrlString() + " " + Util.getIpAddress(request) + " " + (new java.util.Date()) + "\nView: " + view);
	
	String catalog = cn.getSchemaName();

	String qry = "SELECT TEXT FROM USER_VIEWS WHERE VIEW_NAME='" + view +"'";
	if (owner != null) 
		qry = "SELECT TEXT FROM ALL_VIEWS WHERE OWNER='" + owner + "' AND VIEW_NAME='" + view +"'"; 
	
%>
<div id="objectTitle" style="display:none"><%= view %></div>
<h2>VIEW: <%= view %> &nbsp;&nbsp;<a href="Javascript:runQuery('<%=catalog%>','<%=view%>')"><img border=0 src="image/icon_query.png" title="query"></a>
<a href="pop.jsp?type=VIEW&key=<%=view%>" target="_blank"><img title="Pop Out" border=0 src="image/popout.png"></a>
</h2>

<%= owner==null?cn.getComment(view):cn.getSynTableComment(owner, view) %><br/>

<table id="dataTable" border=1 class="gridBody" style="margin-left: 10px;">
<tr>
	<th class="headerRow">Column Name</th>
	<th class="headerRow">Type</th>
	<th class="headerRow">Null</th>
	<th class="headerRow">Default</th>
 	<th class="headerRow">Comments</th>
 </tr>

<%	
	List<TableCol> list = cn.getTableDetail(owner, view);
	int rowCnt = 0;
	for (int i=0;i<list.size();i++) {
		TableCol rec = list.get(i);
		
		// check if primary key
		String col_disp = rec.getName().toLowerCase();
		if (rec.isPrimaryKey()) col_disp = "<span class='primary-key'>" + col_disp + "</span>";
		
		rowCnt++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";		
%>
<tr class="simplehighlight">
	<td class="<%= rowClass%>"><%= col_disp %></td>
	<td class="<%= rowClass%>"><%= rec.getTypeName() %></td>
	<td class="<%= rowClass%>"><%= rec.getNullable()==0?"N":"" %></td>
	<td class="<%= rowClass%>"><%= rec.getDefaults() %></td>
 	<td class="<%= rowClass%>"><%= owner==null?cn.getComment(view, rec.getName()):cn.getSynColumnComment(owner, view, rec.getName()) %></td>
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
<pre>
<%= text %>
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

