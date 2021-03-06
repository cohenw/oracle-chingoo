<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	boolean cpas = true;
	int counter = 0;
	String sql = request.getParameter("sql");
	String id = request.getParameter("id");
	
	String pageNo = request.getParameter("pageNo");
	int pgNo = 1;
	if (pageNo != null) pgNo = Integer.parseInt(pageNo);

	String sortColumn = request.getParameter("sortColumn");
	String sortDirection = request.getParameter("sortDirection");
	
	if (sql==null) sql = "SELECT * FROM TABLE";
	sql = sql.trim();
	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
	sql = sql.replaceAll("&gt;",">").replace("&lt;","<");

System.out.println("sql=" + sql);	
	String searchValue = request.getParameter("searchValue");
	if (searchValue==null) searchValue = "";
	
	Connect cn = (Connect) session.getAttribute("CN");
	Query q = new Query(cn, sql);

	if (q.isError()) {
%>
	<%= q.getMessage() %>
<%		
		return;
	}

	q.removeFilter();
	if (sortColumn != null && !sortColumn.equals("")) q.sort(sortColumn, sortDirection);
	if (searchValue !=null && !searchValue.equals("")) q.search(searchValue);

	// get table name
	String tbl = null;
	List<String> tbls = Util.getTables(sql); 
	if (tbls.size()>0) tbl = tbls.get(0);

	String tname = tbl;
	if (tname.indexOf(".") > 0) tname = tname.substring(tname.indexOf(".")+1);

	int linesPerPage = 20;
	int totalCount = q.getRecordCount();
	int filteredCount = q.getFilteredCount();
	int totalPage = q.getTotalPage(linesPerPage);
	
	// Primary Key for PK Link
	String pkName = cn.getPrimaryKeyName(tname);
	int pkColIndex = -1;	boolean hasPK = false;
	List<String> pkColList = null;
	if (pkName != null) {
		pkColList = cn.getConstraintColList(pkName);
		
		// check if PK columns are in the result set
		int matchCount = 0;
		for (int j=0;j<pkColList.size();j++) {
			String colName = pkColList.get(j);
			for  (int i = 0; i<= q.getColumnCount()-1; i++){
				String col = q.getColumnLabel(i);
				if (col.equalsIgnoreCase(colName)) {
					matchCount++;
					continue;
				}
			}
		}

		hasPK = pkColList.size() > 0 && (pkColList.size() == matchCount);
	}
	
%>

<% if (q.getRecordCount() > 0) { %>

<div style="float: left;">
<% if (pgNo>1) { %>
<a href="Javascript:gotoPageWork(<%=id%>, <%= pgNo - 1%>)"><img border=0 src="image/prev.png" border=0 align="bottom"></a>
<% } %>

<% if (totalPage > 1) { %>
Page: <b><%= pgNo %></b> of <%= totalPage %>
<% } %>

<% if (q.getTotalPage(linesPerPage) > pgNo) { %>
<a href="Javascript:gotoPageWork(<%=id%>, <%= pgNo + 1%>)"><img border=0 src="image/next.png" border=0 align="bottom"></a>
<% } %>

Found: <%= filteredCount %>
<% if (totalCount > filteredCount) {%>
(of <%= totalCount %>)
<% } %>
</div>

<div id="help-<%= id %>" style="float: left; display: block;" >
&nbsp; &nbsp;
<a id="modeHide-<%=id%>" href="Javascript:setColumnMode(<%=id%>,'hide')">Hide</a>
<a href="Javascript:showAllColumnTable('table-<%=id%>')">Show All</a>&nbsp;
<% if (totalCount>=2) { %>
<a id="modeSort-<%=id%>" href="Javascript:setColumnMode(<%=id%>,'sort')">Sort</a>
<% } %>

&nbsp;&nbsp;&nbsp;&nbsp;
<% if (totalCount>=10) { %>
<img src="image/view.png" border=0 ><input id="search-<%=id%>" value="<%= searchValue %>" size=15 onChange="searchTableWork(<%=id%>,$(this).val())">
<a href="Javascript:clearSearchWork(<%=id%>)"><img border="0" border=0 src="image/clear.gif"></a>
<% } %>
</div>
<br clear="all"/>
<% } %>

<table id="table-<%= id %>" border=1 class="gridBody">
<tr>
<%
	int offset = 0;
	if (hasPK) {
		offset ++;
%>
	<th class="headerRow">Link</th>
<%
	}

	boolean numberCol[] = new boolean[500];
	int colIdx = 0;
	for  (int i = 0; i<= q.getColumnCount()-1; i++){
	
		colIdx++;
		String colName = q.getColumnLabel(i);
		int colType = q.getColumnType(i);
		numberCol[colIdx] = Util.isNumberType(colType);
			
		String tooltip = q.getColumnToolTip(i);
		String comment =  cn.getComment(tname, colName);
		if (comment != null && comment.length() > 0) tooltip += " " + comment;
			
		String extraImage = "";
		boolean highlight = false;
		if (colName.equals(sortColumn)) {
			highlight = true;
			if (sortDirection.equals("0"))
				extraImage = "<img src='image/sort-ascending.png'>";
			else
				extraImage = "<img src='image/sort-descending.png'>";
		}
		
		String cpasDisp = "";
		if (cpas) {
			String capt = cn.getCpasCodeCapt(tname, colName);
			if (capt != null) 
				cpasDisp += "<br/> &gt;  <span class='cpas'>" + capt + "</span>";
		}			
		
%>
<th class="headerRow"><a <%= ( highlight?"style='background-color:yellow;'" :"")%>
	href="Javascript:setColumn(<%= id %>, '<%=colName%>', <%= colIdx%>);" title="<%= Util.escapeHtml(tooltip) %>"><%=colName.toLowerCase()%></a>
	<%= extraImage %><%= cpasDisp %>
</th>
<%
	} 
%>
</tr>

<%
	int rowCnt = 0;
	q.rewind(linesPerPage, pgNo);
	String pkValues = ""; 
	
	while (q.next()) {
		rowCnt++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";
%>
<tr class="simplehighlight">
<%
	if (hasPK && q.hasData()) {
		String keyValue = null;
	
		for (int i=0;q.hasData() && i<pkColList.size(); i++) {
			String v = q.getValue(pkColList.get(i));
			if (i==0) keyValue = v;
			else keyValue = keyValue + "^" + v; 
		}
		pkValues = keyValue;
		
		String linkUrlTree = "data-link.jsp?table=" + tname + "&key=" + Util.encodeUrl(keyValue);
		linkUrlTree = "data-link.jsp?qry=" + tname + "|" + keyValue;
%>
	<td class="<%= rowClass%>">
		<a target="_blank" href='<%= linkUrlTree %>'><img src="image/star.png" border=0 title="Data link" onmouseover="this.src='image/star2.png';" onmouseout="this.src='image/star.png';"></a>
	</td>
<%
	}

	colIdx=0;
	for  (int i = 0; q.hasData() && i < q.getColumnCount(); i++){
		colIdx++;
		String val = q.getValue(i);
		String valDisp = Util.escapeHtml(val);
		if (val != null && val.endsWith(" 00:00:00")) valDisp = val.substring(0, val.length()-9);
		if (val==null) valDisp = "<span class='nullstyle'>null</span>";
		if (val !=null && val.length() > 50) {
			id = Util.getId();
			String id_x = Util.getId();
			valDisp = valDisp.substring(0,50) + "<a id='"+id_x+"' href='Javascript:toggleText(" +id_x + "," +id +")'>...</a><span id='"+id+"' style='display: none;'>" + valDisp.substring(50) + "</span>";
		}
			
		String colName = q.getColumnLabel(i);
		String keyValue = val;
		
		if (cpas) {

			
			String code = cn.getCpasCodeValue(tname, colName, val, q);
			if (code!=null && !code.equals(""))	{
				valDisp += "<br/> &gt; <span class='cpas'>" + code + "</span>";
			}
		}		
%>
<td class="<%= rowClass%>" <%= (numberCol[colIdx])?"align=right":""%>><%=valDisp%>
</td>
<%
	}
%>
</tr>
<%
		if (q.hasData()) counter++;
		if (counter >= linesPerPage) break;
	}
%>
</table>
</div>