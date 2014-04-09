<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	String owner = request.getParameter("owner");
	String tool = request.getParameter("name");
	Connect cn = (Connect) session.getAttribute("CN");

	String catalog = cn.getSchemaName();

	String qry=null;
	String ttype=null;
	if (tool.equalsIgnoreCase("dictionary"))
		qry = "SELECT * FROM DICTIONARY ORDER BY 1";
	else if (tool.equalsIgnoreCase("sequence"))
		qry = "SELECT * FROM USER_SEQUENCES ORDER BY 1";
	else if (tool.equalsIgnoreCase("db link"))
		qry = "SELECT * FROM USER_DB_LINKS ORDER BY 1";
	else if (tool.equalsIgnoreCase("User role priv")) 
		qry = "SELECT * FROM USER_ROLE_PRIVS";
	else if (tool.equalsIgnoreCase("User sys priv")) 
		qry = "SELECT * FROM USER_SYS_PRIVS";
	else if (tool.equalsIgnoreCase("search program")) { 
		qry = "SELECT * FROM USER_SOURCE WHERE lower(text) like lower('%[Search Keyword (ex: insert into TABLE )]%')";
		if (cn.getTargetSchema() != null) {
			qry = "SELECT * FROM ALL_SOURCE WHERE WNER='" + cn.getTargetSchema() + "' AND lower(text) like lower('%[Search Keyword (ex: insert into TABLE )]%')";
		}
		ttype = "SEARCH_PROGRAM";
	}
	else if (tool.equalsIgnoreCase("table column")) {
		qry = "SELECT OWNER, TABLE_NAME, NUM_ROWS FROM ALL_TABLES WHERE TABLE_NAME IN (SELECT TABLE_NAME FROM ALL_TAB_COLS WHERE COLUMN_NAME = upper('[Column Name]')) ORDER BY 1";
		ttype = "SEARCH_COLUMN";
	}
	else if (tool.equalsIgnoreCase("table/view columns")) {
		qry = "SELECT TABLE_NAME FROM ALL_TAB_COLS WHERE COLUMN_NAME = upper('[ColumnName1, Column Name2, ...]')";
		ttype = "SEARCH_COLUMNS";
	}
	else if (tool.equalsIgnoreCase("invalid objects")) 
		qry = "SELECT object_type, object_name, status FROM user_objects WHERE status != 'VALID' ORDER BY object_type, object_name";
	else if (tool.equalsIgnoreCase("oracle version"))
		qry = "SELECT * FROM GV$VERSION";
	else if (tool.equalsIgnoreCase("schema size"))
		qry = "SELECT segment_type, round(sum(bytes)/1000000) as MB FROM USER_SEGMENTS group by  segment_type " +
			"union all SELECT 'TOTAL SCHEMA SIZE', round(sum(bytes)/1000000) as MB FROM USER_SEGMENTS";
	else if (tool.equalsIgnoreCase("large tables")) 
		qry = "select table_name, round(bytes/1000000) MB from ( " +
				"SELECT segment_name table_name, bytes " +
				 "FROM user_segments WHERE segment_type = 'TABLE' UNION ALL " +
				 "SELECT i.table_name, s.bytes FROM user_indexes i, user_segments s WHERE s.segment_name = i.index_name " +
				 " AND   s.segment_type = 'INDEX' UNION ALL " +
				 " SELECT l.table_name, s.bytes FROM user_lobs l, user_segments s  WHERE s.segment_name = l.segment_name " +
				 " AND   s.segment_type = 'LOBSEGMENT' UNION ALL " +
				 " SELECT l.table_name, s.bytes FROM user_lobs l, user_segments s WHERE s.segment_name = l.index_name " +
				 " AND   s.segment_type = 'LOBINDEX' ) where bytes > [Size in MB (ex: 10)] * 1000000 order by 2 desc";
	else if (tool.equalsIgnoreCase("users"))
		qry = "SELECT * FROM ALL_USERS";
	else if (tool.equalsIgnoreCase("Recently modified objects"))
		qry = "SELECT * FROM USER_OBJECTS ORDER BY TIMESTAMP DESC";
	else if (tool.equalsIgnoreCase("User Sessions"))
		qry = "SELECT * FROM V$SESSION";

%>
<h2><%= tool %> &nbsp;&nbsp;</h2>

<% if (qry != null)  {%>
<jsp:include page="detail-tool-query.jsp">
	<jsp:param value="<%= qry %>" name="qry"/>
	<jsp:param value="<%= ttype %>" name="ttype"/>
</jsp:include>

<% } %>

<% if (tool.equalsIgnoreCase("search table data")) { %>
<b>You can search table content (data).</b>
<jsp:include page="content-search.jsp"/>
<% } %>

<% if (tool.equalsIgnoreCase("search view definition")) { %>
<jsp:include page="content-search-view.jsp"/>
<% } %>

<% if (tool.equalsIgnoreCase("search trigger definition")) { %>
<jsp:include page="content-search-trigger.jsp"/>
<% } %>

<% if (tool.equalsIgnoreCase("user defined page")) { %>
<jsp:include page="udp.jsp"/>
<% } %>

<% if (tool.equalsIgnoreCase("saved query")) { %>
<jsp:include page="sq.jsp"/>
<% } %>

<% if (tool.equalsIgnoreCase("Schema Diff")) { %>
<jsp:include page="schema-diff.jsp"/>
<% } %>

<% if (tool.equalsIgnoreCase("Preferences")) { %>
<jsp:include page="pref.jsp"/>
<% } %>

<% if (tool.equalsIgnoreCase("Package Analysis")) { %>
<jsp:include page="refresh-package-table.jsp"/>
<% } %>

<% if (tool.equalsIgnoreCase("Trigger Analysis")) { %>
<jsp:include page="refresh-trigger-table.jsp"/>
<% } %>


<% if (tool.equalsIgnoreCase("Clone Member")) { %>
<jsp:include page="clone-member.jsp"/>
<% } %>

<% if (tool.equalsIgnoreCase("Clone Member (External DB)")) { %>
<jsp:include page="clone-member-ext.jsp"/>
<% } %>

<% if (tool.equalsIgnoreCase("XML Formatter")) { %>
<jsp:include page="xml-format.jsp"/>
<% } %>
