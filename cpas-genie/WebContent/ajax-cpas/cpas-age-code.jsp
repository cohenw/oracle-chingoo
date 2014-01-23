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

	String ruleage = request.getParameter("ruleage");
	String sql = "SELECT expcode, name FROM CPAS_AGE WHERE VALU = '" + ruleage + "'";
//Util.p(sql);
	List<String[]> res = cn.query(sql, false);

	String name = "";
	String text = "";
	for (int j=0;j<res.size();j++) {
		text += res.get(j)[1] + "\n";
		name = res.get(j)[2];
	}

%>

<b><%= name %></b><br/><br/>
<table>
<td valign=top><pre style="font-family: Consolas;">
<pre style="font-family: Consolas;">
<%= new HyperSyntax4PB().getHyperSyntax(cn, text, "PROCEDURE", "")%>
</pre></td>
</table>
<br/>

