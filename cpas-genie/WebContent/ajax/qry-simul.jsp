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
	String sql2 = request.getParameter("sql2");
	String id = request.getParameter("id");
	String layout = request.getParameter("layout");
	String appLayout = request.getParameter("applylayout");
	String rowsPerPage = request.getParameter("rowsPerPage");
	if (rowsPerPage==null || rowsPerPage.equals("")) rowsPerPage = "10";

	String as = request.getParameter("as");  // action statement
System.out.println("AS=" + as);	
	boolean showFKLink = false;  

	String pageNo = request.getParameter("pageNo");
	int pgNo = 1;
	if (pageNo != null) pgNo = Integer.parseInt(pageNo);

	String sortColumn = request.getParameter("sortColumn");
	String sortDirection = request.getParameter("sortDirection");
	String main = request.getParameter("main");
	
	if (sql==null) sql = "SELECT * FROM TABLE";
	sql = sql.trim();
	if (sql.endsWith(";")) sql = sql.substring(0, sql.length()-1);
	sql = sql.replaceAll("&gt;",">").replace("&lt;","<");

	String searchValue = request.getParameter("searchValue");
	if (searchValue==null) searchValue = "";

	Connect cn = (Connect) session.getAttribute("CN");
	
if (as != null && as.startsWith("BEGIN")) {
	cn.execute(as);
}
	Query q = new Query(cn, sql, false);

	if (q.isError()) {
%>
		<%= q.getMessage() %>
<%		
		return;
	}
	
	q.removeFilter();
	if (sortColumn != null && !sortColumn.equals("")) q.sort(sortColumn, sortDirection);

	if (searchValue !=null && !searchValue.equals("")) {
		q.search(searchValue);
	}
	
	// get table name
	String tbl = null;
	List<String> tbls = Util.getTables(sql); 
	if (tbls.size()>0) tbl = tbls.get(0);
//	System.out.println("XXX TBL=" + tbl);

	boolean hasDataLink = false;
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
		
		fkLinkTab.add(rTable);
		fkLinkCol.add(linkCol);

		int colCount = Util.countMatches(linkCol, ",") + 1;
		if (colCount == 1) {
			if (rTable != null) linkTable.put(linkCol, rTable);
		}	
	}
	
	// Primary Key for PK Link
	String pkName = cn.getPrimaryKeyName(tname);
	int pkColIndex = -1;
//	System.out.println("sql=" + sql);
//	System.out.println("pkName=" + pkName);
	
	boolean hasPK = false;
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

		hasPK = pkColList.size() > 0;
	}
	

	int linesPerPage = Integer.parseInt(rowsPerPage);
	int totalCount = q.getRecordCount();
	int filteredCount = q.getFilteredCount();
	int totalPage = q.getTotalPage(linesPerPage);

	String subKeys="";
	HashSet<String> hs = new HashSet<String>();
//process sql2
if (sql2 !=null && !sql2.equals("")) {
	String tmp = sql2.replaceAll("[\n\r\t]", " ");
	tmp = tmp.replaceAll("=", " ");
	tmp = tmp.replaceAll("\\)", " ");
	tmp = tmp.replaceAll("\\(", " ");
	StringTokenizer st = new StringTokenizer(tmp, " ");

	while (st.hasMoreTokens()) {
		String token = st.nextToken();
		if (token.startsWith(":A.")) {
			hs.add(token.substring(3));
		}
	}
	
//	System.out.println("sql2=" + sql2);
//	System.out.println("hs=" + hs);
	for (String s:hs) {
		subKeys += s + "|";	
	}
//	System.out.println("subKeys=" + subKeys);
}

List<String[]> layoutCols = cn.query("SELECT CNAME, CPOS, CWIDTH,  (select code from cpas_table_col where tname=A.tname and cname=A.cname) code FROM CPAS_LAYOUT_COL A WHERE USERNAME='DEFAULT_SETUP' AND TNAME='" + layout + "' AND CPOS > 0 ORDER BY CPOS", false);

boolean applyLayout = false;
if (appLayout!=null && appLayout.equals("1") && layoutCols.size() > 0) applyLayout = true;


String id2 = Util.getId(); 
%>
<%-- 
sortColumn, sortDirection = <%=sortColumn +"," + sortDirection %> Layout=<%= layout %><br/>
 --%>
<span style="font-family: Consolas; font-size: 16px;"><b><%=new HyperSyntax().getHyperSyntax(cn, sql, "SQL")%></b></span>
<a href="javascript:openQuery('<%=id2%>')"><img src="image/sout.gif" border=0 align=middle  title="<%=sql%>"/></a>
<a href="javascript:toggleLayout('<%=id%>')">Layout</a>
<div style="display: none;" id="sql-<%=id2%>"><%= sql%></div>

<br/>
<% if (q.getRecordCount() > 0) { %>

<div style="float: left;">
<% if (pgNo>1) { %>
<a href="Javascript:gotoPage(<%=id%>, <%= pgNo - 1%>)"><img border=0 src="image/prev.png" border=0 align="bottom"></a>
<% } %>

<% if (totalPage > 1) { %>
Page: <b><%= pgNo %></b> of <%= totalPage %>
<% } %>

<% if (q.getTotalPage(linesPerPage) > pgNo) { %>
<a href="Javascript:gotoPage(<%=id%>, <%= pgNo + 1%>)"><img border=0 src="image/next.png" border=0 align="bottom"></a>
<% } %>

Found: <b><%= filteredCount %></b>
<% if (totalCount > filteredCount) {%>
(of <%= totalCount %>)
<% } %>

<% if (filteredCount > 10) {%>
&nbsp;&nbsp;&nbsp;
Rows/Page 
<select id="linePerPage" name="linePerPage" onChange="rowsPerPage(this.options[this.selectedIndex].value);">
<option value="1" <%= (linesPerPage==1?"SELECTED":"") %>>1</option>
<option value="2" <%= (linesPerPage==2?"SELECTED":"") %>>2</option>
<option value="5" <%= (linesPerPage==5?"SELECTED":"") %>>5</option>
<option value="10" <%= (linesPerPage==10?"SELECTED":"") %>>10</option>
<option value="20" <%= (linesPerPage==20?"SELECTED":"") %>>20</option>
<% if (totalCount>=20) { %>
<option value="50" <%= (linesPerPage==50?"SELECTED":"") %>>50</option>
<% } %>
<% if (totalCount>=50) { %>
<option value="100" <%= (linesPerPage==100?"SELECTED":"") %>>100</option>
<% } %>
<%-- <% if (totalCount>=100) { %>
<option value="200" <%= (linesPerPage==200?"SELECTED":"") %>>200</option>
<% } %>
<% if (totalCount>=200) { %>
<option value="500" <%= (linesPerPage==500?"SELECTED":"") %>>500</option>
<% } %>
<% if (totalCount>=500) { %>
<option value="1000" <%= (linesPerPage==1000?"SELECTED":"") %>>1000</option>
<% } %>
 --%></select>
<% } %>
</div>

<%-- <a style="float: left;" href="Javascript:showHelp(<%=id%>)">+</a>
 --%>
<div id="help-<%= id %>" style="float: left; display: block;" >
&nbsp; &nbsp;
<% if (!applyLayout) { %>
<a id="modeHide-<%=id%>" href="Javascript:setColumnMode(<%=id%>,'hide')">Hide</a>
<a href="Javascript:showAllColumnTable('table-<%=id%>')">Show All</a>&nbsp;
<% if (totalCount>=2) { %>
<a id="modeSort-<%=id%>" href="Javascript:setColumnMode(<%=id%>,'sort')">Sort</a>
<% } %>
<% } %>
&nbsp;&nbsp;&nbsp;&nbsp;
<% if (totalCount>=5) { %>
<img src="image/view.png" border=0 ><input id="search-<%=id%>" value="<%= searchValue %>" size=15 onChange="searchTable(<%=id%>,$(this).val())"  placeholder="search">
<a href="Javascript:clearSearch(<%=id%>)"><img border="0" border=0 src="image/clear.gif"></a>
<% } %>
</div>
<br clear="all"/>
<% } %>

<%
	String tableClass ="gridBody";
	//tableClass = "gridBodyBOLD";

%>

<table id="table-<%=id%>" border=1 class="<%= tableClass %>">
<tr>

<%
	int offset = 0;
 	if (sql2 != null && !sql2.equals("")) {
		offset ++;

%>
	<th class="headerRow">Select</th>
<%
 	}
	boolean numberCol[] = new boolean[500];
	boolean hasData = q.hasMetaData();
	int colIdx = 0;

	String colTypes[] = new String[layoutCols.size()];
	String colPicts[] = new String[layoutCols.size()];
	
if (applyLayout) {
	int i=0;
	for (String[] row: layoutCols) {
		String cname = row[1];
		String cpos = row[2];
		String cwidth = row[3];
		boolean highlight = false;
		
		String colDisp = cn.getCpasUtil().getColumnCaption(layout, cname);
		colTypes[i] = cn.getCpasUtil().getColumnType(layout, cname);
		colPicts[i] = cn.getCpasUtil().getColumnPict(layout, cname);
		if (colPicts[i]==null) colPicts[i] = "";
%>
<%-- <th class="headerRow"><%=colDisp%><br/><span class='cpas'><%= colTypes[i] %> <%= colPicts[i] %></span></th>
 --%><th class="headerRow"><%=colDisp%></th>
<%
		i++;
	}
}	

if (!applyLayout) {
	for  (int i = 0; i<= q.getColumnCount()-1; i++){
	
		String colName = q.getColumnLabel(i);

		//System.out.println(i + " column type=" +rs.getMetaData().getColumnType(i));
		colIdx++;
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
		
		String colDisp = colName.toLowerCase();
		String cpasDisp = "";
		if (cpas) {
			String capt = cn.getCpasCodeCapt(tname, colName);
			if (capt != null) 
				cpasDisp += "<br/> &gt;  <span class='cpas'>" + capt + "</span>";
		}			
		
%>
<th class="headerRow"><a <%= ( highlight?"style='background-color:yellow;'" :"")%>
	href="Javascript:setColumn(<%= id %>, '<%=colName%>', <%= colIdx + offset %>);" title="<%= tooltip %>"><%=colDisp%></a>
	<%= extraImage %><%= cpasDisp %>
</th>

<%
	}
}	
%>
</tr>

<%
	int rowCnt = 0;
	String pkValues = ""; 

	q.rewind(linesPerPage, pgNo);
	
	while (q.next()) {
		rowCnt++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";
		
		String subValues = "";
		for (String c : hs) {
			subValues += q.getValue(c) + "|";
		}
		
%>
<tr class="simplehighlight">
<% if (sql2 != null && !sql2.equals("")) { %>
	<td class="<%= rowClass%>">
		<input name="select" type="radio" onChange="Javascript:queryDetail('<%= subKeys %>','<%=subValues%>')">
	</td>
<%
	}

	colIdx=0;
	
	if (applyLayout) {
		
		for  (int i = 0; i < layoutCols.size(); i++){
			colIdx++;
			String colName = layoutCols.get(i)[1];
			String val = q.getValue(colName);
			if (val==null) val="";
			
			String valDisp = Util.escapeHtml(val);
			String cd = layoutCols.get(i)[4];
			if (cd!=null && !cd.equals("")) {
				String cv = cn.getCpasUtil().getGrupValue(cd, val, null);
				if (cv != null) val = cv;
			} else {
				String code = cn.getCpasCodeValue(tname, colName, val, q);
				if (code!=null)	{
					valDisp = code;
				}
			}
			valDisp = Util.escapeHtml(val);
			
			String align="left";
			
			if (colTypes[i] !=null && colTypes[i].endsWith("N")) align="right";
			
			if (colTypes[i] !=null && colTypes[i].endsWith("N") && colPicts[i].length() > 0 && Util.isNumber(valDisp)) {
				String tmp = "SELECT TO_CHAR('" + valDisp + "','"+colPicts[i] +"') FROM DUAL";
				String tmp2 = cn.queryOne(tmp);
				//valDisp += " " + colPicts[i] + " " + tmp + " " + tmp2;
				tmp2 = tmp2.trim();
				//System.out.println("tmp2="+tmp2);
				if (tmp2.startsWith(".")) tmp2 = "0" + tmp2;
				valDisp = tmp2;
			}
			
%>
<td class="<%= rowClass%>" align=<%= align%>><%=valDisp%>
</td>
<%		}
	}
	
	
	if (!applyLayout) {

		for  (int i = 0; q.hasData() && i < q.getColumnCount(); i++){

				colIdx++;
				String colTypeName = q.getColumnTypeName(i);
				String val = q.getValue(i);
				String valDisp = Util.escapeHtml(val);
				if (val != null && val.endsWith(" 00:00:00")) valDisp = val.substring(0, val.length()-9);
				if (val==null || val.equals("")) valDisp = "<span class='nullstyle'>null</span>";
				if (val !=null && val.length() > 50) {
					id = Util.getId();
					String id_x = Util.getId();
					valDisp = valDisp.substring(0,50) + "<a id='"+id_x+"' href='Javascript:toggleText(" +id_x + "," +id +")'>...</a><span id='"+id+"' style='display: none;'>" + valDisp.substring(50) + "</span>";
				}
				
				String colName = q.getColumnLabel(i);
				String lTable = "";
				String keyValue = val;
				boolean isLinked = false;
				String linkUrl = "";
				String dialogUrl = "";
				String linkImage = "image/view.png";
				if (lTable != null  && false) {
					isLinked = true;
					linkUrl = "ajax/fk-lookup.jsp?table=" + lTable + "&key=" + Util.encodeUrl(keyValue);
					dialogUrl = "\"" + lTable + "\",\"" + Util.encodeUrl(keyValue) + "\"";
				} else if (val != null && val.startsWith("BLOB ")) {
					isLinked = true;
					String tpkName = cn.getPrimaryKeyName(tbl);
					String tpkCol = cn.getConstraintCols(tpkName);
					//String tpkValue = q.getValue(tpkCol);
					String tpkValue = pkValues;
					
//					linkUrl ="ajax/blob.jsp?table=" + tbl + "&col=" + colName + "&key=" + Util.encodeUrl(tpkValue);
					String fname = q.getValue("filename");
					linkUrl ="blob_download?table=" + tbl + "&col=" + colName + "&key=" + Util.encodeUrl(tpkValue)+"&filename="+fname;
					linkImage ="image/download.gif";
				} else if (colTypeName.equals("CLOB")) {
					isLinked = true;
					String tpkName = cn.getPrimaryKeyName(tbl);
					String tpkCol = cn.getConstraintCols(tpkName);
					String tpkValue = pkValues;
					
//					linkUrl ="blob.jsp?table=" + tbl + "&col=" + colName + "&key=" + Util.encodeUrl(tpkValue);
					String fname = "download.txt";
					if (val.startsWith("<?xml")) fname = "download.xml";
					if (val.startsWith("<html")) fname = "download.html";
					
					linkUrl ="clob_download?table=" + tbl + "&col=" + colName + "&key=" + Util.encodeUrl(tpkValue)+"&filename="+fname;
					linkImage ="image/download.gif";
				}
/*				
				if (pkColIndex >0 && i == pkColIndex) {
					isLinked = true;
					linkUrl = "ajax/pk-link.jsp?table=" + tname + "&key=" + Util.encodeUrl(keyValue);
					linkImage = "image/link.gif";
				}
*/
if (cpas) {
	String code = cn.getCpasCodeValue(tname, colName, val, q);
	if (code!=null && !code.equals(""))	valDisp += "<br/> &gt; <span class='cpas'>" + code + "</span>";
}

%>
<td class="<%= rowClass%>" <%= (numberCol[colIdx])?"align=right":""%>><%=valDisp%>
<%-- <%= (val!=null && isLinked?"<a class='inspect' href='" + linkUrl  + "'><img border=0 src='" + linkImage + "'></a>":"")%>
 --%>
<%= (val!=null && isLinked && linkImage.equals("image/view.png")? "<a href='Javascript:showDialog(" + dialogUrl + ")'><img border=0 src='" + linkImage + "'></a>":"")%>
<%= (val!=null && isLinked && linkImage.equals("image/download.gif")? "<a href='" + linkUrl + "' target=_blank><img border=0 src='" + linkImage + "'></a>":"")%>
</td>
<%
		}
%>
</tr>
<%
	}
	if (q.hasData()) counter++;
	if (counter >= linesPerPage) break;
	}
%>
</table>

<% if (!showFKLink) return; %>

</div>