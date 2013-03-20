<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.oracle.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	String searchKey = request.getParameter("searchKey");
	if (searchKey != null) searchKey = searchKey.trim();
%>

<%

	ContentSearchTrigger cst = cn.contentSearchTrigger;
	List<String> tables = cst.search(cn, searchKey);
%>
<% 
	int i = 0;
	for (String tname : tables) {
%>
<a href="javascript:loadPackage('<%= tname %>');"><%= tname %></a><br/>
<% } %>

<br/>

<%= tables.size() %> trigger(s) found.