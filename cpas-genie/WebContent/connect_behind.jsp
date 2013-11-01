<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%!
	public String getCookie(HttpServletRequest request, String cookieName) {
		String value = null;
		
		Cookie cookies [] = request.getCookies ();
		Cookie myCookie = null;
		if (cookies != null) {
			for (int i = 0; i < cookies.length; i++) {
				if (cookies [i].getName().equals (cookieName)) {
					myCookie = cookies[i];
					break;
				}
			}	
		}
		
		if (myCookie != null) value = myCookie.getValue();		
		return value;
	}
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");
	// if connected, redirect to home
	if (cn!=null && cn.isConnected()) {
		out.println("Connected.");
		return;
	}

	String url = request.getParameter("url");
	String username = request.getParameter("username");
	String password = request.getParameter("password");
	String email = request.getParameter("email");
	String targetSchema = request.getParameter("targetSchema");

	// CPAS User ID login 
	String cpasuserid = request.getParameter("cpasuserid");
//	Util.p("cpasuserid="+cpasuserid);
	if (cpasuserid != null && !cpasuserid.equals("")) {
		targetSchema = username;
		username = cpasuserid;
	}
//	Util.p("targetSchema="+targetSchema);
//	Util.p("username="+username);
//	Util.p("password="+password);
	
	String ipAddress = Util.getIpAddress(request);
	
	cn = new Connect(session, url, username, password, ipAddress, true, targetSchema);
	cn.setUrl(request.getRequestURL().toString());
	cn.serverUrl = Util.getURL(request);
	String ua = request.getHeader("user-agent");
	cn.setUserAgent(ua);
    System.out.println ("User Agent: " + ua);
	
	if (cn.isConnected()) {
		// you're connected.
		// assign the Connect object to session
		//session.setAttribute("CN", cn);
		GenieManager.getInstance().addSession(cn);
	
		// get cookie
		String oldUrls = getCookie(request, "url");
		
		// keep only 20 urls
		StringTokenizer st = new StringTokenizer(oldUrls, " ");
		int i = 0;
		String tmp = "";
		while (st.hasMoreTokens()) {
			i++;
			tmp += st.nextToken() + " ";
			if (i>=20) break;
		}
		oldUrls = tmp;
		
		// set Cookie
		String newUrl = username + "@" + url;
//Util.p("newUrl=" + newUrl);
		if (targetSchema != null && !targetSchema.equals(""))
			newUrl = targetSchema + "@" + url;
//Util.p("newUrl2=" + newUrl);
		String newUrls = "";
		
		if (oldUrls != null) {
			oldUrls = oldUrls.replace(newUrl, "").trim();
			newUrls = newUrl + " " + oldUrls;
		} else
			newUrls = newUrl;
		
 		
		Cookie cookie = new Cookie ("url", newUrls);
		cookie.setMaxAge(365 * 24 * 60 * 60);
//		cookie.setPath("/");
		response.addCookie(cookie);

		if (email != null && email.length() > 2 && email.contains("@")) {
			Cookie cookie2 = new Cookie ("email", email);
			cookie2.setMaxAge(365 * 24 * 60 * 60);
//			cookie.setPath("/");
			response.addCookie(cookie2);
			
			cn.setEmail(email);
			System.out.println("Email " + email + " " + ipAddress);
		}
		
		// redirect to homepage
		out.println("Connected.");
//		System.out.println("Connected.");
//		response.sendRedirect("ajax/connected.jsp");
		return;
	}
%>

	<b>Sorry, Genie could not connect to the database.</b>
	Message: <%= cn.getMessage() %>
	<br/><br/>
	
	<a href="javascript:history.back()">Try Again</a>
