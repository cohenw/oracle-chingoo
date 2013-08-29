<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%!

public ArrayList<String> getProcessList(Connect cn, String ptype) {
	String qry = "SELECT * FROM CPAS_PROCESS WHERE TYPE = '" + ptype + "' AND UPPER(SECLABEL) != 'SC_NEVER' ORDER BY POSITION";
	Query q = new Query(cn, qry, false);
	ArrayList<String> res = new ArrayList<String>();

	String qry2 = "SELECT NAME FROM CPAS_TAB WHERE TAB='" + ptype+"'";
	if (cn.getCpasType()==2) qry2 = "SELECT NAME FROM CPAS_PROCESSTYPE WHERE TYPE='" + ptype+"'";
	String pname= cn.queryOne(qry2);

	if (pname==null || pname.equals("null")) {
		pname= cn.queryOne("SELECT NAME FROM CPAS_PROCESS WHERE PROCESS='" + ptype+"'");
	}
	if (pname==null || pname.equals("null")) {
		pname= cn.queryOne("SELECT NAME FROM CPAS_CODE_VALUE WHERE GRUP='CCV' AND VALU='" + ptype+"'");
	}

	q.rewind(1000, 1);
	int rowCnt = 0;
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

		res.add(name + "," + process);
	} 

	return res;
}


public ArrayList<String> getEventList(Connect cn, String process) {
	String qry = "SELECT * FROM CPAS_PROCESS_EVENT WHERE PROCESS = '" + process + "' AND UPPER(SECLABEL) != 'SC_NEVER' AND PEVENT IS NULL ORDER BY POSITION"; 
	ArrayList<String> res = new ArrayList<String>();
	Query q = new Query(cn, qry, false);

	String pname = cn.queryOne("SELECT NAME FROM CPAS_PROCESS WHERE PROCESS='" + process+"'");

	int rowCnt = 0;
	q.rewind(1000, 1);
	while (q.next() && rowCnt < 1000) {
		String event = q.getValue("event");
		String pevent = q.getValue("pevent");
		String name = q.getValue("name");
		String position = q.getValue("position");
		String action = q.getValue("action");
		String uparam = q.getValue("uparam");
		String seclabel = q.getValue("seclabel");
		String log = q.getValue("log");
		String rkey = q.getValue("rkey");

		rowCnt ++;
		String actionName = cn.queryOne("SELECT NAME FROM CPAS_ACTION WHERE ACTION ='" + action + "'");
		String secName = cn.queryOne("SELECT CAPTION FROM SECSWITCH WHERE LABEL ='" + seclabel + "'");

		if (action==null || action.equals("NN")) actionName = "";
		String indent = "";
		if (position.contains(".")) indent =  "&nbsp;&nbsp;&nbsp;-";
		if (pevent!=null) indent =  "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
		name = indent + name;
		
		res.add(name + "," + event);
	}
	return res;
}

%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	String actionid = request.getParameter("actionid");

	String qry = "SELECT LEVEL, ITEMID, CAPTION, SWITCH, ACTIONID, TREEKEY, UDATA FROM TREEVIEW A START WITH ACTIONID=" + actionid + " AND SDI = 'WP' AND SCHEMA = 'TREEVIEW' CONNECT BY PARENTID = PRIOR ITEMID AND SDI = 'WP' AND SCHEMA = 'TREEVIEW' " +
			" AND EXISTS (SELECT 1 FROM TREEACTION_STMT WHERE SDI=A.SDI AND ACTIONID=A.ACTIONID AND ACTIONTYPE='AW' AND UPPER(ACTIONSTMT) !='SC_NEVER') " +
			" ORDER BY SORTORDER";	

	Query q = new Query(cn, qry, false);	
	
	q.rewind(1000, 1);
	int rowCnt = 0;
%>
<b>Site Map</b><br/>

<%	
	while (q.next()) {
		//LEVEL, ITEMID, CAPTION, SWITCH, ACTIONID, TREEKEY, UDATA, TRANSLATE, RATIO
		String caption = q.getValue("CAPTION");
		String level = q.getValue("LEVEL");
		actionid = q.getValue("ACTIONID");
		if (level.equals("1")) continue;
		
		rowCnt ++;
			
		qry = "SELECT actionstmt FROM TREEACTION_STMT WHERE SDI = 'WP' AND ACTIONID=" + actionid + " AND ACTIONTYPE='AS'"; 	
		String actionName = cn.queryOne(qry);
//		qry = "SELECT CAPTION, TREEKEY FROM TREEVIEW where sdi='WP' and actionid=" + actionid;
%>
<br/>
<a href="Javascript:loadProcess('<%=actionName%>');"><%= caption %></a><br/>
<table border=1 cellspacing=0 cellpadding=5 style="margin-left: 20px; border: 1px solid #CCCCCC; border-collapse: collapse;">
<tr>

<%
		ArrayList<String> processes = getProcessList(cn, actionName);
		for (String p: processes) {
			String pp[] = p.split(",");
%>
<td valign=top nowrap valign=top>
	<a href="Javascript:setProcess('<%=actionName%>','<%=pp[1]%>');"><%= pp[0] %></a><br/>
<%			
			ArrayList<String> events = getEventList(cn, pp[1]);
			for (String e: events) {
				String ee[] = e.split(",");
%>
				<a style="margin-left: 20px;" href="Javascript:setEvent('<%=actionName%>','<%=pp[1]%>','<%=ee[1]%>')"><%= ee[0] %></a><br/>
<%				
			}


		}
%>
</td>
</tr>
</table>
<%		
	}
%>
