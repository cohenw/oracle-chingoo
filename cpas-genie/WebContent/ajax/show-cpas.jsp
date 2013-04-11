<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%!
	String tables1[] = {"MEMBER", "PERSON", "PENSIONER", "ACCOUNT", "CALC", "BATCH", "EMPLOYER", "FUND"};
	String tables2[] = {"BATCHCAT", "BATCHCAT_TASK", "ERRORCAT", "REPORTCAT", "REQUESTCAT", "TASKCAT", "FWIZCAT", "WIZARDCAT"};
	String tables3[] = {"CPAS_CODE", "CPAS_CALCTYPE", "CPAS_CATALOG", "CPAS_WIZARD", "CPAS_VALIDATION", "CPAS_ACTION", "CPAS_TABLE", "CPAS_LAYOUT"};
	String tables4[] = {"CPAS_DATE", "CPAS_JML", "CPAS_GROUP", "CPAS_SEARCHTYPE", "CPASFIND", "CPAS_DOC", /*"CPAS_FORM",*/ "CPAS_PARAMETER", "CPAS_AGE"};
	String tables5[] = {"FORMULA", "RULE", "EXPOSE", "EXPOSE_RULE", "PLAN_RULEID", "", "CPAS_ROLE", "SECSWITCH"};
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	
	String cntCustom = cn.queryOne("SELECT count(*) FROM USER_OBJECTS WHERE OBJECT_NAME='CUSTOMTREEVIEW'");
	boolean hasCustomTV = cntCustom.equals("1");
%>
<head>
<script type="text/javascript">

	function q(tname) {
		$("#sql").val("SELECT * FROM " + tname);
		$("#form1").submit();
	}	
	function qr(sql) {
		$("#sql").val(sql);
		$("#form1").submit();
	}	
</script>

</head>

<div>
<h2><img src="image/cpas.jpg"> CPAS Catalog</h2>

<% if (cn.isTVS("TREEVIEW")) { %>
<a href="cpas-online.jsp" target="_blank">CPAS Online</a> 
<% } else { %>
<span class="nullstyle">CPAS Online</span>
<% } %>

|
<% if (cn.isTVS("CPAS_SDI")) { %>
<a href="cpas-treeview.jsp" target="_blank">CPAS Tree View</a>
<% } else { %>
<span class="nullstyle">CPAS Tree View</span>
<% } %>

|
<% if (hasCustomTV && cn.isTVS("CPAS_SDI")) { %> 
<a href="cpas-customtreeview.jsp" target="_blank">CPAS Custom Tree View</a> |
<% } %> 

<% if (cn.isTVS("CPAS_SDI")) { %>
<a href="cpas-process.jsp" target="_blank">CPAS Process</a>
<% } else { %>
<span class="nullstyle">CPAS Process</span>
<% } %>
|

<% if (cn.isTVS("CPAS_ROLE_SECSWITCH")) { %>
<a href="cpas-rolesec.jsp" target="_blank">Role Privileges</a>
<% } else { %>
<span class="nullstyle">Role Privileges</span>
<% } %>

<br/><br/>
<table width=700 style="margin-left: 20px;">
<td valign=top>
<% for (String tbl : tables1) {%>
	<% if (tbl.equals("")) { %>
	<br/>
	<% } else if (cn.isTVS(tbl)) { %>
	<li><a href="Javascript:q('<%=tbl%>')"><%=tbl%></a> <span class="rowcountstyle"><%= cn.getTableRowCount(tbl) %></span></li>
	<% } else { %>
	<li><span class="nullstyle"><%=tbl%></span></li>
	<% } %>
<% } %>
</td>
<td valign=top>
<% for (String tbl : tables2) {%>
	<% if (tbl.equals("")) { %>
	<br/>
	<% } else if (cn.isTVS(tbl)) { %>
	<li><a href="Javascript:q('<%=tbl%>')"><%=tbl%></a> <span class="rowcountstyle"><%= cn.getTableRowCount(tbl) %></span></li>
	<% } else { %>
	<li><span class="nullstyle"><%=tbl%></span></li>
	<% } %>
<% } %>
</td>
<td valign=top>
<% for (String tbl : tables3) {%>
	<% if (tbl.equals("")) { %>
	<br/>
	<% } else if (cn.isTVS(tbl)) { %>
	<li><a href="Javascript:q('<%=tbl%>')"><%=tbl%></a> <span class="rowcountstyle"><%= cn.getTableRowCount(tbl) %></span></li>
	<% } else { %>
	<li><span class="nullstyle"><%=tbl%></span></li>
	<% } %>
<% } %>
</td>
<td valign=top>
<% for (String tbl : tables4) {%>
	<% if (tbl.equals("")) { %>
	<br/>
	<% } else if (cn.isTVS(tbl)) { %>
	<li><a href="Javascript:q('<%=tbl%>')"><%=tbl%></a> <span class="rowcountstyle"><%= cn.getTableRowCount(tbl) %></span></li>
	<% } else { %>
	<li><span class="nullstyle"><%=tbl%></span></li>
	<% } %>
<% } %>
</td>
<td valign=top>
<% for (String tbl : tables5) {%>
	<% if (tbl.equals("")) { %>
	<br/>
	<% } else if (cn.isTVS(tbl)) { %>
	<li><a href="Javascript:q('<%=tbl%>')"><%=tbl%></a> <span class="rowcountstyle"><%= cn.getTableRowCount(tbl) %></span></li>
	<% } else { %>
	<li><span class="nullstyle"><%=tbl%></span></li>
	<% } %>
<% } %>
</td>
</table>

<form id="form1" name="form1" target=_blank action="query.jsp" method="post">
<input id="sql" name="sql" type="hidden" value="select * from tab"/>
</form>

<b>Quick Search</b>
<form id="form1" name="form1" target=_blank action="query.jsp" method="post" style="margin-left: 20px;">
<input name="key" type="radio" id="mkey" value="mkey" checked><label for="mkey">mkey</label>
<input name="key" type="radio" id="calcid" value="calcid"><label for="calcid">calcid</label>
<input name="key" type="radio" id="processid" value="processid"><label for="processid">processid</label>
<input name="key" type="radio" id="accountid" value="accountid"><label for="accountid">accountid</label>
<input name="key" type="radio" id="penid" value="penid"><label for="penid">penid</label>
<input name="key" type="radio" id="personid" value="personid"><label for="personid">personid</label>
<input name="key" type="radio" id="errorid" value="errorid"><label for="errorid">errorid</label>
<input name="key" type="radio" id="requestid" value="requestid"><label for="requestid">requestid</label>
<br/>
<input name="value" size=20>
<input type="submit">
</form>

<br/>
<table>
<td valign=top>
<b>Quick Query</b><br/>
<table style="margin-left: 20px;"><td>
<% if (cn.isTVS("BATCHCAT")) { %>
	<li><a href="Javascript:qr('SELECT * FROM BATCH ORDER BY PROCESSID DESC')">Latest Batches</a></li>
<% } else { %>
	<li><span class="nullstyle">Latest Batches</span></li>
<% } %>

<% if (cn.isTVS("REQUEST")) { %>
<li><a href="Javascript:qr('SELECT * FROM REQUEST ORDER BY REQUESTID DESC')">Latest Requests</a></li>
<% } else { %>
	<li><span class="nullstyle">Latest Requests</span></li>
<% } %>

<% if (cn.isTVS("WEBWIZARD")) { %>
<li><a href="Javascript:qr('SELECT * FROM WEBWIZARD ORDER BY RUNID DESC')">Latest Web Wizards</a></li>
<% } else { %>
	<li><span class="nullstyle">Latest Web Wizards</span></li>
<% } %>

<% if (cn.isTVS("WIZARD_RUN")) { %>
<li><a href="Javascript:qr('SELECT * FROM WIZARD_RUN ORDER BY RUNID DESC')">Latest Web Wizards</a></li>
<% } %>

<% if (cn.isTVS("CALC")) { %>
<li><a href="Javascript:qr('SELECT * FROM CALC ORDER BY CALCID DESC')">Latest Calcs</a></li>
<% } else { %>
	<li><span class="nullstyle">Latest Calcs</span></li>
<% } %>

<% if (cn.isTVS("CONNSESSION")) { %>
<li><a href="Javascript:qr('SELECT * FROM CONNSESSION ORDER BY SESSIONID DESC')">Latest Online Sessions</a></li>
<% } else { %>
	<li><span class="nullstyle">Latest Online Sessions</span></li>
<% } %>

<% if (cn.isTVS("TASK")) { %>
<li><a href="Javascript:qr('SELECT * FROM TASK ORDER BY TASKID DESC')">Latest Tasks</a></li>
<% } else { %>
	<li><span class="nullstyle">Latest Tasks</span></li>
<% } %>

</td></table>
</td>
<td valign=top>
<b>Query</b><br/>
<form target="_blank" action="query.jsp" method="post">
<textarea style="margin-left:20px;" name="sql" cols=50 rows=4>SELECT * FROM TAB</textarea>
<input type="submit">
</form>

</td>
</table>

<br/><br/>

<b>Note:</b>
<div style="margin-left: 20px;">
Please send me any bug report, feedback, enhancement ideas.<br/>
Thanks.
<br/><br/>
Spencer Hwang
<br/>
<a href="mailto:spencerh@cpas.com">spencerh@cpas.com</a>
</div>

</div>