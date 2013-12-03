<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	int counter = 0;
	Connect cn = (Connect) session.getAttribute("CN");
	
	String name = request.getParameter("key");
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
	
	String q = "SELECT START_LINE, END_LINE, PROCEDURE_LABEL FROM GENIE_PA_PROCEDURE WHERE PACKAGE_NAME='" + gPkg +"' AND PROCEDURE_NAME='" + gPrc + "' ORDER BY START_LINE";
	//System.out.println(q);
	List<String[]> proc0 = cn.query(q, false);
	
	
%>

<%
for (int i=0;i<proc0.size();i++) {
	int start = Integer.parseInt(proc0.get(i)[1]);
	int end = Integer.parseInt(proc0.get(i)[2]);
	String label = proc0.get(i)[3];
	
	q = "SELECT LINE, TEXT FROM USER_SOURCE WHERE TYPE IN ('PACKAGE BODY','TYPE BODY') AND NAME = '" + gPkg + "' AND LINE BETWEEN " + start + " AND " + end+ " ORDER BY LINE";
	if (cn.getTargetSchema() != null) {
		q = "SELECT LINE, TEXT FROM ALL_SOURCE WHERE OWNER='" + cn.getTargetSchema() + "' AND TYPE IN ('PACKAGE BODY','TYPE BODY') AND NAME = '" + gPkg + "' AND LINE BETWEEN " + start + " AND " + end+ " ORDER BY LINE";
	}
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
//String syntax = hs.getHyperSyntax(cn, text, type, name);
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


