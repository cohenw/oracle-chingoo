<%@ page language="java" import="java.util.*" import="java.sql.*"
	import="chingoo.oracle.*" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>

<%!
public void DFS(Connect cn, int maxLevel, String pkg, String prc, ArrayList<PTree> pt, HashSet<String> explored, ArrayList<String> path, int level) {

	if (level >=maxLevel) return;
	
	String q = "SELECT target_pkg_name, target_proc_name FROM CHINGOO_PA_DEPENDENCY WHERE PACKAGE_NAME='" + pkg + "' AND PROCEDURE_NAME='" + prc + "' ORDER BY DECODE(TARGET_PKG_NAME,'" + pkg + "','0',TARGET_PKG_NAME), 2";
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
			DFS(cn, maxLevel, sPkg, sPrc, pt, explored, newPath, level +1);
		}
	}
}


public ArrayList<String> getTargetList(Connect cn, String pkg, String prc) {

	String q = "SELECT target_pkg_name, target_proc_name FROM CHINGOO_PA_DEPENDENCY WHERE PACKAGE_NAME='" + pkg + "' AND PROCEDURE_NAME='" + prc + "' ORDER BY DECODE(TARGET_PKG_NAME,'" + pkg + "','0',TARGET_PKG_NAME), 2";
	List<String[]> proc1 = cn.query(q, false);

	ArrayList<String> res = new ArrayList<String>(); 
	for (int i=0;i<proc1.size();i++) {
		String target = proc1.get(i)[1] + "." + proc1.get(i)[2];

		res.add(target);
	}
	
	return res;
}

public ArrayList<String> getCallerList(Connect cn, String pkg, String prc) {

	String q = "SELECT package_name, procedure_name FROM CHINGOO_PA_DEPENDENCY WHERE TARGET_PKG_NAME='" + pkg + "' AND TARGET_PROC_NAME='" + prc + "' ORDER BY DECODE(PACKAGE_NAME,'" + pkg + "','0',PACKAGE_NAME), 2";
	List<String[]> proc1 = cn.query(q, false);

	ArrayList<String> res = new ArrayList<String>(); 
	for (int i=0;i<proc1.size();i++) {
		String target = proc1.get(i)[1] + "." + proc1.get(i)[2];

		res.add(target);
	}
	
	return res;
}

public String showPath(Connect cn, String mainPkg, ArrayList<String> path) {
	String res = "";
	
	for (String s: path) {
		res += disp(cn, mainPkg, s) + " &gt; ";
	}
	
	return res;
}

public String showReversePath(Connect cn, String mainPkg, ArrayList<String> path) {
	String res = "";
	
	for (String s: path) {
		res += disp(cn, mainPkg, s) + " &lt; ";
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
	
	String q = "SELECT TABLE_NAME, OP_SELECT, OP_INSERT, OP_UPDATE, OP_DELETE FROM CHINGOO_PA_TABLE WHERE PACKAGE_NAME='" + gPkg +"' AND PROCEDURE_NAME='" + gPrc + "' ORDER BY table_name";
//	System.out.println(q);
	List<String[]> list0 = cn.query(q, false);
	
	HashSet<String> marked = new HashSet<String>();
	Queue<PTree> queue = new LinkedList();
	queue.add(new PTree(name, new ArrayList<String>()));
	marked.add(name);
	
	
	q = "SELECT START_LINE, END_LINE, PROCEDURE_LABEL FROM CHINGOO_PA_PROCEDURE WHERE PACKAGE_NAME='" + gPkg +"' AND PROCEDURE_NAME='" + gPrc + "' ORDER BY START_LINE";
//	System.out.println(q);
	List<String[]> proc0 = cn.query(q, false);
	
	String id = Util.getId();
%>

<html>
<head>
<title>Package Tree</title>

<meta name="description"
	content="Chingoo is an open-source, web based oracle database schema navigator." />
<meta name="keywords" content="Oracle Web Database OpenSource JDBC" />
<meta name="author" content="Spencer Hwang" />

<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
<script src="script/jquery-ui-1.8.18.custom.min.js"	type="text/javascript"></script>
<script src="script/chingoo.js?<%=Util.getScriptionVersion()%>" type="text/javascript"></script>

<link rel="icon" type="image/png" href="image/chingoo-icon.png">
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
</script>

</head>
<body>

<form name="form-map" id="form-map" action="package-tree.jsp" method="get">
<input id="name-map" name="name" type="hidden">
</form>

	<table width=100% border=0>
		<td><h2 style="color: blue;"><img src="image/cpas.jpg"
			title="Version <%=Util.getVersionDate()%>" /> Package Tree</h2></td>
		<td></td>
		<td>&nbsp;</td>

		<td>
<a href="index.jsp">Home</a> |
<a href="query.jsp" target="_blank">Query</a>
		</td>
		<td><b><%=cn.getUrlString()%></b></td>

<td align=right nowrap>
<%--
<b>Search</b> <input id="globalSearch" style="width: 200px;"/>
<input type="button" value="Find" onClick="Javascript:processSearch($('#globalSearch').val())"/>
 --%>
 </td>

 	</table>

<h3><%= gPkg + "." + cn.getProcedureLabel(gPkg, gPrc)  %>
&nbsp;&nbsp;
<a target=_blank href="src2.jsp?name=<%= gPkg %>#<%= gPrc.toLowerCase() %>">Source</a>
<a target=_blank href="package-browser.jsp?name=<%= name %>">PackgeBrowser</a>
</h3>

<b><a href="javascript:toggleData('<%=id%>')"><img id="img-<%=id%>" border=0 align=top src="image/plus.gif">Source Code</a></b>
<div id="div-<%=id %>" style="display: none; margin-left: 20px; background-color: #eeeeee;">
<%
for (int i=0;i<proc0.size();i++) {
	int start = Integer.parseInt(proc0.get(i)[1]);
	int end = Integer.parseInt(proc0.get(i)[2]);
	String label = proc0.get(i)[3];
	
	q = "SELECT LINE, TEXT FROM USER_SOURCE WHERE TYPE='PACKAGE BODY' AND NAME = '" + gPkg + "' AND LINE BETWEEN " + start + " AND " + end+ " ORDER BY LINE";
	//System.out.println(q);
	List<String[]> src = cn.query(q, false);
	String text = "";
	for (int j=0;j<src.size();j++) text += src.get(j)[2];
%>


<table>
<td valign=top align=right><pre style="font-family: Consolas; color: gray;">
<% 
	for (int k= start;k<=end;k++) {
		out.print(k+"\n");
	}	
%>
</pre></td>
<td bgcolor="green"></td>
<td valign=top><pre style="font-family: Consolas;">
<%= new HyperSyntax4PB().getHyperSyntax(cn, text, "PROCEDURE", gPkg)%>
</pre></td>
</table>
<br/>
<%		
	}
%>
</div>
<br/>

<h3>Table CRUD</h3>
<div style="margin-left: 20px;">
<%
for (int i=0;i<list0.size();i++) {
		String tname = list0.get(i)[1];
		String op = "";
		String opS = list0.get(i)[2];
		String opI = list0.get(i)[3];
		String opU = list0.get(i)[4];
		String opD = list0.get(i)[5];
		
		if (opI.equals("1")) op += "C";
		if (opS.equals("1")) op += "R";
		if (opU.equals("1")) op += "U";
		if (opD.equals("1")) op += "D";
%>
	<a target=_blank href="pop.jsp?key=<%= tname %>"><b><%= tname %></b></a> <span style='color: red; font-weight: bold;'><%= op %></span></br/>
<%		
	}
%>
</div>

<form id="form_level" name="form_level" method="get" action="package-tree.jsp">
<input name="name" type="hidden" value="<%=name%>">
<h3>Drill Down - up to
<input name="level" type="radio" value="1" onClick="javascript:changeLevel()" <%=(maxLevel==1)?"checked":"" %>>1
<input name="level" type="radio" value="2" onClick="javascript:changeLevel()" <%=(maxLevel==2)?"checked":"" %>>2
<input name="level" type="radio" value="3" onClick="javascript:changeLevel()" <%=maxLevel==3?"checked":"" %>>3
<input name="level" type="radio" value="4" onClick="javascript:changeLevel()" <%=maxLevel==4?"checked":"" %>>4
<input name="level" type="radio" value="5" onClick="javascript:changeLevel()" <%=maxLevel==5?"checked":"" %>>5
<input name="level" type="radio" value="6" onClick="javascript:changeLevel()" <%=maxLevel==6?"checked":"" %>>6
<input name="level" type="radio" value="7" onClick="javascript:changeLevel()" <%=maxLevel==7?"checked":"" %>>7
level
</h3>
</form>
<div id="drilldown" style="margin-left: 20px;">
<%
{
	ArrayList<PTree> pt = new ArrayList<PTree>(); 
	HashSet<String> explored = new HashSet<String>();
	ArrayList<String> path = new ArrayList<String>(); 
	DFS(cn, maxLevel, gPkg, gPrc, pt, explored, path, 0);
	int divOpen = 0;

	int prev = 0;
	for (int i=0; i< pt.size(); i++) {
		PTree p = pt.get(i);
//		System.out.println(p.getName() + " " + p.getPath());
		String s = p.getName();
		int lvl = p.getPath().size() + 1;
		int next = -1;
		if ((i+1) <pt.size()) {
			PTree pn = pt.get(i+1);
			next = pn.getPath().size() + 1;
		}
		
		int idx = s.indexOf(".");
		String pkg = s.substring(0,idx);
		String prc = s.substring(idx+1);
%>
<% if (lvl <= prev) {

	for (int j=prev; j>=lvl;j--) {
		divOpen--;
%>
</div>
<%  } 
} 
%>
<%-- 	 <%= lvl %> <%= prev %> <%= next %><%= showPath(gPkg,  p.getPath()) %> <a href="package-tree.jsp?name=<%=s%>"> <%= disp(gPkg, s) %></a><br/>
 --%>
 
<% 
	id = Util.getId();
	divOpen++;
%>
<a href="javascript:toggleData('<%=id%>')"><img id="img-<%=id%>" border=0 align=top src="image/minus.gif"></a>
<a href="package-tree.jsp?name=<%=s%>"> <%= disp(cn, gPkg, s) %></a>
<br/>
<div id="div-<%=id%>" style='margin-left: 80px;'> 

<%
	
	String q1 = "SELECT TABLE_NAME, OP_SELECT, OP_INSERT, OP_UPDATE, OP_DELETE FROM CHINGOO_PA_TABLE WHERE PACKAGE_NAME='" + pkg +"' AND PROCEDURE_NAME='" + prc + "' ORDER BY table_name";
//	System.out.println(q);
List<String[]> list = cn.query(q1, false);

for (int k=0;k<list.size();k++) {
		String tname = list.get(k)[1];
		String op = "";
		String opS = list.get(k)[2];
		String opI = list.get(k)[3];
		String opU = list.get(k)[4];
		String opD = list.get(k)[5];
		
		if (opI.equals("1")) op += "C";
		if (opS.equals("1")) op += "R";
		if (opU.equals("1")) op += "U";
		if (opD.equals("1")) op += "D";
%>
	<a target=_blank href="pop.jsp?key=<%= tname %>"><b><%= tname %></b></a> <span style='color: red; font-weight: bold;'><%= op %></span></br/>
<%		
}
%>


<%
		prev = lvl;
	}
	while (divOpen>0) {
		divOpen--;
%>
		</div>
<%		
	}
}
%>
</div>


<br/>
<h3>Called By</h3>
<div id="zoomout" style="margin-left: 20px;">
<%
	queue = new LinkedList();
	queue.add(new PTree(name, new ArrayList<String>()));
	marked.clear();
	marked.add(name);

while (true) {
		PTree x = queue.poll();
		if (x == null) break;

		ArrayList<String> path = x.getPath();
//System.out.println("x="+x.getName() + " " + path);		

		String pkg = x.getPackage();
		String prc = x.getProcedure();

		ArrayList<String> list = getCallerList(cn, pkg, prc); 
		for (String s: list) {
			//System.out.println("s0="+s);	
			if (s.startsWith("DEF.")) continue;
			if (marked.contains(s)) continue;
%>
			 <%= showReversePath(cn, gPkg, path) %> <a href="package-tree.jsp?name=<%=s%>"> <%= disp(cn, gPkg, s) %></a><br/>
<%
			marked.add(s);

			if ((path.size()+1) >=maxLevel) continue;
			ArrayList<String> newpath = new ArrayList<String>();
			newpath.addAll(path);
			newpath.add(s);
			queue.add( new PTree(s, newpath));
		}
		
	}
%>
</div>
<br/><br/><br/><br/><br/>

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

<form id="form-map" action="package-tree.jsp" method="get">
<input id="name-map" name="name" type="hidden">
</form>
</body>
</html>
