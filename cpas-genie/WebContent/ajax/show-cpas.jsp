<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	String tables1[] = {"MEMBER", "CLIENT", "PLAN", "EMPLOYER", "PERSON", "PENSIONER", "", "ACCOUNT", "CALC", "BATCH",  "FUND", "REQUEST", "TASK"};
	String tables2[] = {"BATCHCAT", "BATCHCAT_TASK", "ERRORCAT", "REPORTCAT", "REQUESTCAT", "TASKCAT", "FWIZCAT", "WIZARDCAT", "", "CPAS_CODE", "CPAS_REPORT", "CPAS_KIT", "CPAS_WIZARD", "CPAS_VALIDATION"};
	String tables3[] = {"CPAS_CALCTYPE", "CPAS_CATALOG", "CPAS_ACTION", "CPAS_TABLE", "CPAS_LAYOUT", "CPAS_DATE", "CPAS_JML", "CPAS_GROUP", "CPAS_DOC", /*"CPAS_FORM",*/ "CPAS_PARAMETER", "CPAS_AGE", "", "CPAS_SEARCHTYPE", "CPASFIND"};
	String tables4[] = {"FORMULA", "RULE", "EXPOSE", "EXPOSE_RULE", "PLAN_RULEID", "", "CPAS_ROLE", "SECSWITCH"};

	Connect cn = (Connect) session.getAttribute("CN");

	if (cn.isTVS("SV_MEMBER")) tables1[0] = "SV_MEMBER";
	if (cn.isTVS("SV_CLIENT")) tables1[1] = "SV_CLIENT";
	if (cn.isTVS("SV_PLAN")) tables1[2] = "SV_PLAN";

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
<!-- <h3><img src="image/cpas.jpg"> CPAS Catalog</h3>
 -->
 <h3>
 CPAS 
<% if (cn.isTVS("CPAS_SDI")) { %>
<a href="cpas-on.jsp" target="_blank">Online</a>
	<% if (hasCustomTV) { %>
		<a href="cpas-on-custom.jsp" target="_blank">Custom</a>
	<% } %>
<% } else { %>
<span class="nullstyle">Online</span>
<% } %>

|
<% if (cn.isTVS("CPAS_SDI")) { %>
<a href="cpas-treeview.jsp" target="_blank">TreeView</a>
	<% if (hasCustomTV) { %> 
		<a href="cpas-customtreeview.jsp" target="_blank">Custom</a>
	<% } %> 
<% } else { %>
<span class="nullstyle">TreeView</span>
<% } %>

|
<% if (cn.isTVS("CPAS_SDI")) { %>
<a href="cpas-process.jsp" target="_blank">Process</a>
<% } else { %>
<span class="nullstyle">Process</span>
<% } %>

|
<% if (cn.isTVS("CPAS_CODE")) { %>
<a href="cpas-code.jsp" target="_blank">Code</a>
<% } else { %>
<span class="nullstyle">Code</span>
<% } %>

|

<% if (cn.isTVS("CPAS_ROLE_SECSWITCH")) { %>
<a href="cpas-rolesec.jsp" target="_blank">Role</a>
<% } else { %>
<span class="nullstyle">Role</span>
<% } %>
<br/><br/>

Test 
<% if (cn.isTVS("CT$MATRIX")) { %>
<a href="bc_matrix.jsp" target="_blank">Matrix</a>
<% } else { %>
<span class="nullstyle">Matrix</span>
<% } %>
|
<% if (cn.isPackage("BC")|| ( cn.isPackageProc("BC.getFormula")&&cn.isPackageProc("BC.setAll"))) { %>
<a href="bencalc.jsp" target="_blank">BenCalc</a>
|
<a href="bencalc_member.jsp" target="_blank">BenCalc-Member</a>
<% } else { %>
<span class="nullstyle">Formula</span>
<% } %>
<%-- 
|
<% if (cn.isPackageProc("BC.setAll")) { %>
<a href="bc_test.jsp" target="_blank">BenCalc</a>
<% } else { %>
<span class="nullstyle">BenCalc</span>
<% } %>

 --%>
</h3>

<b>Quick Search</b>
<form id="form0" name="form0" target=_blank action="query.jsp" method="post" style="margin-left: 20px;">
<input name="key" type="radio" id="mkey" value="mkey" checked><label for="mkey">mkey</label>
<input name="key" type="radio" id="calcid" value="calcid"><label for="calcid">calcid</label>
<input name="key" type="radio" id="memno" value="memno"><label for="memno">memno</label>
<input name="key" type="radio" id="personid" value="personid"><label for="personid">personid</label>
<input name="key" type="radio" id="sin" value="sin"><label for="sin">sin</label>
<input name="key" type="radio" id="processid" value="processid"><label for="processid">processid</label>
<input name="key" type="radio" id="accountid" value="accountid"><label for="accountid">accountid</label>
<input name="key" type="radio" id="penid" value="penid"><label for="penid">penid</label>
<input name="key" type="radio" id="errorid" value="errorid"><label for="errorid">errorid</label>
<input name="key" type="radio" id="requestid" value="requestid"><label for="requestid">requestid</label>
<br/>
<input name="value" size=20>
<input type="submit">
</form>

<table>
<td valign=top>
<b>Quick Query</b><br/>
<table style="margin-left: 20px;"><td nowrap>
<% if (cn.isTVS("CALC")) { %>
<li><a href="Javascript:qr('SELECT * FROM CALC ORDER BY CALCID DESC')">Latest Calcs</a></li>
<% } else { %>
	<li><span class="nullstyle">Latest Calcs</span></li>
<% } %>

<% if (cn.isTVS("BATCH")) { %>
	<li><a href="Javascript:qr('SELECT * FROM BATCH ORDER BY PROCESSID DESC')">Latest Batches</a></li>
<% } else { %>
	<li><span class="nullstyle">Latest Batches</span></li>
<% } %>

<% if (cn.isTVS("BATCH_QUEUE")) { %>
	<li><a href="Javascript:qr('SELECT * FROM BATCH_QUEUE ORDER BY SPROCESSID DESC')">Latest Batch Tasks</a></li>
<% } else { %>
	<li><span class="nullstyle">Latest Batch Tasks</span></li>
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
<li><a href="Javascript:qr('SELECT * FROM WIZARD_RUN ORDER BY RUNID DESC')">Latest Web Wizard Runs</a></li>
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
<textarea style="margin-left:20px;" name="sql" cols=50 rows=6>SELECT * FROM TAB</textarea>
<input type="submit">
</form>

</td>
</table>

<b>Tables</b>
<table width=650 style="margin-left: 20px;">
<td valign=top width=25%>
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
<td valign=top width=25%>
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
<td valign=top width=25%>
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
<td valign=top width=25%>
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
</table>

<form id="form1" name="form1" target=_blank action="query.jsp" method="post">
<input id="sql" name="sql" type="hidden" value="select * from tab"/>
</form>


<b>Note:</b>
<br/>
<img src="image/video.png">
<a href="http://genie.cpas.com/genie-video/index.html" target=_blank><span style="background-color: yellow;">Watch tutorial videos</span></a>
<br/><br/>

<div style="margin-left: 20px;">
Please send me any bug report, feedback, enhancement ideas.<br/>
Thanks.
<br/><br/>
Spencer Hwang
<br/>
<a href="mailto:spencerh@cpas.com">spencerh@cpas.com</a><br/>
x350
</div>

</div>