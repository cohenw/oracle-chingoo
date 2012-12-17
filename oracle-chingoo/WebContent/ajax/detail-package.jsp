<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.oracle.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	String owner = request.getParameter("owner");
	String name = request.getParameter("name");

	// incase owner is null & table has owner info
	if (owner==null && name!=null && name.indexOf(".")>0) {
		int idx = name.indexOf(".");
		owner = name.substring(0, idx);
		name = name.substring(idx+1);
	}
	System.out.println(cn.getUrlString() + " " + Util.getIpAddress(request) + " " + (new java.util.Date()) + "\nPackage: " + name);
	
	if (owner==null) owner = cn.getSchemaName().toUpperCase();
	
	String catalog = cn.getSchemaName();

	String sourceUrl = "source.jsp?name=" + name;
	if (owner != null) sourceUrl += "&owner=" + owner;
	
	String typeName = cn.getObjectType(owner, name);
%>
<div id="objectTitle" style="display:none"><%= name %></div>
<h2><%= typeName %>: <%= name %> &nbsp;&nbsp;<a href="<%=sourceUrl%>" target="_blank"><img border=0 src="image/icon_query.png" title="Source code"></a>
<a href="pop.jsp?type=PACKAGE&key=<%=name%>" target="_blank"><img title="Pop Out" border=0 src="image/popout.png"></a>
</h2>


<%

	String qry = "SELECT distinct PROCEDURE_NAME FROM all_procedures where owner='" + owner + "' and object_name='" + name + "' and PROCEDURE_NAME is not null order by 1";
	List<String> list = cn.queryMulti(qry);

%>

<% 
	if (typeName.equals("TRIGGER")) {
		String q = "SELECT DISTINCT TYPE FROM USER_SOURCE WHERE NAME='" + name +"' ORDER BY TYPE";
		if (owner != null) q = "SELECT DISTINCT TYPE FROM ALL_SOURCE WHERE OWNER='" + owner + "' AND NAME='" + name +"' ORDER BY TYPE";

		List<String[]> types = cn.query(q);
%>
<%
for (int k=0;k<types.size();k++) {
	String type = types.get(k)[1];

	String qry2 = "SELECT TYPE, LINE, TEXT FROM USER_SOURCE WHERE NAME='" + name +"' AND TYPE = '" + type + "' ORDER BY TYPE, LINE";
	if (owner != null) qry2 = "SELECT TYPE, LINE, TEXT FROM ALL_SOURCE WHERE OWNER='" + owner + "' AND NAME='" + name +"' AND TYPE = '" + type + "' ORDER BY TYPE, LINE";

	List<String[]> list2 = cn.query(qry2);
	
	String text = "";
	for (int i=0;i<list2.size();i++) {
		String ln = list2.get(i)[3];
		if (!ln.endsWith("\n")) ln += "\n";
		text += Util.escapeHtml(ln);
	}

%>
<b><a href="javascript:tDiv('div-<%=k%>')"><%= type %></a></b><br/>
<div id="div-<%=k%>" style="display: block;">
<pre class='brush: sql'>
<%= text %>
</pre>
</div>
<%
}
%>
<% 
	} 
%>

<% 
	if (list.size()>0) { 
%>
<b>Procedures</b>
<table border=0 width=800>
<td width=8%>&nbsp;</td>
<td valign=top width=23%>
<%
	int listSize = (list.size() / 4) + 1;
	int cnt = 0;
	for (int i=0; i<list.size(); i++) {
		cnt++;
%>

<% if ((cnt-1)>=listSize) { %>
		</td><td valign=top width=23%>
<%
		cnt = 1;
	} 
%>
	<%= list.get(i).toLowerCase() %><br/>		
<% }
}
%>
</td>
</table>


<br/>

<b>Dependencies</b>

<table border=0 width=800>
<tr>
	<td width=8%>&nbsp;</td>
	<td width=23% bgcolor=#ccccff>Program</td>
	<td width=23% bgcolor=#ccccff>Table</td>
	<td width=23% bgcolor=#ccccff>View</td>
	<td width=23% bgcolor=#ccccff>Synonym</td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td valign=top><%= cn.getDependencyPackage(owner, name) %></td>
	<td valign=top><%= cn.getDependencyTable(owner, name) %></td>
	<td valign=top><%= cn.getDependencyView(owner, name) %></td>
	<td valign=top><%= cn.getDependencySynonym(owner, name) %></td>
</tr>
</table>
<br/>

