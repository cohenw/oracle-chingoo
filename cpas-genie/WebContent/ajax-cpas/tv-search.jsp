<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	String keyword = Util.nvl(request.getParameter("keyword"));
	String ruleType = request.getParameter("ruleType");
	String key = keyword.toUpperCase().trim();

	String qry = "SELECT * FROM TREEVIEW WHERE UPPER(CAPTION) LIKE '%" + key + "%' OR TREEKEY='" + key + "' " +
				"UNION " +
				"SELECT * FROM TREEVIEW WHERE UDATA='"+key+"' " +
				"UNION " +
//				"SELECT * FROM TREEVIEW WHERE (SDI, SCHEMA, ACTIONID) IN (SELECT SDI, SCHEMA, ACTIONID FROM TREEACTION_STMT WHERE actiontype IN ('MS','DS','MT','DT') AND upper(actionstmt) like '%" + key + "%') " +
				"SELECT * FROM TREEVIEW WHERE (SDI, SCHEMA, ACTIONID) IN (SELECT SDI, SCHEMA, ACTIONID FROM TREEACTION_STMT WHERE upper(actionstmt) like '%" + key + "%') " +
				"ORDER BY 1, 2";
	
	if (ruleType != null) {
		qry = "SELECT * FROM TREEVIEW WHERE UDATA='"+ruleType+"' " +
				"ORDER BY 1, 2";
	}
	Query q = new Query(cn, qry, false);
Util.p(qry);
%>
<b>CPAS TreeView search for "<%= keyword %>"</b>
<br/><br/>

<b>Tree View</b>
<br/>

<table id="dataTable" border=1 class="gridBody">
<tr>
	<th class="headerRow">SDI</th>
	<th class="headerRow">Caption</th>
	<th class="headerRow">Treekey</th>
	<th class="headerRow">UDATA</th>
 </tr>

<%
	int rowCnt = 0;
	q.rewind(1000, 1);
	while (q.next() && rowCnt < 1000) {
		String sdi = q.getValue("sdi");
		String caption = q.getValue("caption");
		String treekey = q.getValue("treekey");
		String udata = Util.nvl(q.getValue("udata"));

		rowCnt ++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";	
		
		String sdiName = cn.queryOne("SELECT NAME FROM CPAS_SDI WHERE SDI='" + sdi + "'");
%>
<tr class="simplehighlight">
	<td class="<%= rowClass%>" nowrap><%= sdi %></a><br/><span class='cpas'><%= sdiName %></span></td>
	<td class="<%= rowClass%>" nowrap><a href="cpas-treeview.jsp?sdi=<%=sdi%>&treekey=<%=treekey%>"><%= caption %></a></td>
	<td class="<%= rowClass%>" nowrap><%= treekey %></td>
	<td class="<%= rowClass%>" nowrap><%= udata %></td>
</tr>
<%
	} 
%>
</table>
<br/>
