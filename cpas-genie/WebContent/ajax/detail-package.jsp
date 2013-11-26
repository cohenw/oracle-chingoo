<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	boolean hasGenieTable = cn.isTVS("GENIE_PA");
	String owner = request.getParameter("owner");
	String name = request.getParameter("name");

	// incase owner is null & table has owner info
	if (owner==null && name!=null && name.indexOf(".")>0) {
		int idx = name.indexOf(".");
		owner = name.substring(0, idx);
		name = name.substring(idx+1);
	}
//	System.out.println(cn.getUrlString() + " " + Util.getIpAddress(request) + " " + (new java.util.Date()) + "\nPackage: " + name);
	
	if (owner==null) owner = cn.getSchemaName().toUpperCase();
	if (cn.getTargetSchema() != null) owner = cn.getTargetSchema();
	
	String catalog = cn.getSchemaName();

	String sourceUrl = "src2.jsp?name=" + name;
	if (owner != null) sourceUrl += "&owner=" + owner;
	
	String typeName = cn.getObjectType(owner, name);
	String pname = name;
	if (owner!=null && !owner.equalsIgnoreCase(cn.getSchemaName())) pname = owner + "." + name;
%>
<div id="objectTitle" style="display:none"><%= typeName %>: <%= name %></div>
<h2><%= typeName %>: <%= pname %> &nbsp;&nbsp;<a href="<%=sourceUrl%>" target="_blank"><img border=0 src="image/sourcecode.gif" title="Source code"></a>
<a href="pop.jsp?type=PACKAGE&key=<%=pname%>" target="_blank"><img title="Pop Out" border=0 src="image/popout.png"></a>
<% if (hasGenieTable && (typeName.equals("PACKAGE")||typeName.equals("TYPE"))) { %>
<a target=_blank href="package-browser.jsp?name=<%= pname %>">Package Browser</a>
<a target="_blank" href="analyze-package.jsp?name=<%= pname %>">Analyze</a>
<% } %>
</h2>


<%

	String qry = "SELECT distinct PROCEDURE_NAME FROM all_procedures where owner='" + owner + "' and object_name='" + name + "' and PROCEDURE_NAME is not null order by 1";
	List<String> list = cn.queryMulti(qry);

%>

<% 
	if (typeName.equals("TRIGGER")) {
		String q = "SELECT DISTINCT TYPE FROM USER_SOURCE WHERE NAME='" + name +"' ORDER BY TYPE";
		if (cn.getTargetSchema() != null) {
			q = "SELECT DISTINCT TYPE FROM ALL_SOURCE WHERE OWNER='" + cn.getTargetSchema() + "' AND NAME='" + name +"' ORDER BY TYPE";
		}
		if (owner != null) q = "SELECT DISTINCT TYPE FROM ALL_SOURCE WHERE OWNER='" + owner + "' AND NAME='" + name +"' ORDER BY TYPE";

		List<String[]> types = cn.query(q, false);
%>
<%
for (int k=0;k<types.size();k++) {
	String type = types.get(k)[1];

	String qry2 = "SELECT TYPE, LINE, TEXT FROM USER_SOURCE WHERE NAME='" + name +"' AND TYPE = '" + type + "' ORDER BY TYPE, LINE";
	if (cn.getTargetSchema() != null) {
		qry2 = "SELECT TYPE, LINE, TEXT FROM ALL_SOURCE WHERE OWNER='" + cn.getTargetSchema() + "' AND NAME='" + name +"' AND TYPE = '" + type + "' ORDER BY TYPE, LINE";
	}
	if (owner != null) qry2 = "SELECT TYPE, LINE, TEXT FROM ALL_SOURCE WHERE OWNER='" + owner + "' AND NAME='" + name +"' AND TYPE = '" + type + "' ORDER BY TYPE, LINE";

	List<String[]> list2 = cn.query(qry2, false);
	
	String text = "";
	for (int i=0;i<list2.size();i++) {
		String ln = list2.get(i)[3];
		if (!ln.endsWith("\n")) ln += "\n";
		if (typeName.equals("TRIGGER"))
			text += ln;
		else
			text += Util.escapeHtml(ln);
	}
//Util.p(text);
%>
<b><a href="javascript:tDiv('div-<%=k%>')"><%= type %></a></b><br/>
<div id="div-<%=k%>" style="display: block;">
<pre style="font-family: Consolas;"><%=new HyperSyntax().getHyperSyntax(cn, text, type, name)%></pre>
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
	String prcName = list.get(i).toUpperCase();
	prcName = cn.getProcedureLabel(name+"."+prcName);
%>
	<a target="_blank" href="<%= sourceUrl%>#<%= list.get(i).toLowerCase() %>"><%= prcName %></a>
	&nbsp;
<% if (hasGenieTable) { %>	
 	<a target="_blank" href="package-tree.jsp?name=<%= name + "." + list.get(i) %>"><img border=0 src="image/link.gif"></a>

<% } %> 	<br/>		
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
	<td valign=top nowrap><%= cn.getDependencyPackage(owner, name) %></td>
	<td valign=top nowrap><%= cn.getDependencyTable(owner, name) %></td>
	<td valign=top nowrap><%= cn.getDependencyView(owner, name) %></td>
	<td valign=top nowrap><%= cn.getDependencySynonym(owner, name) %></td>
</tr>
</table>
<br/>

