<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.Connect" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%! 
	public String getNumRows (String numRows) {
		if (numRows==null) numRows = "";
		else {
			int n = Integer.parseInt(numRows);
			if (n < 1000) {
				numRows = numRows;
			} else if (n < 1000000) {
				numRows = Math.round(n /1000) + "K";
			} else {
				numRows = (Math.round(n /100000) / 10.0 )+ "M";
			}
		}
		return numRows;
	}

%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	String filter = request.getParameter("filter");

	String qry = "SELECT SYNONYM_NAME, TABLE_OWNER, TABLE_NAME, (SELECT NUM_ROWS FROM ALL_TABLES WHERE OWNER=A.TABLE_OWNER AND TABLE_NAME =A.TABLE_NAME) NUM_ROWS FROM USER_SYNONYMS A ORDER BY 1"; 	
	List<String[]> list = cn.query(qry);

	int totalCnt = list.size();
	int selectedCnt = 0;
	if (filter !=null) filter = filter.toUpperCase();
	for (int i=0; i<list.size();i++) {
		if (filter != null && !list.get(i)[1].contains(filter)) continue;
		selectedCnt ++;
	}

%>
Found <%= selectedCnt %> synonym(s).
<br/><br/>
<%	
	if (filter !=null) filter = filter.toUpperCase();
	for (int i=0; i<list.size();i++) {
		if (filter != null && !list.get(i)[1].contains(filter)) continue;
		String numRow = getNumRows(list.get(i)[4]);
%>
	<li><a href="javascript:loadSynonym('<%=list.get(i)[1]%>');"><%=list.get(i)[1]%></a> <span class="rowcountstyle"><%=numRow%> <%--= cn.getTableRowCount(list.get(i)[2], list.get(i)[3]) --%></span></li>
<% 
	} 
%>

