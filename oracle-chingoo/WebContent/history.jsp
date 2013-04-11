<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.oracle.*" 
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
	<title>Chingoo Query History</title>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 

    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>

	<script src="script/main.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <script src="script/data-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <script src="script/query-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>

	<link rel="icon" type="image/png" href="image/chingoo-icon.png">

<script language="Javascript">
	
	function run(divName) {
		var qry = $("#" + divName).html();
		$("#sql").val(qry);
		//alert(qry);
		$("#form1").submit();
		//document.forms["form1"].submit();
		
		
	}	
</script>
	
</head>
<body>

<table>
<td><br><img src="image/chingoo-small.gif"/></td>
<td><%= cn.getUrlString() %> Database: <%= cn.getSchemaName() %></td>
</table>

<table id="dataTable" class="gridBody" border=1 width=800>
<tr class="rowHeader">
<th>Run</th>
<th>Query</th>
<th>Time</th>
</tr>

<%
	Iterator iterator = logs.iterator();
	int idx = 0;
	while  (iterator.hasNext()) {
		idx ++;
		QueryLog ql = (QueryLog) iterator.next();
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
		<td><%= ql.getTime() %></td>
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