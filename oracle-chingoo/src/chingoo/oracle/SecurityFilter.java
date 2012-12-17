package chingoo.oracle;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.Enumeration;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class SecurityFilter implements Filter {

	String[] exceptionPages = {
			"test/", 
			"login.jsp", 
			"monitor.jsp", 
			"ping.jsp",
			"remove-cookie.jsp",
			"connect_new.jsp", 
			"connect_behind.jsp",
			"no-connection.jsp"};


	public void doFilter(ServletRequest request, ServletResponse response,
			FilterChain chain) throws IOException, ServletException {

		HttpServletResponse resp = (HttpServletResponse) response;
		HttpServletRequest req = (HttpServletRequest) request;
		HttpSession session = req.getSession();
		String servletPath = req.getServletPath();

		if (!servletPath.contains(".jsp")) {
			chain.doFilter(request, response);
			return;
		}
		
		boolean isExceptionPage = false;
		for (int i=0; i<exceptionPages.length;i++) {
			if (servletPath.contains(exceptionPages[i])) {
				isExceptionPage = true;
				break;
			}
		}

		if (isExceptionPage) {
			chain.doFilter(request, response);
			return;
		}

		Connect cn = (Connect) session.getAttribute("CN");
		if (cn==null || !cn.isConnected()) {
			String redirectPage = "login.jsp";
			if (servletPath.contains("ajax/")) {
				redirectPage = "no-connection.jsp";
				//System.out.println("ajax/no-connection.jsp");
			}
			
			resp.sendRedirect(redirectPage);
			return;
		}
		
		chain.doFilter(request, response);
		if (servletPath.startsWith("/save-history.jsp")) return;
		if (servletPath.startsWith("/ajax/auto-complete")) return;
		if (servletPath.startsWith("/ajax/search-progress.jsp")) return;

//		if (servletPath.startsWith("/ajax/qry-simple.jsp")) return;
/*		
		String qry = req.getQueryString();
		if (qry==null || qry.equals("")) {
			StringBuffer jb = new StringBuffer();
			  String line = null;
			  try {
			    BufferedReader reader = request.getReader();
			    while ((line = reader.readLine()) != null)
			      jb.append(line);
			  } catch (Exception e) { }
			
			qry = jb.toString();
		}
*/
		String qry="";
		Enumeration paramNames = request.getParameterNames();
	    while(paramNames.hasMoreElements()) {
	      String paramName = (String)paramNames.nextElement();
	      String[] paramValues = request.getParameterValues(paramName);
	      if (paramValues.length == 1) {
	        String paramValue = paramValues[0];
	        if (paramValue.length() > 0)
		    	qry += paramName + "=" + paramValue + " ";
	      } else if (paramValues.length > 1) {
  	        qry += paramName + "=";
	        for(int i=0; i<paramValues.length; i++) {
		        qry += paramValues[i] + ",";
	        }
	        qry += " ";
	      }
	    }		
		
		String ip = Util.getIpAddress(req);
		if (ip==null) ip = "";	
		
		System.out.println(servletPath + " " + qry + " " + ip); // + " " + (new java.util.Date()));
	}

	public void init(FilterConfig chain) throws ServletException {
		// TODO Auto-generated method stub

	}

	public void destroy() {
		// TODO Auto-generated method stub
		
	}

}