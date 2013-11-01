<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.oracle.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");

	String table = request.getParameter("tname");
	String tname = table;
	String owner = request.getParameter("owner");
	boolean isView = false; 
	
	// incase owner is null & table has owner info
	if (owner==null && table!=null && table.indexOf(".")>0) {
		int idx = table.indexOf(".");
		owner = table.substring(0, idx);
		table = table.substring(idx+1);
	}
	
//	String catalog = null;
	int idx = table.indexOf(".");
/* 	if (idx>0) {
		catalog = table.substring(0, idx);
		tname = table.substring(idx+1);
	}
	if (catalog==null) catalog = cn.getSchemaName();
 */
	if (owner==null) owner = cn.getSchemaName().toUpperCase();
	//System.out.println("owner=" + owner);
	//System.out.println("tname=" + tname);
	
	String pkName = cn.getPrimaryKeyName(owner, table);
	//System.out.println("pkName=" + pkName);
	
	ArrayList<String> pk = cn.getPrimaryKeys(owner, tname);
	if (pkName == null && owner != null) pkName = cn.getPrimaryKeyName(owner, table);

	String pkCols = cn.getConstraintCols(owner, pkName);
	if (pkName != null && pkCols.equals(""))
		pkCols = cn.getConstraintCols(owner, pkName);
	
	List<ForeignKey> fks = cn.getForeignKeys(owner, table);
	if (owner != null) fks = cn.getForeignKeys(owner, table);

	if(fks.size()==0) {
		// check if it is VIEW
		String q = "SELECT distinct REFERENCED_OWNER, REFERENCED_NAME, REFERENCED_TYPE from all_dependencies WHERE OWNER='" + owner + 
			"' and NAME='" + tname + "' AND REFERENCED_TYPE IN ('TABLE','VIEW') AND REFERENCED_OWNER != 'PUBLIC' ORDER BY REFERENCED_NAME";
		List<String[]> lst = cn.query(q, false);
		for (int i=0;i<lst.size();i++) {
			ForeignKey fk = new ForeignKey();
			fk.rOwner = lst.get(i)[1];
			fk.rTableName = lst.get(i)[2];
			fks.add(fk);
		}		
		isView = true;
	}
	
	List<String> refTabs = cn.getReferencedTables(owner, table);
	
//	List<TableCol> list = cn.getTableDetail(owner, table);	
	List<TableCol> list = cn.getTableDetail(table);
	List<String[]> refIdx = cn.getIndexes(owner, tname);
	List<String> refConst = cn.getConstraints(owner, tname);
	
%>

<html>
<head> 
	<title>ERD: <%= tname %></title>
	<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>
    <script src="script/data-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'>
	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
	<link rel="icon" type="image/png" href="image/chingoo-icon.png">
    
<script type="text/javascript">
	function toggleDiv(id) {
		var img = $("#img-"+ id).attr("src");
		if (img.indexOf("plus")>=0) {
			$("#img-"+ id).attr("src","image/minus.gif");
			$("#sub-"+id).slideDown();
		} else {
			$("#img-"+ id).attr("src","image/plus.gif");
			$("#sub-"+id).slideUp();
		}
	}
	
	function hideDiv(id) {
		$("#div-"+id).slideUp();
	}
	
	function openAll() {
		$("div ").each(function() {
			var divName = $(this).attr('id');
			if (divName != null && divName.indexOf("sub-")>=0) {
				$("#"+divName).slideDown();
				$("#img-"+divName.substring(4)).attr("src", "image/minus.gif");
			}
		});
	}
	
	function closeAll() {
		$("div ").each(function() {
			var divName = $(this).attr('id');
			if (divName != null && divName.indexOf("sub-")>=0) {
				$("#"+divName).slideUp();
				$("#img-"+divName.substring(4)).attr("src", "image/plus.gif");
			}
		});
	}
	
	function hideEmpty() {
		$("span ").each(function() {
			var spanName = $(this).attr('id');
			if (spanName != undefined && spanName.substring(0,7) == "rowcnt-") {
				var id = spanName.substring(7);
				var rowcnt = $("#"+spanName+".rowcountstyle").html();
				//alert('hide ' + id + " " + rowcnt);
				if (rowcnt == "0") hideDiv(id);
			}
		});
	}
	
	
	function runQuery(tab) {
		var sList = "";
		//var form = "DIV_" + tab; 

		var query = "SELECT * FROM " + tab + " A";
		
		$("#sql-query").val(query);
		$("#FORM_query").submit();
	}

	function loadTable(tname) {
		$("#tname").val(tname);
		$("#FORM_load").submit();
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

<div style="background-color: #EEEEEE; padding: 6px; border:1px solid #888888; border-radius:10px;">
<img src="image/data-link.png" align="middle"/>
<span style="color: blue; font-family: Arial; font-size:16px; font-weight:bold;">ERD</span>
<b><%= cn.getUrlString() %></b>
&nbsp;&nbsp;&nbsp;&nbsp;

<a href="index.jsp" target="_blank">Home</a> |
<a href="query.jsp" target="_blank">Query</a>

<span style="float:right;">
Search <input id="globalSearch" style="width: 200px;" placeholder="table or view name"/>
</span>
</div>

<br/>
<a href="Javascript:openAll()">Open All</a>&nbsp;
<a href="Javascript:closeAll()">Close All</a>&nbsp;
<a href="Javascript:hideEmpty()">Hide Empty Table</a>
<br/><br/>


<form id="FORM_query" name="FORM_query" action="query.jsp" target="_blank" method="post">
<input id="sql-query" name="sql" type="hidden"/>
<input name="norun" type="hidden" value="YES"/>
</form>

<form id="FORM_load" name="FORM_load" action="erd2.jsp" method="get">
<input id="tname" name="tname" type="hidden"/>
</form>


<div style="width: 1400px;">

<div id="div1" style="width: 450; float:left; margin: 4px; padding: 6px; border:0px solid #888888; ">

<% 
HashSet <String> hsTable = new HashSet<String>();
for (ForeignKey rec: fks) {
	if (hsTable.contains(rec.rTableName)) 
		continue;
	else
		hsTable.add(rec.rTableName);
		
	List<TableCol> list1 = cn.getTableDetail(rec.rOwner, rec.rTableName);
	ArrayList<String> pk1 = cn.getPrimaryKeys(rec.rOwner, rec.rTableName);
	
	
	String id = Util.getId();
%>
<table border=0 cellpadding=0 sellspacing=0>
<td width=180 valign=top>
<%
HashSet <String> hsTable0 = new HashSet<String>();
List<ForeignKey> fks0 = cn.getForeignKeys(owner, rec.rTableName);
if (owner != null) fks0 = cn.getForeignKeys(owner, rec.rTableName);
for (ForeignKey rec0: fks0) {
	if (hsTable0.contains(rec0.rTableName)) 
		continue;
	else
		hsTable0.add(rec0.rTableName);
	
	String tbl2 = rec0.rTableName;
%>
<div style="margin: 4px; padding:6px; background-color: #ffffcc; width:170px; border: 1px solid #cccccc; float: left;">
<b><a href="erd2.jsp?tname=<%= tbl2 %>"><%= tbl2 %></a></b> <span class="rowcountstyle"><%= cn.getTableRowCount(tbl2) %></span>
<a href="javascript:runQuery('<%= tbl2 %>')"><img border=0 src="image/view.png"></a>
<a href="pop.jsp?type=TABLE&key=<%= tbl2 %>" target="_blank"><img border=0 width=12 height=12 src="image/popout.png"></a>
</div><br/>

<% } %>
<div style="margin: 4px; padding:6px; width:174px;">&nbsp;</div>
</td>
<td width=36 valign=top>
<% if (hsTable0.size() > 0) { %>
<img src="image/blue_arrow_left.png" style="margin-top:5px; float:left">
<% } %>
<br/>
<div style="width: 32px;"></div>
</td>
<td valign=top>
<div id="div-<%=id%>" style="margin: 4px; padding:6px; background-color: #ffffcc; width:200px; border: 1px solid #cccccc; float: left;">
<b><a href="erd2.jsp?tname=<%= rec.rTableName %>"><%= rec.rTableName %></a></b> <span id="rowcnt-<%=id%>" class="rowcountstyle"><%= cn.getTableRowCount(rec.rTableName) %></span>
<a href="javascript:toggleDiv('<%= id %>')"><img id="img-<%=id%>" border=0 align=top src="image/plus.gif"></a>
<a href="javascript:runQuery('<%= rec.rTableName %>')"><img border=0 src="image/view.png"></a>
<a href="pop.jsp?type=TABLE&key=<%= rec.rTableName%>" target="_blank"><img border=0 width=12 height=12 src="image/popout.png"></a>
<a href="javascript:hideDiv('<%= id %>')">x</a>

<div id="sub-<%=id%>" style="display: none;">
<table>
<%
for (TableCol t: list1) {
	String colDisp = t.getName().toLowerCase();
	if (pk1.contains(t.getName())) colDisp = "<b>" + colDisp + "</b>";
%>
<tr>
<td width="10">&nbsp;</td>
<td>
<%= colDisp %>
</td>
<td>
<%= t.getTypeName() %>
</td>
</tr>
<% } %>
</table>
</div>
</div>
</td></table>
<% } %>

</div>

<img src="image/blue_arrow_left.png" style="margin-top:20px; float:left">

<div id="div2" style="width: 250; float:left; margin: 4px; padding: 6px; border:0px solid #888888; ">
<%
	String id = Util.getId();
%>

<div id="mainDiv" style="margin: 4px; padding:6px; background-color: #99FFFF; width:230px; border: 2px solid #333333;">
<b><%= tname %></b> <span class="rowcountstyle"><%= cn.getTableRowCount(tname) %></span>
<a href="javascript:toggleDiv('<%= id %>')"><img id="img-<%=id%>" border=0 align=top src="image/minus.gif"></a>
<a href="javascript:runQuery('<%= tname %>')"><img border=0 src="image/view.png"></a>
<a href="pop.jsp?type=TABLE&key=<%= tname %>" target="_blank"><img border=0 width=12 height=12 src="image/popout.png"></a>
<div id="sub-<%=id%>" style="display: block;">
<table>
<%
for (TableCol t: list) {
	String colDisp = t.getName().toLowerCase();
	if (pk.contains(t.getName())) colDisp = "<b>" + colDisp + "</b>";
%>
<tr>
<td width="10">&nbsp;</td>
<td>
<%= colDisp %>
</td>
<td>
<%= t.getTypeName() %>
</td>
</tr>
<% } %>
</table>
</div>
</div>

<br/>
<%-- TABLE DETAIL --%>
<% if (pkName != null)  {%>
<b>Primary Key</b><br/>
&nbsp;&nbsp;&nbsp;&nbsp;<%= pkName %> (<%= pkCols.toLowerCase() %>) 

<br/><br/>
<% } %>

<% 
	if (fks.size()>0 && !isView) { 
%>
<b>Foreign Key</b><br/>
<%

	for (int i=0; i<fks.size(); i++) {
		ForeignKey rec = fks.get(i);
		String rTable = rec.rTableName; //cn.getTableNameByPrimaryKey(rec.rConstraintName);
		boolean tabLink = true;
		if (rTable == null) {
//			rTable = rec.rOwner + "." + rec.rConstraintName;

			rTable = cn.getTableNameByPrimaryKey(rec.rOwner, rec.rConstraintName);
			
//			rTable = rec.rOwner + "." + rec.tableName;
			tabLink = false;
			tabLink = true;
		}
		if (!(rec.rOwner.equalsIgnoreCase(cn.getSchemaName()))) rTable = rec.rOwner + "." + rTable;
%>
&nbsp;&nbsp;&nbsp;&nbsp;<%= rec.constraintName %>
	(<%= cn.getConstraintCols(rec.owner, rec.constraintName).toLowerCase() %>)
	->
<%
	if (tabLink) {
%>
	<a href="Javascript:loadTable('<%= rTable %>')"><%= rTable %></a> <span class="rowcountstyle"><%= cn.getTableRowCount(rTable) %></span>
<%
	} else {
%>	
	<%= rTable %>
<%
	}
%>
	(<%= cn.getConstraintCols(rec.rOwner, rec.rConstraintName).toLowerCase() %>)
	
	On delete <%= rec.deleteRule %>
	<br/>
<%
 }
%>
	<br/>
<%
} 
%>

<% 
	if (refConst.size()>0) { 
%>
<b>Constraints</b><br/>
<%

	for (int i=0; i<refConst.size(); i++) {
		String constName = refConst.get(i);
%>
	&nbsp;&nbsp;&nbsp;&nbsp;<%= constName %> 
	<br/>
<%
	}
%>
<br/>
<%
	}
%>

<% 
	if (refIdx.size()>0) { 
%>
<b>Index</b><br/>
<%

	for (int i=0; i<refIdx.size(); i++) {
		String indexName = refIdx.get(i)[0];
		String indexType = refIdx.get(i)[1];
		if (indexType.equals("NONUNIQUE")) indexType= "";
%>
	&nbsp;&nbsp;&nbsp;&nbsp;<%= indexName %> 
	<%= cn.getIndexColumns(owner, indexName).toLowerCase() %>
	<%= indexType %> 
	<br/>
<%
	}
%>
<br/>
<%
}
%>


</div>

<img src="image/blue_arrow_left.png" style="margin-top:20px; float:left">

<div id="div3" style="float:left; margin: 4px; padding: 6px; border:0px solid #888888; ">

<% for (String tbl: refTabs) {
	if (tbl.equals(tname)) continue;
	if (tbl.startsWith(owner+".")) {
		int x = tbl.indexOf(".");
		tbl = tbl.substring(x+1);
	}
		
	List<String> refTabs2 = cn.getReferencedTables(tbl);
	List<TableCol> list1 = cn.getTableDetail(tbl);
	ArrayList<String> pk1 = cn.getPrimaryKeys(tbl);
	id = Util.getId();
%>

<div id="div-<%=id%>">
<table cellpadding=0 cellspacing=0 border=0>
<td valign=top>

<div id="div3-<%=id%>" style="margin: 4px; padding:6px; background-color: #ffffcc; width:200px; border: 1px solid #cccccc; float: left;">
<b><a href="erd2.jsp?tname=<%= tbl %>"><%= tbl %></a></b> <span id="rowcnt-<%=id%>" class="rowcountstyle"><%= cn.getTableRowCount(tbl) %></span>
<a href="javascript:toggleDiv('<%= id %>')"><img id="img-<%=id%>" border=0 align=top src="image/plus.gif"></a>
<a href="javascript:runQuery('<%= tbl %>')"><img border=0 src="image/view.png"></a>
<a href="pop.jsp?type=TABLE&key=<%= tbl %>" target="_blank"><img border=0 width=12 height=12 src="image/popout.png"></a>
<a href="javascript:hideDiv('<%= id %>')">x</a>


<div id="sub-<%=id%>" style="display: none;">
<table>
<%
for (TableCol t: list1) {
	String colDisp = t.getName().toLowerCase();
	if (pk1.contains(t.getName())) colDisp = "<b>" + colDisp + "</b>";
%>
<tr>
<td width="10">&nbsp;</td>
<td>
<%= colDisp %>
</td>
<td>
<%= t.getTypeName() %>
</td>
</tr>
<% } %>
</table>
</div>
</div>

</td>
<td valign=top>
<% if (refTabs2.size() > 0 ) { %>
<img src="image/blue_arrow_left.png" style="margin-top:5px; float:left">
<% } %>
</td>

<td valign=top>
<%

  for (String tbl2: refTabs2) { 
	List<TableCol> list2 = cn.getTableDetail(tbl);
	ArrayList<String> pk2 = cn.getPrimaryKeys(tbl);
	id = Util.getId();
%>
<div id="div-<%=id%>" style="margin: 4px; padding:6px; background-color: #ffffcc; width:200px; border: 1px solid #cccccc; float: left;">
<b><a href="erd2.jsp?tname=<%= tbl2 %>"><%= tbl2 %></a></b> <span id="rowcnt-<%=id%>" class="rowcountstyle"><%= cn.getTableRowCount(tbl2) %></span>
<a href="javascript:runQuery('<%= tbl2 %>')"><img border=0 src="image/view.png"></a>
<a href="pop.jsp?type=TABLE&key=<%= tbl2 %>" target="_blank"><img border=0 width=12 height=12 src="image/popout.png"></a>
</div><br/>
<% } %>

</div>
<br/>
</td>
</table>
</div>
<% } %>
</div>

</div>

<br clear="all"/>

    <script type="text/javascript">
    $(document).ready(function(){
    	openAll();
      });
    </script>

<form id="FormPop" name="FormPop" target="_blank" method="post" action="pop.jsp">
<input id="popType" name="type" type="hidden" value="OBJECT">
<input id="popKey" name="key" type="hidden">
</form>


<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '<%= Util.trackingId() %>']);
  _gaq.push(['_setDomainName', 'none']);
  _gaq.push(['_trackPageview']);

  _gaq.push(['_trackEvent', 'Erd', 'Erd <%= table %>']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>

</body>
</html>