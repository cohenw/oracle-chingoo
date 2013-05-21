<%@ page language="java" import="java.util.*" import="java.sql.*"
	import="spencer.genie.*" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>

<%!

public ArrayList<String> getTargetList(Connect cn, String pkg, String prc) {

	String q = "SELECT target_pkg_name, target_proc_name FROM GENIE_PA_DEPENDENCY WHERE PACKAGE_NAME='" + pkg + "' AND PROCEDURE_NAME='" + prc + "' ORDER BY DECODE(TARGET_PKG_NAME,'" + pkg + "','0',TARGET_PKG_NAME), 2";
	List<String[]> proc1 = cn.query(q, false);

	ArrayList<String> res = new ArrayList<String>(); 
	for (int i=0;i<proc1.size();i++) {
		String target = proc1.get(i)[1] + "." + proc1.get(i)[2];

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

public String showPath(String mainPkg, ArrayList<String> path) {
	String res = "";
	
	for (String s: path) {
		res += disp(mainPkg, s) + " &gt; ";
	}
	
	return res;
}

public String showReversePath(String mainPkg, ArrayList<String> path) {
	String res = "";
	
	for (String s: path) {
		res += disp(mainPkg, s) + " &lt; ";
	}
	
	return res;
}

public String disp(String mainPkg, String name) {
	int idx = name.indexOf(".");
	if (idx <0) return name;
	
	String pkg = name.substring(0, idx);
	String prc = name.substring(idx+1).toLowerCase();
	
	if (pkg.equals(mainPkg)) return prc;
	
	return pkg + "." + prc;
}

%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	String name = request.getParameter("name");
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
	
	String q = "SELECT TABLE_NAME, OP_SELECT, OP_INSERT, OP_UPDATE, OP_DELETE FROM GENIE_PA_TABLE WHERE PACKAGE_NAME='" + gPkg +"' AND PROCEDURE_NAME='" + gPrc + "' ORDER BY table_name";
//	System.out.println(q);
	List<String[]> list0 = cn.query(q, false);
	
	HashSet<String> marked = new HashSet<String>();
	Queue<PTree> queue = new LinkedList();
	queue.add(new PTree(name, new ArrayList<String>()));
	marked.add(name);
%>

<html>
<head>
<title>Package Drill Down</title>

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
</script>
</head>
<body>

<h2><%= name %>
&nbsp;&nbsp;
<a target=_blank href="src2.jsp?name=<%= gPkg %>#<%= gPrc.toLowerCase() %>">Source</a>
<a target=_blank href="package-browser.jsp?name=<%= name %>">PackgeBrowser</a>
</h2>

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

<h3>Drill Down</h3>
<div id="drilldown" style="margin-left: 20px;">
<%
	while (true) {
		PTree x = queue.poll();
		if (x == null) break;

		ArrayList<String> path = x.getPath();
//System.out.println("x="+x.getName() + " " + path);		

		String pkg = x.getPackage();
		String prc = x.getProcedure();

		ArrayList<String> list = getTargetList(cn, pkg, prc); 
		for (String s: list) {
			if (s.startsWith("DEF.")) continue;
			//System.out.println("s0="+s);		
			if (marked.contains(s)) continue;
%>
			 <%= showPath(gPkg, path) %> <a href="package-drill.jsp?name=<%=s%>"> <%= disp(gPkg, s) %></a>
<%--
&nbsp;&nbsp;			 
<a target=_blank href="src2.jsp?name=<%= pkg %>#<%= prc.toLowerCase() %>">S</a>
<a target=_blank href="package-browser.jsp?name=<%= s %>">P</a>
 --%>			 
			 <br/>
			 
<%
			marked.add(s);

			if (path.size() >5) continue;
			ArrayList<String> newpath = new ArrayList<String>();
			newpath.addAll(path);
			newpath.add(s);
			queue.add( new PTree(s, newpath));
		}
		
	}
%>
</div>

<br/>
<h3>Zoom Out</h3>
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
			 <%= showReversePath(gPkg, path) %> <a href="package-drill.jsp?name=<%=s%>"> <%= disp(gPkg, s) %></a><br/>
<%
			marked.add(s);

			if (path.size() >5) continue;
			ArrayList<String> newpath = new ArrayList<String>();
			newpath.addAll(path);
			newpath.add(s);
			queue.add( new PTree(s, newpath));
		}
		
	}
%>
</div>

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
