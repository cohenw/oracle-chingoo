<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	String searchKey = request.getParameter("searchKey");
	if (searchKey != null) searchKey = searchKey.trim();
%>
<%

	ContentSearchView csv = cn.contentSearchView;
	List<String> tables = csv.search(cn, searchKey);
%>
<% 
	int i = 0;
	for (String tname : tables) {
%>
<%-- <a href="javascript:loadView('<%= tname %>');"><%= tname %></a><br/>
 --%><a target=_blank href="pop.jsp?type=VIEW&key=<%= tname %>"><%= tname %></a><br/>

<% } %>

<br/>

<%= tables.size() %> view(s) found.