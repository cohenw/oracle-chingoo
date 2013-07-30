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

	String key = request.getParameter("key");
	String sql = "SELECT SOURCE, CAPTION, SELECTSTMT FROM CPAS_CODE WHERE GRUP = '" + key + "'";
	int cpasType = cn.getCpasType();
	if (cpasType ==5) {
		sql = "SELECT TYPE, (SELECT capt from CODE_CAPTION WHERE GRUP='"	+ key + "' AND LANG='E'), (SELECT STMTCODE FROM CODE_SELECT WHERE GRUP=A.GRUP) STMT FROM CODE A WHERE GRUP='"	+ key + "'";
	}
	
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

	if (cpasType == 5) {
		if (source.equals("G")) {
			sql = "SELECT VALU, NAME FROM CODE_VALUE_NAME WHERE GRUP='" + key + "'";
		} if (source.equals("C")||source.equals("P")) {
			sql = selectstmt;
		}
	}
	
	
	boolean isDynamic = false;

	ArrayList<String> varAl = getBindVariableList(sql);
	if (varAl.size() >0 ) isDynamic = true;
System.out.println("isDynamic=" + isDynamic);

	String sqlh = sql;
	String dynamicVars = request.getParameter("dynamicVars");
	//System.out.println("*** dynamicVars=" + dynamicVars);
	if (dynamicVars!=null && dynamicVars.length() > 0) {
		isDynamic = true;
		String[] vars = dynamicVars.split(" ");
		for (String var : vars) {
			System.out.println("* " + var + ": " + request.getParameter(var));
			sqlh = sqlh.replaceAll(var, "'" + request.getParameter(var) + "'");
		}
	}		
	
%>
<b><%=caption %></b><br/>
<div id="sql-<%=id%>" style="display: none;"><%= sql %></div>
<span id="sqlorig-<%=id%>"><%= sql %></span>
&nbsp;
<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" border="0"></a>
&nbsp;
<div style="display: none;" id="sql-<%=id%>"><%= sql%></div>
<div style="display: none;" id="mode-<%=id%>">sort</div>
<div style="display: none;" id="ori-<%=id%>">H</div>
<div style="display: none;" id="hide-<%=id%>"></div>
<div style="display: none;" id="sort-<%=id%>"></div>
<div style="display: none;" id="sortdir-<%=id%>">0</div>

<br/>
<%
	if (isDynamic) {
		String varlist = "";
		int i=0;
		for (String var:varAl) {
			varlist += var.substring(1) + " ";
			i++;
%>
	<%= var %> <input id="dyn<%=id%>-<%= var.substring(1) %>" length=30>
<%
		}
%>
		<input id="dyn<%=id%>-vars" value="<%= varlist.trim() %>" type="hidden"/>
		<input type="button" value="submit" onClick="applyParameter(<%=id%>)">
<%		
		//return;
	}
%>


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