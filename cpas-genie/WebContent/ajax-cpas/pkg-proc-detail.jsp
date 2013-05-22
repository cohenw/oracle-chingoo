<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	String key = request.getParameter("key");
%>
<%
	int counter = 0;
	String name = key;
	String pkg=null;
	String prc=null;
	if (name != null && !name.equals("")) {
		int idx = name.indexOf(".");
		pkg = name.substring(0,idx).toUpperCase();
		prc = name.substring(idx+1).toUpperCase();
	}
	
	String q = "SELECT TABLE_NAME, OP_SELECT, OP_INSERT, OP_UPDATE, OP_DELETE FROM GENIE_PA_TABLE WHERE PACKAGE_NAME='" + pkg +"' AND PROCEDURE_NAME='" + prc + "' ORDER BY table_name";
//	System.out.println(q);
	List<String[]> list = cn.query(q, false);

	q = "SELECT TARGET_PKG_NAME, TARGET_PROC_NAME FROM GENIE_PA_DEPENDENCY WHERE PACKAGE_NAME='" + pkg +"' AND PROCEDURE_NAME='" + prc + "' ORDER BY DECODE(TARGET_PKG_NAME,'" + pkg + "','0',TARGET_PKG_NAME), 2";
//	System.out.println(q);
	List<String[]> proc1 = cn.query(q, false);

	String id = "";
%>
<div style="margin-left: 20px;">
<%
	for (int i=0;i<list.size();i++) {
		String tname = list.get(i)[1];
		String op = "";
		String opS = list.get(i)[2];
		String opI = list.get(i)[3];
		String opU = list.get(i)[4];
		String opD = list.get(i)[5];
		
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
<div style="margin-left: 20px;">
<%
	for (int i=0;i<proc1.size();i++) {
		String target = proc1.get(i)[1] + "." + proc1.get(i)[2].toLowerCase();
		String disp = target;
		if (proc1.get(i)[1].equals(pkg)) disp = proc1.get(i)[2].toLowerCase();
		
		id = Util.getId();
		String cpkg = proc1.get(i)[1];
		String cprc = proc1.get(i)[2];

		if (!cn.isPackage(cpkg)) continue;
%>
	<a href="javascript:toggleData('<%=id%>')"><img id="img-<%=id%>" border=0 align=top src="image/plus.gif"></a>
<%-- 	<a href="pkg-link.jsp?name=<%=target%>"><%= disp %></a></br/>
 --%>	<a href="javascript:loadProc('<%=cpkg%>','<%=cprc%>')"><%= disp %></a></br/>
	<div id="key-<%= id %>" style="margin-left: 40px; display: none;"><%= target %></div>
	<div id="div-<%=id%>" style="margin-left: 40px; display: none;">XXX</div>
<%		
	}
%>
</div>

