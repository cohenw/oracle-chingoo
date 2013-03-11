<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	import="org.apache.commons.lang3.StringEscapeUtils" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%!

	static String syntaxString1[] = {"CREATE", "OR", "REPLACE", "BODY", "IS", "PACKAGE","FUNCTION","RETURN",
		"IN", "OUT", "CURSOR", "SELECT", "FROM", "WHERE", "AND", "TYPE", "ROWTYPE", "EXCEPTION",
		"PROCEDURE", "PRAGMA", "RESTRICT_REFERENCES", "END", "DEFAULT", "EXCEPTION_INIT", "BEGIN", "IF",
		"OPEN", "FETCH", "CLOSE", "FOR", "INTO", "INSERT", "DELETE", "VALUES", "AS", "TRUE", "FALSE",
		"THEN", "ELSE", "ELSIF", "NOT", "NULL"};

	static String syntaxString2[] = {"NUMBER", "VARCHAR", "VARCHAR2", "DATE", "BOOLEAN"};
	
	HashSet<String> syntax1 = new HashSet<String>(Arrays.asList(syntaxString1));
	HashSet<String> syntax2 = new HashSet<String>(Arrays.asList(syntaxString2));
	
	public ArrayList<Range> extractComments(String text) {

		ArrayList<Range> list = new ArrayList<Range>();

		// extract multiple line comments - ex: /* .... */
		int last = 0;
		int start = 0;
		while (true) {
			start = text.indexOf("/*", last);
			
			if (start < 0) break;
			
			int end = text.indexOf("*/", start+2);
			if (end < 0) break;
			
			end +=2;
			
			System.out.println(start + " - " + (end));
			list.add(new Range(start, end));
			last = end;
		}
		
		// extract single line comments
		last = 0;
		while (true) {
			start = text.indexOf("--", last);
			
			if (start < 0) break;
			
			int end = text.indexOf("\n", start+2);
			if (end < 0) break;
			
			end += 1;
			
			System.out.println(start + " : " + end);
			list.add(new Range(start, end));
			last = end;
		}
		
		Collections.sort(list, new Comparator<Range>(){
			 
            public int compare(Range o1, Range o2) {
        		return o1.start - o2.start;
            }
 
        });		
		return list;
	}

	public String syntax(String text) {
		StringTokenizer st = new StringTokenizer(text, " \t(),\n;%", true);
		String s = "";
		
		while (st.hasMoreTokens()) {
			String token = st.nextToken();
			
			String tmp = token.toUpperCase();
			if (syntax1.contains(tmp)) {
				s += "<span class='syntax1'>" + token + "</span>";
			} else if (syntax2.contains(tmp)) {
				s += "<span class='syntax2'>" + token + "</span>";
			} else {
				s += token;
			}
		}
		
		return s;
	}

	private static int countLines(String str){
		   String[] lines = str.split("\r\n|\r|\n");
		   return  lines.length;
		}
%>
<%
	String name = request.getParameter("name");
	String owner = request.getParameter("owner");
	
	Connect cn = (Connect) session.getAttribute("CN");
		
	String catalog = cn.getSchemaName();

	
	String q = "SELECT DISTINCT TYPE FROM USER_SOURCE WHERE NAME='" + name +"'  ORDER BY TYPE";
	if (owner != null) q = "SELECT DISTINCT TYPE FROM ALL_SOURCE WHERE OWNER='" + owner + "' AND NAME='" + name +"' ORDER BY TYPE";

	List<String[]> types = cn.query(q);
%>
<html>
<head>
	<title>Source for <%= name %></title>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 

	<script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
	<script src="script/main.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
	<script type="text/javascript" src="script/shCore.js"></script>
	<script type="text/javascript" src="script/shBrushSql.js"></script>
    <link href='css/shCore.css' rel='stylesheet' type='text/css' > 
    <link href="css/shThemeDefault.css" rel="stylesheet" type="text/css" />
    <link href="css/style.css?<%= Util.getScriptionVersion() %>" rel="stylesheet" type="text/css" />
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

<style>
.comment { 
    color: gray;
}
.syntax1 { 
#    font-weight: bold;
    color: blue;
}
.syntax2 { 
    color: brown;
}
</style>
</head>
<body>


<img src="image/icon_query.png" align="middle"/>
<%= cn.getUrlString() %>

<br/>

<h2><%= name %></h2>

<%
for (int k=0;k<types.size();k++) {
	String type = types.get(k)[1];

	String qry = "SELECT TYPE, LINE, TEXT FROM USER_SOURCE WHERE NAME='" + name +"' AND TYPE = '" + type + "' ORDER BY TYPE, LINE";
	if (owner != null) qry = "SELECT TYPE, LINE, TEXT FROM ALL_SOURCE WHERE OWNER='" + owner + "' AND NAME='" + name +"' AND TYPE = '" + type + "' ORDER BY TYPE, LINE";

	List<String[]> list = cn.query(qry);
	
	String text = "";
	for (int i=0;i<list.size();i++) {
		String ln = list.get(i)[3];
		if (!ln.endsWith("\n")) ln += "\n";
		//text += Util.escapeHtml(ln);
		text += ln;
		
	}

//	text = text.substring(0, 31) + "<span style='color: green;'>" +  text.substring(31,1052) + "</span>" + text.substring(1052);
	
	ArrayList<Range> comments = extractComments(text);
	System.out.println(comments);
	
%>

<b><a href="javascript:tDiv('div-<%=k%>')"><%= type %></a></b><br/>
<div id="div-<%=k%>" style="display: block;">
<table>
<td valign=top align=right><pre style="color:green;">
<% 
	int lines = countLines(text);
for (int i=1;i<=lines;i++)
	out.println(i);
%>
</pre>
</td>
<td>&nbsp;</td>
<td valign=top>
<pre style="font-family: courier new, courier, monospace; font-size: 12px;">
<%
int start=0;
for (Range r:comments) {
	out.print(syntax(text.substring(start, r.start)));
	out.print("<span class='comment'>");
	out.print(text.substring(r.start, r.end));
	out.print("</span>");
	start = r.end;
}
out.print(syntax(text.substring(start)));

%>
</pre>

</td>
</table>

</div>
<%
}
%>


<br/></br/>
<a href="javascript:window.close()">Close</a>

</body>
</html>

<script type="text/javascript">
  function tDiv(id) {
	  $("#"+id).toggle();
  }

</script>

