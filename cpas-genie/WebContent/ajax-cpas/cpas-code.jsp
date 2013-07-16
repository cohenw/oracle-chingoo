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

	String key = request.getParameter("key");
	String sql = "SELECT SOURCE, CAPTION, SELECTSTMT FROM CPAS_CODE WHERE GRUP = '" + key + "'";
	
	List<String[]> res = cn.query(sql, false);

	if (res.size() == 0) return;
	String id = Util.getId();
	String source = res.get(0)[1];
	String caption = res.get(0)[2];
	String selectstmt = res.get(0)[3];

	if (source.equals("T"))
		sql = "SELECT VALU, NAME FROM CPAS_CODE_VALUE WHERE GRUP='" + key + "'";
	else if (source.equals("S") || source.equals("3"))
		sql = selectstmt;
	else if (source.equals("P") && false) {
		// to do for 'P' : procedure
		String stmt = cn.queryOne("SELECT SELECTSTMT FROM CPAS_CODE WHERE GRUP = '" + key + "'");
		System.out.println("stmt=" + stmt);
		if (stmt.startsWith("BEGIN")) {
			CallableStatement call = cn.getConnection().prepareCall(stmt);
			call.execute();
			call.close();
		}
		sql = "SELECT VALU, NAME FROM CT$CODE ORDER BY ORDERBY";
	}
	
	
%>
<b><%=caption %></b><br/>
<div id="sql-<%=id%>" style="display: none;"><%= sql %></div>
<%= sql %>
&nbsp;
<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" border="0"></a>
&nbsp;
<div style="display: none;" id="sql-<%=id%>"><%= sql%></div>
<div style="display: none;" id="mode-<%=id%>">sort</div>
<div style="display: none;" id="ori-<%=id%>">H</div>
<div style="display: none;" id="hide-<%=id%>"></div>
<div style="display: none;" id="sort-<%=id%>"></div>
<div style="display: none;" id="sortdir-<%=id%>">0</div>
<div id="div-<%=id%>">
<jsp:include page='../ajax/qry-simple.jsp'>
	<jsp:param value="<%= sql %>" name="sql"/>
	<jsp:param value="1" name="dataLink"/>
	<jsp:param value="<%= id %>" name="id"/>
</jsp:include>
</div>

<script type="text/javascript">
//	hideNullColumn("" + <%= id %>);
	hideNullColumnTable("" + <%= id %>);
</script>