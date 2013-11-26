<%@ page language="java" import="java.util.*" import="java.sql.*"
	import="spencer.genie.*" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>

<%!
public String getTableCRUD(String pkgPrc, Connect cn) {
	int idx = pkgPrc.indexOf(".");
	String pkg = pkgPrc.substring(0, idx);
	String prc = pkgPrc.substring(idx+1);
	
	String q1 = "SELECT TABLE_NAME, OP_SELECT, OP_INSERT, OP_UPDATE, OP_DELETE FROM GENIE_PA_TABLE WHERE PACKAGE_NAME='" + pkg +"' AND PROCEDURE_NAME='" + prc + "' ORDER BY table_name";
	List<String[]> list0 = cn.query(q1, false);

	String res ="";
	String crud="";
	for (int i=0;i<list0.size();i++) {
		String tname = list0.get(i)[1];
		String op = "";
		String opS = list0.get(i)[2];
		String opI = list0.get(i)[3];
		String opU = list0.get(i)[4];
		String opD = list0.get(i)[5];
		if (opI.equals("1")) if (!crud.contains("C")) crud += "C";
		if (opS.equals("1")) if (!crud.contains("R")) crud += "R";
		if (opU.equals("1")) if (!crud.contains("U")) crud += "U";
		if (opD.equals("1")) if (!crud.contains("D")) crud += "D";
		
		res += "<a target=_blank href='pop.jsp?key=" + tname + "'><b>" + tname + "</b></a> <span style='color: red; font-weight: bold;'>" + crud + "</span> <span class='rowcountstyle'>"+ cn.getTableRowCount(tname) + "</span><br/>";
		crud="";
	}
	
	return res;
}

public ArrayList<String> getTargetList(Connect cn, String pkg, String prc) {

	String q = "SELECT target_pkg_name, target_proc_name FROM GENIE_PA_DEPENDENCY WHERE PACKAGE_NAME='" + pkg + "' AND PROCEDURE_NAME='" + prc + "' ORDER BY DECODE(TARGET_PKG_NAME,'" + pkg + "','0',TARGET_PKG_NAME), 2";
	List<String[]> proc1 = cn.query(q, false);

	ArrayList<String> res = new ArrayList<String>(); 
	for (int i=0;i<proc1.size();i++) {
		String target = proc1.get(i)[1] + "." + proc1.get(i)[2];

		if (cn.isPackageProc(target))
			res.add(target);
	}
	
	return res;
}

public ArrayList<String> getCallerList(Connect cn, String pkg, String prc) {

	String q = "SELECT package_name, procedure_name FROM GENIE_PA_DEPENDENCY WHERE TARGET_PKG_NAME='" + pkg + "' AND TARGET_PROC_NAME='" + prc + "' ORDER BY DECODE(PACKAGE_NAME,'" + pkg + "','0',PACKAGE_NAME), 2";
	List<String[]> proc1 = cn.query(q, false);

	ArrayList<String> res = new ArrayList<String>(); 
	for (int i=0;i<proc1.size();i++) {
		String target = proc1.get(i)[1] + "." + proc1.get(i)[2];

		res.add(target);
	}
	
	return res;
}

public ArrayList<String> getTriggerCallerList(Connect cn, String pkg, String prc) {

	String q = "SELECT trigger_name FROM GENIE_TR_DEPENDENCY WHERE TARGET_PKG_NAME='" + pkg + "' AND TARGET_PROC_NAME='" + prc + "' ORDER BY 1";
	List<String[]> trg1 = cn.query(q, false);

	ArrayList<String> res = new ArrayList<String>(); 
	for (int i=0;i<trg1.size();i++) {
		String target = trg1.get(i)[1];

		res.add(target);
	}
	
	return res;
}

public String disp(Connect cn, String mainPkg, String name) {
	int idx = name.indexOf(".");
	if (idx <0) return name;
	
	String pkg = name.substring(0, idx);
	String prc = name.substring(idx+1);
	prc = cn.getProcedureLabel(pkg, prc);
	
	if (pkg.equals(mainPkg)) return prc;
	
	return pkg + "." + prc;
}

%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	String name = request.getParameter("name");
	String level = request.getParameter("level");
	if (level==null || level.equals("")) level = "3";
	int maxLevel = Integer.parseInt(level);
	
	if (name != null) name = name.toUpperCase();
	String gPkg = "";
	String gPrc = "";
	if (name != null) {
		int idx = name.indexOf(".");
		if (idx <0) {
			gPkg = name;
		} else {
			gPkg = name.substring(0, idx);
			gPrc = name.substring(idx+1);
		}
	}
	cn.createPkg();
	cn.createTrg();
	
	String q1 = "SELECT 1 FROM GENIE_PA A, USER_OBJECTS B WHERE PACKAGE_NAME='" + gPkg.toUpperCase()+ "' AND A.PACKAGE_NAME=B.OBJECT_NAME AND B.OBJECT_TYPE IN ('PACKAGE BODY','TYPE BODY') AND	A.CREATED >= B.LAST_DDL_TIME";
	if (cn.getTargetSchema() != null) {
		q1 = "SELECT 1 FROM GENIE_PA A, ALL_OBJECTS B WHERE B.OWNER='" + cn.getTargetSchema() + "' AND PACKAGE_NAME='" + gPkg.toUpperCase()+ "' AND A.PACKAGE_NAME=B.OBJECT_NAME AND B.OBJECT_TYPE IN ('PACKAGE BODY','TYPE BODY') AND	A.CREATED >= B.LAST_DDL_TIME";
	}
	List<String[]> pkgs = cn.query(q1, false);
//	System.out.println(q1);
//	System.out.println(pkgs.size());
	if (pkgs.size() == 0) {
		response.sendRedirect("analyze-package.jsp?name="+gPkg+"&callback=" +  Util.escapeHtml("package-tree.jsp?name=" + name));
		return;
	}
	
	String q = "SELECT TABLE_NAME, OP_SELECT, OP_INSERT, OP_UPDATE, OP_DELETE FROM GENIE_PA_TABLE WHERE PACKAGE_NAME='" + gPkg +"' AND PROCEDURE_NAME='" + gPrc + "' ORDER BY table_name";
//	System.out.println(q);
	List<String[]> list0 = cn.query(q, false);
	
	HashSet<String> marked = new HashSet<String>();
	Queue<PTree> queue = new LinkedList();
	queue.add(new PTree(name, new ArrayList<String>()));
	marked.add(name);
	
	
	q = "SELECT START_LINE, END_LINE, PROCEDURE_LABEL FROM GENIE_PA_PROCEDURE WHERE PACKAGE_NAME='" + gPkg +"' AND PROCEDURE_NAME='" + gPrc + "' ORDER BY START_LINE";
//	System.out.println(q);
	List<String[]> proc0 = cn.query(q, false);
	
	String id = Util.getId();
%>

<html>
<head>
<title>Package Tree</title>

<meta name="description"
	content="Genie is an open-source, web based oracle database schema navigator." />
<meta name="keywords" content="Oracle Web Database OpenSource JDBC" />
<meta name="author" content="Spencer Hwang" />

<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
<script src="script/jquery-ui-1.8.18.custom.min.js"	type="text/javascript"></script>
<script src="script/genie.js?<%=Util.getScriptionVersion()%>" type="text/javascript"></script>

<link rel="icon" type="image/png" href="image/Genie-icon.png">
<link rel="stylesheet"
	href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css" />
<link rel='stylesheet' type='text/css'
	href='css/style.css?<%=Util.getScriptionVersion()%>'>


<script type="text/javascript">
function toggleData(id) {
	var imgSrc = $("#img-" + id).attr("src");
	var divName = "div-" + id;
	//alert(imgSrc);
	if (imgSrc.indexOf("plus") > 0) {
		$("#img-" + id).attr("src","image/minus.gif");
	} else {
		$("#img-" + id).attr("src","image/plus.gif");
		$("#" + divName).slideUp();
		return;
	}

	if ($("#" + divName).html().length > 3){
		$("#" + divName).slideDown();
		return;
	}
}

function loadProc(pkgName, prcName) {
	$("#name-map").val(pkgName+"."+prcName);
	$("#form-map").submit();
}	

</script>

<style>
  .highlight { background:yellow; }
</style>

<script type="text/javascript">
var hi_v = "";
function hi_on(v) {
	if (hi_v != "") hi_off(hi_v);
	$("." + v).addClass("highlight");
	hi_v = v;
}
function hi_off(v) {
	$("." + v).removeClass("highlight");
}

function changeLevel() {
	$("#form_level").submit();
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
//	alert(oname);
	$("#popKey").val(oname);
	$("#FormPop").submit();
}
    
</script>

</head>
<body>

<div style="background-color: #EEEEEE; padding: 6px; border:1px solid #888888; border-radius:10px;">
<img src="image/tree.png" align="middle"/>
<span style="color: blue; font-family: Arial; font-size:16px; font-weight:bold;">Package Tree</span>
 
&nbsp;&nbsp;
<b><%= cn.getUrlString() %></b>
&nbsp;&nbsp;
<a href="index.jsp" target="_blank">Home</a> |
<a href="query.jsp" target="_blank">Query</a>

<span style="float:right;">
Search <input id="globalSearch" style="width: 200px;" placeholder="table or view name"/>
</span>
</div>



<h2><%= gPkg + "." + cn.getProcedureLabel(gPkg, gPrc)  %></h2>

&nbsp;&nbsp;
<a target=_blank href="src2.jsp?name=<%= gPkg %>#<%= gPrc.toLowerCase() %>">PackageSource</a>
<a target=_blank href="package-browser.jsp?name=<%= name %>">PackgeBrowser</a>
<a target=_blank href="analyze-package.jsp?name=<%= gPkg %>">Analyze</a>


<form name="form-map" id="form-map" action="package-tree.jsp" method="get">
<input id="name-map" name="name" type="hidden">
</form>

<%
	if (gPkg.startsWith("DATA$VALIDATION_")) {
		String sql = "SELECT vkey, descr, errorid FROM CPAS_VALIDATION WHERE packname='" +gPkg + "' AND VNAME='" + cn.getProcedureLabel(gPkg, gPrc) + "'";
%>
<br/>
<b>CPAS Validation</b><br/>
<div id="div-<%=id%>">
<jsp:include page='ajax/qry-simple.jsp'>
	<jsp:param value="<%= sql %>" name="sql"/>
	<jsp:param value="1" name="dataLink"/>
	<jsp:param value="<%= id %>" name="id"/>
</jsp:include>
</div>
<br/>
<%
	}
%>


<br/>
<table border=0 cellpadding=0 cellspacing=0>
<td valign=top>

<div style="width: 250; float:left; margin: 4px; padding: 6px; border:1px solid #888888; background-color: #99FFFF;">
<b><%= cn.getProcedureLabel(gPkg, gPrc)  %></b><a href="javascript:showSource('<%= name %>')"><img src="image/detail.png"></a><br/>
<div style="margin-left:20px;"><%= getTableCRUD(name, cn) %></div>
</div>

</td>
<td valign=top>
<% id = Util.getId(); %>
	<a href="javascript:toggleData('<%=id%>')">
	<img style="margin-top:10px;" src="image/ico-arrow-right.gif"><br/>
	<img id="img-<%=id%>" border=0 align=top src="image/minus.gif"></a>
</td>
<td valign=top bgcolor="#999999" width=2></td>
<td valign=top>
<div id="div-<%=id %>" style="display: block;">
<%
	ArrayList<String> l = getTargetList(cn, gPkg, gPrc);

	for (String s : l) {
%>
<table border=0 cellpadding=0 cellspacing=0>
<td valign=top>
	<div style="width: 250; margin: 4px; padding: 6px; border:1px solid #888888; background-color: #FFFFCC;">
		<a href="package-tree.jsp?name=<%=s%>"><%= disp(cn, gPkg, s) %></a><a href="javascript:showSource('<%= s %>')"><img src="image/detail.png"></a><br/>
		<div style="margin-left:20px;"><%= getTableCRUD(s, cn) %></div>
	</div>
</td>
<td valign=top>
<%
	int idx = s.indexOf(".");
	String pkg = s.substring(0,idx);
	String prc = s.substring(idx+1);
	ArrayList<String> l2 = getTargetList(cn, pkg, prc);

	int i0=0;
	for (String s2 : l2) {
		i0++;
		if (i0==1) {
			id = Util.getId();
%>
	<a href="javascript:toggleData('<%=id%>')">
	<img  style="margin-top:10px;" src="image/ico-arrow-right.gif"><br/>
	<img id="img-<%=id%>" border=0 align=top src="image/minus.gif"></a>
	</td>
	<td valign=top bgcolor="#999999" width=2></td>
	<td valign=top>
		<div id="div-<%=id %>" style="display: block;">
<%			
		}
%>
<table border=0 cellpadding=0 cellspacing=0>
<td valign=top>

	<table border=0 cellpadding=0 cellspacing=0>
	<td valign=top>
		<div style="width: 250; margin: 4px; padding: 6px; border:1px solid #888888; background-color: #FFFFCC;">
			<a href="package-tree.jsp?name=<%=s2%>"><%= disp(cn, gPkg, s2) %></a><a href="javascript:showSource('<%= s2 %>')"><img src="image/detail.png"></a><br/>
			<div style="margin-left:20px;"><%= getTableCRUD(s2, cn) %></div>
		</div>
	</td>
	<td valign=top>
<%
		int idx2 = s2.indexOf(".");
		String pkg2 = s2.substring(0,idx2);
		String prc2 = s2.substring(idx2+1);
		ArrayList<String> l3 = getTargetList(cn, pkg2, prc2);

		int i2=0;
		for (String s3 : l3) {
			i2++;
			if (i2==1) {
				id = Util.getId();
%>
	<a href="javascript:toggleData('<%=id%>')">
	<img  style="margin-top:10px;" src="image/ico-arrow-right.gif"><br/>
	<img id="img-<%=id%>" border=0 align=top src="image/minus.gif"></a>
	</td>
	<td valign=top bgcolor="#999999" width=2></td>
	<td valign=top>
		<div id="div-<%=id %>" style="display: block;">
<%			
			}
%>	
			<div style="width: 250; margin: 4px; padding: 6px; border:1px solid #888888; background-color: #FFFFCC;">
			<a href="package-tree.jsp?name=<%=s3%>"><%= disp(cn, gPkg, s3) %></a><a href="javascript:showSource('<%= s3 %>')"><img src="image/detail.png"></a><br/>
			<div style="margin-left:20px;"><%= getTableCRUD(s3, cn) %></div>
		</div>
<%			
		}
%>	
		</div>
	</td>
	</table>
	<br/>
</td>
</table>
<% 	} %>
</div>
</td>
</table>
<br/>
<%	} %>
</div>
</td>
</table>

<br/>

<hr/>
<br/>



<table border=0 cellpadding=0 cellspacing=0>
<td valign=top>

<div style="width: 250; float:left; margin: 4px; padding: 6px; border:1px solid #888888; background-color: #99FFFF;">
<b><%= cn.getProcedureLabel(gPkg, gPrc)  %></b><a href="javascript:showSource('<%= name %>')"><img src="image/detail.png"></a><br/>
<div style="margin-left:20px;"><%= getTableCRUD(name, cn) %></div>
</div>

</td>
<td valign=top>
<% id = Util.getId(); %>
	<a href="javascript:toggleData('<%=id%>')">
	<img  style="margin-top:10px;" src="image/ico-arrow-left.gif"><br/>
	<img id="img-<%=id%>" border=0 align=top src="image/minus.gif"></a>
</td>
<td valign=top bgcolor="#999999" width=2></td>
<td valign=top>
<div id="div-<%=id %>" style="display: block;">
<%
	ArrayList<String> l0 = getCallerList(cn, gPkg, gPrc);

	for (String s : l0) {
%>
<table border=0 cellpadding=0 cellspacing=0>
<td valign=top>
	<div style="width: 250; margin: 4px; padding: 6px; border:1px solid #888888; background-color: #FFFFCC;">
		<a href="package-tree.jsp?name=<%=s%>"><%= disp(cn, gPkg, s) %></a><a href="javascript:showSource('<%= s %>')"><img src="image/detail.png"></a><br/>
		<div style="margin-left:20px;"><%= getTableCRUD(s, cn) %></div>
		
	</div>
</td>
<td valign=top>
<%
	int idx = s.indexOf(".");
	String pkg = s.substring(0,idx);
	String prc = s.substring(idx+1);
	ArrayList<String> l2 = getCallerList(cn, pkg, prc);

	int i0=0;
	for (String s2 : l2) {
		i0++;
		if (i0==1) {
			id = Util.getId();
%>
	<a href="javascript:toggleData('<%=id%>')">
	<img  style="margin-top:10px;" src="image/ico-arrow-left.gif"><br/>
	<img id="img-<%=id%>" border=0 align=top src="image/minus.gif"></a>
	</td>
	<td valign=top bgcolor="#999999" width=2></td>
	<td valign=top>
		<div id="div-<%=id %>" style="display: block;">
<%			
		}
%>
<table border=0 cellpadding=0 cellspacing=0>
<td valign=top>

	<table border=0 cellpadding=0 cellspacing=0>
	<td valign=top>
		<div style="width: 250; margin: 4px; padding: 6px; border:1px solid #888888; background-color: #FFFFCC;">
			<a href="package-tree.jsp?name=<%=s2%>"><%= disp(cn, gPkg, s2) %></a><a href="javascript:showSource('<%= s2 %>')"><img src="image/detail.png"></a><br/>
			<div style="margin-left:20px;"><%= getTableCRUD(s2, cn) %></div>
		</div>
	</td>
	<td valign=top>
<%
		int idx2 = s2.indexOf(".");
		String pkg2 = s2.substring(0,idx2);
		String prc2 = s2.substring(idx2+1);
		ArrayList<String> l3 = getCallerList(cn, pkg2, prc2);

		int i2=0;
		for (String s3 : l3) {
			i2++;
			if (i2==1) {
				id = Util.getId();
%>
	<a href="javascript:toggleData('<%=id%>')">
	<img  style="margin-top:10px;" src="image/ico-arrow-left.gif"><br/>
	<img id="img-<%=id%>" border=0 align=top src="image/minus.gif"></a>
	</td>
	<td valign=top bgcolor="#999999" width=2></td>
	<td valign=top>
		<div id="div-<%=id %>" style="display: block;">
<%			
			}
%>	
			<div style="width: 250; margin: 4px; padding: 6px; border:1px solid #888888; background-color: #FFFFCC;">
			<a href="package-tree.jsp?name=<%=s3%>"><%= disp(cn, gPkg, s3) %></a><a href="javascript:showSource('<%= s3 %>')"><img src="image/detail.png"></a><br/>
			<div style="margin-left:20px;"><%= getTableCRUD(s3, cn) %></div>
		</div>
<%			
		}
%>	
	</div>
	</td>
	</table>
	<br/>
</td>
</table>
<% 	} %>
</div>
</td>
</table>
<br/>
<%	} %>
</div>
</td>
</table>
<br/>




<br/>
<%
//for Triggers

		ArrayList<String> list = getTriggerCallerList(cn, gPkg, gPrc); 
		for (String s: list) {
%>			
	<a target="_blank" href="pop.jsp?type=PACKAGE&key=<%=s %>"><%= s %></a><br/>
<%			
		}
%>













<br/>
<form id="FORM_query" name="FORM_query" action="query.jsp" target="_blank" method="post">
<input id="sql-query" name="sql" type="hidden"/>
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

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>


</body>
</html>
