package spencer.genie;

import java.io.IOException;
import javax.servlet.*;

public class UTF8Filter implements Filter {
	public void destroy() {
	}

	public void doFilter(ServletRequest request, ServletResponse response,
			FilterChain chain) throws IOException, ServletException {
		request.setCharacterEncoding("UTF-8"); // encodes the charater in UTF-8
												// format.
		chain.doFilter(request, response);
	}

	public void init(FilterConfig filterConfig) throws ServletException {
	}
}

