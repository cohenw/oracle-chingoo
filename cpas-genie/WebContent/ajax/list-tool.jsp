<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.Connect" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	String filter = request.getParameter("filter");

	List<String> list = new ArrayList<String>();
	list.add("Search Table");
	list.add("Search Program");
	list.add("Search View");
	list.add("Search Trigger");
	list.add("");
	list.add("Table Column");
	list.add("Schema Diff");
	list.add("");

	list.add("User Defined Page");
	list.add("");

	list.add("Dictionary");
	list.add("Sequence");
	list.add("DB link");
	list.add("Users");
	list.add("User role priv");
	list.add("User sys priv");
	list.add("Invalid Objects");
	list.add("Oracle Version");
	list.add("");

	list.add("Schema Size");
	list.add("Large Tables");

	list.add("");
	list.add("Saved Query");
	list.add("Preferenceses");

%>

<% if (cn.isCpas()) { %>
<a href="javascript:showCPAS()"><img src="image/cpas.jpg" width=12 height=12>
CPAS Catalogs</a> <br/><br/>
 
<% } %>

<% 
	if (filter !=null) filter = filter.toUpperCase();
	for (int i=0; i<list.size();i++) {
		if (filter != null && !list.get(i).toUpperCase().contains(filter)) continue;
		
	if (list.get(i)==null || list.get(i).equals("")) {
%>
	<br/>
<%	} else { %>
	<li><a href="javascript:loadTool('<%=list.get(i)%>');"><%=list.get(i)%></a></li>
<% 
	} 
	}
%>

