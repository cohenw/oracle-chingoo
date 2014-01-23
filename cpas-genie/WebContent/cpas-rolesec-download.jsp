<%@ page language="java" import="java.util.*" import="java.sql.*"
	import="spencer.genie.*" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%><%!
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

%><%
response.setContentType("text/csv");
String disposition = "attachment; fileName=roles.csv";
response.setHeader("Content-Disposition", disposition);

	Connect cn = (Connect) session.getAttribute("CN");
	String id = request.getParameter("id");
	String process = request.getParameter("process");
	String event = request.getParameter("event");

	//String selectedRole[] = request.getParameters("selectedRole");
//	String[] selectedRole = request.getParameterValues("selectedRole");
	
	List<String[]> roles = cn.query("SELECT RNAME, DESCR FROM CPAS_ROLE ORDER BY 1", true);
	List<String[]> secs = cn.query("SELECT LABEL, CAPTION FROM SECSWITCH ORDER BY 1", true);
	List<String[]> rolesecs = cn.query("SELECT RNAME, LABEL, GRANTED FROM CPAS_ROLE_SECSWITCH ORDER BY 1, 2", 10000, true);
	
	Hashtable<String,String> ht = new Hashtable<String,String>(); 
	for (String[] rolesec: rolesecs) {
		String key = rolesec[1] + "." + rolesec[2];
		String val = rolesec[3];
		ht.put(key, val);
	}
%>CPAS Role Privileges
Database: <%= cn.getUrlString() %>

<% 
out.print(",,");
for (String[] role : roles) { 
	String roleName = role[1];
	out.print(roleName + ",");
}
out.println();

out.print(",,");
for (String[] role : roles) { 
	String roleName = role[2];
	out.print( "\"" + roleName + "\",");
}
out.println();


int rowCnt=0;
for (String[] sec : secs) { 
	rowCnt++;
	out.print(sec[1] + "," + sec[2] + ",");

	for (String[] role : roles) { 
		out.print(getRoleSec(ht, role[1],sec[1]) + ",");
	}
	out.println();
}
%>
