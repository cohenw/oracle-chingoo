<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%!
public synchronized List<String> getLogicalChildTables(Connect cn, String tname, Query q) {
//System.out.println("tname="+tname);	
	List<String> list = new ArrayList<String>();

	if ( tname.equals("BATCH") ) {
		String paramTable = cn.queryOne("SELECT PARAMTABLE FROM BATCHCAT WHERE BATCHKEY='" +q.getValue("BATCHKEY") +"'");
		//System.out.println("paramTable=" + paramTable);
		if (paramTable != null && !paramTable.equals("")) {
			list.add(paramTable);
		}
		String batchKey = q.getValue("BATCHKEY");
		String qry = "SELECT BUFFERTABLE FROM BATCHCAT_BUFFER WHERE BATCHKEY='" + batchKey + "' " +
			"AND EXISTS (SELECT 1 FROM USER_OBJECTS WHERE OBJECT_NAME=BUFFERTABLE)";
		if (cn.getTargetSchema() != null) {
			qry = "SELECT BUFFERTABLE FROM BATCHCAT_BUFFER WHERE BATCHKEY='" + batchKey + "' " +
					"AND EXISTS (SELECT 1 FROM ALL_OBJECTS WHERE OWNER = '" + cn.getTargetSchema() + "' AND OBJECT_NAME=BUFFERTABLE)";
		}
		
		//System.out.println("qry="+qry);	
		List<String> lst = cn.queryMulti(qry);
		list.addAll(lst);

		if (batchKey.equals("PBR")) {
			list.add("BATCH_BUF$DATA$PBRHR$BUFF");
			list.add("BATCH_BUF$DATA$PBRFR$BUFF");
			list.add("BATCH_BUF$DATA$PBR$STATUS");
			list.add("BATCH_BUF$DATA$PBR$ERR");
			list.add("BATCH_BUF$DATA$PBR$ELOG");
		}
		
		list.add("BATCH_ERROR");
		list.add("CALC_ERROR");

	} else if ( tname.equals("ERRORCAT") ) {
		if (cn.isTVS("CPAS_VALIDATION")) list.add("CPAS_VALIDATION");
		if (cn.isTVS("BATCHCAT_PREVALSET")) list.add("BATCHCAT_PREVALSET");
	}

	return list;
}

public String getQryStmt(String sql, Query q) {
//	System.out.println("tname="+tname);
	
	// replace [colname] to 'XXX' where XXX is the value of colname
	boolean needInput = false;
	List<String> params = new ArrayList<String>();
	
	String tmp ="";
	if (sql.contains("[") && sql.contains("]")) {
		needInput = true;

		int prev = 0;
		while (true) {
			int start = sql.indexOf("[", prev);
			if (start <0) break;
			int end = sql.indexOf("]", start);
			if (end <0) break;
			tmp = sql.substring(start+1, end);
		
			params.add(tmp);
			prev = end+1;
		}
	}
	
	System.out.println("params=" + params);
	for (String param: params) {
		sql = sql.replaceAll("\\[" + param + "\\]" , q.getValue(param));
	}
	
	
	return sql;
}

%>
<%
	int counter = 0;
	Connect cn = (Connect) session.getAttribute("CN");

	String table = request.getParameter("table");
	String key = request.getParameter("key");
	String rowid = request.getParameter("rowid");
	
	String qry = request.getParameter("qry");
	if (qry != null && !qry.equals("")) {
		int idx = qry.indexOf("|");
		table = qry.substring(0,idx);
		key = qry.substring(idx+1).replaceAll("\\|", "^");
//		System.out.println("table=" + table);
//		System.out.println("key=" + key);
	}
	
	List<String> refTabs = cn.getReferencedTables(table);

	String sql = cn.getPKLinkSql(table, key, rowid);
//	System.out.println(cn.getUrlString() + " " + Util.getIpAddress(request) + " " + (new java.util.Date()) + "\nDatalink " + sql);
	System.out.println("*** Datalink " + sql);
/*
	Query q = cn.queryCache.getQueryObject(sql);
	if (q==null) {
		q = new Query(cn, sql);
		cn.queryCache.addQuery(sql, q);
	}
*/
	Query q = new Query(cn, sql);

	List<String> lcTabs = getLogicalChildTables(cn, table, q); // logical child tables
	lcTabs.removeAll(refTabs);

	// Foreign keys - For FK lookup
	List<ForeignKey> fks = cn.getForeignKeys(table);
//System.out.println("fks.size()=" + fks.size());	
	Hashtable<String, String>  linkTable = new Hashtable<String, String>();

	List<String> fkLinkTab = new ArrayList<String>();
	List<String> fkLinkCol = new ArrayList<String>();
	
	HashSet hs = new HashSet();
	
	for (int i=0; i<fks.size(); i++) {
		ForeignKey rec = fks.get(i);
		String linkCol = cn.getConstraintCols(rec.constraintName);
		String rTable = cn.getTableNameByPrimaryKey(rec.rConstraintName);
		
		fkLinkTab.add(rTable);
		fkLinkCol.add(linkCol);
		hs.add(linkCol);
		//System.out.println("HS=" + linkCol);
	}

	List<String> autoLoadFK = new ArrayList<String>();
	List<String> autoLoadChild = new ArrayList<String>();
	
	String title = table + " " + key;
	if (rowid!=null) {
		title = table + " " + rowid;
	}
	
	// custom link
	String customLinks = null;
	
	if (cn.isTVS("GENIE_LINK"))
		customLinks = cn.queryOne("SELECT SQL_STMTS FROM GENIE_LINK WHERE TNAME ='" + table + "'", false);
%>


<html>
<head> 
	<title><%= title %></title>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 

    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    <script src="script/data-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>

	<style>
	.ui-autocomplete-loading { background: white url('image/ui-anim_basic_16x16.gif') right center no-repeat; }
.ui-autocomplete {
		max-height: 500px;
		overflow-y: auto;
		/* prevent horizontal scrollbar */
		overflow-x: hidden;
		/* add padding to account for vertical scrollbar */
		padding-right: 20px;
	}
	/* IE 6 doesn't support max-height
	 * we use height instead, but this forces the menu to always be this tall
	 */
	* html .ui-autocomplete {
		height: 500px;
	}	
	</style>
	    
    <script>
	$(function() {
		$( "#globalSearch" ).autocomplete({
			source: "ajax/auto-complete2.jsp",
			minLength: 2,
			select: function( event, ui ) {
				popObject( ui.item ?
					ui.item.value: "" );
			}
		}).data( "autocomplete" )._renderItem = function( ul, item ) {
			return $( "<li></li>" )
			.data( "item.autocomplete", item )
			.append( "<a>" + item.label + " <span class='rowcountstyle'>" + item.desc + "</span></a>" )
			.appendTo( ul );
		};
	});	

	function popObject(oname) {
//		alert(oname);
		$("#popKey").val(oname);
    	$("#FormPop").submit();
	}
	    
    </script>
    
</head> 

<body>
<%
	String id = Util.getId();
%>

<div style="background-color: #ffffff;">
<img src="image/star-big.png" align="middle"/>

 <b>DATA LINK</b>
&nbsp;&nbsp;
<%= cn.getUrlString() %>

&nbsp;&nbsp;&nbsp;&nbsp;

<a href="Javascript:hideNullColumn()">Hide Null</a> |
<a href="Javascript:showAllColumn()">Show All</a> |
<a href="Javascript:newQry()">Pop Query</a> |
<a href="query.jsp" target="_blank">Query</a> |
<a id="showERD" href="Javascript:showERD('<%=table%>')">Show ERD</a> |
<a href="erd_svg.jsp?tname=<%= table %>" target="_blank">ERD</a>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<!-- <a href="Javascript:openWorksheet()">Open Work Sheet</a>
 -->
Search <input id="globalSearch" style="width: 200px;" placeholder="table or view name"/>
</div>

<br/><br/>

<div id="tableList1" style="display: hidden; margin-left: 20px;">
</div>



<%
	id = Util.getId();
%>

<b><%= table %></b> (<span class="rowcountstyle"><%= 1 %></span> / <%= cn.getTableRowCount(table) %>)
&nbsp;&nbsp;<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" border=0 title="<%=sql%>"/></a>
<span class="cpas"><%= cn.getCpasComment(table) %></span>
<%-- <%= sql %> --%>
<div style="display: none;" id="sql-<%=id%>"><%= sql%></div>
<div style="display: none;" id="mode-<%=id%>">hide</div>
<div style="display: none;" id="ori-<%=id%>">H</div>
<div style="display: none;" id="hide-<%=id%>"></div>
<% if (table.equals("MEMBER")) {
	int idx = key.indexOf("^");
	String clnt= key.substring(0,idx);
	String mkey = key.substring(idx+1);
	String eid = clnt + "_" + mkey;
	String fname = "C" + clnt + "_M" + mkey + ".member";
%>
	<a target="_blank" href="cpas-extract.jsp?id=<%=eid%>&fname=<%=fname%>&type=MEMBER">Extract Script</a>
<% } %>
<% if (table.equals("_ERRORCAT")) {
	String eid = key;
	int idx = key.indexOf("^");
	if (idx >0) eid= key.substring(0,idx);
	String fname = eid.replace('-', '_') + ".error";
%>
	<a target="_blank" href="cpas-extract.jsp?id=<%=eid%>&fname=<%=fname%>&type=ERROR">Extract Script</a>
<% } %>

<br/>
<div id="div-<%=id %>" style1="padding: 5px; background-color: gray;">
<jsp:include page="ajax/qry-simple.jsp">
	<jsp:param value="<%= sql %>" name="sql"/>
	<jsp:param value="0" name="dataLink"/>
	<jsp:param value="<%= id %>" name="id"/>
	<jsp:param value="1" name="main" />
</jsp:include>
</div>
<br/>











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

<%
	int cntFK = 0;

// viewTable should link to the table
if (cn.isViewTable(table)) {
//	System.out.println("ViewTable !!!!!!");
	String tmp = cn.getViewTableName(table);
	//fkLinkTab.add("SV_MEMBER");
	
	String tmp2 = cn.getPrimaryKeyName(tmp);
	String linkCol = cn.getConstraintCols(tmp2);
	String rTable = cn.getTableNameByPrimaryKey(tmp2);
	
	fkLinkTab.add(rTable);
	fkLinkCol.add(linkCol);
//	hs.add(linkCol);
}


	for (int i=0; i<fkLinkTab.size(); i++) {
		String ft = fkLinkTab.get(i);
		String fc = fkLinkCol.get(i);
		
		String keyValue = null;
		String[] colnames = fc.split("\\,");
		boolean hasNull = false;
		for (int j=0; j<colnames.length; j++) {
			String x = colnames[j].trim();
			String v = (q==null?"":q.getValue(x));
//			System.out.println("x,v=" +x +"," + v);
			if (v==null) hasNull = true;
			if (keyValue==null)
				keyValue = v;
			else
				keyValue += "^" + v;
		}
		
		if (hasNull) continue;
		
		cntFK ++;
		String fsql = cn.getPKLinkSql(ft, keyValue);
		id = Util.getId();
		autoLoadFK.add(id);
%>
<% if (cntFK == 1) {%>
	<b><a style="margin-left: 150px;" href="Javascript:toggleFK()">Foreign Key <img id="img-fk" border=0 src="image/minus.gif"></a></b><br/>
<div id="div-fk" style="margin-top:10px;">
		<img style="margin-left: 170px;" src="image/arrow_down.jpg"><br/>
<% } %>

<div id="div-fkk-<%=id%>"  style="margin-left: 170px;">
<a href="javascript:loadData('<%=id%>',1)"><b><%=ft%></b> <img id="img-<%=id%>" border=0 align=middle src="image/plus.gif"></a>
(<span class="rowcountstyle"><%= 1 %></span> / <%= cn.getTableRowCount(ft) %>)
<span class="cpas"><%= cn.getCpasComment(ft) %></span>
&nbsp;&nbsp;<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" border=0 align=middle  title="<%=fsql%>"/></a>
(<%= table %>.<%= fc.toLowerCase() %>)
&nbsp;&nbsp;<a href="javascript:hideDiv('div-fkk-<%=id%>')"><img src="image/clear.gif" border=0/></a>
<div style="display: none;" id="sql-<%=id%>"><%= fsql%></div>
<div style="display: none;" id="mode-<%=id%>">hide</div>
<div style="display: none;" id="ori-<%=id%>">H</div>
<div style="display: none;" id="hide-<%=id%>"></div>
<div id="div-<%=id%>" style="display: none;"></div>
<br/>
</div>
<% } %>
</div>

<%
// see if there is logial foreign key
  int cntLFK = 0;

	for (int i=0; i< q.getColumnCount(); i++) {
		String label = q.getColumnLabel(i);
		String ft=null, fsql="", fc="";
		
		if (hs.contains(label)) continue;
		if (hs.contains("CLNT, " + label)) continue;
		if (hs.contains("PENID, " + label)) continue;
		if (q.getValue(label)==null) continue;
		for (int j=0; j < cn.getCpasUtil().logicalLink2.length; j++) {
			if (label.equals(cn.getCpasUtil().logicalLink2[j][0])) {
				ft = cn.getCpasUtil().logicalLink2[j][2];
				fsql = cn.getPKLinkSql(ft, q.getValue(cn.getCpasUtil().logicalLink2[j][1])+ "^" + q.getValue(label));
				break;
			}
		}

		for (int j=0; ft==null && j < cn.getCpasUtil().logicalLink.length; j++) {
			if (label.equals(cn.getCpasUtil().logicalLink[j][0])) {
				ft = cn.getCpasUtil().logicalLink[j][1];
				fsql = cn.getPKLinkSql(ft, q.getValue(label));
				System.out.println("*** " + fsql);
				break;
			}
		}

		String tc = table + "." + label;
		for (int j=0; ft==null && j < cn.getCpasUtil().logicalLinkSpec.length; j++) {
			if (tc.equals(cn.getCpasUtil().logicalLinkSpec[j][0])) {
				ft = cn.getCpasUtil().logicalLinkSpec[j][1];
				fsql = cn.getPKLinkSql(ft, q.getValue(label));
				break;
			}
		}
		
		if (ft == null) continue;
		if (fkLinkTab.contains(ft)) continue;
		if (ft.equals(table)) continue;
		if (q.getValue(label)==null) continue;
		
		// check if there is matched record
		Query qc = new Query(cn, fsql);
		if (qc.getRecordCount()==0) continue;
		
		fc = label;
		id = Util.getId();
		autoLoadFK.add(id);
		cntLFK++;

%>
<% if (cntLFK == 1) {%>
	<b><a style="margin-left: 150px;" href="Javascript:toggleLFK()">CPAS Logical Link <img id="img-lfk" border=0 src="image/minus.gif"></a></b><br/>
<div id="div-lfk" style="margin-top:10px;">
		<img style="margin-left: 170px;" src="image/arrow_down.jpg"><br/>
<% } %>


<div id="div-fkk-<%=id%>"  style="margin-left: 170px;">
> <a href="javascript:loadData('<%=id%>',1)"><b><%=ft%></b> <img id="img-<%=id%>" border=0 align=middle src="image/plus.gif"></a>
(<span class="rowcountstyle"><%= 1 %></span> / <%= cn.getTableRowCount(ft) %>)
<span class="cpas"><%= cn.getCpasComment(ft) %></span>
&nbsp;&nbsp;<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" border=0 align=middle  title="<%=fsql%>"/></a>
(<%= table %>.<%= fc.toLowerCase() %>)
&nbsp;&nbsp;<a href="javascript:hideDiv('div-fkk-<%=id%>')"><img src="image/clear.gif" border=0/></a>
<div style="display: none;" id="sql-<%=id%>"><%= fsql%></div>
<div style="display: none;" id="mode-<%=id%>">hide</div>
<div style="display: none;" id="ori-<%=id%>">H</div>
<div style="display: none;" id="hide-<%=id%>"></div>
<div id="div-<%=id%>" style="display: none;"></div>
<br/>
</div>	
<%	  
	}
%>

<% if (cntFK > 0 || cntLFK > 0) {%>
</div>
<% } %>

<br/>


<%
	// Primary Key for PK Link
	String pkName = cn.getPrimaryKeyName(table);
	String pkCols = null;
	String pkColName = null;
	int pkColIndex = -1;
	if (pkName != null) {
		pkCols = cn.getConstraintCols(pkName);
		int colCount = Util.countMatches(pkCols, ",") + 1;
		pkColName = pkCols;
	}

	int cntRef = 0;
	for (int i=0; rowid==null && i<refTabs.size(); i++) {
		String refTab = refTabs.get(i);
//System.out.println("refTab="+refTab);		
		String fkColName = cn.getRefConstraintCols(table, refTab);
//System.out.println("fkColName="+fkColName);		
		int recCount = cn.getPKLinkCount(refTab, fkColName , key);
		if (recCount==0) continue;
		String refsql = cn.getRelatedLinkSql(refTab, fkColName, key);

		id = Util.getId();
		autoLoadChild.add(id);
		cntRef++;
%>

<% if (cntRef == 1) {%>
	<b><a style="margin-left: 20px;" href="Javascript:toggleChild()">Child Table <img id="img-child" border=0 src="image/minus.gif"></a></b><br/>
<div id="div-child">
	<img style="margin-left: 40px;" src="image/arrow_up.jpg"><br/>
<% } %>

<div id="div-child-<%=id%>">
<a style="margin-left: 40px;" href="javascript:loadData('<%=id%>',0)"><b><%= refTab %></b> <img id="img-<%=id%>" border=0 align=middle src="image/plus.gif"></a>
(<span class="rowcountstyle"><%= recCount %></span> / <%= cn.getTableRowCount(refTab) %>)
<span class="cpas"><%= cn.getCpasComment(refTab) %></span>
&nbsp;&nbsp;<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" align=middle border=0 title="<%=refsql%>"/></a>
&nbsp;&nbsp;<a href="javascript:hideDiv('div-child-<%=id%>')"><img src="image/clear.gif" border=0/></a>

<% if (refTab.equals("CALC_DETAIL")) { %>
	<a target="_blank" href="cpas-calcdetail.jsp?calcid=<%=key%>">Calc Detail</a>
<% } %>
<% if (refTab.equals("CALC_HTMLDETAIL")) { %>
	<a target="_blank" href="cpas-calchtmldetail.jsp?calcid=<%=key%>">Calc Detail</a>
<% } %>

<div style="display: none;" id="sql-<%=id%>"><%= refsql%></div>
<div style="display: none;" id="hide-<%=id%>"></div>
<div style="display: none;" id="sort-<%=id%>"></div>
<div style="display: none;" id="sortdir-<%=id%>">0</div>
<div style="display: none;" id="mode-<%=id%>">sort</div>
<div style="display: none;" id="ori-<%=id%>">H</div>
<div id="div-<%=id%>" style="margin-left: 40px; display: none;"></div>
<br/>
</div>
<%	
	}	
%>
<% if (cntRef > 0) {%>
	</div>
<% } %>

<%
	int lc = 0;
	for (int i=0; i<lcTabs.size(); i++) {
		String refTab = lcTabs.get(i);
		String fkColName = "PROCESSID";
		
		String qr = "SELECT COLUMN_NAME from user_tab_columns where table_name='" + refTab + "' " + 
				"and COLUMN_NAME in ('PROCESSID', 'PROCESSKEY')";
		if (cn.getTargetSchema() != null) {
			qr = "SELECT COLUMN_NAME from all_tab_columns where owner='" + cn.getTargetSchema() + "' and table_name='" + refTab + "' " + 
					"and COLUMN_NAME in ('PROCESSID', 'PROCESSKEY')";
		}
		
		fkColName = cn.queryOne(qr);
		if (fkColName== null) fkColName = "PROCESSID";
		
		if (table.equals("REPORTCAT")) {
			fkColName = "FILEID";
			key = q.getValue("FILEID");
		} else if (refTab.equals("CPAS_VALIDATION") || refTab.equals("BATCHCAT_PREVALSET")) {
			fkColName = "ERRORID";
			key = q.getValue("ERRORID");
		} 
			
		int recCount = cn.getPKLinkCount(refTab, fkColName , key);
		if (recCount==0) continue;
		String refsql = cn.getRelatedLinkSql(refTab, fkColName, key);

		if (refTab.equals("CALC_ERROR")) {
			refsql = "SELECT * FROM CALC_ERROR WHERE CALCID IN (SELECT CALCID FROM CALC WHERE PROCESSID='"+key+"')";
		} else if (refTab.equals("CPAS_VALIDATION")) {
			refsql = "SELECT * FROM CPAS_VALIDATION WHERE ERRORID IN ('"+key+"')";
		}
		
		id = Util.getId();
		lc++;
		//autoLoadChild.add(id);
		//cntRef++;
%>
<% if (lc == 1) {%>
	<b><a style="margin-left: 20px;" href="Javascript:toggleLChild()">CPAS Logical Child Table <img id="img-lchild" border=0 src="image/minus.gif"></a></b><br/>
<div id="div-lchild">
	<img style="margin-left: 40px;" src="image/arrow_up.jpg"><br/>
<% } %>

<div id="div-lchild-<%=id%>">
<a style="margin-left: 40px;" href="javascript:loadData('<%=id%>',0)"><b><%= refTab %></b> <img id="img-<%=id%>" border=0 align=middle src="image/plus.gif"></a>
(<span class="rowcountstyle"><%= recCount %></span> / <%= cn.getTableRowCount(refTab) %>)
<span class="cpas"><%= cn.getCpasComment(refTab) %></span>
&nbsp;&nbsp;<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" align=middle border=0 title="<%=refsql%>"/></a>
&nbsp;&nbsp;<a href="javascript:hideDiv('div-child-<%=id%>')"><img src="image/clear.gif" border=0/></a>
<div style="display: none;" id="sql-<%=id%>"><%= refsql%></div>
<div style="display: none;" id="hide-<%=id%>"></div>
<div style="display: none;" id="sort-<%=id%>"></div>
<div style="display: none;" id="sortdir-<%=id%>">0</div>
<div style="display: none;" id="mode-<%=id%>">sort</div>
<div style="display: none;" id="ori-<%=id%>">H</div>
<div id="div-<%=id%>" style="margin-left: 70px; display: none;"></div>
<br/>
</div>
<%	
	}	
%>

<% if (lcTabs.size() > 0) {%>
</div>
<% } %>


<% if (customLinks != null) {%>
	<b><a style="margin-left: 20px;" href="Javascript:toggleCustom()">Custom Link <img id="img-custom" border=0 src="image/minus.gif"></a></b><br/>
<div id="div-custom">
<%
	StringTokenizer st = new StringTokenizer(customLinks, ";");

	while (st.hasMoreTokens()) {
		String stmt = st.nextToken();
		List<String> tbls = Util.getTables(stmt);
		
		
		id = Util.getId();
		String refTab = tbls.get(0);
		String refsql = getQryStmt(stmt, q);
%>
<div id="div-custom-<%=id%>">
<a style="margin-left: 40px;" href="javascript:loadData('<%=id%>',0)"><b><%= refTab %></b> <img id="img-<%=id%>" border=0 align=middle src="image/plus.gif"></a>

&nbsp;&nbsp;<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" align=middle border=0 title="<%=refsql%>"/></a>
&nbsp;&nbsp;<a href="javascript:hideDiv('div-child-<%=id%>')"><img src="image/clear.gif" border=0/></a>
<div style="display: none;" id="sql-<%=id%>"><%= refsql%></div>
<div style="display: none;" id="hide-<%=id%>"></div>
<div style="display: none;" id="sort-<%=id%>"></div>
<div style="display: none;" id="sortdir-<%=id%>">0</div>
<div style="display: none;" id="mode-<%=id%>">sort</div>
<div style="display: none;" id="ori-<%=id%>">H</div>
<div id="div-<%=id%>" style="margin-left: 40px; display: none;"></div>
<br/>
</div>
<% 	} %>
</div>
<%} %>

<br/><br/>
<a href="Javascript:window.close()">Close</a>
&nbsp;&nbsp;&nbsp;
<a href="custom_link.jsp?tname=<%= table %>" target="_blank">Edit Custom DataLink</a>
<br/><br/>

<script type="text/javascript">
$(document).ready(function() {
<%
	for (String id1: autoLoadFK) {
%>
	loadData(<%=id1%>,1);
<%
	}
%>

<%
if (autoLoadChild.size() <= 5) {
	for (String id1: autoLoadChild) {
%>
	loadData(<%=id1%>,0);
<%
	}
}
%>
<%
	if (cntFK > 2 && cntLFK > 0) {
%>

toggleLFK();
<%
	}
%>
});	    
</script>

<form name="form_worksheet" target="_blank" action="worksheet.jsp" method="post">
<input id="sqls" name="sqls" type="hidden">
</form>

<form id="FormPop" name="FormPop" target="_blank" method="post" action="pop.jsp">
<input id="popType" name="type" type="hidden" value="OBJECT">
<input id="popKey" name="key" type="hidden">
</form>

<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '<%= Util.trackingId() %>']);
  _gaq.push(['_setDomainName', 'none']);
  _gaq.push(['_trackPageview']);
  
  _gaq.push(['_trackEvent', 'Datalink', 'Datalink <%= table %>']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>

<form id="FORM_query" name="FORM_query" action="query.jsp" target="_blank" method="post">
<input id="sql-query" name="sql" type="hidden"/>
</form>

</body>
</html>

