<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="java.text.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	HashMap<String, QueryLog> map = cn.getQueryHistory();
	
    List<QueryLog> logs = new ArrayList<QueryLog>(map.values());

    Collections.sort(logs, new Comparator<QueryLog>() {

        public int compare(QueryLog o1, QueryLog o2) {
            return o1.getTime().compareTo(o2.getTime());
        }
    });
%>

<html>
<head> 
	<title>Genie Query History</title>

	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 

    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>

	<script src="script/main.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <script src="script/data-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <script src="script/query-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
	<script src="script/timeago.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>

	<link rel="icon" type="image/png" href="image/Genie-icon.png">

<script language="Javascript">
	
	function run(divName) {
		var qry = $("#" + divName).html();
		$("#sql").val(qry);
		//alert(qry);
		$("#form1").submit();
		//document.forms["form1"].submit();
		
		
	}	
	$(document).ready(function() {
		$("abbr.timeago").timeago();
	});	
</script>
	
</head>
<body>

<div style="background-color: #E6F8E0; padding: 6px; border:1px solid #CCCCCC; border-radius:10px;">
<img src="image/icon_query.png" width=20 height=20 align="top"/>
<span style="color: blue; font-family: Arial; font-size:16px; font-weight:bold;">Query History</span>
&nbsp;&nbsp;&nbsp;
<b><%= cn.getUrlString() %></b>
&nbsp;&nbsp;&nbsp;
<a href="index.jsp" target="_blank">Home</a> |
<a href="query.jsp" target="_blank">Query</a>
<!-- <span style="float:right;">
Search <input id="globalSearch" style="width: 200px;" placeholder="table or view name"/>
</span>
 -->
</div>
<div style="height: 4px;"></div>

<table id="dataTable" class="gridBody" border=1 width=1000>
<tr class="rowHeader">
<th>Run</th>
<th>Query</th>
<th>Time Ago</th>
</tr>

<%
	int idx = 0;
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
	for (int i=logs.size()-1;i>=0;i--) {
		QueryLog ql = logs.get(i);
		idx ++;
/*
	Iterator iterator = logs.iterator();
	while  (iterator.hasNext()) {
		idx ++;
		QueryLog ql = (QueryLog) iterator.next();
*/
		String divName ="QRY-" + idx;

		String rowClass = "odd";
		if (idx%2 == 0) rowClass = "even";
%>
	<tr class="<%=rowClass%>">
		<td><a href="Javascript:run('<%= divName %>')">run</a></td>
		<td>
			<div style="display: none;" id="<%= divName %>"><%= ql.getQueryString() %></div>
			<div style="font-family: Consolas;"><%=new HyperSyntax().getHyperSyntax(cn, ql.getQueryString(), "SQL")%></div>
		</td>
		<td nowrap><%-- <%= ql.getTime() %> --%>
			<abbr class="timeago" title="<%= sdf.format(ql.getTime()) %>"><%= sdf.format(ql.getTime()) %></abbr>
		</td>
	</tr>
<%
	}
 %>

</table>

<form id="form1" name="form1" target=_blank action="query.jsp" method="post">
<input id="sql" name="sql" type="hidden" value="select * from tab"/>
</form>

<br/><br/>
<a href="Javascript:window.close()">Close</a>
<br/><br/>

</body>
</html>