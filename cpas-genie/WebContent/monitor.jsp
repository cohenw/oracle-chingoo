<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%!
public String extractJS(String str) {
	
	int start = 0;
	int end;
	
	String res = "";

	while (true) {
		start = str.indexOf("Javascript:", start);
		if (start < 0 ) break;
		end = str.indexOf("'>", start);
		if (end < 0 ) break;
		String tk = str.substring(start+11, end);
				
		res += tk + "<br/>\n";
		//System.out.println("*** " + res);
		start = end;
	}

	return res;
}


%>
<%
	GenieManager gm = GenieManager.getInstance();
	ArrayList<Connect> ss = gm.getSessions();
%>

<html>
<head> 
	<title>Genie Sessions <%= ss.size() %></title>
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    <script src="script/genie.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <script src="script/data-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <script src="script/worksheet-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>

    <meta http-equiv="refresh" content="60;">
</head> 

<body>

<b>Genie Sessions</b>
<br/><br/>
<%= new Date() %><br/>
<table id="dataTable" border=1 class="gridBody">
<tr>
	<th class="headerRow">Database / User</th>
	<th class="headerRow">Hist</th>
	<th class="headerRow">Count</th>
	<th class="headerRow">Queries</th>
</tr>
<% 
	int rowCnt = 0;
	for (Connect cn : ss) {
		HashMap<String,QueryLog> map = cn.getQueryHistory();
	    List<QueryLog> logs = new ArrayList<QueryLog>(map.values());

	    Collections.sort(logs, new Comparator<QueryLog>() {

	        public int compare(QueryLog o1, QueryLog o2) {
	            return o1.getTime().compareTo(o2.getTime());
	        }
	    });
	    
		String qry = "";
    	if (map != null) {
	    	Iterator iterator = logs.iterator();
    		int idx = 0;
    		while  (iterator.hasNext()) {
    			idx ++;
    			QueryLog ql = (QueryLog) iterator.next();
				qry += ql.getQueryString() + "; " + ql.getCount() + "<br/>";
    		}
    	}		
    	String savedHistory = cn.getAddedHistory();

    	rowCnt++;
    	String rowClass = "oddRow";
    	if (rowCnt%2 == 0) rowClass = "evenRow";
    	
%>
<tr class="simplehighlight">
	<td valign=top class="<%= rowClass%>">
		<%= cn.getUrlString() %><br/>
		IP: <%= cn.getIPAddress() %><br/>
		Agent: <%= cn.getUserAgent() %><br/>
		Email: <%= cn.getEmail() %><br/>
		Login Date: <%= cn.getLoginDate() %><br/>
		Last Date: <%= cn.getLastDate() %><br/>
		<span style="display: none;"><%= cn.pwd %></span>
	</td>
	<td nowrap valign=top class="<%= rowClass%>"><%= extractJS(savedHistory) %>&nbsp;</td>
	<td nowrap valign=top class="<%= rowClass%>"><%= map.size() %>&nbsp;</td>
	<td valign=top class="<%= rowClass%>"><p style="white-space:pre;"><%= qry %>&nbsp;</p></td>
</tr>

<% 
	}
%>
</table>

</body>
</html>

