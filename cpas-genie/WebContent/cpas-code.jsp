<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%!
	ArrayList<String> getBindVariableList(String qry) {
		ArrayList<String> al = new ArrayList<String>();
		if (qry==null) return al;
		StringTokenizer st = new StringTokenizer(qry, " =)\n");

		while (st.hasMoreTokens()) {
			String token = st.nextToken().trim();
			if (token.startsWith(":") && !token.startsWith(":=") && token.length()>1) {
				System.out.println("token=" + token);
				al.add(token);
			}
		}
		return al;
	}
%>

<%
	int counter = 0;
	Connect cn = (Connect) session.getAttribute("CN");

	String q = "SELECT caption, grup FROM cpas_code order by 1";
	List<String[]> codes = cn.query(q);

	String q2 = "SELECT caption, grup FROM cpas_code order by 2";
	List<String[]> codes2 = cn.query(q2);
	
	String key = request.getParameter("key");
	String key2 = request.getParameter("key2");
	if (key2 != null && key2.length()>0)
		key = key2;
	
	if (key==null) key = "";
%>
<html>
<head> 
	<title>CPAS Code</title>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 

    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    <script src="script/genie.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <script src="script/data-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
	<link rel='stylesheet' type='text/css' href='css/doc.css?<%=Util.getScriptionVersion()%>'>
	<link rel='stylesheet' type='text/css' href='css/newdoc.css?<%=Util.getScriptionVersion()%>'>
	
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
	    
	<script type="text/javascript">
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
		$("#popKey").val(oname);
    	$("#FormPop").submit();
	}
	    
	function loadProc(pkgName, prcName) {
		$("#name-map").val(pkgName+"."+prcName);
		$("#form-map").submit();
	}	
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

<div id="topline" style="background-color: #EEEEEE; pading: 0px; border:1px solid #888888; border-radius:10px;">
<table width=100% border=0 cellpadding=0 cellspacing=0>
<td width="44">
<img align=top src="image/lamp.png" alt="Ver. <%= Util.getVersionDate() %>" title="<%= Util.getBuildNo() %>"/>
</td>
<td>
<span style="font-family: Arial; font-size:18px;"><span style="background-color:black; color: white;">C</span><span style="background-color:#FF9900; color: white;">PAS</span> <span style="color: blue; font-family: Arial; font-size:18px; font-weight:bold;">Code</span></span>
</td>
<!-- <td nowrap><h2 style="color: blue;">Genie</h2></td> -->
<td><b><%= cn.getUrlString() %></b></td>
<td nowrap>

<a href="index.jsp">Home</a> |
<a href="query.jsp" target="_blank">Query</a>

</td>
<td align=right nowrap>

Search <input id="globalSearch" style="width: 200px;" placeholder="table or view name"/>
</td>
</table>
</div>


<br/>

<form>
CODE
<select name="key">
<%

	for (String[] cd: codes) {
%>
	<option value="<%= cd[2] %>" <%= key.equals(cd[2])?"SELECTED":"" %>><%= cd[1] %> [<%= cd[2] %>]</option>
<%
	}
%>
</select>
<select name="key2">
<option></option>
<%

	for (String[] cd: codes2) {
%>
	<option value="<%= cd[2] %>">[<%= cd[2] %>] <%= cd[1] %></option>
<%
	}
%>
</select>

<input type="submit">
</form>
<hr/>
<%
String sql = "SELECT SOURCE, CAPTION, SELECTSTMT FROM CPAS_CODE WHERE GRUP = '" + key + "'";
int cpasType = cn.getCpasType();
if (cpasType ==5) {
	sql = "SELECT TYPE, (SELECT capt from CODE_CAPTION WHERE GRUP='"	+ key + "' AND LANG='E'), (SELECT STMTCODE FROM CODE_SELECT WHERE GRUP=A.GRUP) STMT FROM CODE A WHERE GRUP='"	+ key + "'";
}

List<String[]> res = cn.query(sql, false);

if (res.size() == 0) return;
String id = Util.getId();
String source = res.get(0)[1];
String caption = res.get(0)[2];
String selectstmt = res.get(0)[3];

if (source.equals("T"))
	sql = "SELECT VALU, NAME FROM CPAS_CODE_VALUE WHERE GRUP='" + key + "'";
else if (source.equals("S") || source.equals("3"))
	sql = selectstmt;
else if (source.equals("P") && false) {
	// to do for 'P' : procedure
	String stmt = cn.queryOne("SELECT SELECTSTMT FROM CPAS_CODE WHERE GRUP = '" + key + "'");
	System.out.println("stmt=" + stmt);
	if (stmt.startsWith("BEGIN")) {
		CallableStatement call = cn.getConnection().prepareCall(stmt);
		call.execute();
		call.close();
	}
	sql = "SELECT VALU, NAME FROM CT$CODE ORDER BY ORDERBY";
}

if (cpasType == 5) {
	if (source.equals("G")) {
		sql = "SELECT VALU, NAME FROM CODE_VALUE_NAME WHERE GRUP='" + key + "'";
	} if (source.equals("C")||source.equals("P")) {
		sql = selectstmt;
	}
}


boolean isDynamic = false;

ArrayList<String> varAl = getBindVariableList(sql);
if (varAl.size() >0 ) isDynamic = true;
System.out.println("isDynamic=" + isDynamic);

String sqlh = sql;
String dynamicVars = request.getParameter("dynamicVars");
//System.out.println("*** dynamicVars=" + dynamicVars);
if (dynamicVars!=null && dynamicVars.length() > 0) {
	isDynamic = true;
	String[] vars = dynamicVars.split(" ");
	for (String var : vars) {
		System.out.println("* " + var + ": " + request.getParameter(var));
		sqlh = sqlh.replaceAll(var, "'" + request.getParameter(var) + "'");
	}
}		


%>

<h2><%=caption %> [<%= key %>]</h2>
<div id="sql-<%=id%>" style="display: none;"><%= sql %></div>
<span id="sqlorig-<%=id%>"><%= sql %></span>
&nbsp;
<a href="javascript:openQuery('<%=id%>')"><img src="image/linkout.png" border="0"></a>
&nbsp;
<div style="display: none;" id="sql-<%=id%>"><%= sql%></div>
<div style="display: none;" id="mode-<%=id%>">sort</div>
<div style="display: none;" id="ori-<%=id%>">H</div>
<div style="display: none;" id="hide-<%=id%>"></div>
<div style="display: none;" id="sort-<%=id%>"></div>
<div style="display: none;" id="sortdir-<%=id%>">0</div>

<br/>
<%
	if (isDynamic) {
		String varlist = "";
		int i=0;
		for (String var:varAl) {
			varlist += var.substring(1) + " ";
			i++;
			String defaultVal = (String) session.getAttribute(var.substring(1));
			if (defaultVal==null) defaultVal = "";
Util.p("-- " + var);			
%>
	<%= var %> <input id="dyn<%=id%>-<%= var.substring(1) %>" length=30 value="<%=defaultVal%>">
<%
		}
%>
		<input id="dyn<%=id%>-vars" value="<%= varlist.trim() %>" type="hidden"/>
		<input type="button" value="submit" onClick="applyParameter(<%=id%>)">
<%		
		//return;
	}
%>

<div id="div-<%=id%>">
<jsp:include page='ajax/qry-simple.jsp'>
	<jsp:param value="<%= sql %>" name="sql"/>
	<jsp:param value="0" name="dataLink"/>
	<jsp:param value="<%= id %>" name="id"/>
	<jsp:param value="0" name="dataLink"/>
	<jsp:param value="0" name="cpas"/>
</jsp:include>
</div>

<br/>
<h2>Referenced By</h2>
<%
	sql = "SELECT * FROM CPAS_TABLE_COL A WHERE CODE='"+key+"'";
	id = Util.getId();
%>
<%= sql %>
<div id="sql-<%=id%>" style="display: none;"><%= sql %></div>
<span id="sqlorig-<%=id%>"><%= sql %></span>
&nbsp;
&nbsp;
<a href="javascript:openQuery('<%=id%>')"><img src="image/linkout.png" border="0"></a>
&nbsp;
<div id="div-<%=id%>">
<jsp:include page='ajax/qry-simple.jsp'>
	<jsp:param value="<%= sql %>" name="sql"/>
	<jsp:param value="1" name="dataLink"/>
	<jsp:param value="<%= id %>" name="id"/>
	<jsp:param value="0" name="cpas"/>
</jsp:include>
</div>

<br/>
<%
if (cn.isTVS("BATCHCAT_IFACE_COL")) {
	sql = "SELECT * FROM BATCHCAT_IFACE_COL A WHERE CODE='"+key+"'";
	id = Util.getId();
%>
<%= sql %>
<div id="sql-<%=id%>" style="display: none;"><%= sql %></div>
<span id="sqlorig-<%=id%>"><%= sql %></span>
&nbsp;
&nbsp;
<a href="javascript:openQuery('<%=id%>')"><img src="image/linkout.png" border="0"></a>
&nbsp;
<div id="div-<%=id%>">
<jsp:include page='ajax/qry-simple.jsp'>
	<jsp:param value="<%= sql %>" name="sql"/>
	<jsp:param value="1" name="dataLink"/>
	<jsp:param value="<%= id %>" name="id"/>
	<jsp:param value="0" name="cpas"/>
</jsp:include>
</div>
<br/>
<%
}
if (cn.isTVS("CPAS_WIZARD_FIELD")) {
	sql = "SELECT * FROM CPAS_WIZARD_FIELD A WHERE CODE='"+key+"'";
	id = Util.getId();
%>
<%= sql %>
<div id="sql-<%=id%>" style="display: none;"><%= sql %></div>
<span id="sqlorig-<%=id%>"><%= sql %></span>
&nbsp;
&nbsp;
<a href="javascript:openQuery('<%=id%>')"><img src="image/linkout.png" border="0"></a>
&nbsp;
<div id="div-<%=id%>">
<jsp:include page='ajax/qry-simple.jsp'>
	<jsp:param value="<%= sql %>" name="sql"/>
	<jsp:param value="1" name="dataLink"/>
	<jsp:param value="<%= id %>" name="id"/>
	<jsp:param value="0" name="cpas"/>
</jsp:include>
</div>

<br/>
<%
}
if (cn.isTVS("CPAS_REPORT_PARAMETER")) {
	sql = "SELECT * FROM CPAS_REPORT_PARAMETER A WHERE CODE='"+key+"'";
	id = Util.getId();
%>
<%= sql %>
<div id="sql-<%=id%>" style="display: none;"><%= sql %></div>
<span id="sqlorig-<%=id%>"><%= sql %></span>
&nbsp;
&nbsp;
<a href="javascript:openQuery('<%=id%>')"><img src="image/linkout.png" border="0"></a>
&nbsp;
<div id="div-<%=id%>">
<jsp:include page='ajax/qry-simple.jsp'>
	<jsp:param value="<%= sql %>" name="sql"/>
	<jsp:param value="1" name="dataLink"/>
	<jsp:param value="<%= id %>" name="id"/>
	<jsp:param value="0" name="cpas"/>
</jsp:include>
</div>
<%
}
%>


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

<form id="FORM_query" name="FORM_query" action="query.jsp" target="_blank" method="post">
<input id="sql-query" name="sql" type="hidden"/>
</form>

<form id="FormPop" name="FormPop" target="_blank" method="post" action="pop.jsp">
<input id="popType" name="type" type="hidden" value="OBJECT">
<input id="popKey" name="key" type="hidden">
</form>

<script type="text/javascript">
//	hideNullColumn("" + <%= id %>);
	hideNullColumnTable("" + <%= id %>);
</script>

</body>
</html>
