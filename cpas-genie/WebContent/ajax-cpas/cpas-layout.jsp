<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%!
	ArrayList<String> getBindVariableList(String qry) {
		ArrayList<String> al = new ArrayList<String>();
		if (qry==null) return al;
		StringTokenizer st = new StringTokenizer(qry, " =)\n");

		while (st.hasMoreTokens()) {
			String token = st.nextToken().trim();
			if (token.startsWith(":") && !token.startsWith(":=") && token.length()>1) {
				System.out.println("token=" + token);
				al.add(token);
			}
		}
		return al;
	}
%>

<%
	int counter = 0;
	Connect cn = (Connect) session.getAttribute("CN");

	String tname = request.getParameter("tname");
	String tmp = "SELECT '" + tname + "' FROM DUAL UNION " + 
			"SELECT actionstmt from TREEACTION_STMT WHERE (sdi, schema, actionid) in ( " +
			"SELECT sdi, schema, actionid FROM TREEACTION_STMT WHERE actiontype='MS' AND actionstmt like '%FROM " + tname + " %') and actiontype='MT' and actionstmt not like 'SELECT%'" +
			"union " +
			"SELECT actionstmt from TREEACTION_STMT where (sdi, schema, actionid) in ( " +
			"SELECT sdi, schema, actionid FROM TREEACTION_STMT WHERE actiontype='DS' AND actionstmt like '%FROM " + tname + " %') and actiontype='DT' and actionstmt not like 'SELECT%'";		

	String sql = "SELECT * FROM CPAS_TABLE WHERE TNAME IN (" + tmp + ")";
	
	List<String[]> res = cn.query(sql, false);

	String id = Util.getId();
%>
<b><%= tname %></b><br/>
<div id="sql-<%=id%>" style="display: none;"><%= sql %></div>
<span id="sqlorig-<%=id%>" style="display: none;"><%= sql %></span>
&nbsp;
<a href="javascript:openQuery('<%=id%>')"><img src="image/linkout.png" border="0"></a>
&nbsp;
<div style="display: none;" id="sql-<%=id%>"><%= sql%></div>
<div style="display: none;" id="mode-<%=id%>">sort</div>
<div style="display: none;" id="ori-<%=id%>">H</div>
<div style="display: none;" id="hide-<%=id%>"></div>
<div style="display: none;" id="sort-<%=id%>"></div>
<div style="display: none;" id="sortdir-<%=id%>">0</div>

<br/>
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