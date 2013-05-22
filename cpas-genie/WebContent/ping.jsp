<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.Connect" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

	boolean connected = true;
	if (cn==null || !cn.isConnected()) {
		connected = false;
	} else {
		cn.ping();
	}
	
//	System.out.println("ping " + connected + " " + (new Date()));

/*
	String email = cn.getEmail();
	if (email == null || email.equals("")) {
		String ip = cn.getIPAddress();
		if (ip==null) return;
		if (ip.equals("172.16.1.67")) email = "pauls@cpas.com";
		if (ip.equals("172.16.1.50")) email = "marcusw@cpas.com";
		
		Cookie cookie2 = new Cookie ("email", email);
		cookie2.setMaxAge(365 * 24 * 60 * 60);
		response.addCookie(cookie2);
	
		cn.setEmail(email);
	}
*/	
%>

<%=connected%> <%= new Date() %>
