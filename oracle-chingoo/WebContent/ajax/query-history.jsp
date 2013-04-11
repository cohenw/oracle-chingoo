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
<head>
<script type="text/javascript">

	function run(divName) {
		var qry = $("#" + divName).html();
		$("#sql").val(qry);
		//alert(qry);
		$("#form1").submit();
		//document.forms["form1"].submit();
		
		
	}	
</script>
	
</head>

<b>Query History</b>
<br/><br/>

<table id="dataTable" class="gridBody" border=1 width=600>
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

