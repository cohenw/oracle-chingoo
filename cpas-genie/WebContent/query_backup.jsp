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
	if (sql==null) sql = "SELECT * FROM TABLE";
	sql = sql.trim();
	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
	sql = sql.replaceAll("&gt;",">").replace("&lt;","<");
	
	String norun = request.getParameter("norun");
	
	Connect cn = (Connect) session.getAttribute("CN");
	
	if (cn==null) {
%>	
		Connection lost. <a href="Javascript:window.close()">Close</a>
<%
		return;
	}
	
	int lineLength = Util.countLines(sql);
	if (lineLength <5) lineLength = 5;
	
	OldQuery q = new OldQuery(cn, sql, request);
	ResultSet rs = q.getResultSet();
	
	// get table name
	String tbl = null;
	//String temp = sql.replaceAll("\n", " ").trim();
	String temp=sql.replaceAll("[\n\r\t]", " ");
	
	int idx = temp.toUpperCase().indexOf(" FROM ");
	if (idx >0) {
		temp = temp.substring(idx + 6);
		idx = temp.indexOf(" ");
		if (idx > 0) temp = temp.substring(0, idx).trim();
		
		tbl = temp.trim();
		
		
		idx = tbl.indexOf(" ");
		if (idx > 0) tbl = tbl.substring(0, idx);
	}
//	System.out.println("XXX TBL=" + tbl);
	
	String tname = tbl;
	if (tname.indexOf(".") > 0) tname = tname.substring(tname.indexOf(".")+1);

	// Foreign keys - For FK lookup
	List<ForeignKey> fks = cn.getForeignKeys(tname);
	Hashtable<String, String>  linkTable = new Hashtable<String, String>();
//	Hashtable<String, String>  linkTable2 = new Hashtable<String, String>();
	
	List<String> fkLinkTab = new ArrayList<String>();
	List<String> fkLinkCol = new ArrayList<String>();
	
	for (int i=0; i<fks.size(); i++) {
		ForeignKey rec = fks.get(i);
		String linkCol = cn.getConstraintCols(rec.constraintName);
		String rTable = cn.getTableNameByPrimaryKey(rec.rConstraintName);
		
		System.out.println("linkCol=" + linkCol);
		System.out.println("rTable=" + rTable);
		
		int colCount = Util.countMatches(linkCol, ",") + 1;
		if (colCount == 1) {
			if (rTable != null) linkTable.put(linkCol, rTable);
			System.out.println("linkTable");
		} else {
			// check if columns are part of result set
			int matchCount = 0;
			String[] t = linkCol.split("\\,");
			for (int j=0;j<t.length;j++) {
				String colName = t[j].trim();
				for  (int k = 1; rs != null && k<= rs.getMetaData().getColumnCount(); k++){
					String col = q.getColumnLabel(k);
					if (col.equalsIgnoreCase(colName)) {
						matchCount++;
						continue;
					}
				}
			}
			if (rTable != null && matchCount==colCount) {
				fkLinkTab.add(rTable);
				fkLinkCol.add(linkCol);
			}
			System.out.println("linkTable2");
		}
	}
	
	// Primary Key for PK Link
	String pkName = cn.getPrimaryKeyName(tname);
	boolean pkLink = false;
	int pkColIndex = -1;
	
	List<String> pkColList = null;
	if (pkName != null) {
		pkColList = cn.getConstraintColList(pkName);
		
		// check if PK columns are in the result set
		int matchCount = 0;
		for (int j=0;j<pkColList.size();j++) {
			String colName = pkColList.get(j);
			for  (int i = 1; rs != null && i<= rs.getMetaData().getColumnCount(); i++){
				String col = q.getColumnLabel(i);
				if (col.equalsIgnoreCase(colName)) {
					matchCount++;
					continue;
				}
			}
		}

		// there should be other tables that has FK to this
		List<String> refTabs = cn.getReferencedTables(tname);
		if (matchCount == pkColList.size() && refTabs.size()>0) {
			pkLink = true;
		}
	}
%>
<html>
<head> 
	<title>Genie - Query</title>
    <link rel='stylesheet' type='text/css' href='css/style.css'>
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    <script src="script/query-methods.js?20120301" type="text/javascript"></script>
    
    <script type="text/javascript">
	$(document).ready(function() {
		showTable('<%=tbl%>');
	});	    
    </script>
</head> 

<body>
<table>
<td><br><img src="image/small-genie.gif"/></td>
<td><%= cn.getUrlString() %> Database: <%= cn.getSchemaName() %></td>
</table>

Table
<select size=1 id="selectTable" name=""selectTable"" onChange="showTable(this.options[this.selectedIndex].value);"">
	<option></option>
<% for (int i=0; i<cn.getTables().size();i++) { %>
	<option value="<%=cn.getTable(i)%>"><%=cn.getTable(i)%></option>
<% } %>
</select>

<input id="input-table" size=30 value="" onChange="showTable(this.value)"/>
<br/>


<!-- <div id="table-lookup"> -->
<!-- <form> -->
<!-- <table border=0> -->
<!-- <td valign=top> -->
<!-- <select size=10 id="selectTable" name="selectTable2" onChange="showTableCols(this.options[this.selectedIndex].value);"> -->
<%-- <% for (int i=0; i<cn.getTables().size();i++) { %> --%>
<%-- 	<option value="<%=cn.getTable(i)%>"><%=cn.getTable(i)%></option> --%>
<%-- <% } %> --%>
<!-- </select> -->
<!-- </td> -->
<!-- <td valign=top><div id="tableColumns"></div></td> -->
<!-- </table> -->
<!-- </form> -->
<!-- </div>  -->


<div id="table-detail"></div>

<a href="Javascript:copyPaste('SELECT');">SELECT</a>&nbsp;
<a href="Javascript:copyPaste('COUNT(*)');">COUNT(*)</a>&nbsp;
<a href="Javascript:copyPaste('FROM');">FROM</a>&nbsp;
<a href="Javascript:copyPaste('WHERE');">WHERE</a>&nbsp;
<a href="Javascript:copyPaste('=');">=</a>&nbsp;
<a href="Javascript:copyPaste('LIKE');">LIKE</a>&nbsp;
<a href="Javascript:copyPaste('IS');">IS</a>&nbsp;
<a href="Javascript:copyPaste('NOT');">NOT</a>&nbsp;
<a href="Javascript:copyPaste('NULL');">NULL</a>&nbsp;
<a href="Javascript:copyPaste('AND');">AND</a>&nbsp;
<a href="Javascript:copyPaste('OR');">OR</a>&nbsp;
<a href="Javascript:copyPaste('IN');">IN</a>&nbsp;
<a href="Javascript:copyPaste('()');">()</a>&nbsp;
<a href="Javascript:copyPaste('EXISTS');">EXISTS</a>&nbsp;
<a href="Javascript:copyPaste('GROUP BY');">GROUP-BY</a>&nbsp;
<a href="Javascript:copyPaste('HAVING');">HAVING</a>&nbsp;
<a href="Javascript:copyPaste('ORDER BY');">ORDER-BY</a>&nbsp;
<a href="Javascript:copyPaste('DESC');">DESC</a>&nbsp;

<form name="form1" id="form1" method="post" action="query_backup.jsp">
<textarea id="sql" name="sql" cols=100 rows=<%= lineLength %>><%= sql %></textarea><br/>
<input type="submit" value="Submit"/>
&nbsp;
<input type="button" value="Download" onClick="Javascript:download()"/>
</form>

<%= q.getMessage() %>

<%
	if (norun!=null || q.getResultSet() == null) {
%>
<br/><br/>
<a href="Javascript:window.close()">Close</a>
<br/><br/>

</body>
</html>
<%
		return;		
	}
%>

Time : <%=new Date()%>

<!-- <a href="Javascript:web()">web?</a> -->
<table id="dataTable" border=1 class="gridBody">
<tr>

<%
	int offset = 0;
	if (pkLink) {
		offset ++;
%>
	<th class="headerRow"><b>PK</b> <a href="Javascript:hide(<%= offset %>)">x</a></th>
<%
	}
	if (fkLinkTab.size()>0) {
		offset ++;
%>
	<th class="headerRow"><b>FK Link</b> <a href="Javascript:hide(<%= offset %>)">x</a></th>
<%
	}
	boolean numberCol[] = new boolean[500];

	boolean hasData = false;
	if (rs != null) hasData = rs.next();
	int colIdx = 0;
	for  (int i = 1; rs != null && i<= rs.getMetaData().getColumnCount(); i++){
	
		String colName = q.getColumnLabel(i);

			//System.out.println(i + " column type=" +rs.getMetaData().getColumnType(i));
			colIdx++;
			int colType = q.getColumnType(i);
			numberCol[colIdx] = Util.isNumberType(colType);
			
			String tooltip = ""; //q.getColumnTypeName(i);
			String comment =  cn.getComment(tname, colName);
			if (comment != null && comment.length() > 0) tooltip += " " + comment;
			
%>
<th class="headerRow"><b><a href="Javascript:copyPaste('<%=colName%>');" title="<%= tooltip %>"><%=colName%></a></b> <a href="Javascript:hide(<%=colIdx + offset%>)">x</a></th>
<%
	} 
%>
</tr>


<%
	int rowCnt = 0;
	while (rs != null && hasData/* && rs.next() */) {
		rowCnt++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";
%>
<tr>

<%
	if (pkLink) {
		String keyValue = null;
		
		for (int i=0;i<pkColList.size(); i++) {
			String v = q.getValue(pkColList.get(i));
			if (i==0) keyValue = v;
			else keyValue = keyValue + "^" + v; 
		}
		
		String linkUrl = "ajax/pk-link.jsp?table=" + tname + "&key=" + Util.encodeUrl(keyValue);
%>
	<td class="<%= rowClass%>"><a class='inspect' href='<%= linkUrl %>'><img border=0 src="image/link.gif"></a></td>
<%
	}
if (fkLinkTab.size()>0) {
%>
<td class="<%= rowClass%>">
<% 
	for (int i=0;i<fkLinkTab.size();i++) { 
		String t = fkLinkTab.get(i);
		String c = fkLinkCol.get(i);
		
		String keyValue = null;
		String[] colnames = c.split("\\,");
		for (int j=0; j<colnames.length; j++) {
			String x = colnames[j].trim();
			String v = q.getValue(x);
//			System.out.println("x,v=" +x +"," + v);
			if (keyValue==null)
				keyValue = v;
			else
				keyValue += "^" + v;
		}
		
		String url = "ajax/fk-lookup.jsp?table=" + t + "&key=" + Util.encodeUrl(keyValue);
%>
<a class="inspect" href="<%= url%>"><%=t%><img border=0 src="image/view.png"></a>&nbsp;

<%			} %>
</td>
<%		}
		colIdx=0;
		for  (int i = 1; i <= rs.getMetaData().getColumnCount(); i++){

				colIdx++;
				String val = q.getValue(i);
				String valDisp = Util.escapeHtml(val);
				if (val != null && val.endsWith(" 00:00:00")) valDisp = val.substring(0, val.length()-9);
				if (val==null) valDisp = "<span class='nullstyle'>null</span>";

				String colName = q.getColumnLabel(i);
				String lTable = linkTable.get(colName);
				String keyValue = val;
				boolean isLinked = false;
				String linkUrl = "";
				String linkImage = "image/view.png";
				if (lTable != null) {
					isLinked = true;
					linkUrl = "ajax/fk-lookup.jsp?table=" + lTable + "&key=" + Util.encodeUrl(keyValue);
				} else if (val != null && val.startsWith("BLOB ")) {
					isLinked = true;
					String tpkName = cn.getPrimaryKeyName(tbl);
					String tpkCol = cn.getConstraintCols(tpkName);
					String tpkValue = q.getValue(tpkCol);
					
					linkUrl ="ajax/blob.jsp?table=" + tbl + "&col=" + colName + "&key=" + Util.encodeUrl(tpkValue);
				}
				
				if (pkColIndex >0 && i == pkColIndex) {
					isLinked = true;
					linkUrl = "ajax/pk-link.jsp?table=" + tname + "&key=" + Util.encodeUrl(keyValue);
					linkImage = "image/link.gif";
				}
%>
<td  class="<%= rowClass%>" <%= (numberCol[colIdx])?"align=right":""%>><%=valDisp%>
<%= (val!=null && isLinked?"<a class='inspect' href='" + linkUrl  + "'><img border=0 src='" + linkImage + "'></a>":"")%>
</td>
<%
		}
%>
</tr>
<%		counter++;
//		if (counter >= Def.MAX_ROWS) break;
		
		if (!rs.next()) break;
	}
	
	q.close();

%>
</table>
<%= counter %> rows found.<br/>
Elapsed Time <%= q.getElapsedTime() %>ms.<br/>

<br/><br/>
<a href="Javascript:window.close()">Close</a>
<br/><br/>

</body>
</html>