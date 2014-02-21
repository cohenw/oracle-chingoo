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
	Connect cn1 = (Connect) session.getAttribute("CN");
	Connect cn2 = (Connect) session.getAttribute("CN2");

	String clnt = request.getParameter("clnt");
	String mkey = request.getParameter("mkey");
	String newmkey = request.getParameter("newmkey");

	Connection oCon1 = cn1.getConnection();
	Connection oCon2 = cn2.getConnection();

	String res="";
	String eid = clnt + "_" + mkey;
	
	// mare sure member exists
	String sql = "SELECT count(*) FROM MEMBER WHERE CLNT='"+clnt+"' AND MKEY='"+mkey+"'";
	String cnt= cn2.queryOne(sql, false);
	if (cnt.equals("0")) {
		out.println("MKEY ["+mkey+"] not exists in DB2.");
		return;
	}

	// check if the mkey is taken
	sql = "SELECT count(*) FROM MEMBER WHERE CLNT='"+clnt+"' AND MKEY='"+newmkey+"'";
	cnt= cn1.queryOne(sql, false);
	if (!cnt.equals("0")) {
		out.println("MKEY ["+newmkey+"] exists in DB1.");
		return;
	}

//	Util.p("$$$ " + cn2.getSchemaName().toUpperCase());    
//	if (1>0) return;

	
	String cStmt = "{ call UTIL_EXTRACTDATA.getScriptGUI(?,?,?,?,?) }";
 	CallableStatement oStmt;
    int nResult = 0;
    
    StringBuffer sb = new StringBuffer();
    String script="";
    try {
    	//'CLINET_55SG','MEMBER','0001_2994','S'
    	
    	oStmt = oCon2.prepareCall(cStmt);
		oStmt.setString(1,cn2.getSchemaName().toUpperCase());
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
        
//        oCon.commit();
    } catch (SQLException e) {
        e.printStackTrace();
        out.println(e);
    }
    
	
	// reset MKEY
	script = script.replaceAll("'"+mkey +"'","'"+newmkey +"'");

	cn1.getConnection().setAutoCommit(false);
	
	String del = "--Block End\n/\n";
	String[] arr = script.split(del);
	
	boolean error = false;
	for (String stmt : arr) {
		if (stmt.startsWith("SET DEFINE O")) continue;
//		Util.p("##### " + stmt);
//		Util.p("$$$$$");
		try {
			CallableStatement call = cn1.getConnection().prepareCall(stmt);
			call.execute();
			call.close();
   	 	} catch (SQLException e) {
      	  	e.printStackTrace();
      	  	Util.p("##### " + stmt);
      	  	out.println(e);
      	  	error = true;
      	  	cn1.getConnection().rollback();
      	 	cn1.getConnection().setAutoCommit(true);
      	  	break;
    	}
	}

	cn1.getConnection().setAutoCommit(true);

	if (error) return;
	cn1.getConnection().commit();
	
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
