<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="chingoo.oracle.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	int counter = 0;
	
	String sql = request.getParameter("sql");

	if (sql==null) sql = "SELECT * FROM TABLE";
	sql = sql.trim();
	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
	sql = sql.replaceAll("&gt;",">").replace("&lt;","<");
	
	Connect cn = (Connect) session.getAttribute("CN");
	
//	Query q = (Query) session.getAttribute(sql);
	Query q = cn.queryCache.getQueryObject(sql);
	if (q==null) {
		q = new Query(cn, sql);
		cn.queryCache.addQuery(sql, q);
	} else {
//		System.out.println("*** REUSE Query");
	}
%>
<a href="Javascript:resetFilter()">Reset filter</a>
<!-- &nbsp;
<a href="Javascript:hideFilterWithOneValue()">Hide filters that have only one value</a>
 -->
<table id="filterTable" border=1 class="gridBody">
<tr>
<%
for (int c=0; c<q.getColumnCount();c++) {	
	String cname = q.getColumnLabel(c);

%>
<th class="headerRow"><%= cname.toLowerCase() %> <a href="Javascript:removeFilterCol(<%=c+1%>)"><img border=0 src="image/delete.png"></a></th>
<%
}
%>
</tr>
<tr>
<%
for (int c=0; c<q.getColumnCount();c++) {	
	String cname = q.getColumnLabel(c);
	List<FilterRecord> list = q.getFilterListWithCount(c);
%>

<td>
<select size=10 id="filterSelect-<%=c%>" class="filterCol" onchange="setFilter()" style="font-size: 12px;">
<option value="">All</option>
<% for (int i=0; i<list.size(); i++) { 
		FilterRecord rec = list.get(i);
		String value = rec.getValue();
		String dispValue = value;
		if (rec.getCount() > 1) dispValue += "\t[" + rec.getCount() + "]";
%>
	<option value="<%= value %>"><%= dispValue %></option>
<% } %>
</select>
</td>
<%
}
%>
</tr>
</table>

