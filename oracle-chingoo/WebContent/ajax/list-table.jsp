<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.oracle.*" 
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
	boolean hideEmpty = request.getParameter("hideEmpty") != null;
	//hideEmpty = true;
	
	String qry = "SELECT TABLE_NAME, NUM_ROWS FROM USER_TABLES ORDER BY 1"; 	
	//List<String> list = cn.queryMulti(qry);
	List<String[]> list = cn.query(qry, true);
	
	int totalCnt = list.size();
	int selectedCnt = 0;
	if (filter !=null) filter = filter.toUpperCase();
	for (int i=0; i<list.size();i++) {
		if (filter != null && !list.get(i)[1].contains(filter)) continue;
		if (hideEmpty && getNumRows(list.get(i)[2]).equals("0")) continue;
		selectedCnt ++;
	}

%>
Found <%= selectedCnt %> table(s).
<br/><br/>
<%	
	if (filter !=null) filter = filter.toUpperCase();
	for (int i=0; i<list.size();i++) {
		if (filter != null && !list.get(i)[1].contains(filter)) continue;
		if (hideEmpty && getNumRows(list.get(i)[2]).equals("0")) continue;
%>
	<li><a href="javascript:loadTable('<%=list.get(i)[1]%>');"><%=list.get(i)[1]%></a> <span class="rowcountstyle"><%= getNumRows(list.get(i)[2]) %></span></li>
<% 
	} 
%>
