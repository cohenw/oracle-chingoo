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
	String temp = request.getParameter("cpas");
	if(temp!=null&&temp.equals("0")) cpas = false;

	String dataLink = request.getParameter("dataLink");
	boolean dLink = (dataLink != null && dataLink.equals("1"));
	//dLink = true;

	String showFK = request.getParameter("showFK");
	boolean showFKLink = (showFK != null && showFK.equals("1"));  

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

%>

<%
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

		hasPK = pkColList.size() > 0 && (pkColList.size() == matchCount);
	}
	
	int linesPerPage = 10;
	int totalCount = q.getRecordCount();
	int filteredCount = q.getFilteredCount();
	int totalPage = q.getTotalPage(linesPerPage);
	
%>
<%-- <b><%= tname %></b> --%> 
<%--<%= cn.getComment(tname) --%>

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

Found: <%= filteredCount %>
<% if (totalCount > filteredCount) {%>
(of <%= totalCount %>)
<% } %>

</div>

<%-- <a style="float: left;" href="Javascript:showHelp(<%=id%>)">+</a>
 --%>
<div id="help-<%= id %>" style="float: left; display: block;" >
&nbsp; &nbsp;
<a id="modeHide-<%=id%>" href="Javascript:setColumnMode(<%=id%>,'hide')">Hide</a>
<a href="Javascript:showAllColumnTable('table-<%=id%>')">Show All</a>&nbsp;
<% if (totalCount>=2) { %>
<a id="modeSort-<%=id%>" href="Javascript:setColumnMode(<%=id%>,'sort')">Sort</a>
<% } %>
&nbsp;<a href="Javascript:transposeToggle(<%=id%>)">Transpose</a>

&nbsp;&nbsp;&nbsp;&nbsp;
<% if (totalCount>=5) { %>
<img src="image/view.png" border=0 ><input id="search-<%=id%>" value="<%= searchValue %>" size=15 onChange="searchTable(<%=id%>,$(this).val())" placeholder="search">
<a href="Javascript:clearSearch(<%=id%>)"><img border="0" border=0 src="image/clear.gif"></a>
<% } %>
</div>
<br clear="all"/>
<% } %>

<%
	String tableClass ="gridBody";
	if (main != null) tableClass = "gridBodyBOLD";

%>

<table id="table-<%= id %>" border=1 class="<%= tableClass %>">
<tr>

<%
	int offset = 0;
	if (hasPK && dLink) {
		offset ++;
%>
	<th class="headerRow">Link</th>
<%
	}

	
	boolean numberCol[] = new boolean[500];

	boolean hasData = q.hasMetaData();
	int colIdx = 0;
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
			
			if (pkColList != null && pkColList.contains(colName)) colDisp = "<b>" + colDisp + "</b>";
			
			String cpasDisp = "";
			if (cpas) {
				String capt = cn.getCpasCodeCapt(tname, colName);
				if (capt != null) 
					cpasDisp += "<br/> &gt;  <span class='cpas'>" + capt + "</span>";
			}			

			String grup = cn.getCpasCodeGrup(tname, colName);
			if (grup == null || grup.equals("_")) grup = "";
			
			if (grup != null && !grup.equals("")) {
				String codeTable = cn.getCpasUtil().getCpasCodeTable();
//				grup = " -&gt; <a href=\"javascript:showDialog('" + codeTable + "','"+grup+"')\">" + grup + "</a>";
				grup = " <a href=\"javascript:showCpasCode('"+grup+"')\">" + grup + "</a>";
			}			
%>
<th class="headerRow"><a <%= ( highlight?"style='background-color:yellow;'" :"")%>
	href="Javascript:setColumn(<%= id %>, '<%=colName%>', <%= colIdx + offset %>);" title="<%= tooltip %>"><%=colDisp%></a>
	<%= extraImage %><%= cpasDisp %> <%= grup %>
</th>
<%
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
%>
<tr class="simplehighlight">

<%
	if (hasPK && q.hasData() && dLink) {
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
		<a href='<%= linkUrlTree %>'><img src="image/star.png" border=0 title="Data link" onmouseover="this.src='image/star2.png';" onmouseout="this.src='image/star.png';"></a>
	</td>
<%
	}

	colIdx=0;
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
				String lTable = linkTable.get(colName);
				String keyValue = val;
				boolean isLinked = false;
				String linkUrl = "";
				String dialogUrl = "";
				String linkImage = "image/view.png";
				boolean isLogicalLink = false;
//System.out.println("lTable="+lTable + " dLink="+ dLink);
				if (lTable != null /*  && dLink */) {
					isLinked = true;
//					linkUrl = "ajax/fk-lookup.jsp?table=" + lTable + "&key=" + Util.encodeUrl(keyValue);
					dialogUrl = "\"" + lTable + "\",\"" + Util.encodeUrl(keyValue) + "\"";
				} else if (val != null && val.startsWith("BLOB ")) {
					isLinked = true;
					String tpkName = cn.getPrimaryKeyName(tbl);
					String tpkCol = cn.getConstraintCols(tpkName);
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
					if (val!=null && val.startsWith("<?xml")) fname = "download.xml";
					if (val!=null && val.startsWith("<html")) fname = "download.html";
					
					linkUrl ="clob_download?table=" + tbl + "&col=" + colName + "&key=" + Util.encodeUrl(tpkValue)+"&filename="+fname;
					linkImage ="image/download.gif";
				} else {
					
					for (int j=0; j < cn.getCpasUtil().logicalLink2.length; j++) {
						if (colName.equals(cn.getCpasUtil().logicalLink2[j][0]) && !tname.equals(cn.getCpasUtil().logicalLink2[j][2])) {
							String theOtherVal = q.getValue( cn.getCpasUtil().logicalLink2[j][1] );

							if (theOtherVal != null && !theOtherVal.equals("")) {
								isLinked = true;
								lTable = cn.getCpasUtil().logicalLink2[j][2];
								keyValue = theOtherVal + "^" + val;
								dialogUrl = "\"" + lTable + "\",\"" + Util.encodeUrl(keyValue) + "\"";
							}
						}
					}
					
					lTable = cn.getCpasUtil().getLinkedTable(tname, colName);
					if (lTable != null && !isLinked) {
						isLinked = true;
						keyValue = val;
						dialogUrl = "\"" + lTable + "\",\"" + Util.encodeUrl(keyValue) + "\"";
					}

					String tc = tname + "." + colName;
					for (int j=0; !isLinked && j < cn.getCpasUtil().logicalLinkSpec.length; j++) {
						if (tc.equals(cn.getCpasUtil().logicalLinkSpec[j][0]) && !tname.equals(cn.getCpasUtil().logicalLinkSpec[j][1])) {
							isLinked = true;
							lTable = cn.getCpasUtil().logicalLinkSpec[j][1];
							keyValue = val;
							dialogUrl = "\"" + lTable + "\",\"" + Util.encodeUrl(keyValue) + "\"";
						}
					}

					if (!isLinked && colName.endsWith("PERSONID")) {
						isLinked = true;
						lTable = "PERSON";
						keyValue = val;
						linkUrl = "Javascript:showDialog('" + lTable + "','" + Util.encodeUrl(keyValue) + "' )";
						dialogUrl = "\"" + lTable + "\",\"" + Util.encodeUrl(keyValue) + "\"";
					}

					if (val==null || val.equals("*")) isLinked = false;
					if (isLinked) {
						isLogicalLink = true;
						linkImage = "image/view2.png";
					}
				}
/*				
				if (pkColIndex >0 && i == pkColIndex) {
					isLinked = true;
					linkUrl = "ajax/pk-link.jsp?table=" + tname + "&key=" + Util.encodeUrl(keyValue);
					linkImage = "image/link.gif";
				}
*/

if (pkColList != null && pkColList.contains(colName)) valDisp = "<span class='pk'>" + valDisp + "</span>";
if (cpas) {

	
	String code = cn.getCpasCodeValue(tname, colName, val, q);
	if (code!=null && !code.equals(""))	{
		if (!isLogicalLink) 
			valDisp += "<br/> &gt; <span class='cpas'>" + code + "</span>";
		else
			valDisp += "<br/> &gt; <span class='cpas2'>" + code + "</span>";
	}
	
	if (colName.equalsIgnoreCase("TREEKEY") && !q.getValue("SDI").equals("")) {
		linkUrl ="cpas-treeview.jsp?sdi=" + q.getValue("SDI") + "&treekey="+val;
		linkImage="image/linkout.png";
		isLinked = true;
	}
}

%>
<td class="<%= rowClass%>" <%= (numberCol[colIdx])?"align=right":""%>><%=valDisp%>
<%-- <%= (val!=null && isLinked?"<a class='inspect' href='" + linkUrl  + "'><img border=0 src='" + linkImage + "'></a>":"")%>
 --%>
<%= (val!=null && isLinked && linkImage.startsWith("image/view")? "<a href='Javascript:showDialog(" + dialogUrl + ")'><img border=0 src='" + linkImage + "'></a>":"")%>
<%= (val!=null && isLinked && linkImage.equals("image/download.gif")? "<a href='" + linkUrl + "' target=_blank><img border=0 src='" + linkImage + "'></a>":"")%>
<%= (val!=null && isLinked && linkImage.equals("image/linkout.png")? "<a href='" + linkUrl + "' target=_blank><img border=0 src='" + linkImage + "'></a>":"")%>
<%
	if (tname.equals("CPAS_VALIDATION") && colName.equals("VNAME")) {
		String pkg = q.getValue("PACKNAME") + "." + q.getValue("VNAME");
		out.println(" <a target=_blank href='package-tree.jsp?name=" + pkg + "'><img src='image/sourcecode.gif' border='0' width=16 heigh=16>Source</a>");
	}

	if (tname.equals("CPAS_WIZARD_SETUP") && colName.equals("PACKAGE_NAME")) {
		String pkg = q.getValue("PACKAGE_NAME");
		out.println(" <a target=_blank href='pop.jsp?type=PACKAGE&key=" + pkg + "'><img src='image/sourcecode.gif' border='0' width=16 heigh=16>Detail</a>");
	}

%>
</td>
<%
		}
%>
</tr>
<%		if (q.hasData()) counter++;
		if (counter >= linesPerPage) break;
	}
	
%>
</table>

<% if (!showFKLink) return; %>
<% if (fkLinkTab.size()<=0) return; 

	id = Util.getId();
%>

<a href="Javascript:toggleDiv('img-<%=id%>','div-<%=id%>')"><img id="img-<%=id%>" border=0 src="image/plus.gif"></a>
<div id="div-<%=id%>" style="display: none; margin-left:30px;">
<img src="image/down_arrow.gif">
<%
for (int i=0; i<fkLinkTab.size(); i++) {
	String ft = fkLinkTab.get(i);
	String fc = fkLinkCol.get(i);
	
	String keyValue = null;
	String[] colnames = fc.split("\\,");

	boolean hasNull = false;
	for (int j=0; j<colnames.length; j++) {
		String x = colnames[j].trim();
		String v = q.getValue(x);
//		System.out.println("x,v=" +x +"," + v);

		if (v==null) hasNull = true;
		if (keyValue==null)
			keyValue = v;
		else
			keyValue += "^" + v;
	}
	
	if (hasNull) continue;
	String fsql = cn.getPKLinkSql(ft, keyValue);
	id = Util.getId();
%>
<div id="div-fkk-<%=id %>">
<br/>
<a href="javascript:loadData('<%=id%>',1)"><b><%=ft%></b> <img id="img-<%=id%>" border=0 src="image/plus.gif"></a>
<span class="cpas"><%= cn.getCpasComment(ft) %></span>

&nbsp;&nbsp;
<a href="pop.jsp?key=<%= tname %>" target="_blank" title="Detail"><img src="image/detail.png"></a>
<a href="javascript:openQuery('<%=id%>')"><img src="image/linkout.png" border=0 title="<%=fsql%>"/></a>
(<%= tname %>.<%=fc.toLowerCase() %>)
&nbsp;&nbsp;<a href="javascript:hideDiv('div-fkk-<%=id%>')"><img src="image/clear.gif" border=0/></a>
<div style="display: none;" id="sql-<%=id%>"><%= fsql%></div>
<div style="display: none;" id="mode-<%=id%>">hide</div>
<div style="display: none;" id="hide-<%=id%>"></div>
<div id="div-<%=id%>" style="display: none;"></div>
</div>
<% } %>

</div>