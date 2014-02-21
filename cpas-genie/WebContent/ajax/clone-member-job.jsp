<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	import="oracle.jdbc.OracleTypes"
	import="java.io.*"
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");

	String clnt = request.getParameter("clnt");
	String mkey = request.getParameter("mkey");
	String newmkey = request.getParameter("newmkey");

	Connection oCon = cn.getConnection();
	String res="";
	String eid = clnt + "_" + mkey;
	
	// check if the mkey is taken
	String sql = "SELECT count(*) FROM MEMBER WHERE CLNT='"+clnt+"' AND MKEY='"+newmkey+"'";
	String cnt= cn.queryOne(sql, false);
	if (!cnt.equals("0")) {
		out.println("MKEY ["+newmkey+"] exists.");
		return;
	}

    String cStmt = "{ call UTIL_EXTRACTDATA.getScriptGUI(?,?,?,?,?) }";
 	CallableStatement oStmt;
    int nResult = 0;
    
    StringBuffer sb = new StringBuffer();
    String script="";
    
    try {
    	//'CLINET_55SG','MEMBER','0001_2994','S'
    	
    	oStmt = oCon.prepareCall(cStmt);
		oStmt.setString(1,cn.getSchemaName().toUpperCase());
		oStmt.setString(2,"MEMBER");
		oStmt.setString(3,eid);
        oStmt.setString(4,"C");
		oStmt.registerOutParameter(5, OracleTypes.CLOB);
		oStmt.execute();
        
        Clob clob1 = oStmt.getClob(5);

//        StringBuilder sb = new StringBuilder();
        try {
            Reader reader = clob1.getCharacterStream();
            BufferedReader br = new BufferedReader(reader);

            String line;
            while(null != (line = br.readLine())) {
//                sb.append(line + "\n");
                //out.println(line);
                sb.append(line +"\n");
            }
            br.close();
        } catch (Exception e) {
        	out.println(e);
        }
        
        script = sb.toString();
        
        oStmt.close();
        
        oCon.commit();
    } catch (SQLException e) {
        e.printStackTrace();
        out.println(e);
    }
    
	//out.flush();
	// remove comment
	//int idx = script.indexOf("*/");
	//if (idx >0) script = script.substring(idx+2);
	
	// remove /
	//script = script.replaceAll("/\n","\n");
	
	
	// reset MKEY
	script = script.replaceAll("'"+mkey +"'","'"+newmkey +"'");

	cn.getConnection().setAutoCommit(false);
	
	String del = "--Block End\n/\n";
	String[] arr = script.split(del);
	
	boolean error = false;
	for (String stmt : arr) {
		if (stmt.startsWith("SET DEFINE O")) continue;
//		Util.p("##### " + stmt);
//		Util.p("$$$$$");
		try {
			CallableStatement call = cn.getConnection().prepareCall(stmt);
			call.execute();
			call.close();
   	 	} catch (SQLException e) {
      	  	e.printStackTrace();
      	  	Util.p("##### " + stmt);
      	  	out.println(e);
      	  	error = true;
      	  	cn.getConnection().rollback();
      	 	cn.getConnection().setAutoCommit(true);
      	  	break;
    	}
	}
/*
	try {
		CallableStatement call = cn.getConnection().prepareCall(script);
		call.execute();
		call.close();
    } catch (SQLException e) {
        e.printStackTrace();
        out.println(e);
    }
*/
//cn.getConnection().rollback();  // for test
	cn.getConnection().setAutoCommit(true);

	if (error) return;
	cn.getConnection().commit();
	
	sql = "SELECT * FROM MEMBER WHERE CLNT='"+clnt+"' AND MKEY='"+newmkey+"'";
	String id = Util.getId();
%>

<jsp:include page='qry-simple.jsp'>
	<jsp:param value="<%= sql %>" name="sql"/>
	<jsp:param value="1" name="dataLink"/>
	<jsp:param value="<%= id %>" name="id"/>
	<jsp:param value="0" name="cpas"/>
</jsp:include>

Script Size: <%= (int) script.length() / 1000 %> K
