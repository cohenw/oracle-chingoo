<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	String ptype = request.getParameter("ptype");
	
	String qry = "SELECT * FROM CPAS_PROCESS WHERE TYPE = '" + ptype + "' AND UPPER(SECLABEL) != 'SC_NEVER' ORDER BY POSITION";
	Query q = new Query(cn, qry, false);
	
	String qry2 = "SELECT NAME FROM CPAS_TAB WHERE TAB='" + ptype+"'";
	if (cn.getCpasType()==2) qry2 = "SELECT NAME FROM CPAS_PROCESSTYPE WHERE TYPE='" + ptype+"'";
	String pname= cn.queryOne(qry2);

	if (pname==null || pname.equals("null")) {
		pname= cn.queryOne("SELECT NAME FROM CPAS_PROCESS WHERE PROCESS='" + ptype+"'");
	}
	if (pname==null || pname.equals("null")) {
		pname= cn.queryOne("SELECT NAME FROM CPAS_CODE_VALUE WHERE GRUP='CCV' AND VALU='" + ptype+"'");
	}
	
	
//	String pname = cn.queryOne("SELECT NAME FROM CPAS_TAB WHERE TAB='" + ptype+"'");
	String id = Util.getId();
%>
<b>Process</b>
<%--  - <%= pname %> [<%= ptype %>]
 --%>
<a href="javascript:openQuery('<%=id%>')"><img src="image/linkout.png" border=0 title="<%=qry%>"/></a>
<div style="display: none;" id="sql-<%=id%>"><%= qry%></div>
<br/>
<%
	int rowCnt = 0;

	q.rewind(1000, 1);
	while (q.next() && rowCnt < 1000) {
		String process = q.getValue("PROCESS");
		String name = q.getValue("NAME");
		String descr = q.getValue("DESCR");
		String seclabel = q.getValue("SECLABEL");
		String logflag = q.getValue("LOGFLAG");
		String rkey = q.getValue("RKEY");

		rowCnt ++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";
		
		String secName = cn.queryOne("SELECT CAPTION FROM SECSWITCH WHERE LABEL ='" + seclabel + "'");
%>

<a id="pr-<%= process %>" href="javascript:loadEvent('<%= process %>');" title="<%= process %>"><%= name %></a>
|
<%--
	<td class="<%= rowClass%>" nowrap><%= process==null?"":process %></td>
	<td class="<%= rowClass%>" nowrap><%= descr==null?"":descr %></td>
	<td class="<%= rowClass%>" nowrap><%= seclabel==null?"":seclabel  + " <span class='cpas'>" + secName + "</span>"%></td>
 	
	<td class="<%= rowClass%>" nowrap><%= logflag==null?"":logflag %></td>
	<td class="<%= rowClass%>" nowrap><%= rkey==null?"":rkey %></td>
 --%>
<%
	} 
%>
