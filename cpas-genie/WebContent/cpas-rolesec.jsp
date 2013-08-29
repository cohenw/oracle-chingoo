<%@ page language="java" import="java.util.*" import="java.sql.*"
	import="spencer.genie.*" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>

<%!
public String _getRoleSec(List<String[]> rolesecs, String role, String sec) {
	for (String[] rolesec: rolesecs) {
		if (rolesec[1].equals(role) && rolesec[2].equals(sec)) {
			String res = rolesec[3];
			if (res.equals("N")) res = "";
			return res;
		}
	}
	return "";
}

public String getRoleSec(Hashtable<String,String> ht, String role, String sec) {
	String key = role + "." + sec;
	String val = ht.get(key);
	if (val == null || val.equals("N")) val = "";

	return val;
}

%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	String id = request.getParameter("id");
	String process = request.getParameter("process");
	String event = request.getParameter("event");

	//String selectedRole[] = request.getParameters("selectedRole");
	String[] selectedRole = request.getParameterValues("selectedRole");
	
	List<String[]> roles = cn.query("SELECT RNAME, DESCR FROM CPAS_ROLE ORDER BY 1", true);
	List<String[]> secs = cn.query("SELECT LABEL, CAPTION FROM SECSWITCH ORDER BY 1", true);
	List<String[]> rolesecs = cn.query("SELECT RNAME, LABEL, GRANTED FROM CPAS_ROLE_SECSWITCH ORDER BY 1, 2", 10000, true);
	
	Hashtable<String,String> ht = new Hashtable<String,String>(); 
	for (String[] rolesec: rolesecs) {
		String key = rolesec[1] + "." + rolesec[2];
		String val = rolesec[3];
		ht.put(key, val);
	}
%>

<html>
<head>
<title>CPAS Role Privileges</title>

<meta name="description"
	content="Genie is an open-source, web based oracle database schema navigator." />
<meta name="keywords" content="Oracle Web Database OpenSource JDBC" />
<meta name="author" content="Spencer Hwang" />

<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
<script src="script/jquery-ui-1.8.18.custom.min.js"
	type="text/javascript"></script>
<script src="script/genie.js?<%=Util.getScriptionVersion()%>"
	type="text/javascript"></script>

<link rel="icon" type="image/png" href="image/Genie-icon.png">
<link rel="stylesheet"
	href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css" />
<link rel='stylesheet' type='text/css'
	href='css/style.css?<%=Util.getScriptionVersion()%>'>

<style>
</style>


<script type="text/javascript">
$(document).ready(function(){
	setHighlight();
})
</script>

</head>

<body>


<div id="topline" style="background-color: #EEEEEE; padding: 0px; border:1px solid #888888; border-radius:10px;">
<table width=100% border=0 cellpadding=0 cellspacing=0>
<td width="44">
<img align=top src="image/lamp.png" alt="Ver. <%= Util.getVersionDate() %>" title="<%= Util.getBuildNo() %>"/>
</td>
<td>
<span style="font-family: Arial; font-size:18px;"><span style="background-color:black; color: white;">C</span><span style="background-color:#FF9900; color: white;">PAS</span> <span style="color: blue; font-family: Arial; font-size:18px; font-weight:bold;">CPAS Role Privileges</span></span>
</td>
<!-- <td nowrap><h2 style="color: blue;">Genie</h2></td> -->
<td><b><%= cn.getUrlString() %></b></td>
<td nowrap>

<a href="index.jsp">Home</a> |
<a href="query.jsp" target="_blank">Query</a> 

</td>
<td align=right nowrap>
</td>
</table>
</div>
<div style="height: 4px;"></div>

<form method="get">
<input type="Submit" value="Refresh">

<table id="dataTable" border=1 class="gridBody">
<tr>
<th class="headerRow"></th>
<% for (String[] role : roles) { 
String roleName = role[1];
roleName = roleName.replaceAll("_","_<br/>");

boolean showColumn = false;
if (selectedRole==null || selectedRole.length==0) showColumn = true;
if (!showColumn)
for (String sel: selectedRole) {
	if (sel.equals(role[1])) {
		showColumn = true;
		break;
	}
}
if (showColumn) {
%>
<th class="headerRow" width=70 wrap><a title="<%= role[2] %>"><%= roleName %></a></th>
<% }
 } %>


<th class="headerRow" wrap>Diff</th>

</tr>

<% if (selectedRole==null) {%>
<tr>
<th class="headerRow"></th>
<% for (String[] role : roles) { 
String roleId = role[1];
%>
<th class="headerRow"><input type="checkbox" name="selectedRole" value="<%=roleId%>"></th>
<% } %>

<th class="headerRow"></th>

</tr>

<% } %>
<%-- 
<tr>
<th class="headerRow"></th>
<th class="headerRow"></th>
<% for (String[] role : roles) { %>
<th class="headerRow"><%= role[2] %></th>
<% } %>
</tr>

 --%><% 
int rowCnt=0;
for (String[] sec : secs) { 
	rowCnt++;
	String rowClass = "oddRow";
	if (rowCnt%2 == 0) rowClass = "evenRow";
%>

<tr class="simplehighlight">
<th class="headerRow" nowrap align=left><a target="_blank" href="cpas-seclabel.jsp?key=<%= sec[1] %>" title="<%= sec[2] %>"><%= sec[1] %></a></th>

<% 
boolean diff = false;
String prevVal = null;
for (String[] role : roles) { 

	boolean showColumn = false;
	if (selectedRole==null || selectedRole.length==0) showColumn = true;
	if (!showColumn)
	for (String sel: selectedRole) {
		if (sel.equals(role[1])) {
			showColumn = true;
			break;
		}
	}
	if (showColumn) {
		String newVal = getRoleSec(ht, role[1],sec[1]);
		if (prevVal ==null) 
			prevVal = newVal;
		else {
			if (!newVal.equals(prevVal)) {
				diff = true;
			}
		}
%>
<td class="<%= rowClass%>" align=center><%= getRoleSec(ht, role[1],sec[1]) %></td>
<% }
} %>

<th class="headerRow" nowrap align=left>
<% if (diff) { %>
<a title="<%= sec[2] %>"><%= sec[1] %></a>
<% } %>
</th>

</tr>

<% } %>

</table>
</form>

<br/><br/><br/><br/>

<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '<%= Util.trackingId() %>']);
  _gaq.push(['_setDomainName', 'none']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>

</body>
</html>
