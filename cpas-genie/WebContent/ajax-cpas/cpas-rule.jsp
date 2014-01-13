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

	String ruleid = request.getParameter("ruleid");
	String sql = "SELECT texttype, text FROM RULE_SOURCE WHERE RULEID = '" + ruleid + "' ORDER BY texttype desc, line";
	List<String[]> res = cn.query(sql, false);

	String text = "";
	for (int j=0;j<res.size();j++) {
		if (res.get(j)[2]==null) {
			text += "\n";
			continue;
		}
		if (res.get(j)[1].equals("R")) 
			text += "-- " + res.get(j)[2] + "\n";
		else
			text += res.get(j)[2] + "\n";
	}

%>

<table>
<td valign=top><pre style="font-family: Consolas;">
<pre style="font-family: Consolas;">
<%= new HyperSyntax4PB().getHyperSyntax(cn, text, "PROCEDURE", "")%>
</pre></td>
</table>
<br/>

