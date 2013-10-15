<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%!
public void BFS(Connect cn, int maxLevel, String pkg, String prc, ArrayList<PTree> pt, HashSet<String> explored, ArrayList<String> path, int level) {

	if (level >=maxLevel) return;
	
	String q = "SELECT target_pkg_name, target_proc_name FROM GENIE_PA_DEPENDENCY WHERE PACKAGE_NAME='" + pkg + "' AND PROCEDURE_NAME='" + prc + "' ORDER BY DECODE(TARGET_PKG_NAME,'" + pkg + "','0',TARGET_PKG_NAME), 2";
	List<String[]> proc1 = cn.query(q, false);
	
	ArrayList<String> res = new ArrayList<String>(); 
	for (int i=0;i<proc1.size();i++) {
		String sPkg = proc1.get(i)[1];
		String sPrc = proc1.get(i)[2];
		String target = sPkg + "." + sPrc;
		if (target.startsWith("DEF.")) continue;
	//if (explored.contains(target)) continue;

		
		pt.add(new PTree(target, path));

		ArrayList<String> newPath = new ArrayList<String>();
		newPath.addAll(path);
		newPath.add(target);		
		if (!explored.contains(target)) {
			explored.add(target);
			BFS(cn, maxLevel, sPkg, sPrc, pt, explored, newPath, level +1);
		}
	}
}

public synchronized List<String> getLogicalChildTables(Connect cn, String tname, Query q) {
//System.out.println("tname="+tname);	
	List<String> list = new ArrayList<String>();

	if ( tname.equals("BATCH") ) {
		list.add("CALC");
		// 1 Param table
		String paramTable = cn.queryOne("SELECT PARAMTABLE FROM BATCHCAT WHERE BATCHKEY='" +q.getValue("BATCHKEY") +"'");
		//System.out.println("paramTable=" + paramTable);
		if (paramTable != null && !paramTable.equals("")) {
			list.add(paramTable);
		}

		// 2 Buffer tables
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

		// 3 Tables from CRUD info	
		qry = "SELECT DISTINCT METHODNAME FROM BATCHCAT_TASK WHERE BATCHKEY='" + batchKey + "' AND METHODNAME != 'IMPBATCH'";
		lst = cn.queryMulti(qry);
		if (cn.isTVS("GENIE_PA_TABLE")) {
			 for (String pkg:lst) {
				ArrayList<PTree> pt = new ArrayList<PTree>(); 
				HashSet<String> explored = new HashSet<String>();
				ArrayList<String> path = new ArrayList<String>(); 
				BFS(cn, 5, pkg, "PERFORM", pt, explored, path, 0);

				HashSet<String> pkgs = new HashSet<String>();
				for (int i=0; i< pt.size(); i++) {
					PTree p = pt.get(i);
					if (!pkgs.contains(p.getPackage())) {
						pkgs.add(p.getPackage());
						//Util.p(p.getPackage());
					}
				}
				
				for (String pkgName: pkgs) {

					String q2 = "SELECT distinct table_name " +
							"FROM GENIE_PA_TABLE A WHERE PACKAGE_NAME='" + pkgName + "' AND " +
									" (op_insert='1' OR " +
	                    			"  (cols_update like '%|PROCESSID|%' OR cols_update like '%|PROCESSKEY|%' OR cols_update like '%|BATCHRUNID|%')) AND " +
									" exists (select 1 from user_tab_columns where table_name=A.table_name and column_name in ('PROCESSKEY','PROCESSID','BATCHRUNID'))";
					if (cn.getTargetSchema() != null) {
						q2 = "SELECT distinct table_name " +
								"FROM GENIE_PA_TABLE A WHERE PACKAGE_NAME='" + pkgName + "' AND " +
										" (op_insert='1' OR " +
		                    			"  (cols_update like '%|PROCESSID|%' OR cols_update like '%|PROCESSKEY|%' OR cols_update like '%|BATCHRUNID|%')) AND " +
										" exists (select 1 from all_tab_columns where owner='" + cn.getTargetSchema() + "' and table_name=A.table_name and column_name in ('PROCESSKEY','PROCESSID','BATCHRUNID'))";					}
					
					//Util.p(q2);
					List<String> l2 = cn.queryMulti(q2);
					for (String tbl:l2) {
						if (!list.contains(tbl)) {
							//Util.p(" *** " + tbl);
							list.add(tbl);
						}
					}
				}
			 }
		} 

		// 3 Sort by table name
		Collections.sort(list);
		
/*		
		// 3 Tables from CRUD info		
		// for BATCH get the package name
		// and get the table names from genie CRUD info
		// if the table has processid/processkey and not part of list, add to the list
		qry = "SELECT DISTINCT METHODNAME FROM BATCHCAT_TASK WHERE BATCHKEY='" + batchKey + "' AND METHODNAME != 'IMPBATCH'";
		lst = cn.queryMulti(qry);
		if (cn.isTVS("GENIE_PA_TABLE")) {
		 for (String pkg:lst) {
			//Util.p(pkg);
			String q2 = "select * from (SELECT distinct table_name " +
					"FROM GENIE_PA_TABLE A WHERE PACKAGE_NAME='" + pkg.toUpperCase() + "' and (op_insert='1' or op_update='1')) A " +
					"where exists (select 1 from USER_TAB_COLUMNS where table_name=A.table_name and column_name in ('PROCESSID', 'PROCESSKEY')) " +
					"order by 1";
			//Util.p(q2);
			List<String> l2 = cn.queryMulti(q2);
			for (String tbl:l2) {
				if (!list.contains(tbl)) {
					//Util.p(tbl);
					list.add(tbl);
				}
			}
		 }
		}
*/
		if (!list.contains("BATCH_ERROR"))
			list.add("BATCH_ERROR");
		if (!list.contains("CALC_ERROR"))
			list.add("CALC_ERROR");
		if (!list.contains("TASK") && cn.hasColumn("TASK", "PROCESSID"))
			list.add("TASK");
		

	} else if ( tname.equals("ERRORCAT") ) {
		if (cn.isTVS("CPAS_VALIDATION")) list.add("CPAS_VALIDATION");
		if (cn.isTVS("BATCHCAT_PREVALSET")) list.add("BATCHCAT_PREVALSET");
	} else if (tname.equals("FORMULA")) {
		list.add("PLAN_CALCTYPE_REPFIELD");
		list.add("MEMBER_PLAN_OVERRIDE");
//		Util.p("*** " + list);
	} else if (tname.equals("MEMBER")||tname.equals("SV_MEMBER")) {
		list.add("MEMBER_PLAN_ACCOUNT");
		list.add("ACCOUNT");
	} else if (tname.equals("CALC")) {
//		String qry = "SELECT TABLE_NAME FROM USER_TABLES A WHERE TABLE_NAME LIKE 'CALC_%' AND EXISTS (SELECT 1 FROM USER_TAB_COLS WHERE TABLE_NAME=A.TABLE_NAME AND COLUMN_NAME = 'CALCID') ORDER BY 1";
		String qry = "SELECT DISTINCT TABLE_NAME FROM USER_IND_COLUMNS A WHERE column_name='CALCID' /*and column_position=1 */ and table_name not like 'BIN%' ORDER BY 1";
		List<String> l2 = cn.queryMulti(qry);
		for (String tbl:l2) {
			//Util.p(" *** " + tbl);
			if (!list.contains(tbl)) {
				//Util.p(" *** " + tbl);
				list.add(tbl);
			}
		}
	} else if (tname.equals("CONNSESSION")) {
		if (cn.isTVS("WEBWIZARD"))
			list.add("WEBWIZARD");
	} else if (tname.equals("CPASSESSION")) {
		if (cn.isTVS("CONNSESSION"))
			list.add("CONNSESSION");
	}

	return list;
}

public String getQryStmt(String sql, Query q) {
	// replace [colname] to 'XXX' where XXX is the value of colname
	boolean needInput = false;
	List<String> params = new ArrayList<String>();
	
	String tmp ="";
	if (sql.contains(":")) {
		needInput = true;

		int prev = 0;
		while (true) {
			int start = sql.indexOf(":", prev);
			if (start <0) break;
			int end = sql.indexOf(" ", start);
			if (end <0) end = sql.length();
			tmp = sql.substring(start+1, end);
		
			if (tmp.endsWith(")")||tmp.endsWith(",")) tmp = tmp.substring(0, tmp.length()-1);
			params.add(tmp);
			prev = end+1;
		}
	}
	
	//System.out.println("params=" + params);
	
	for (String param: params) {
		String value = q.getValue(param);
		if (value.matches("\\d{4}-\\d{2}-\\d{2}")) {
			value = "to_date('" + value + "','yyyy-mm-dd')";
		} else {
			value = "'" + value + "'";
		}
		sql = sql.replaceAll(":" + param, value);
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
	//Util.p(refTabs.toString());
	lcTabs.removeAll(refTabs);
	if (table.equals("BATCH") && cn.isTVS("BD_CALC_REQUEST")) lcTabs.add("BD_CALC_REQUEST");

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
    <script src="script/genie.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
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

<div style="background-color: #E6F8E0; padding: 6px; border:1px solid #CCCCCC; border-radius:10px;">
<img src="image/star-big.png" width=20 height=20 align="top"/>
<span style="color: blue; font-family: Arial; font-size:16px; font-weight:bold;">Data Link</span>
 
&nbsp;&nbsp;
<b><%= cn.getUrlString() %></b>

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
<span style="float:right;">
Search <input id="globalSearch" style="width: 200px;" placeholder="table or view name"/>
</span>
</div>

<br/>

<div id="tableList1" style="display: hidden; margin-left: 20px;">
</div>



<%
	id = Util.getId();
%>

<b><%= table %></b> (<span class="rowcountstyle"><%= 1 %></span> / <%= cn.getTableRowCount(table) %>)
&nbsp;&nbsp<a href="pop.jsp?key=<%= table %>" target="_blank" title="Detail"><img border=0 src="image/detail.png"></a>
<a href="erd2.jsp?tname=<%= table %>" target="_blank" title="ERD"><img border=0 src="image/erd-s.gif"></a>
 <a href="javascript:openQuery('<%=id%>')"><img src="image/linkout.png" border=0 title="<%=sql%>"/></a>
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
		<img style="margin-left: 170px;" src="image/arrow_down.png"><br/>
<% } %>

<div id="div-fkk-<%=id%>"  style="margin-left: 170px;">
<a href="javascript:loadData('<%=id%>',1)"><b><%=ft%></b> <img id="img-<%=id%>" border=0 src="image/plus.gif"></a>
(<span class="rowcountstyle"><%= 1 %></span> / <%= cn.getTableRowCount(ft) %>)
<span class="cpas"><%= cn.getCpasComment(ft) %></span>
&nbsp;&nbsp;
<a href="pop.jsp?key=<%= ft %>" target="_blank" title="Detail"><img border=0 src="image/detail.png"></a>
<a href="erd2.jsp?tname=<%= ft %>" target="_blank" title="ERD"><img border=0 src="image/erd-s.gif"></a>
<a href="javascript:openQuery('<%=id%>')"><img src="image/linkout.png" border=0 title="<%=fsql%>"/></a>
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

		ft = cn.getCpasUtil().getLinkedTable(table, label);
		if (ft != null) {
			fsql = cn.getPKLinkSql(ft, q.getValue(label));
		}
/*
		for (int j=0; ft==null && j < cn.getCpasUtil().logicalLink.length; j++) {
			if (label.equals(cn.getCpasUtil().logicalLink[j][0])) {
				ft = cn.getCpasUtil().logicalLink[j][1];
				fsql = cn.getPKLinkSql(ft, q.getValue(label));
				//System.out.println("*** " + fsql);
				break;
			}
		}
*/
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
	<b><a style="margin-left: 150px;" href="Javascript:toggleLFK()">CPAS Logical Foreign Key <img id="img-lfk" border=0 src="image/minus.gif"></a></b><br/>
<div id="div-lfk" style="margin-top:10px;">
		<img style="margin-left: 170px;" src="image/arrow_down.png"><br/>
<% } %>


<div id="div-fkk-<%=id%>"  style="margin-left: 170px;">
> <a href="javascript:loadData('<%=id%>',1)"><b><%=ft%></b> <img id="img-<%=id%>" border=0 src="image/plus.gif"></a>
(<span class="rowcountstyle"><%= 1 %></span> / <%= cn.getTableRowCount(ft) %>)
<span class="cpas"><%= cn.getCpasComment(ft) %></span>
&nbsp;&nbsp;
<a href="pop.jsp?key=<%= ft %>" target="_blank" title="Detail"><img border=0 src="image/detail.png"></a>
<a href="erd2.jsp?tname=<%= ft %>" target="_blank" title="ERD"><img border=0 src="image/erd-s.gif"></a>
<a href="javascript:openQuery('<%=id%>')"><img src="image/linkout.png" border=0 title="<%=fsql%>"/></a>
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
		if (refTab.startsWith(cn.getSchemaName().toUpperCase()+".")) {
			refTab = refTab.substring(refTab.indexOf(".")+1); 
		}
//System.out.println("refTab="+refTab);		
		String fkColName = cn.getRefConstraintCols(table, refTab);
//System.out.println("fkColName="+fkColName);

		int recCount = 0;
		String refsql = "";
		recCount = cn.getPKLinkCount(refTab, fkColName , key);
		refsql = cn.getRelatedLinkSql(refTab, fkColName, key);
		
		if (recCount==0) continue;

		id = Util.getId();
		autoLoadChild.add(id);
		cntRef++;
%>

<% if (cntRef == 1) {%>
	<b><a style="margin-left: 20px;" href="Javascript:toggleChild()">Child Table <img id="img-child" border=0 src="image/minus.gif"></a></b><br/>
<div id="div-child">
	<img style="margin-left: 40px;" src="image/arrow_up.png"><br/>
<% } %>

<div id="div-child-<%=id%>">
<a style="margin-left: 40px;" href="javascript:loadData('<%=id%>',0)"><b><%= refTab %></b> <img id="img-<%=id%>" border=0 src="image/plus.gif"></a>
(<span class="rowcountstyle"><%= recCount %></span> / <%= cn.getTableRowCount(refTab) %>)
<span class="cpas"><%= cn.getCpasComment(refTab) %></span>
&nbsp;&nbsp;
<a href="pop.jsp?key=<%= refTab %>" target="_blank" title="Detail"><img border=0 src="image/detail.png"></a>
<a href="erd2.jsp?tname=<%= refTab %>" target="_blank" title="ERD"><img border=0 src="image/erd-s.gif"></a>
<a href="javascript:openQuery('<%=id%>')"><img src="image/linkout.png" border=0 title="<%=refsql%>"/></a>
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
		String fkColName = "";
		
		if (table.equals("BATCH")) {
		
			String qr = "SELECT COLUMN_NAME from user_tab_columns where table_name='" + refTab + "' " + 
					"and COLUMN_NAME in ('PROCESSID', 'PROCESSKEY', 'BATCHRUNID')";
			if (cn.getTargetSchema() != null) {
				qr = "SELECT COLUMN_NAME from all_tab_columns where owner='" + cn.getTargetSchema() + "' and table_name='" + refTab + "' " + 
						"and COLUMN_NAME in ('PROCESSID', 'PROCESSKEY', 'BATCHRUNID')";
			}
		
			fkColName = cn.queryOne(qr);
			if (fkColName== null) fkColName = "PROCESSID";
			if (refTab.equals("TASK")) {
				if (cn.hasColumn("TASK", "BATCHRUNID"))
					fkColName = "BATCHRUNID";
			}
			//if (refTab.equals("BD_CALC_REQUEST")) fkColName = "FEED_PROCESSID";
			
		} else if (table.equals("CALC")) {
			fkColName = "CALCID";
			key = q.getValue("CALCID");
		} else if (table.equals("REPORTCAT")) {
			fkColName = "FILEID";
			key = q.getValue("FILEID");
		} else if (refTab.equals("CPAS_VALIDATION") || refTab.equals("BATCHCAT_PREVALSET")) {
			fkColName = "ERRORID";
			key = q.getValue("ERRORID");
		} else if (refTab.equals("PLAN_CALCTYPE_REPFIELD")||refTab.equals("MEMBER_PLAN_OVERRIDE")) {
			fkColName = "FKEY";
			key = q.getValue("FKEY");
		} else if (refTab.equals("WEBWIZARD")&&table.equals("CONNSESSION")) {
			fkColName = "SESSIONID";
			key = q.getValue("SESSIONID");
		} else if (refTab.equals("CONNSESSION")&&table.equals("CPASSESSION")) {
			fkColName = "SESSIONID";
			key = q.getValue("SESSIONID");
		}

		//Util.p(table+"-"+refTab + "-");				
		int recCount = 0;
		String refsql = "";
		if ((table.equals("MEMBER")||table.equals("SV_MEMBER")) && refTab.equals("ACCOUNT")) {
			refsql = "SELECT * FROM ACCOUNT WHERE ACCOUNTID IN (SELECT ACCOUNTID FROM MEMBER_PLAN_ACCOUNT WHERE CLNT='"+q.getValue("CLNT")+"' AND MKEY='"+q.getValue("MKEY")+"')";
			String tmp = refsql.replace("SELECT * ", "SELECT COUNT(*) ");
			recCount = cn.getQryCount(tmp);
		} else if ((table.equals("MEMBER")||table.equals("SV_MEMBER")) && refTab.equals("MEMBER_PLAN_ACCOUNT")) {
			refsql = "SELECT * FROM MEMBER_PLAN_ACCOUNT WHERE ACCOUNTID IN (SELECT ACCOUNTID FROM MEMBER_PLAN_ACCOUNT WHERE CLNT='"+q.getValue("CLNT")+"' AND MKEY='"+q.getValue("MKEY")+"')";
			String tmp = refsql.replace("SELECT * ", "SELECT COUNT(*) ");
			recCount = cn.getQryCount(tmp);
		} else if (table.equals("BATCH") && refTab.equals("BD_CALC_REQUEST")) {
			refsql = "SELECT * FROM BD_CALC_REQUEST WHERE PROCESSID="+ key + " OR FEED_PROCESSID=" + key;
			Util.p(refsql);
			
			String tmp = refsql.replace("SELECT * ", "SELECT COUNT(*) ");
			recCount = cn.getQryCount(tmp);
		} else {
			recCount = cn.getPKLinkCount(refTab, fkColName , key);
			refsql = cn.getRelatedLinkSql(refTab, fkColName, key);
		}
		
		if (recCount==0) continue;

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
<br/>
	<b><a style="margin-left: 20px;" href="Javascript:toggleLChild()">CPAS Logical Child Table <img id="img-lchild" border=0 src="image/minus.gif"></a></b><br/>
<div id="div-lchild">
	<img style="margin-left: 40px;" src="image/arrow_up.png"><br/>
<% } %>

<div id="div-lchild-<%=id%>">
<a style="margin-left: 40px;" href="javascript:loadData('<%=id%>',0)"><b><%= refTab %></b> <img id="img-<%=id%>" border=0 src="image/plus.gif"></a>
(<span class="rowcountstyle"><%= recCount %></span> / <%= cn.getTableRowCount(refTab) %>)
<span class="cpas"><%= cn.getCpasComment(refTab) %></span>
&nbsp;&nbsp;
<a href="pop.jsp?key=<%= refTab %>" target="_blank" title="Detail"><img border=0 src="image/detail.png"></a>
<a href="erd2.jsp?tname=<%= refTab %>" target="_blank" title="ERD"><img border=0 src="image/erd-s.gif"></a>
<a href="javascript:openQuery('<%=id%>')"><img src="image/linkout.png" border=0 title="<%=refsql%>"/></a>
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
<a style="margin-left: 40px;" href="javascript:loadData('<%=id%>',0)"><b><%= refTab %></b> <img id="img-<%=id%>" border=0 src="image/plus.gif"></a>

&nbsp;&nbsp;
<a href="pop.jsp?key=<%= refTab %>" target="_blank" title="Detail"><img src="image/detail.png"></a>
<a href="erd2.jsp?tname=<%= refTab %>" target="_blank" title="ERD"><img border=0 src="image/erd-s.gif"></a>
<a href="javascript:openQuery('<%=id%>')"><img src="image/linkout.png" border=0 title="<%=refsql%>"/></a>
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


<%
List<String> refViews = cn.getReferencedViews(table);

int cnt=0;
if (refViews.size()>0) {
%>

<br/>
<b><a style="margin-left: 20px;" href="Javascript:toggleView()">View <img id="img-view" border=0 src="image/plus.gif"></a></b><br/>
<div id="div-view" style="display:none; margin-left: 40px;">

<%
	String condition = Util.buildCondition(pkCols,  key);
	String[] pks = pkCols.split("\\,");
//	for (String pk: pks)
		//Util.p("pks="+pk);
	for (int i=0; i<refViews.size(); i++) {
	
		String refView = refViews.get(i);

		List<TableCol> cols = cn.getTableDetail(null, refView);
		//Util.p(refView + " size=" + cols.size());
		//Util.p(" " + cols);
		boolean isOK = false;
		for (String c: pks) { // for every PK columns
			c = c.trim();
			isOK = false;
			//Util.p("c=" + c);
			for (TableCol co: cols) { // make sure the PK column is in the view
				//Util.p("*=" + co.getName());
				if ( co.getName().equals(c)) {
					isOK = true;
					//Util.p("found=" + co.getName());
					break;
				}
			}
			if (!isOK) break;
		}
		if (!isOK) {
			//Util.p("no found - " + refView);
			continue;
		}
		//Util.p(cols.toString());

		cnt++;
//		String refsql = cn.getRelatedLinkSql(refView, fkColName, key);

		String refsql = "SELECT * FROM " + refView + " WHERE " + condition;
		id = Util.getId();
%>	
	<div style="display: none;" id="sql-<%=id%>"><%= refsql%></div>
	<a href="Javascript:openQuery('<%= id %>')"><%= refView %></a>&nbsp;&nbsp;<br/>		
<% } }%>
</div>



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

