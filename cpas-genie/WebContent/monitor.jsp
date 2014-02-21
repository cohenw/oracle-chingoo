<%@ page language="java" 
	import="java.util.*" 
	import="java.text.*" 
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

	int cnt=0;
	while (true) {
		start = str.indexOf("Javascript:", start);
		if (start < 0 ) break;
		end = str.indexOf("'>", start);
		if (end < 0 ) break;
		String tk = str.substring(start+11, end);
				
		res += tk + "<br/>\n";
		//System.out.println("*** " + res);
		start = end;
		if (++cnt>=10) break;
		
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
	<script src="script/timeago.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>

    <meta http-equiv="refresh" content="60;">
<script language="Javascript">
	
	$(document).ready(function() {
		$("abbr.timeago").timeago();
	});	
</script>    
</head> 

<body>

<b>Cache Schemas</b><br/>
<%
	Hashtable<String,CacheSchema> csTable = CacheManager.getInstance().getCsTable();
%>

<% 
	List<String> expired = new ArrayList<String>();
	Date current = new Date();
	for (CacheSchema cs : csTable.values()) {
		// expire if it's too old

		if ((current.getTime() - cs.loadDate.getTime()) > (1000 * 60 * 60 * 24)) {  // 24 hours
			Util.p("expired cs " + cs.dbUrl);
			expired.add(cs.dbUrl);
		}
%>
	<%= cs.dbUrl %> :  <%= cs.loadDate %><br/>
<%		
	}

	for (String exp:expired) {
		CacheManager.getInstance().getCsTable().remove(exp);
	}
%>

<br/><br/>
<b>Genie Sessions</b>
<br/>
<%= new Date() %><br/>
<table id="dataTable" border=1 class="gridBody">
<tr>
	<th class="headerRow">Database / User</th>
	<th class="headerRow">Hist</th>
	<th class="headerRow">JSP log</th>
	<th class="headerRow">Q Count</th>
	<th class="headerRow">Queries</th>
</tr>
<% 
	int rowCnt = 0;
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
	for (Connect cn : ss) {
		HashMap<String,QueryLog> map = cn.getQueryHistory();
	    if (map==null) {
	    	ss.remove(cn);
	    	continue;
	    }
	    	//map = new HashMap <String,QueryLog>();
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
    			if (ql.getTime().before(cn.getLoginDate())) continue;
//				qry += ql.getQueryString() + "; " + ql.getCount() + "<br/>";
				qry += new HyperSyntax().getHyperSyntax(cn, ql.getQueryString(), "SQL") + "; " + ql.getCount() + "<br/>";
				
    		}
    	}		
    	String quickLink = cn.getQuickLinksText();
    	String jsplogStr = "";
    	ArrayList<String> al = cn.getJspLog();
    	for (int i=0; i<al.size()&& i<20;i++) {
    		jsplogStr += "<li>" + al.get(al.size()-i-1) +"<br/>";   		
    	}
    	
    	jsplogStr += "<br/><br/>";
    	HashMap<String, PageCount> pc = cn.getPageCount();
    	List<PageCount> list = new ArrayList<PageCount>(pc.values());
    	Collections.sort(list, new Comparator<PageCount>() {
    	    public int compare(PageCount a, PageCount b) {
    	        return a.getPage().compareTo(b.getPage());
    	    }
    	});
    	for (PageCount p: list) {
    		jsplogStr += "<li>" + p.getPage() +" " +  p.getCount()+"<br/>";   		
    	}
    	rowCnt++;
    	String rowClass = "oddRow";
    	if (rowCnt%2 == 0) rowClass = "evenRow";
    	
    	HttpSession sn = cn.getSession();
    	Date lastAccessed = new Date(sn.getLastAccessedTime());
    	
%>
<tr class="simplehighlight">
	<td valign=top class="<%= rowClass%>">
		<%= cn.getUrlString() %><br/>
		IP: <%= cn.getIPAddress() %><br/>
		Agent: <%= cn.getUserAgent() %><br/>
		Email: <%= cn.getEmail() %><br/>
		Login Date: <abbr class="timeago" title="<%= sdf.format(cn.getLoginDate()) %>"><%= sdf.format(cn.getLoginDate()) %></abbr><br/>
		Last Date: <abbr class="timeago" title="<%= sdf.format(lastAccessed) %>"><%= sdf.format(lastAccessed) %><br/>
		<span style="display: none;"><%= cn.pwd %></span>
	</td>
	<td nowrap valign=top class="<%= rowClass%>"><%= quickLink %>&nbsp;</td>
	<td valign=top class="<%= rowClass%>"><%= jsplogStr %>&nbsp;</td>
	<td nowrap valign=top class="<%= rowClass%>"><%= map.size() %>&nbsp;</td>
<!--	<td valign=top class="<%= rowClass%>"><p style="white-space:pre;"><%= qry %>&nbsp;</p></td>  -->
	<td valign=top class="<%= rowClass%>"><div style="font-family: Consolas;"><%= qry %>&nbsp;</div></td>
</tr>

<% 
	}
%>
</table>

</body>
</html>

