<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	HashMap<String, QueryLog> map = cn.getQueryHistory();
	
	
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

<div style="font-size: 18px;">
<b>CPAS Catalog</b>
<br/><br/>
<a href="cpas-treeview.jsp" target="_blank">CPAS Tree View</a> |
<% if (hasCustomTV) { %> 
<a href="cpas-customtreeview.jsp" target="_blank">CPAS Custom Tree View</a> |
<% } %> 
<a href="cpas-process.jsp" target="_blank">CPAS Process</a> |
<a href="cpas-online.jsp" target="_blank">CPAS Online</a> |
<a href="cpas-rolesec.jsp" target="_blank">Role Privileges</a>
<br/><br/>
<table width=400>
<td valign=top>
<li><a href="Javascript:q('BATCHCAT')">BATCHCAT</a></li>
<li><a href="Javascript:q('ERRORCAT')">ERRORCAT</a></li>
<li><a href="Javascript:q('REPORTCAT')">REPORTCAT</a></li>
<li><a href="Javascript:q('REQUESTCAT')">REQUESTCAT</a></li>
<li><a href="Javascript:q('TASKCAT')">TASKCAT</a></li>
<li><a href="Javascript:q('WIZARDCAT')">WIZARDCAT</a></li>
<br/>

<li><a href="Javascript:q('CPAS_CATALOG')">CPAS_CATALOG</a></li>
<li><a href="Javascript:q('CPAS_CODE')">CPAS_CODE</a></li>
<li><a href="Javascript:q('CPAS_WIZARD')">CPAS_WIZARD</a></li>
<li><a href="Javascript:q('CPAS_VALIDATION')">CPAS_VALIDATION</a></li>
<li><a href="Javascript:q('CPAS_ROLE')">CPAS_ROLE</a></li>
<br/>

<li><a href="Javascript:q('CPAS_ACTION')">CPAS_ACTION</a></li>
<li><a href="Javascript:q('CPAS_AGE')">CPAS_AGE</a></li>

</td>
<td valign=top>
<li><a href="Javascript:q('CPAS_DATE')">CPAS_DATE</a></li>
<li><a href="Javascript:q('CPAS_CALCTYPE')">CPAS_CALCTYPE</a></li>
<li><a href="Javascript:q('CPAS_JML')">CPAS_JML</a></li>
<li><a href="Javascript:q('CPAS_GROUP')">CPAS_GROUP</a></li>
<li><a href="Javascript:q('CPAS_TABLE')">CPAS_TABLE</a></li>
<li><a href="Javascript:q('CPAS_LAYOUT')">CPAS_LAYOUT</a></li>
<br/>

<li><a href="Javascript:q('CPAS_SEARCHTYPE')">CPAS_SEARCHTYPE</a></li>
<li><a href="Javascript:q('CPASFIND')">CPASFIND</a></li>
<br/>

<li><a href="Javascript:q('CPAS_DOC')">CPAS_DOC</a></li>
<li><a href="Javascript:q('CPAS_FORM')">CPAS_FORM</a></li>
<br/>

<li><a href="Javascript:q('CPAS_PARAMETER')">CPAS_PARAMETER</a></li>

</td>
</table>

<form id="form1" name="form1" target=_blank action="query.jsp" method="post">
<input id="sql" name="sql" type="hidden" value="select * from tab"/>
</form>

<br/>
<b>Quick Search</b>
<form id="form1" name="form1" target=_blank action="query.jsp" method="post">
<input name="key" type="radio" id="mkey" value="mkey"><label for="mkey">mkey</label>
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
<b>Query</b><br/>
<li><a href="Javascript:qr('SELECT * FROM BATCH ORDER BY PROCESSID DESC')">Latest Batches</a></li>
<li><a href="Javascript:qr('SELECT * FROM REQUEST ORDER BY REQUESTID DESC')">Latest Requests</a></li>
<li><a href="Javascript:qr('SELECT * FROM WEBWIZARD ORDER BY RUNID DESC')">Latest Web Wizards</a></li>

</div>