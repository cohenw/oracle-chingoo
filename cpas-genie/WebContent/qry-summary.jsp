<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	int counter = 0;
	String sql = request.getParameter("sql");
	String sortColumn = request.getParameter("sortColumn");
	String sortDirection = request.getParameter("sortDirection");
	String pageNo = request.getParameter("pageNo");
	
	String filterColumn = request.getParameter("filterColumn");
	String filterValue = request.getParameter("filterValue");
	String filter2 = request.getParameter("filter2");
	String searchValue = request.getParameter("searchValue");
	if (searchValue==null) searchValue = "";

	if (sql==null) sql = "SELECT * FROM TABLE";
	sql = sql.trim();
	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
	sql = sql.replaceAll("&gt;",">").replace("&lt;","<");
	
	String norun = request.getParameter("norun");
	
	Connect cn = (Connect) session.getAttribute("CN");
	
	int lineLength = Util.countLines(sql);
	if (lineLength <5) lineLength = 5;
	
	Query q = cn.queryCache.getQueryObject(sql);
	if (q==null) {
		q = new Query(cn, sql);
		cn.queryCache.addQuery(sql, q);
	} else {
	}

	if (q.isError()) {
%>
		<%= q.getMessage() %>
<%		
		return;
	}
	
	q.removeFilter();

	if (sortColumn != null && !sortColumn.equals("")) q.sort(sortColumn, sortDirection);
	if (filterColumn != null && !filterColumn.equals("")) {
		if (filterColumn.equals("0")) {
			filterColumn = q.getColumnLabel(0);
		}
		q.filter(filterColumn, filterValue);
	}
	
	if (filter2 != null && !filter2.equals("")) {
		q.filter2(filter2);
	}
	
	if (searchValue !=null && !searchValue.equals("")) {
		q.search(searchValue);
	}
	
	// get table name
	String tbl = Util.getMainTable(sql);
	List<String> tbls = Util.getTables(sql); 
	if (tbls.size()>0) tbl = tbls.get(0);

	String tname = tbl;
	if (tname==null) tname = "";
	if (tname.indexOf(".") > 0) tname = tname.substring(tname.indexOf(".")+1);

%>

<%--
<%= cn.getUrlString() %>&nbsp;&nbsp;&nbsp;&nbsp; <%= new Date() %>
--%>
<b>Summary</b> 

<table id="dataTable" border=1 class="gridBody">
<tr>

<%
	int offset = 0;
		offset ++;
%>
	<th class="headerRow"><b></b></th>
<%
	boolean numberCol[] = new boolean[500];

	boolean hasData = q.hasMetaData();
	q.calcSummary();
	
	int colIdx = 0;
	for  (int i = 0; i<= q.getColumnCount()-1; i++){
	
		String colName = q.getColumnLabel(i);

		colIdx++;
		int colType = q.getColumnType(i);
		numberCol[colIdx] = Util.isNumberType(colType);
			
		String colDisp = colName.toLowerCase();
%>
<th class="headerRow"><%=colDisp%></a>
</th>
<%
	} 
%>
</tr>


<%
	String rowName[] = {"Count","Min","Max","Sum"};

	int rowCnt = 0;
	String pkValues = ""; 

	q.rewind(1000, 1);
	q.next();
	
	for (int row=0;row<rowName.length; row++) {
		rowCnt++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";
%>
<tr class="simplehighlight">
<td style="background-color: #D6E7FF">
<b><%= rowName[row] %></b>
</td>
<%
	colIdx=0;
	for  (int i = 0; i < q.getColumnCount(); i++){
		colIdx++;
		
		String val = "";
		if (row==0)
			val = q.getSummaryCount(colIdx); 
		else if (row==1)
			val = q.getSummaryMin(colIdx); 
		else if (row==2)
			val = q.getSummaryMax(colIdx); 
		else if (row==3)
			val = q.getSummarySum(colIdx); 
		
		if (val==null) val = "";
		String colTypeName = q.getColumnTypeName(i);
		String valDisp = Util.escapeHtml(val);
		if (val != null && val.endsWith(" 00:00:00")) valDisp = val.substring(0, val.length()-9);
		if (val==null || val.equals("")) valDisp = "<span class='nullstyle'>null</span>";
		if (val !=null && val.length() > 200) {
			String id = Util.getId();
			String id_x = Util.getId();
			valDisp = valDisp.substring(0,200) + "<a id='"+id_x+"' href='Javascript:toggleText2(" +id_x + "," +id +")'>...</a><span id='"+id+"' style='display: none;'>" + valDisp.substring(200) + "</span>";
			
		}
%>
<td class="<%= rowClass%>" <%= ( row==0 || numberCol[colIdx])?"align=right":""%>><%=valDisp%>
</td>
<%
		}
%>
</tr>
<%		if (q.hasData()) counter++;
	}
%>
</table>
<br/>


