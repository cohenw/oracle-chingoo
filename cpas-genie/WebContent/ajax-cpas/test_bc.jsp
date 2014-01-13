<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*"
	import="oracle.jdbc.OracleTypes"
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%!
public String getTestBC(Connection conn, String testvar) {
	String res="";
	if (conn != null) {

	    String cStmt = "{ ? = call " + testvar + " }";
	    CallableStatement oStmt=null;
	    int nResult = 0;
	    
	    try {
	    	oStmt = conn.prepareCall(cStmt);
			oStmt.registerOutParameter(1, OracleTypes.VARCHAR);
	        oStmt.execute();
	        
	        res = oStmt.getString(1);

	    } catch (SQLException e) {
	    	res = "ERROR " + e.getMessage();
	        e.printStackTrace();
	    } finally {
		    try {
		    	if (oStmt != null)
				    oStmt.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
	    }
	}
	
	return res;
}

%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	String key = request.getParameter("key");

	String res = getTestBC(cn.getConnection(), key);
%>

<%= res %>