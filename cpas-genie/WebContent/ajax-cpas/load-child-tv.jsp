<%@ page language="java" import="java.util.*" import="java.sql.*"
	import="spencer.genie.*" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<%
	String sdi = request.getParameter("sdi");
	String parentid = request.getParameter("parentid");

	Connect cn = (Connect) session.getAttribute("CN");
	String qry = "SELECT * FROM TREEVIEW WHERE parentid='" + parentid + "' and sdi='" + sdi + "' ORDER BY SORTORDER";	

	Query q = new Query(cn, qry, false);
	q.rewind(1000, 1);
	int rowCnt = 0;
	String rq="";
	String itemid="";
	String treekey=""; 
	String actionid="";
	int childCnt=0;
	while (q.next()) {
		String caption = q.getValue("CAPTION");
		itemid = q.getValue("ITEMID");
		treekey = q.getValue("TREEKEY");
		actionid = q.getValue("ACTIONID");
		rowCnt ++;
		String id = Util.getId();
		//Util.p(caption+","+itemid+","+treekey+","+actionid);

		rq = cn.queryOne("SELECT ACTIONSTMT FROM TREEACTION_STMT WHERE SDI = '"+sdi+"' AND ACTIONID=" + actionid + " AND ACTIONTYPE='MB'");
		if (rq==null) rq="";
		childCnt = cn.getQryCount("SELECT COUNT(*) FROM TREEVIEW WHERE parentid='" + itemid + "' and sdi='" + sdi + "'");
		if (caption.equals("<TV_CLIENTS_ITEM>")) rq = "SELECT SNAME, CLNT FROM CLIENT";
if (rq.equals("")) {
 if (childCnt > 0) { %>
	<a href="Javascript:toggle(<%=id%>, <%=itemid%>)"><img id="img-<%=id%>" src="image/plus.gif" align="top"></a>
<% } %>
	<a id="aa-<%=id%>" href="Javascript:loadCon('<%=sdi %>',<%=actionid%>,'<%=treekey %>',<%=id%>,'<%=itemid %>')"><%= Util.escapeHtml(caption) %></a><br/>
	<div id="div-<%=id%>" style="margin-left: 20px; display:none;">*</div>
<% } 
}%>

<% if (!rq.equals("")) { 
	//childCnt = cn.getQryCount("SELECT COUNT(*) FROM TREEVIEW WHERE parentid='" + itemid + "' and sdi='" + sdi + "'");
	Util.p(rq);
	q = new Query(cn, rq, false);
	q.rewind(1000, 1);
	while (q.next()) {
		String caption = q.getValue(0);
		String key = q.getValue(1);
		rowCnt ++;
		String id = Util.getId();

		//int childCnt = cn.getQryCount("SELECT COUNT(*) FROM TREEVIEW WHERE parentid='" + itemid + "' and sdi='" + sdi + "'");
%>
		<% if (childCnt > 0) { %>
		<a href="Javascript:toggle(<%=id%>, <%=itemid%>)"><img id="img-<%=id%>" src="image/plus.gif" align="top"></a>
	<% } %>
		<a id="aa-<%=id%>" href="Javascript:loadCon2('<%=sdi %>',<%=actionid%>,'<%=treekey %>',<%=id%>,'<%=itemid %>','<%=key %>')"><%= Util.escapeHtml(caption) %></a><br/>
		<div id="div-<%=id%>" style="margin-left: 20px; display:none;">*</div>
	<% } 
}
%>
