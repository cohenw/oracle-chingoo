<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	String process = request.getParameter("process");
	String event = request.getParameter("event");
	String qry = "SELECT * FROM CPAS_PROCESS_EVENT_VIEW WHERE PROCESS = '" + process + 
			"' AND EVENT='" + event + "' AND SECLABEL != 'SC_NEVER' ORDER BY POSITION"; 	
	Query q = new Query(cn, qry, false);

	String ename = cn.queryOne("SELECT NAME FROM CPAS_PROCESS_EVENT WHERE PROCESS='" + process+"' AND EVENT='" + event + "'");
	String id = Util.getId();
%>
<b>Event View</b> - <%= ename %> [<%= process %>,<%= event %>]
<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" border=0 align=middle  title="<%=qry%>"/></a>
<div style="display: none;" id="sql-<%=id%>"><%= qry%></div>
<br/>

<table id="dataTable" border=1 class="gridBody">
<tr>
	<th rowspan=2 class="headerRow">Description</th>
	<th rowspan=2 class="headerRow">Position</th>
	<th rowspan=2 class="headerRow">SDI,Treeview Key</th>
	<th rowspan=2 class="headerRow">UData</th>
	<th rowspan=2 class="headerRow">Read</th>
	<th class="headerRow" colspan="3">Upper Browser</th>
	<th class="headerRow" colspan="3">Lower Browser</th>
</tr>
<tr>
	<th class="headerRow">Add</th>
	<th class="headerRow">Upd</th>
	<th class="headerRow">Del</th>
	<th class="headerRow">Add</th>
	<th class="headerRow">Upd</th>
	<th class="headerRow">Del</th>
</tr>


<%
	int rowCnt = 0;
	q.rewind(1000, 1);
	while (q.next() && rowCnt < 1000) {
		String descr = q.getValue("caption");
		String position = q.getValue("position");
		String seclabel = q.getValue("seclabel");
		String sdi = q.getValue("sdi");
		String tv = q.getValue("treekey");
		String udata = q.getValue("udata");

		rowCnt ++;
		String rowClass = "oddRow";
		if (rowCnt%2 == 0) rowClass = "evenRow";	
		
		String secName = cn.queryOne("SELECT CAPTION FROM SECSWITCH WHERE LABEL ='" + seclabel + "'");
		String sdiName = cn.queryOne("SELECT NAME FROM CPAS_SDI WHERE SDI ='" + sdi + "'");
%>
<tr class="simplehighlight">
	<td class="<%= rowClass%>" nowrap><%= descr==null?"":descr %></td>
	<td class="<%= rowClass%>" nowrap><%= position %></td>
<%-- 	<td class="<%= rowClass%>" nowrap><%= sdi==null?"":sdi /* + " <span class='cpas'>" + sdiName + "</span>" */%></td>
 --%>
 	<td class="<%= rowClass%>" nowrap><%= sdi==null?"":"[" + sdi +"] "%><%= tv==null?"":tv %>
<%
String read = "";
String uadd = "";
String uupd = "";
String udel = "";
String ladd = "";
String lupd = "";
String ldel = "";

//cn.queryOne("SELECT actionstmt")
if (tv!=null && sdi!=null) {
	qry = "SELECT * FROM TREEACTION_STMT WHERE (sdi, actionid) in (SELECT sdi, actionid FROM TREEVIEW WHERE SDI = '" + sdi + "' AND TREEKEY='" + tv +"')";
	id = Util.getId();

	read = cn.queryOne("SELECT actionstmt FROM TREEACTION_STMT WHERE (sdi, actionid) in (SELECT sdi, actionid FROM TREEVIEW WHERE SDI = '" + sdi + "' AND TREEKEY='" + tv +"') AND actiontype='AW'");
	uadd = cn.queryOne("SELECT actionstmt FROM TREEACTION_STMT WHERE (sdi, actionid) in (SELECT sdi, actionid FROM TREEVIEW WHERE SDI = '" + sdi + "' AND TREEKEY='" + tv +"') AND actiontype='MN'");
	uupd = cn.queryOne("SELECT actionstmt FROM TREEACTION_STMT WHERE (sdi, actionid) in (SELECT sdi, actionid FROM TREEVIEW WHERE SDI = '" + sdi + "' AND TREEKEY='" + tv +"') AND actiontype='ME'");
	udel = cn.queryOne("SELECT actionstmt FROM TREEACTION_STMT WHERE (sdi, actionid) in (SELECT sdi, actionid FROM TREEVIEW WHERE SDI = '" + sdi + "' AND TREEKEY='" + tv +"') AND actiontype='MR'");
	ladd = cn.queryOne("SELECT actionstmt FROM TREEACTION_STMT WHERE (sdi, actionid) in (SELECT sdi, actionid FROM TREEVIEW WHERE SDI = '" + sdi + "' AND TREEKEY='" + tv +"') AND actiontype='DN'");
	lupd = cn.queryOne("SELECT actionstmt FROM TREEACTION_STMT WHERE (sdi, actionid) in (SELECT sdi, actionid FROM TREEVIEW WHERE SDI = '" + sdi + "' AND TREEKEY='" + tv +"') AND actiontype='DE'");
	ldel = cn.queryOne("SELECT actionstmt FROM TREEACTION_STMT WHERE (sdi, actionid) in (SELECT sdi, actionid FROM TREEVIEW WHERE SDI = '" + sdi + "' AND TREEKEY='" + tv +"') AND actiontype='DR'");
	
	read = read==null?"":read;
	uadd = uadd==null?"":uadd;
	uupd = uupd==null?"":uupd;
	udel = udel==null?"":udel;
	ladd = ladd==null?"":ladd;
	lupd = lupd==null?"":lupd;
	ldel = ldel==null?"":ldel;
%>
<a href="javascript:openQuery('<%=id%>')"><img src="image/sql.png" border=0 align=middle  title="<%=qry%>"/></a>
<br/>
<a href="javascript:openSimul('<%=sdi%>','<%=tv%>')">Simulator</a>
<a href="cpas-treeview.jsp?sdi=<%= sdi %>&treekey=<%= tv %>" target="_blank">Treeview</a>
<div style="display: none;" id="sql-<%=id%>"><%= qry%></div>
	
<% } %>
	</td>
	<td class="<%= rowClass%>" nowrap><%= udata==null?"":udata %></td>
	<td class="<%= rowClass%>" nowrap><%= read %></td>
	<td class="<%= rowClass%>" nowrap><%= uadd %></td>
	<td class="<%= rowClass%>" nowrap><%= uupd %></td>
	<td class="<%= rowClass%>" nowrap><%= udel %></td>
	<td class="<%= rowClass%>" nowrap><%= ladd %></td>
	<td class="<%= rowClass%>" nowrap><%= lupd %></td>
	<td class="<%= rowClass%>" nowrap><%= ldel %></td>
</tr>
<%
	} 
%>
</table>

