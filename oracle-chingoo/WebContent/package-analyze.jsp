<%@ page language="java" import="java.util.*" import="java.sql.*"
	import="chingoo.oracle.*" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	String name = request.getParameter("name");

	String q = "SELECT object_name FROM user_objects where object_type='PACKAGE BODY' ORDER BY 1";
	if (cn.isTVS("CHINGOO_PA")) {
		q = "SELECT object_name FROM user_objects A where object_type='PACKAGE BODY' AND NOT EXISTS (SELECT 1 FROM CHINGOO_PA WHERE PACKAGE_NAME=A.OBJECT_NAME AND CREATED > A.LAST_DDL_TIME) ORDER BY 1";
	}
	q = "SELECT object_name FROM user_objects where object_type='PACKAGE BODY' AND object_name IN ('" + name + "') ORDER BY 1";

	List<String[]> pkgs = cn.query(q, false);
%>
<html>
<head>
	<title>Source for <%= name %></title>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 

	<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
	<script src="script/main.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
	<script type="text/javascript" src="script/shCore.js"></script>
	<script type="text/javascript" src="script/shBrushSql.js"></script>
    <link href='css/shCore.css' rel='stylesheet' type='text/css' > 
    <link href="css/shThemeDefault.css" rel="stylesheet" type="text/css" />
    <link href="css/style.css?<%= Util.getScriptionVersion() %>" rel="stylesheet" type="text/css" />
	<link rel="icon" type="image/png" href="image/chingoo-icon.png">

<script type="text/javascript">
$(document).ready(function() {
	$("#wait").html("Done.");
});
</script>
</head>
<body>
	Analyze Package: <b><%= name %></b><br/>
	
<div id="wait">
<img src="image/waiting_big.gif">
</div>
<%
	for (int k=0;k<pkgs.size();k++) {
		String type = "PACKAGE BODY";
		String pkgName = pkgs.get(k)[1]; 
		System.out.println(pkgName);
		out.println((k+1) + " " + pkgName+"<br/>");
		out.flush();
		
		String qry = "SELECT TYPE, LINE, TEXT FROM USER_SOURCE WHERE NAME='" + pkgName +"' AND TYPE = '" + type + "' ORDER BY TYPE, LINE";
		List<String[]> list = cn.query(qry, 20000, false);
		
		String text = "";
		int line = 0;
		for (int i=0;i<list.size();i++) {
			String ln = list.get(i)[3];
			line = Integer.parseInt(list.get(i)[2]);
			if (!ln.endsWith("\n")) ln += "\n";
			//text += Util.escapeHtml(ln);
			text += ln;
			
		}
		
		PackageTable pt = new PackageTable(pkgName, text);
		cn.AddPackageTable(pkgName, pt.getHM(), pt.getHMIns(), pt.getHMUpd(), pt.getHMDel());
//		System.out.println(pt.getHM());
//		out.println(pt.getHM()+"<br/>");

		HyperSyntax hs = new HyperSyntax();
		String syntax = hs.getHyperSyntax(cn, text, "PACKAGE BODY", pkgName);
		HashSet<String> packageProc = hs.getPackageProcedure();
//		System.out.println(packageProc);
		cn.AddPackageProcDetail(pkgName, pt.getPD());
		cn.AddPackageProc(pkgName, packageProc);		
		hs = null;
		list=null;
	}

//	out.println("Done.<br/>");
%>

</body>
</html>