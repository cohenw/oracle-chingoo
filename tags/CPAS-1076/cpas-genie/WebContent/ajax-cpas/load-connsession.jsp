<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	String sid = request.getParameter("sid");

	String qry = "SELECT * FROM CONNSESSION_DATA WHERE SESSIONID = " + sid; 
	Query q = new Query(cn, qry, false);

	q.rewind(1000, 1);
%>
{
<%
	while (q.next()) {
		String value = "";
		String tagName = q.getValue("tagname");
		String tagType = q.getValue("tagtype");
		if (tagType.equals("C"))
			value = q.getValue("tagcvalue");
		else if (tagType.equals("N"))
			value = q.getValue("tagnvalue");
		else if (tagType.equals("D"))
			value = q.getValue("tagdvalue");
		
		if (value==null) value="";
%>
"<%=tagName%>":"<%=value%>",
<%
	}	
%>
"LAST":"-1"
}
 