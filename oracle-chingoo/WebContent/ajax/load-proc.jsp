<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.oracle.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%!
public String getTables(List<String[]> list0, String type) {
	String res ="";
	
	for (int i=0;i<list0.size();i++) {
		String tname = list0.get(i)[1];
		String op = "";
		String opS = list0.get(i)[2];
		String opI = list0.get(i)[3];
		String opU = list0.get(i)[4];
		String opD = list0.get(i)[5];
		
		if (opI.equals("1") && type.equals("INSERT")) res += "<a target=_blank href='pop.jsp?key=" + tname + "'><b>" + tname + "</b></a><br/>";
		if (opS.equals("1") && type.equals("SELECT")) res += "<a target=_blank href='pop.jsp?key=" + tname + "'><b>" + tname + "</b></a><br/>";
		if (opU.equals("1") && type.equals("UPDATE")) res += "<a target=_blank href='pop.jsp?key=" + tname + "'><b>" + tname + "</b></a><br/>";
		if (opD.equals("1") && type.equals("DELETE")) res += "<a target=_blank href='pop.jsp?key=" + tname + "'><b>" + tname + "</b></a><br/>";
	}
	
	return res;
}
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	String key = request.getParameter("key");
	String name = key;
	String pkg=null;
	String prc=null;
	if (name != null && !name.equals("")) {
		int idx = name.indexOf(".");
		pkg = name.substring(0,idx).toUpperCase();
		prc = name.substring(idx+1).toUpperCase();
	}
//System.out.println("prc=" + prc);	
	String q = "SELECT TABLE_NAME, OP_SELECT, OP_INSERT, OP_UPDATE, OP_DELETE FROM CHINGOO_PA_TABLE WHERE PACKAGE_NAME='" + pkg +"' AND PROCEDURE_NAME='" + prc + "' ORDER BY table_name";
//	System.out.println(q);
	List<String[]> list = cn.query(q, false);

	q = "SELECT TARGET_PKG_NAME, TARGET_PROC_NAME FROM CHINGOO_PA_DEPENDENCY WHERE PACKAGE_NAME='" + pkg +"' AND PROCEDURE_NAME='" + prc + "' ORDER BY DECODE(TARGET_PKG_NAME,'" + pkg + "','0',TARGET_PKG_NAME), 2";
//	System.out.println(q);
	List<String[]> proc1 = cn.query(q, false);

	q = "SELECT PACKAGE_NAME, PROCEDURE_NAME FROM CHINGOO_PA_DEPENDENCY WHERE TARGET_PKG_NAME='" + pkg +"' AND TARGET_PROC_NAME='" + prc + "' ORDER BY DECODE(PACKAGE_NAME,'" + pkg + "','0',PACKAGE_NAME), 2";
//	System.out.println(q);
	List<String[]> proc2 = cn.query(q, false);
	
	
	q = "SELECT START_LINE, END_LINE, PROCEDURE_LABEL FROM CHINGOO_PA_PROCEDURE WHERE PACKAGE_NAME='" + pkg +"' AND PROCEDURE_NAME='" + prc + "' ORDER BY START_LINE";
//	System.out.println(q);
	List<String[]> proc0 = cn.query(q, false);
	
	String id = Util.getId();

	if (prc.equals("")) return;
%>
<h2><%= pkg %>.<%= cn.getProcedureLabel(pkg, prc) %>&nbsp;&nbsp;&nbsp;&nbsp;
<a target=_blank href="src2.jsp?name=<%= pkg %>#<%= prc.toLowerCase() %>">Source</a>

<a target=_blank href="package-tree.jsp?name=<%= name %>">Tree</a>
<a target=_blank href="analyze-package.jsp?name=<%= pkg %>">Analyze</a>
</h2> 
<br/>


<b>Table CRUD</b><br/>
<table border=1 class="gridBody" style="margin-left: 20px;">
<tr>
	<th class="headerRow">SELECT</th>
	<th class="headerRow">INSERT</th>
	<th class="headerRow">UPDATE</th>
	<th class="headerRow">DELETE</th>
</tr>
<tr>
<td valign=top><%= getTables(list, "SELECT") %></td>
<td valign=top><%= getTables(list, "INSERT") %></td>
<td valign=top><%= getTables(list, "UPDATE") %></td>
<td valign=top><%= getTables(list, "DELETE") %></td>
</tr>
</table>
<!-- 
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
 -->
<br/>

<% id = Util.getId(); %>
<b><a href="javascript:toggleData('<%=id%>')"><img id="img-<%=id%>" border=0 align=top src="image/plus.gif">Source Code</a></b>
<div id="div-<%=id %>" style="display: none; margin-left: 20px; background-color: #e0e0e0;">
<%
for (int i=0;i<proc0.size();i++) {
	int start = Integer.parseInt(proc0.get(i)[1]);
	int end = Integer.parseInt(proc0.get(i)[2]);
	String label = proc0.get(i)[3];
	
	q = "SELECT LINE, TEXT FROM USER_SOURCE WHERE TYPE IN ('PACKAGE BODY','TYPE BODY') AND NAME = '" + pkg + "' AND LINE BETWEEN " + start + " AND " + end+ " ORDER BY LINE";
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
<%= new HyperSyntax4PB().getHyperSyntax(cn, text, "PROCEDURE", pkg)%></pre>
</td>
</table>

<%		
	}
%>
</div>
<br/><br/>


<b>Calls</b><br/>
<div style="margin-left: 20px;">
<%
	for (int i=0;i<proc1.size();i++) {
		String target = proc1.get(i)[1] + "." + cn.getProcedureLabel(proc1.get(i)[1], proc1.get(i)[2]);
		String disp = target;
		if (proc1.get(i)[1].equals(pkg)) disp = cn.getProcedureLabel(proc1.get(i)[1], proc1.get(i)[2]);
		
		id = Util.getId();
		String cpkg = proc1.get(i)[1];
		String cprc = proc1.get(i)[2];
		if (!cn.isPackage(cpkg)) continue;
%>
	<a href="javascript:toggleData('<%=id%>')"><img id="img-<%=id%>" border=0 align=top src="image/plus.gif"></a>
	<a href="javascript:loadProc('<%=cpkg%>','<%=cprc%>')"><%= disp %></a></br/>
	<div id="key-<%= id %>" style="margin-left: 40px; display: none;"><%= target %></div>
	<div id="div-<%=id%>" style="margin-left: 40px; display: none;"></div>
<%		
	}
%>
</div>

<br/>

<b>Called By</b><br/>
<div style="margin-left: 20px;">
<%
	for (int i=0;i<proc2.size();i++) {
		String target = proc2.get(i)[1] + "." + cn.getProcedureLabel(proc2.get(i)[1], proc2.get(i)[2]);
		String disp = target;
		if (proc2.get(i)[1].equals(pkg)) disp = cn.getProcedureLabel(proc2.get(i)[1], proc2.get(i)[2]);
		String cpkg = proc2.get(i)[1];
		String cprc = proc2.get(i)[2];
		if (!cn.isPackage(cpkg)) continue;
%>
	<a href="javascript:loadProc('<%=cpkg%>','<%=cprc%>')"><%= disp %></a></br/>
<%		
	}
%>
</div>

