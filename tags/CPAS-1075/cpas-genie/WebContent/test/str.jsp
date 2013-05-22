<%@ page language="java" 
	import="java.util.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%!

	String extract(String str) {
	
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
			System.out.println("*** " + res);
			start = end;
		}
	
		return res;
	}

%>

<%
	String str = "<li><a href='Javascript:loadTool(\"Search Program\")'>Search Program</a></li><li><a href='Javascript:loadTable(\"BATCH\")'>BATCH</a></li><li><a href='Javascript:globalSearch(\"batch\")'>batch</a></li>";
%>
<html>
<body>

<%= str %>
<br/><br/>
<%= extract(str) %>

</body>
</html>
