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
	list.add("Search Table Data");
	list.add("Search Program");
	list.add("Search View Definition");
	list.add("Search Trigger Definition");
	list.add("");
	list.add("Table Column");
	list.add("Table/View Columns");
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

	list.add("Recently modified objects");
	list.add("User Sessions");
	
	list.add("Schema Size");
	list.add("Large Tables");

	list.add("");
	list.add("Saved Query");
	list.add("");
	list.add("Package Analysis");
	list.add("Trigger Analysis");
	list.add("Preferences");

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

<br>
<!-- <img src="image/video.png">
<a href="http://genie.cpas.com/genie-video/index.html" target=_blank><span style="background-color: yellow;">Watch tutorial videos</span></a>
 -->