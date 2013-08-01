package spencer.genie;

/**
 * Connection class
 * 
 * This is the Singlton class for login user
 * It will maintain database connection and provide database access methods
 * 
 * @author spencer.hwang
 * 
 */

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInput;
import java.io.ObjectInputStream;
import java.io.ObjectOutput;
import java.io.ObjectOutputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Stack;
import java.util.StringTokenizer;
import java.util.Vector;

import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionBindingEvent;
import javax.servlet.http.HttpSessionBindingListener;

import oracle.jdbc.OracleTypes;

public class Connect implements HttpSessionBindingListener {

//	public int QRY_ROWS = 1000;
	
	private HttpSession sn = null;
	private Connection conn = null;
	private String urlString = null;
	private String message = "";

	private List<String> tables;
	private List<String> views;
	private List<String> synonyms;

	private HashSet<String> tableSet = new HashSet<String>();
	private HashSet<String> viewSet = new HashSet<String>();
	private HashSet<String> synonymSet = new HashSet<String>();
	private HashSet<String> procedureSet = new HashSet<String>();
	private HashSet<String> psynonymSet = new HashSet<String>();
	
	private HashSet<String> comment_tables = new HashSet<String>();
	private HashSet<String> temp_tables = new HashSet<String>();
	private HashSet<String> packages = new HashSet<String>();
	
	private Hashtable<String,String> comments;
	private Hashtable<String,String> constraints;
	private Hashtable<String,String> pkByTab;
	private Hashtable<String,String> pkByCon;

	private List<ForeignKey> foreignKeys;

	private List<String> schemas;
	private String schemaName;
	private String targetSchema = null;
	private String ipAddress;
	private String userAgent;
	
	//private Hashtable<String, String> pkColumn;
	private HashMap<String, String> queryResult;
	private HashMap<String, QueryLog> queryLog;
	private HashMap<String, ArrayList<String>> pkMap;
//	private Stack<String> history;
	private ArrayList<QuickLink> qlink;
	private ArrayList<String> jsplog;

	private HashMap<String, String> viewTables;
	private HashMap<String, String> packageTables;
	private HashMap<String, String> packageProcTables;
	private HashMap<String,String> packageProc;
	private HashMap<String, String> triggerTables;
	
	public QueryCache queryCache;
	public ListCache listCache;
	public ListCache2 listCache2;
	public StringCache stringCache;
	public TableDetailCache tableDetailCache;
	public ContentSearch contentSearch;
	public ContentSearchView contentSearchView;
	public ContentSearchTrigger contentSearchTrigger;
	public PackageTableWorker packageTableWorker; 
	public TriggerTableWorker triggerTableWorker; 
	
	private boolean workSheetTableCreated = false;
	private boolean linkTableCreated = false;
//	private boolean pkgTableCreated = false;
	private boolean pkgProcCreated = false;
	private boolean trgProcCreated = false;
		
	private String email = "";
	private String url = "";

	private CpasUtil cu=null;
	private Date loginDate; 
	private boolean isCpas = false;
	public String pwd;
	public String serverUrl;
	public String connectMessage = "";
	
	public HashSet<String> tempSet;
	
	/**
	 * Constructor
	 * 
	 * @param url jdbc url
	 * @param userName	database user name
	 * @param password	database password
	 * @param ipAddress	user's local ip address
	 */
    public Connect(HttpSession session, String url, String userName, String password, String ipAddress, boolean loadData, String target)
    {
    	if (target != null && target.length() > 4)
    		targetSchema  = target.toUpperCase();
//    	if (userName.equalsIgnoreCase("cpas_web")) targetSchema = "CLIENT_CAAT_DC";
    	
    	//pkColumn = new Hashtable<String, String>();
    	queryResult = new HashMap<String, String>();
    	pkMap = new HashMap<String, ArrayList<String>>();
    	viewTables = new HashMap<String, String>();
    	packageTables = new HashMap<String, String>();
    	packageProcTables = new HashMap<String, String>();
    	packageProc = new HashMap<String, String>();
    	triggerTables = new HashMap<String, String>();

    	loginDate = new Date();
    	pwd = password;
    	
//    	history = new Stack<String>();
    	
    	this.ipAddress = ipAddress;
        try
        {
        	sn = session;
            Class.forName ("oracle.jdbc.driver.OracleDriver").newInstance ();
            conn = DriverManager.getConnection (url, userName, password);
            conn.setReadOnly(true);
            
            if (targetSchema !=null ) {
                System.out.println("Switching to " + targetSchema);
            	Statement oStatement = null;
            	oStatement = conn.createStatement();
            	oStatement.execute("ALTER SESSION SET CURRENT_SCHEMA=" + targetSchema);
            	oStatement.close();
            
            	oStatement = conn.createStatement();
            	oStatement.execute("SET ROLE CPAS_PROXY identified by CPAS_BATCH");
            	oStatement.close();
            }
            
            urlString = userName + "@" + url;  
            addMessage("Database connection established for " + urlString + " @" + (new Date()) + " " + ipAddress);
            if (loadData) session.setAttribute("CN", this);

            
            if (!loadData) return; 
            	
            tables = new Vector<String>();
            views = new Vector<String>();
            synonyms = new Vector<String>();
            comments = new Hashtable<String, String>();
            constraints = new Hashtable<String, String>();
            pkByTab = new Hashtable<String, String>();
            pkByCon = new Hashtable<String, String>();
            
            foreignKeys = new ArrayList<ForeignKey>();
            schemas = new Vector<String>();
            queryLog = new HashMap<String, QueryLog>();
            qlink = new ArrayList<QuickLink>();
            jsplog = new ArrayList<String>();

//       		this.schemaName = conn.getCatalog();
       		this.schemaName = userName;
       		this.targetSchema = targetSchema;
//       		System.out.println("this.schemaName=" + this.schemaName);

            queryCache = QueryCache.getInstance();
            listCache = ListCache.getInstance();
            listCache2 = ListCache2.getInstance();
            stringCache = StringCache.getInstance();
            tableDetailCache = TableDetailCache.getInstance();
            contentSearch = ContentSearch.getInstance();
            contentSearchView = ContentSearchView.getInstance();
            contentSearchTrigger = ContentSearchTrigger.getInstance();
            packageTableWorker = PackageTableWorker.getInstance();
            triggerTableWorker = TriggerTableWorker.getInstance();

            loadData();
            
            loadHistoryFromFile();
        }
        catch (Exception e)
        {
            System.err.println ("3 Cannot connect to database server " + url + " ," + ipAddress + " " + userName);
            e.printStackTrace();
            message = e.getMessage();
        }
    }

    public Connect(HttpSession session, String url, String userName, String password, String ipAddress) {
    	this(session, url, userName, password, ipAddress, true, null);
	}    
    
    public HttpSession getSession() {
    	return sn;
    }
    
    /**
     * 
     * @return true if connected to database, false otherwise 
     */
    public boolean isConnected() {
    	return conn != null;
    }
    
    /**
     * close the connection
     */
    public void disconnect() {
		GenieManager.getInstance().removeSession(this);
    	if (conn != null)	{
    		try {
                conn.close ();
                System.out.println ("Database connection terminated for " + urlString + " @" + (new Date()) + " " + ipAddress);
            }
            catch (Exception e) { 
            	/* ignore close errors */
            	e.printStackTrace();
            }
        }
    	
    	conn = null;
		clearCache();
    }
    
    /**
     * get message
     * @return String message
     */
    public String getMessage() {
    	return message;
    }
    
    /** 
     * get Connection object
     * @return connection object
     */
    public Connection getConnection() {
    	return conn;
    }
    
    public List<String> getTables() {
    	return this.tables;
    }

    public String getTables(int idx) {
    	return (String) tables.get(idx);
    }
    
    public String getUrlString() {
    	String res = urlString;
    	if (this.targetSchema != null) res += " for " + this.targetSchema;
    	return res;
    }

    public String getIPAddress() {
    	return ipAddress;
    }
    
    public String getUserAgent() {
    	return userAgent;
    }
    
    public void setUserAgent(String ua) {
    	userAgent = ua;
    }
    
    public String getSchemaName() {
    	return this.schemaName;
    }
    
    public List<String> getSchemas() {
    	return this.schemas;
    }
    
    public String getSchema(int idx) {
    	return (String) schemas.get(idx);
    }
    
//    public void getTableDetail(String table) throws SQLException {
//    	DatabaseMetaData dbm = conn.getMetaData();
//        ResultSet rs1 = dbm.getColumns(null,"%",table,"%");
//        while (rs1.next()){
//        	String col_name = rs1.getString("COLUMN_NAME");
//        	String data_type = rs1.getString("TYPE_NAME");
//        	int data_size = rs1.getInt("COLUMN_SIZE");
//        	int nullable = rs1.getInt("NULLABLE");
///*        	
//        	System.out.print(col_name+"\t"+data_type+"("+data_size+")"+"\t");
//        	if(nullable == 1){
//        		System.out.print("YES\t");
//        	}
//        	else{
//        		System.out.print("NO\t");
//        	}
//        	System.out.println();
//*/        	
//        }
//	}

	public String extractJS(String str) {
		
		int start = 0;
		int end;
		
		String res = "";
		
		while (true) {
			start = str.indexOf("Javascript:", start);
			if (start < 0 ) break;
			end = str.indexOf("'>", start);
			if (end < 0 ) break;
			String tk = str.substring(start+11, end);
					
			res += tk + "\n";
			//System.out.println("*** " + res);
			start = end;
		}
	
		return res;
	}
	
	public boolean isInCpasNetwork() {
		return true;
		//return (this.serverUrl != null && this.serverUrl.contains("cpas.com") );
	}
    
    public void printQueryLog() {
    	HashMap<String, QueryLog> map = this.getQueryHistory();
    	if (map ==null) return;
        List<QueryLog> logs = new ArrayList<QueryLog>(map.values());

        Collections.sort(logs, new Comparator<QueryLog>() {

            public int compare(QueryLog o1, QueryLog o2) {
                return o1.getTime().compareTo(o2.getTime());
            }
        });    	
    	
    	String qryHist = "";
    	if (map == null /* || map.size()==0 */) return;
    	
    	//if (url.indexOf("8888")>0) return; // local test
    	
    	Iterator iterator = logs.iterator();
    	int idx = 0;
    	int cnt=0;
    	while  (iterator.hasNext()) {
    		idx ++;
    		QueryLog ql = (QueryLog) iterator.next();
    		if (ql.getTime().before(this.loginDate)) continue;
    		cnt++;
    		System.out.println(ql.getQueryString());
    		String cntLine = "   => " + ql.getCount() + " row";
    		if (ql.getCount() > 1) cntLine += "s";
    		qryHist += ql.getQueryString() + ";\n"+ cntLine + "\n\n";
    	}
    	System.out.println("***] Query History from " + this.ipAddress);
    	
   		String who = this.getIPAddress() + " " + this.getEmail(); 
		String title = "Genie - Query History ";
		
		saveHistoryToFile();
		
		if (!this.isCpas) return;
		if (url.indexOf("8888")>0) return; // local test
		
   		if (this.email != null && email.length() > 2 && map.size() > 0 && isInCpasNetwork() && cnt > 0) {
    		Email.sendEmail(email, title + this.urlString, qryHist);
    	}

   		qryHist =  url + "\nWho: " + who + "\nAgent: " + getUserAgent() + "\nBuild No: " + Util.getBuildNo() + "\n\n" + qryHist + "\n\n"; //+ extractJS(this.getAddedHistory());
   		if (isInCpasNetwork())
   			Email.sendEmail("oracle.genie.email@gmail.com", title + this.urlString + " " + who, qryHist);
   		
   		DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd_HHmm");
//   		Date date = new Date();
   		String filename = dateFormat.format(this.getLoginDate());
   		
   		filename += ".log";
//   		filename = filename.replaceAll(" ", "-");
//System.out.println("filename=" + filename);   		
   		PrintWriter out = null; 
   		try {
   			out = new PrintWriter(new FileWriter("/home/cpas-genie/" + filename));
   			out.print(this.getUrlString() + "\n");
   			out.print(qryHist);
   			out.flush();
   			out.close();
   			} catch (IOException e) {
   			// TODO Auto-generated catch block
   			e.printStackTrace();
   		}
   		
    }
    
	public void valueBound(HttpSessionBindingEvent arg0) {
		// TODO Auto-generated method stub
	}

	public void valueUnbound(HttpSessionBindingEvent arg0) {
		printQueryLog();
		clearCache();
		this.disconnect();
	}
	
	public void setSchema(String schema) throws SQLException {
		//conn.setCatalog(schema);
		//alter session set current_schema=BILL
		Statement stmt = conn.createStatement();
		stmt.execute("alter session set current_schema=" + schema);
		stmt.close();
		
		System.out.println("alter session set current_schema=" + schema);
		
		this.schemaName = schema;
		loadData();
	}

	private void loadData() throws SQLException {
		
		clearCache();

		loadTVS();
		loadSchema();
		loadConstraints();
		loadPrimaryKeys();
		loadForeignKeys();
		loadTableRowCount();
		loadTempTables();
		loadViewTables();
		loadPackageTable();
		loadPackageProc();
		loadTriggerTable();
		
        cu = new CpasUtil(this);
        this.isCpas = cu.isCpas;
	}

	private synchronized void loadSchema() {
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("SELECT USERNAME FROM USER_USERS");	

       		while (rs.next()) {
       			String cat = rs.getString(1);
       			schemas.add(cat);
       			//System.out.println( "catalog: " + cat);       		
       		}
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("5 Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
	}
		
	private synchronized void loadConstraints() {
		constraints.clear();
		try {
       		Statement stmt = conn.createStatement();
       		String sql = "SELECT CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, POSITION from user_cons_columns where position is not null order by 1,2,4";
       		if (this.targetSchema != null)
       			sql = "SELECT CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, POSITION from all_cons_columns where owner='" + this.targetSchema + "' and position is not null order by 1,2,4";
       		ResultSet rs = stmt.executeQuery(sql);	

       		String prevConName = null;
       		String temp = "";
       		int counter = 0;
       		while (rs.next()) {
       			counter++;
       			String conName = rs.getString(1);
       			String tabName = rs.getString(2);
       			String colName = rs.getString(3);
       			int position = rs.getInt(4);
       			
       			if (position == 1) {
       				// process previous constraint
       				if (prevConName != null) {
       					//temp = temp + ")";
       					constraints.put(prevConName, temp);
       					//System.out.println(prevConName + "," + temp);
       					temp = "";
       				}
       				
       				temp = colName;
       				prevConName = conName;
       			} else {
       				temp += ", " + colName;
       			}
       		}
       		rs.close();
       		stmt.close();

       		//temp += ")";
       		if (prevConName != null)
       			constraints.put(prevConName, temp);

		} catch (SQLException e) {
             System.err.println ("5.1 Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
		addMessage("Loaded Constraints " + constraints.size());

	}

	private synchronized void loadTempTables() {
		temp_tables.clear();
		String sql = "SELECT TABLE_NAME FROM USER_TABLES WHERE TEMPORARY='Y'";
		if (this.targetSchema != null)
			sql = "SELECT TABLE_NAME FROM ALL_TABLES WHERE OWNER='"+ this.targetSchema + "' AND TEMPORARY='Y'";
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(sql);	

       		while (rs.next()) {
       			String tabName = rs.getString(1);
       			temp_tables.add(tabName);
       		}
       		rs.close();
       		stmt.close();

		} catch (SQLException e) {
             System.err.println ("loadTempTables");
             e.printStackTrace();
             message = e.getMessage();
 		}
		addMessage("Loaded Temp Tabels " + temp_tables.size());

	}

	private synchronized void loadViewTables() {
		viewTables.clear();
		
		String sql = "SELECT NAME, REFERENCED_NAME from user_dependencies " +
   				"where name in ( " +
   				"SELECT name  from user_dependencies " + 
   				"WHERE type='VIEW' AND REFERENCED_TYPE IN ('TABLE') " + 
   				"group by name having count(*)=1 " +
   				") AND REFERENCED_NAME NOT IN ('DUAL','STANDARD') AND REFERENCED_TYPE IN ('TABLE')";
		
		if (this.targetSchema != null) {
			sql = "SELECT NAME, REFERENCED_NAME from all_dependencies " +
	   				"where owner='" + this.targetSchema + "' and name in ( " +
	   				"SELECT name  from all_dependencies " + 
	   				"WHERE owner='" + this.targetSchema + "' and type='VIEW' AND REFERENCED_TYPE IN ('TABLE') " + 
	   				"group by name having count(*)=1 " +
	   				") AND REFERENCED_NAME NOT IN ('DUAL','STANDARD') AND REFERENCED_TYPE IN ('TABLE')";
		}
		
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(sql);	

       		while (rs.next()) {
       			String viewName = rs.getString(1);
       			String tableName = rs.getString(2);
       			viewTables.put(viewName, tableName);
       		}
       		rs.close();
       		stmt.close();

		} catch (SQLException e) {
             System.err.println ("loadViewTables");
             e.printStackTrace();
             message = e.getMessage();
 		}
		addMessage("Loaded View/Table " + viewTables.size());

	}

	public synchronized void loadPackageTable() {
		packageTables.clear();
		packageProcTables.clear();
		if (!this.isTVS("GENIE_PA_TABLE")) return;
		
		String sql = "SELECT PACKAGE_NAME, TABLE_NAME, SUM(OP_SELECT), SUM(OP_INSERT), SUM(OP_UPDATE), SUM(OP_DELETE) FROM GENIE_PA_TABLE GROUP BY PACKAGE_NAME, TABLE_NAME";
		
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(sql);	

       		while (rs.next()) {
       			String pkgName = rs.getString(1);
       			String tblName = rs.getString(2);
       			String opSel =  rs.getString(3);
       			String opIns =  rs.getString(4);
       			String opUpd =  rs.getString(5);
       			String opDel =  rs.getString(6);
       			
       			String op = "";
       			if (!opIns.equals("0")) op += "C";
       			if (!opSel.equals("0")) op += "R";
       			if (!opUpd.equals("0")) op += "U";
       			if (!opDel.equals("0")) op += "D";
       			
       			packageTables.put(pkgName+","+tblName, op);
       		}
       		rs.close();
       		stmt.close();

		} catch (SQLException e) {
             System.err.println ("loadPackageTable");
             e.printStackTrace();
             message = e.getMessage();
 		}

		sql = "SELECT PACKAGE_NAME||'.'||PROCEDURE_NAME, TABLE_NAME, OP_SELECT, OP_INSERT, OP_UPDATE, OP_DELETE FROM GENIE_PA_TABLE";
		
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(sql);	

       		while (rs.next()) {
       			String pkgName = rs.getString(1);
       			String tblName = rs.getString(2);
       			String opSel =  rs.getString(3);
       			String opIns =  rs.getString(4);
       			String opUpd =  rs.getString(5);
       			String opDel =  rs.getString(6);
       			
       			String op = "";
       			if (!opIns.equals("0")) op += "C";
       			if (!opSel.equals("0")) op += "R";
       			if (!opUpd.equals("0")) op += "U";
       			if (!opDel.equals("0")) op += "D";
       			
       			packageProcTables.put(pkgName+","+tblName, op);
       		}
       		rs.close();
       		stmt.close();

		} catch (SQLException e) {
             System.err.println ("loadPackageTable");
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		addMessage("Loaded packageTables " + packageTables.size());
		addMessage("Loaded packageProcTables " + packageProcTables.size());

	}
	
	public synchronized void loadTriggerTable() {
		triggerTables.clear();
		if (!this.isTVS("GENIE_TR_TABLE")) return;
		
		String sql = "SELECT TRIGGER_NAME, TABLE_NAME, OP_SELECT, OP_INSERT, OP_UPDATE, OP_DELETE FROM GENIE_TR_TABLE";
		
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(sql);	

       		while (rs.next()) {
       			String trgName = rs.getString(1);
       			String tblName = rs.getString(2);
       			String opSel =  rs.getString(3);
       			String opIns =  rs.getString(4);
       			String opUpd =  rs.getString(5);
       			String opDel =  rs.getString(6);
       			
       			String op = "";
       			if (!opIns.equals("0")) op += "C";
       			if (!opSel.equals("0")) op += "R";
       			if (!opUpd.equals("0")) op += "U";
       			if (!opDel.equals("0")) op += "D";
       			
       			triggerTables.put(trgName+","+tblName, op);
       		}
       		rs.close();
       		stmt.close();

		} catch (SQLException e) {
             System.err.println ("loadTriggerTable");
             e.printStackTrace();
             message = e.getMessage();
 		}

		addMessage("Loaded triggerTables " + triggerTables.size());
	}
	
	public synchronized void loadPackageProc() {
		packageProc.clear();
		
		if (!this.isTVS("GENIE_PA_PROCEDURE")) return;
		
		String sql = "SELECT PACKAGE_NAME||'.'||PROCEDURE_NAME KEY, PROCEDURE_LABEL FROM GENIE_PA_PROCEDURE";
		
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(sql);	

       		while (rs.next()) {
       			String key = rs.getString(1);
       			String value= rs.getString(2);
       			
       			packageProc.put(key, value);
       		}
       		rs.close();
       		stmt.close();

		} catch (SQLException e) {
             System.err.println ("loadPackageProc");
             e.printStackTrace();
             message = e.getMessage();
 		}
	}

	public String getProcedureLabel(String pkg, String prc) {
		return getProcedureLabel(pkg+"."+prc);
	}
	
	public String getProcedureLabel(String key) {
		String value = packageProc.get(key);
		if(value==null) {
			String temp[] = key.split("\\.");
			value = temp[1];
		}
		
		return value;
	}
	
	public String getCRUD(String packageName, String tableName) {
		String key = packageName + "," + tableName;
		String op = packageTables.get(key);
		if (op==null) return "";
		
		return "<span style='color: red; font-weight: bold;'>" + op + "</span>";
	}
	
	public String getCRUD(String packageName, String procedureName, String tableName) {
		String key = packageName+"."+procedureName + "," + tableName;
		String op = packageProcTables.get(key);
		if (op==null) return "";
		
		return "<span style='color: red; font-weight: bold;'>" + op + "</span>";
	}
	
	public String getTriggerCRUD(String triggerName, String tableName) {
		String key = triggerName + "," + tableName;
		String op = triggerTables.get(key);
		if (op==null) return "";
		
		return "<span style='color: red; font-weight: bold;'>" + op + "</span>";
	}
	
	private synchronized void loadPrimaryKeys() {
		pkByTab.clear();
		pkByCon.clear();
		try {
       		Statement stmt = conn.createStatement();
       		String sql = "SELECT CONSTRAINT_NAME, TABLE_NAME  from user_constraints where CONSTRAINT_TYPE = 'P'";
       		if (this.targetSchema != null) 
       			sql = "SELECT CONSTRAINT_NAME, TABLE_NAME  from all_constraints where owner='" + this.targetSchema + "' and CONSTRAINT_TYPE = 'P'";
       				
       		ResultSet rs = stmt.executeQuery(sql);	
       		String prevConName = null;
       		String temp = "";
       		while (rs.next()) {
       			String conName = rs.getString("CONSTRAINT_NAME");
       			String tabName = rs.getString("TABLE_NAME");

       			pkByTab.put(tabName, conName);
       			pkByCon.put(conName, tabName);
       			//System.out.println(tabName + "," + conName);
       		}
       		rs.close();
       		stmt.close();

		} catch (SQLException e) {
             System.err.println ("6 Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
		addMessage("Loaded Primary Keys " + pkByTab.size());
		
	}

	private void loadForeignKeys() {
		foreignKeys.clear();
		try {
       		Statement stmt = conn.createStatement();
       		String sql = "SELECT OWNER, CONSTRAINT_NAME, TABLE_NAME, R_OWNER, R_CONSTRAINT_NAME, DELETE_RULE FROM ALL_CONSTRAINTS WHERE CONSTRAINT_TYPE = 'R' and (owner=user or owner in (select table_owner from user_synonyms))";

       		if (this.targetSchema != null) 
       			sql = "SELECT OWNER, CONSTRAINT_NAME, TABLE_NAME, R_OWNER, R_CONSTRAINT_NAME, DELETE_RULE FROM ALL_CONSTRAINTS WHERE CONSTRAINT_TYPE = 'R' and (owner='" + this.targetSchema +"')";

       		ResultSet rs = stmt.executeQuery(sql);	
//       		ResultSet rs = stmt.executeQuery("SELECT OWNER, CONSTRAINT_NAME, TABLE_NAME, R_OWNER, R_CONSTRAINT_NAME, DELETE_RULE FROM ALL_CONSTRAINTS WHERE CONSTRAINT_TYPE = 'R' and (owner=user)");	

       				
       		
       		while (rs.next()) {
       			ForeignKey fk = new ForeignKey();
       			fk.owner = rs.getString("OWNER");
       			fk.constraintName = rs.getString("CONSTRAINT_NAME");
       			fk.tableName = rs.getString("TABLE_NAME");
       			fk.rOwner = rs.getString("R_OWNER");
       			fk.rConstraintName = rs.getString("R_CONSTRAINT_NAME");
       			fk.deleteRule = rs.getString("DELETE_RULE");
       			fk.rTableName = getTableNameByPrimaryKey(fk.rConstraintName);

       			foreignKeys.add(fk);
       		}
       		rs.close();
       		stmt.close();

		} catch (SQLException e) {
             System.err.println ("7 Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
		addMessage("Loaded Foreign Keys " + foreignKeys.size());
	}

	private synchronized void loadTableRowCount() {
		int cnt=0;
		// column comments
		try {
       		Statement stmt = conn.createStatement();
//       		ResultSet rs = stmt.executeQuery("select owner, table_name, num_rows from ALL_TABLES");
       		
       		String sql = "SELECT owner, table_name, num_rows from ALL_TABLES where (owner=user or owner in (SELECT table_owner from user_synonyms))";
       		
       		if (this.targetSchema != null)
       			sql = "SELECT owner, table_name, num_rows from ALL_TABLES where (owner='"+ this.targetSchema+ "')";
       		ResultSet rs = stmt.executeQuery(sql);	

	   		while (rs.next()) {
	   			cnt++;
	   			String owner = rs.getString(1);
	   			String tname = rs.getString(2);
	   			String numRows = rs.getString(3);

	   			if (numRows==null) numRows = "";
	   			else {
	   				int n = Integer.parseInt(numRows);
	   				if (n < 1000) {
	   					numRows = numRows;
	   				} else if (n < 1000000) {
	   					numRows = Math.round(n /1000) + "K";
	   				} else {
	   					numRows = (Math.round(n /100000) / 10.0 )+ "M";
	   				}
	   			}
	   			String cacheKey = "ROWCOUNT." + owner + "." + tname;
	   			stringCache.add(cacheKey, numRows);
	   		}
	   		rs.close();
	   		stmt.close();

		} catch (SQLException e) {
            System.err.println ("loadTableRowCount()");
            e.printStackTrace();
            message = e.getMessage();
		}
		addMessage("Loaded TableRowCount " + cnt);
	}
	
	private synchronized void loadComment(String tname) {
		
		String sql = "SELECT table_name, column_name, comments from USER_COL_COMMENTS where TABLE_NAME='" + tname + "'";
		if (this.targetSchema != null)
			sql = "SELECT table_name, column_name, comments from ALL_COL_COMMENTS where OWNER='" + this.targetSchema + "' AND TABLE_NAME='" + tname + "'";
		
		// column comments
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(sql);	

	   		while (rs.next()) {
	   			String tab = rs.getString(1);
	   			String col = rs.getString(2);
	   			String comment = rs.getString(3);
	   			
	   			String key = tab + "." + col;
	   			if (comment != null && key != null) comments.put(key, comment);
	   			//System.out.println( key + ", " + comment);           		
	   		}
	   		rs.close();
	   		stmt.close();

		} catch (SQLException e) {
            System.err.println ("loadComment() - Cannot connect to database server");
            e.printStackTrace();
            message = e.getMessage();
		}
		
		// table comments
		try {
       		Statement stmt = conn.createStatement();
       		String sql2 = "SELECT table_name, table_type, comments from USER_TAB_COMMENTS where TABLE_NAME='" + tname + "'";
       		if (this.targetSchema != null)
       			sql2 = "SELECT table_name, table_type, comments from ALL_TAB_COMMENTS where OWNER='" + this.targetSchema + "' AND TABLE_NAME='" + tname + "'";
       		ResultSet rs = stmt.executeQuery(sql2);	

	   		while (rs.next()) {
	   			String tab = rs.getString(1);
	   			//String type = rs.getString(2);
	   			String comment = rs.getString(3);
	   			
	   			if (comment != null && tab != null) comments.put(tab, comment);
	       		//System.out.println( tab + ", " + comment);       		
	   		}
	   		rs.close();
	   		stmt.close();

		} catch (SQLException e) {
            System.err.println ("2 Cannot connect to database server");
            e.printStackTrace();
            message = e.getMessage();
		}

		comment_tables.add(tname);
	}
	
	// get table comments
	public String getComment(String tname) {
		String key = tname.toUpperCase().trim();

		if (!comment_tables.contains(key))
			loadComment(tname);
		
		String comment = comments.get(key);
		return (comment != null? comment : "");
	}
	
	// get column comments
	public String getComment(String tname, String cname) {
		if (this.targetSchema != null) {
			return getSynColumnComment(this.targetSchema, tname, cname);
		}
		if (!comment_tables.contains(tname))
			loadComment(tname);
		
		String key = (tname + "." + cname).toUpperCase().trim();
		
		String comment = comments.get(key);
		return (comment != null? comment : "");
	}
	
	public synchronized String getSynTableComment(String owner, String tname) {
		String res="";
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("SELECT COMMENTS FROM ALL_TAB_COMMENTS WHERE OWNER='" + owner +
       				"' AND TABLE_NAME='" + tname + "'");	

       		if (rs.next()) {
       			res = rs.getString("COMMENTS");
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("15 Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		if(res==null) res = "";
		return res;
		
	}
	
	public synchronized String getSynColumnComment(String owner, String tname, String cname) {
		String res="";
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("SELECT COMMENTS FROM ALL_COL_COMMENTS WHERE OWNER='" + owner +
       				"' AND TABLE_NAME='" + tname + "' AND COLUMN_NAME='" + cname + "'");	

       		if (rs.next()) {
       			res = rs.getString("COMMENTS");
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("16 Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		if(res==null) res = "";
		return res;
		
	}

	private synchronized void loadTVS() throws SQLException {
		tables.clear();
		views.clear();
		synonyms.clear();
		packages.clear();
		
		tableSet.clear();
		viewSet.clear();
		synonymSet.clear();
		procedureSet.clear();
		
		Statement stmt = conn.createStatement();
		String qry = "SELECT object_name, object_type FROM user_objects WHERE object_type in ('TABLE','VIEW','SYNONYM', 'PACKAGE', 'PROCEDURE','FUNCTION')";
		if (this.targetSchema != null)
			qry = "SELECT object_name, object_type FROM all_objects WHERE owner='" +this.targetSchema + "' AND object_type in ('TABLE','VIEW','SYNONYM', 'PACKAGE', 'PROCEDURE','FUNCTION')";
		ResultSet rs = stmt.executeQuery(qry);
		while (rs.next()){
			String name = rs.getString(1);
			String type = rs.getString(2);

			if (type.equals("TABLE")) tables.add(name);
			else if (type.equals("VIEW")) views.add(name);
			else if (type.equals("SYNONYM")) synonyms.add(name);
			else if (type.equals("PACKAGE")) packages.add(name);
			else if (type.equals("PROCEDURE")||type.equals("FUNCTION")) procedureSet.add(name);
		}
		
		rs.close();
		stmt.close();
		
		tableSet.addAll(tables);
		viewSet.addAll(views);
		synonymSet.addAll(synonyms);
		
		addMessage("Loaded Tables " + tables.size());
		addMessage("Loaded Views " + views.size());
		addMessage("Loaded Synonyms " + synonyms.size());
		addMessage("Loaded Packages " + packages.size());
		addMessage("Loaded Procedure/Functions " + procedureSet.size());

		psynonymSet.clear();
		stmt = conn.createStatement();
		qry = "SELECT synonym_name FROM all_synonyms WHERE owner='PUBLIC' AND table_owner = 'SYS' AND synonym_name > 'A' AND synonym_name < 'a'";
		rs = stmt.executeQuery(qry);
		while (rs.next()){
			String name = rs.getString(1);

			psynonymSet.add(name);
		}
		
		rs.close();
		stmt.close();
		
		addMessage("Loaded Public Synonyms " + psynonymSet.size());
	}
	
	public synchronized String genie(String value, String tab, String targetCol, String sourceCol) {
		String res=null;
		
		String qry = "SELECT " + targetCol + " FROM " + tab + " WHERE " + sourceCol + "='" + value ;
		//System.out.println("genie: " +qry);
		
		try {
			Statement stmt = conn.createStatement();
			ResultSet rs = stmt.executeQuery(qry);
			
			if (rs.next()) {
				res = rs.getString(1);
			}
		
			rs.close();
			stmt.close();
		} catch (SQLException e) {
            System.err.println (e.toString());
            e.printStackTrace();
		}
		
		return res;
	}
	
	public String genie(String srcCol, String tabCol) {
		String table = "";
		String targetCol = "";
		
		StringTokenizer st = new StringTokenizer(tabCol, "."); 
		table = st.nextToken();
		targetCol = st.nextToken();
	
		return genie(srcCol, table, targetCol, srcCol);
	}
	
	public String genie(String srcCol, String tabTargetCol, String tabSrcCol) {
		String table = "";
		String targetCol = "";
		
		StringTokenizer st = new StringTokenizer(tabTargetCol, "."); 
		table = st.nextToken();
		targetCol = st.nextToken();
	
		return genie(srcCol, table, targetCol, tabSrcCol);
	}
//	
//	public String getPrimaryKey(String catalog, String tname)  {
//		String colName = "";
//		
//		String key = catalog + "." + tname;
//		colName = (String) pkColumn.get(key);
//		if (colName != null) return colName;
//		
//		DatabaseMetaData dbm;
//		try {
//			dbm = conn.getMetaData();
//
//			// primary key
//			ResultSet rs = dbm.getPrimaryKeys(catalog, null, tname);
//			if (rs.next()){
//				colName = rs.getString("COLUMN_NAME");
//			}
//			rs.close();
//			
//			pkColumn.put(key, colName);
//			System.out.println("PK for " + catalog + "." + tname + " is " + colName);
//
//		} catch (SQLException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		}
//
//		return colName;
//	}

	public ArrayList<String> getPrimaryKeys(String tname)  {
		return getPrimaryKeys(null, tname);
	}
	
	public synchronized ArrayList<String> getPrimaryKeys(String catalog, String tname)  {
		ArrayList pk = null;
		String colName = "";
		
		String tmp = viewTables.get(tname);
		if (tmp!=null) tname = tmp;  // viewTable
		
		String key = catalog + "." + tname;
		pk = pkMap.get(key);
		if (pk != null) return pk;
		
		DatabaseMetaData dbm;
		try {
			dbm = conn.getMetaData();

			// primary key
			pk = new ArrayList<String>();
			ResultSet rs = dbm.getPrimaryKeys(catalog, null, tname);
			while (rs.next()){
				colName = rs.getString("COLUMN_NAME");
				pk.add(colName);
			}
			rs.close();
			
			pkMap.put(key, pk);
			//System.out.println("PK for " + catalog + "." + tname + " is " + colName);

		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}

		return pk;
	}
	
	public synchronized String getQueryValue(String sql)  {
		String res = "";
		
		res = (String) queryResult.get(sql);
		if (res != null) return res;

		try {
			Statement stmt = conn.createStatement();
			ResultSet rs = stmt.executeQuery(sql);
			
			if (rs.next()) {
				res = rs.getString(1);
			}
			rs.close();
			stmt.close();
			
			if (res!= null)	queryResult.put(sql, res);
			//System.out.println(sql + " => " + res);
			
		} catch (SQLException e) {
			res = e.getMessage();
			e.printStackTrace();
		}
		
		return res;
	}
/*	
	public ResultSet getQueryRS(String sql)  {
		ResultSet rs = null;
		
		try {
			Statement stmt = conn.createStatement();
			rs = stmt.executeQuery(sql);
			
			return rs;
		} catch (SQLException e) {
			rs = null;
		}
		
		return rs;
	}
*/	
	public void addQueryHistory(String qry, int cnt) {
		if (cnt < 1) return;
		QueryLog ql = new QueryLog(qry, cnt);
		queryLog.put(qry, ql);
	}
	
	public HashMap<String,QueryLog> getQueryHistory() {
		return queryLog;
	}
	
	public void ping() {
		String qry = "SELECT 1 from dual";
		try {
			Statement stmt = conn.createStatement();
			ResultSet rs = stmt.executeQuery(qry);
			
			rs.close();
			stmt.close();
		} catch (SQLException e) {
            System.err.println (e.toString());
		}
	}
	
	public String getPrimaryKeyName(String tname) {
		if (tname.contains(".")) {
			String[] temp = tname.split("\\.");
			return getPrimaryKeyName(temp[0], temp[1]);
		}
		
		String tmp = viewTables.get(tname);
		if (tmp!=null) tname = tmp;  // viewTable

		String pkName = pkByTab.get(tname.toUpperCase());
		
		// check for Synonym
		if (pkName == null) {
			String syn=getSynonym(tname) ;
			if (syn != null && syn.contains(".")) {
				return getPrimaryKeyName(syn);
			}
		}		
		
		return pkName;
	}

	public synchronized String getPrimaryKeyName(String owner, String tname) {
		String qry = "SELECT CONSTRAINT_NAME FROM ALL_CONSTRAINTS WHERE OWNER='" +
				owner.toUpperCase() + "' AND TABLE_NAME='" + tname + "' AND CONSTRAINT_TYPE = 'P'";
		
		return queryOne(qry);
	}

	public synchronized String getTableNameByPrimaryKey(String kname) {
		String tName = pkByCon.get(kname.toUpperCase());
		
		// check for other owner
		if (tName == null) {
			String owner = this.queryOne("SELECT OWNER FROM ALL_CONSTRAINTS WHERE CONSTRAINT_NAME='" + kname +"'");
			if (owner != null)
				return getTableNameByPrimaryKey(owner, kname);
		}
		
		return tName;
	}

	public synchronized String getTableNameByPrimaryKey(String owner, String kname) {
		if (owner==null) return this.getTableNameByPrimaryKey(kname);

		String qry = "SELECT OWNER||'.'||TABLE_NAME FROM ALL_CONSTRAINTS WHERE OWNER='" +
				owner + "' AND CONSTRAINT_NAME='" + kname + "'";
		return this.queryOne(qry);
	}

	public synchronized List<String> getConstraintColList(String cname) {
		if (cname.contains(".")) {
			String[] temp = cname.split("\\.");
			return getConstraintColList(temp[0], temp[1]);
		}
		
		
		// check for other owner
		String owner = this.queryOne("SELECT OWNER FROM ALL_CONSTRAINTS WHERE CONSTRAINT_NAME='" + cname +"'");
		if (owner != null) {
			return getConstraintColList(owner, cname);
		}
		
		return getConstraintColList(this.getSchemaName().toUpperCase(), cname);
	}

	public synchronized List<String> getConstraintColList(String owner, String cname) {
		if (owner == null) owner = this.getSchemaName().toUpperCase();
		
		List<String> list = new ArrayList<String>();
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("SELECT column_name from all_cons_columns where " +
       				"owner='" + owner + "' AND constraint_name='" + cname + "' order by position");	

       		while (rs.next()) {
       			String colName = rs.getString(1);
       			list.add(colName);
       		}
       		rs.close();
       		stmt.close();

		} catch (SQLException e) {
             System.err.println ("getConstraintColList - Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		return list;
	}

	public synchronized String getConstraintCols(String cname) {
		if (cname == null) return "";
		
		if (cname.contains(".")) {
			String[] temp = cname.split("\\.");
			return getConstraintCols(temp[0], temp[1]);
		}
		
		String cols = constraints.get(cname.toUpperCase());
		
		// check for other owner
		if (cols==null) {
			String owner = this.queryOne("SELECT OWNER FROM ALL_CONSTRAINTS WHERE CONSTRAINT_NAME='" + cname +"'");
			if (owner != null) {
				return getConstraintCols(owner, cname);
			}
		}
		
		if (cols==null) cols = "";
		return cols;
	}

	public synchronized String getConstraintCols(String owner, String cname) {
		
		if (owner == null) return getConstraintCols(cname);
		
		String res = "";
		String qry = "SELECT COLUMN_NAME from all_cons_columns where  CONSTRAINT_NAME='" + cname 
				+ "' and owner='" + owner + "' ORDER BY position";
		
		List<String> list = queryMulti(qry);

		for (int i=0; i<list.size(); i++) {
			if (i==0) res = list.get(i);
			else res +=", " + list.get(i);
		}
		
		return res;
	}

	public synchronized List<ForeignKey> getForeignKeys(String tname) {
		
		if (tname.contains(".")) {
			String[] temp = tname.split("\\.");
			return getForeignKeys(temp[0], temp[1]);
		}
		
		List<ForeignKey> list = new ArrayList<ForeignKey>();
		
		for (int i=0; i<foreignKeys.size(); i++) {
			ForeignKey fk = foreignKeys.get(i);
			if (fk.tableName.equals(tname)) {
				list.add(fk);
			}
		}
		
		// check for Synonym table
		if (list.size()==0) {
			String syn = getSynonym(tname);
//			System.out.println("syn="+syn);
			if (syn != null && syn.contains(".")) {
				return getForeignKeys(syn);
			}
		}
					
		return list;
	}

	public synchronized List<ForeignKey> getForeignKeys(String owner, String tname) {
		List<ForeignKey> list = new ArrayList<ForeignKey>();
//System.out.println("owner,tname=" + owner + "," + tname);		
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("SELECT * from all_constraints where CONSTRAINT_TYPE = 'R' " +
       				"AND owner='" + owner + "' AND table_name='" + tname + "' order by table_name, constraint_type");	

       		while (rs.next()) {
       			ForeignKey fk = new ForeignKey();
       			fk.owner = rs.getString("OWNER");
       			fk.constraintName = rs.getString("CONSTRAINT_NAME");
       			fk.tableName = rs.getString("TABLE_NAME");
       			fk.rOwner = rs.getString("R_OWNER");
       			fk.rConstraintName = rs.getString("R_CONSTRAINT_NAME");
       			fk.deleteRule = rs.getString("DELETE_RULE");
       			fk.rTableName = getTableNameByPrimaryKey(fk.rConstraintName);
       			if (fk.rTableName != null && fk.rTableName.indexOf(".")>0) {
       				fk.rTableName = fk.rTableName.substring(fk.rTableName.indexOf(".")+1);
       			}

       			list.add(fk);
       		}
       		rs.close();
       		stmt.close();

		} catch (SQLException e) {
             System.err.println ("77 Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		return list;
	}

	public synchronized List<String> getReferencedTables(String tname) {
		
		if (tname.contains(".")) {
			String[] temp = tname.split("\\.");
			return getReferencedTables(temp[0], temp[1]);
		}
		
		List<String> list = new ArrayList<String>();

		String pkName = getPrimaryKeyName(tname);
		if (pkName == null) return list;
		
		for (int i=0; i<foreignKeys.size(); i++) {
			ForeignKey fk = foreignKeys.get(i);
			if (fk.rConstraintName.equals(pkName)) {
				list.add(fk.tableName);
			}
		}
		
		// check for synonym
		if (list.size()==0) {
			String syn = getSynonym(tname);
//System.out.println("*** syn=" + syn);			
			if (syn != null && syn.contains(".")) {
				return getReferencedTables(syn);
			}
		}
		
		// sort by table name and remove dups.
		Set <String> set = new HashSet<String>(list);
		
		List<String> list2 = new ArrayList<String>(set);
		Collections.sort(list2);
		
		return list2;
	}

	public synchronized List<String> getReferencedTables(String owner, String tname) {
		if (owner == null || owner.equalsIgnoreCase(this.getSchemaName())) {
			return getReferencedTables(tname);
		}
		
		String pkName = getPrimaryKeyName(owner, tname);
		
		String qry = "SELECT OWNER||'.'||TABLE_NAME FROM ALL_CONSTRAINTS WHERE " +
				"R_CONSTRAINT_NAME='" + pkName +"' ORDER BY TABLE_NAME";
		
		return this.queryMultiUnique(qry);
	}
	
	public synchronized List<String> getReferencedPackages(String tname) {
		List<String> list = new ArrayList<String>();

		String sql = "SELECT distinct NAME from user_dependencies WHERE REFERENCED_NAME='" + tname + "' AND TYPE IN ('TYPE BODY','PACKAGE BODY','PACKAGE','TYPE','PROCEDURE','FUNCTION') ORDER BY NAME";
		if (this.targetSchema != null)
			sql = "SELECT distinct NAME from all_dependencies WHERE OWNER='" + this.targetSchema + "' AND REFERENCED_NAME='" + tname + "' AND TYPE IN ('TYPE BODY','PACKAGE BODY','PACKAGE','TYPE','PROCEDURE','FUNCTION') ORDER BY NAME";
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(sql);	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String name = rs.getString("NAME");
       			list.add(name);
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("10 Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		return list;
	}
	
	public synchronized List<String> getReferencedProc(String tname) {
		List<String> list = new ArrayList<String>();

		if (!this.isTVS("GENIE_PA_TABLE")) return list;
		
		String sql = "SELECT PACKAGE_NAME, PROCEDURE_NAME FROM GENIE_PA_TABLE WHERE TABLE_NAME='" + tname + "' ORDER BY 1,2";
		if (this.targetSchema != null)
			return list;
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(sql);	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String pkg = rs.getString("PACKAGE_NAME");
       			String prc = rs.getString("PROCEDURE_NAME");
       			list.add(pkg+"." + prc.toLowerCase());
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("11 Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		return list;
	}
	
	public synchronized List<String> getReferencedViews(String tname) {
		List<String> list = new ArrayList<String>();

		String sql = "SELECT distinct NAME from user_dependencies WHERE REFERENCED_NAME='" + tname + "' AND TYPE IN ('VIEW') ORDER BY NAME";
		if (this.targetSchema != null)
			sql = "SELECT distinct NAME from all_dependencies WHERE OWNER='" + this.targetSchema + "' AND REFERENCED_NAME='" + tname + "' AND TYPE IN ('VIEW') ORDER BY NAME";
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(sql);	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String name = rs.getString("NAME");
       			list.add(name);
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("11 Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		return list;
	}
	
	public synchronized List<String[]> getIndexes(String owner, String tname) {
		List<String[]> list = new ArrayList<String[]>();

		if (owner == null) owner = this.getSchemaName().toUpperCase();
		if (this.targetSchema != null) owner = this.targetSchema; 
		try {
			Statement stmt = conn.createStatement();
			ResultSet rs = stmt.executeQuery("SELECT INDEX_NAME, UNIQUENESS FROM ALL_INDEXES WHERE OWNER='" + owner + "' AND TABLE_NAME='" + tname +"'");

			while (rs.next()) {
				String indexName[] = new String[2];
				indexName[0] = rs.getString(1);
				indexName[1] = rs.getString(2);
				
				String t = getTableNameByPrimaryKey(indexName[0]);
				if (t != null) continue; // skip if PK

				String unique = rs.getString(2);
				if (unique.equals("NONUNIQUE")) unique="";
       			list.add(indexName);
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("13 Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		return list;
	}
	
	public synchronized List<String> getConstraints(String owner, String tname) {
		List<String> list = new ArrayList<String>();

		if (owner == null) owner = this.getSchemaName().toUpperCase();
		if (this.targetSchema != null) owner = this.targetSchema; 
		try {
			Statement stmt = conn.createStatement();
			ResultSet rs = stmt.executeQuery("SELECT CONSTRAINT_NAME, SEARCH_CONDITION FROM ALL_CONSTRAINTS WHERE OWNER='" + owner + "' AND TABLE_NAME='" + tname +"' AND constraint_type='C'");

			while (rs.next()) {
				String constName = rs.getString(1)+ " " + rs.getString(2);
				if (!constName.endsWith("IS NOT NULL"))
					list.add(constName);
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("14 Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		return list;
	}
	
	public synchronized List<String> getReferencedTriggers(String tname) {
		List<String> list = new ArrayList<String>();

		String sql = "SELECT distinct NAME from user_dependencies WHERE REFERENCED_NAME='" + tname + "' AND TYPE IN ('TRIGGER') ORDER BY NAME";

		if (this.targetSchema != null)
			sql = "SELECT distinct NAME from all_dependencies WHERE OWNER = '" + this.targetSchema + "' AND REFERENCED_NAME='" + tname + "' AND TYPE IN ('TRIGGER') ORDER BY NAME";
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(sql);	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String name = rs.getString("NAME");
       			list.add(name);
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("12 Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		return list;
	}
	
	public synchronized String getIndexColumns(String owner, String iname) {
		String res = "(";
		if (owner == null) owner = this.getSchemaName().toUpperCase();
		if (this.targetSchema != null) owner = this.targetSchema; 
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("SELECT * from ALL_IND_COLUMNS WHERE " +
       				"TABLE_OWNER='" + owner + "' AND INDEX_NAME='" + iname + "' ORDER BY COLUMN_POSITION");	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String cname = rs.getString("COLUMN_NAME");
       			if (count > 1) res +=", ";
       			res += cname;
       		}
       		
       		res +=")";
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("getIndexColumns - ");
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		return res;
	}
	
	public synchronized String getDependencyPackage(String owner, String name) {
		String res = "";
		if (owner==null) owner = this.getSchemaName().toUpperCase();
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("SELECT distinct REFERENCED_OWNER, REFERENCED_NAME, REFERENCED_TYPE from all_dependencies WHERE OWNER='" + owner + "' AND NAME='" + name + "' AND REFERENCED_TYPE IN ('PACKAGE','PACKAGE BODY','FUNCTION','PROCEDURE','TYPE') AND REFERENCED_OWNER != 'PUBLIC' ORDER BY REFERENCED_NAME");	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String rowner = rs.getString("REFERENCED_OWNER");
       			String rname = rs.getString("REFERENCED_NAME");
       			String rtype = rs.getString("REFERENCED_TYPE");
       			
       			if(!rowner.equalsIgnoreCase(this.getSchemaName()))
       				rname = rowner + "." + rname;
       			res += "<a href='javascript:loadPackage(\""+ rname + "\")'>" + rname + "</a>&nbsp;&nbsp;<br/>";
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("9 Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		return res;
	}

	public synchronized String getDependencyTable(String owner, String name) {
		String res = "";
		if (owner==null) owner = this.getSchemaName().toUpperCase();
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("SELECT distinct REFERENCED_OWNER, REFERENCED_NAME, REFERENCED_TYPE from all_dependencies WHERE OWNER='" + owner + "' and NAME='" + name + "' AND REFERENCED_TYPE IN ('TABLE') AND REFERENCED_OWNER != 'PUBLIC' ORDER BY REFERENCED_NAME");	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String rowner = rs.getString("REFERENCED_OWNER");
       			String rname = rs.getString("REFERENCED_NAME");
       			String rtype = rs.getString("REFERENCED_TYPE");
       			
       			if(!rowner.equalsIgnoreCase(this.getSchemaName()))
       				rname = rowner + "." + rname;

       			String crud = this.getCRUD(name, rname);
       			if (crud==null || crud.equals(""))
       				crud = this.getTriggerCRUD(name, rname);
       			
       			res += "<a href='javascript:loadTable(\""+ rname + "\")'>" + rname + "</a>&nbsp;&nbsp;<span class='rowcountstyle'>" + getTableRowCount(rname) + "</span> " + crud + "<br/>";
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("10 Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		
		return res;
	}

	public synchronized String getDependencyView(String owner, String name) {
		String res = "";
		if (owner==null) owner = this.getSchemaName().toUpperCase();
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("SELECT distinct REFERENCED_OWNER, REFERENCED_NAME, REFERENCED_TYPE from all_dependencies WHERE OWNER='" + owner + "' AND NAME='" + name + "' AND REFERENCED_TYPE IN ('VIEW') AND REFERENCED_OWNER != 'PUBLIC' ORDER BY REFERENCED_NAME");	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String rowner = rs.getString("REFERENCED_OWNER");
       			String rname = rs.getString("REFERENCED_NAME");
       			String rtype = rs.getString("REFERENCED_TYPE");
       			
       			if(!rowner.equalsIgnoreCase(this.getSchemaName()))
       				rname = rowner + "." + rname;

       			res += "<a href='javascript:loadView(\""+ rname + "\")'>" + rname + "</a>&nbsp;&nbsp;" + this.getCRUD(name, rname) + "<br/>";
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("getDependencyView - Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		
		return res;
	}

	public synchronized String getDependencySynonym(String owner, String name) {
		String res = "";
		if (owner==null) owner = this.getSchemaName().toUpperCase();
		if (this.targetSchema != null) owner = this.targetSchema;
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("SELECT distinct REFERENCED_OWNER, REFERENCED_NAME, REFERENCED_TYPE from all_dependencies WHERE OWNER='" + owner + "' and NAME='" + name + "' AND REFERENCED_TYPE IN ('SYNONYM') AND REFERENCED_OWNER != 'PUBLIC' ORDER BY REFERENCED_NAME");	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String rowner = rs.getString("REFERENCED_OWNER");
       			String rname = rs.getString("REFERENCED_NAME");
       			String rtype = rs.getString("REFERENCED_TYPE");
       			
       			if(!rowner.equalsIgnoreCase(this.getSchemaName()))
       				rname = rowner + "." + rname;

       			String qry = "SELECT TABLE_OWNER, TABLE_NAME FROM USER_SYNONYMS WHERE SYNONYM_NAME='" + rname + "'";
       			if (this.targetSchema != null)
       				qry = "SELECT TABLE_OWNER, TABLE_NAME FROM ALL_SYNONYMS WHERE OWNER='" + this.targetSchema + "' AND SYNONYM_NAME='" + rname + "'";
       			List<String[]> list = query(qry);
       			
       			if (list.size() > 0)
       			res += "<a href='javascript:loadSynonym(\""+ rname + "\")'>" + rname + "</a>&nbsp;&nbsp;<span class='rowcountstyle'>" + getTableRowCount(list.get(0)[1], list.get(0)[2]) + "</span><br/>";
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("getDependencySynonym - Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		return res;
	}

	public synchronized String queryOne(String qry, boolean useCache) {
		if (useCache) {
			String res = stringCache.get(qry);
			if (res != null) return res;
		}
		
		String res=null;
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(qry);	

       		if (rs.next()) {
       			res = rs.getString(1);
       		}
       		
       		rs.close();
       		stmt.close();

       		if (useCache) stringCache.add(qry, res);
    		
		} catch (SQLException e) {
            System.err.println ("queryOne - " + qry);
            System.out.println ("queryOne - " + qry);
             e.printStackTrace();
             message = e.getMessage();
 		}
		return res;
	}

	public String queryOne(String qry) {
		return queryOne(qry, true);
	}

	public List<String> queryMulti(String qry) {
		return queryMulti(qry, true);
	}
		
	public synchronized List<String> queryMulti(String qry, boolean useCache) {
		
		List<String> list = null;
		
		if (useCache) {
			list = listCache.getListObject(qry);
			if (list != null) return list;
		}
		
		list = new ArrayList<String>();
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(qry);	

       		while (rs.next()) {
       			String res = rs.getString(1);
       			list.add(res);
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("queryMulti - " + qry);
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		if (useCache) listCache.addList(qry, list);
		return list;
	}

	public List<String> queryMultiUnique(String qry) {
		List <String> list = queryMulti(qry);
		HashSet<String> set = new HashSet<String>(list);
		
		List <String> newList = new ArrayList<String>(set);
		
		return newList;
	}

	public String getSynonym(String sname) {
		String qry = "SELECT SYNONYM_NAME,  table_owner||'.'||table_name FROM USER_SYNONYMS ORDER BY 1";
		if (this.targetSchema != null)
			qry = "SELECT SYNONYM_NAME,  table_owner||'.'||table_name FROM ALL_SYNONYMS WHERE OWNER='" + this.targetSchema + "' ORDER BY 1";
		
		List<String[]> list = query(qry);

		for (String[] syn : list) {
			if (syn[1].equals(sname.toUpperCase())) {
				return syn[2];
			}
			if (syn[1].compareTo(sname.toUpperCase()) > 0) return null;
		}
		
		return null;
	}
	
	public int getPKLinkCount(String tname, String cols, String keys) {
		int cnt = 0;
		
		String condition = Util.buildCondition(cols,  keys);
		String qry = "SELECT COUNT(*) FROM " + tname + " WHERE " + condition;
//System.out.println("qry="+qry);
		
		if (tname.equals("CALC_ERROR") && cols.equals("PROCESSID")) {
			qry = "SELECT COUNT(*) FROM " + tname + " WHERE CALCID IN (SELECT CALCID FROM CALC WHERE PROCESSID='" + keys + "')";
		}
		
		String res = this.queryOne(qry);
		if (res==null || res.equals("")) return 0;
		cnt = Integer.parseInt(res);
		
		return cnt;
	}

	public int getQryCount(String qry) {
		int cnt = 0;
		
		String res = this.queryOne(qry);
		if (res==null || res.equals("")) return 0;
		cnt = Integer.parseInt(res);
		
		return cnt;
	}

	public String getRelatedLinkSql(String tname, String cols, String keys) {
		
		String condition = Util.buildCondition(cols,  keys);
		String qry = "SELECT * FROM " + tname + " WHERE " + condition;

		return qry;
	}

	public String getPKLinkSql(String tname, String keys) {
		return getPKLinkSql(tname, keys, null);
	}
	
	public String getPKLinkSql(String tname, String keys, String rowid) {
		String qry="SELECT * FROM " + tname;

		if (rowid != null) {
			qry += " WHERE ROWID = chartorowid('" + rowid + "')";
			
			return qry;
		}
		
		// Primary Key for PK Link
		String pkName = getPrimaryKeyName(tname);
		String pkCols = null;
		String pkColName = null;
		int pkColIndex = -1;
		if (pkName != null) {
			pkCols = getConstraintCols(pkName);
			int colCount = Util.countMatches(pkCols, ",") + 1;
//			System.out.println("pkCols=" + pkCols + ", colCount=" + colCount);
			pkColName = pkCols;
		}

		String condition = Util.buildCondition(pkColName,  keys);
		if (condition != null && condition.equals("ERROR")) {
			if (tname.equals("ERRORCAT")) condition = "ERRORID=" + keys;
		}
		qry += " WHERE " + condition;
		
		return qry;
	}
	public String getObjectType(String oname) {
		if (oname.contains(".")) {
			String[] temp = oname.split("\\.");
			return getObjectType(temp[0], temp[1]);
		}
		
		String qry = "SELECT OBJECT_TYPE FROM USER_OBJECTS WHERE OBJECT_NAME='" + oname + "'";
		if (this.targetSchema != null)
			qry = "SELECT OBJECT_TYPE FROM ALL_OBJECTS WHERE OWNER='" + this.targetSchema + "' AND OBJECT_NAME='" + oname + "'";
		
		return queryOne(qry);
	}

	public String getObjectType(String owner, String oname) {
		String qry = "SELECT OBJECT_TYPE FROM ALL_OBJECTS WHERE OWNER='" + owner + "' AND OBJECT_NAME='" + oname + "'";
		return queryOne(qry);
	}

	/**
	 * 
	 * @return true if connected user has DBA role
	 */
	public boolean hasDbaRole() {
		
		String qry = "SELECT GRANTED_ROLE FROM USER_ROLE_PRIVS WHERE GRANTED_ROLE='DBA'";
		String dba = this.queryOne(qry);
		
		if (dba.equals("DBA")) return true;
		
		return false;
	}

	public List<TableCol> getTableDetail(String tname) throws SQLException {
		String owner = null;
		if (tname.contains(".")) {
			String[] temp = tname.split("\\.");
			owner = temp[0];
			tname = temp[1];
		}		
		return getTableDetail(owner, tname);
	}

	public synchronized List<TableCol> getTableDetail(String owner, String tname) throws SQLException {
		if (owner==null) {
			// see if the table is users
			if (tables.contains(tname)||views.contains(tname)) {
				owner = schemaName.toUpperCase();
				if(this.targetSchema != null) owner = this.targetSchema;
			} else {
				String syn = this.getSynonym(tname);
				if (syn != null) {
					String[] temp = syn.split("\\.");
					owner = temp[0];
					tname = temp[1];
				}
			}
			
			if (psynonymSet.contains(tname)) owner = "PUBLIC";
		}
/*		
		if (owner==null) {
			return getTableDetail2(owner, tname);
		}
*/
		if (owner==null) owner = this.schemaName;
//		if (this.targetSchema != null) owner = this.targetSchema;
		
		List<TableCol> list = tableDetailCache.get(owner, tname); 
		if (list != null ) return list;
		
		// primary key
		ArrayList<String> pk = getPrimaryKeys(owner, tname);
		
		// for view/Table
		if (pk==null) {
			String tmp = viewTables.get(tname);
			if (tmp!=null) {
				pk = getPrimaryKeys(owner, tmp);
				System.out.println("***pk=" + pk);
			}
		}
		
		list = new ArrayList<TableCol>();
		
		if (owner.equals("PUBLIC")) owner = "SYS";
		Statement stmt = conn.createStatement();
		String qry = "SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, DATA_DEFAULT FROM ALL_TAB_COLUMNS WHERE OWNER='" + owner.toUpperCase() + "' AND TABLE_NAME='" + tname + "' ORDER BY column_id";
//System.out.println("***** " + qry);

		ResultSet rs = stmt.executeQuery(qry);
		while (rs.next()){
			String colName = rs.getString("COLUMN_NAME");
			String dataType = rs.getString("DATA_TYPE");
			int dataSize = rs.getInt("DATA_LENGTH");
			int decimalDigits = rs.getInt("DATA_PRECISION");
			int scale = rs.getInt("DATA_SCALE");
			int nullable = rs.getString("NULLABLE").equals("Y")?1:0;
			
			String colDef = rs.getString("DATA_DEFAULT");
			
			if (colDef==null) colDef="";
			
			String dType = dataType.toLowerCase();
			
			if (dType.equals("varchar") || dType.equals("varchar2") || dType.equals("char"))
				dType += "(" + dataSize + ")";

			if (dType.equals("number")) {
				if (scale > 0)
					dType += "(" + decimalDigits + "," +  scale +")";
				else if (dataSize > 0)
					dType += "(" + decimalDigits + ")";
			}

			TableCol rec = new TableCol();
			rec.setName(colName);
			rec.setType(dataType);
			rec.setSize(dataSize);
			rec.setDecimalDigits(decimalDigits);
			rec.setNullable(nullable);
			rec.setDefaults(colDef);
			rec.setTypeName(dType);
			rec.setPrimaryKey(pk.contains(colName));

			list.add(rec);
		}
		
		rs.close();
		stmt.close();
		
		tableDetailCache.add(owner, tname, list);
		return list;
	}

/*
	public List<TableCol> getTableDetail2(String owner, String tname) throws SQLException {
		List<TableCol> list = tableDetailCache.get(owner, tname); 
		if (list != null ) return list;
		
		list = new ArrayList<TableCol>();

		DatabaseMetaData dbm = conn.getMetaData();
		ResultSet rs1 = dbm.getColumns(owner,"%",tname,"%");

		// primary key
		ArrayList<String> pk = getPrimaryKeys(owner, tname);

		// for view/Table
		if (pk==null) {
			String tmp = viewTables.get(tname);
			if (tmp!=null) {
				pk = getPrimaryKeys(owner, tmp);
				System.out.println("***2 pk=" + pk);
			}
		}

		
		//System.out.println("Detail for " + table);
		while (rs1.next()){
			String colName = rs1.getString("COLUMN_NAME");
			String dataType = rs1.getString("TYPE_NAME");
			int dataSize = rs1.getInt("COLUMN_SIZE");
			int decimalDigits = rs1.getInt("DECIMAL_DIGITS");
			int nullable = rs1.getInt("NULLABLE");
			
			String nulls = (nullable==1)?"":"N";
			String colDef = rs1.getString("COLUMN_DEF");
			if (colDef==null) colDef="";
			
			String dType = dataType.toLowerCase();
			
			if (dType.equals("varchar") || dType.equals("varchar2") || dType.equals("char"))
				dType += "(" + dataSize + ")";

			if (dType.equals("number")) {
				if (dataSize > 0 && decimalDigits > 0)
					dType += "(" + dataSize + "," + decimalDigits +")";
				else if (dataSize > 0)
					dType += "(" + dataSize + ")";
			}

			TableCol rec = new TableCol();
			rec.setName(colName);
			rec.setType(dataType);
			rec.setSize(dataSize);
			rec.setDecimalDigits(decimalDigits);
			rec.setNullable(nullable);
			rec.setDefaults(colDef);
			rec.setTypeName(dType);
			rec.setPrimaryKey(pk.contains(colName));

			list.add(rec);
		}
		
		rs1.close();
		
		tableDetailCache.add(owner, tname, list);
		return list;
	}
*/

/*
	public List<String[]> queryMultiCol(String qry, int cols) {
		return queryMultiCol(qry, cols, true);
	}
	
	public List<String[]> queryMultiCol(String qry, int cols, boolean useCache) {
		
		List<String[]> list = null;
		if (useCache) {
			list = listCache2.getListObject(qry);
			if (list != null) return list;
		}
		
		
//		List<String[]>list = new ArrayList<String[]>();
		list = new ArrayList<String[]>();
		int cnt = 0;
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(qry);	

    		if (cols == 0) {
    			cols = rs.getMetaData().getColumnCount();
    		}
    			
       		while (rs.next()) {
       			String res[] = new String[cols+1];
       			
       			for (int i=1; i<=cols;i++)
       				res[i] = rs.getString(i);
       			list.add(res);
       			cnt++;
       			if (cnt >= 10000) break;
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("queryMultiCol - " + qry);
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		if (useCache) listCache2.addList(qry, list);
		return list;
	}
*/
	
	public String getRefConstraintCols(String master, String detail) {
		// get master table's PK name
		String pkName = this.getPrimaryKeyName(master);
//System.out.println("pkName=" + pkName);		
		// get foreign key list
		List<ForeignKey> fks = this.getForeignKeys(detail);
		
		for (ForeignKey fk : fks) {
			if (fk.rConstraintName.equals(pkName)) {
//				System.out.println("fk.tableName=" + fk.tableName);		
				return this.getConstraintCols(fk.constraintName);
			}
		}
		
		return "";
	}
	
	public void clearCache() {
		if (queryCache!=null) queryCache.clearAll();
		if (listCache!=null) listCache.clearAll();
		if (listCache2!=null) listCache2.clearAll();
		if (stringCache!=null) stringCache.clearAll();
		if (tableDetailCache!=null) tableDetailCache.clearAll();
		
		if (comment_tables!=null) comment_tables.clear();
		if (comments!=null) comments.clear();
	}
	
	public void createTable() throws SQLException {
        conn.setReadOnly(false);
		String stmt1 = 
				"CREATE TABLE GENIE_PAGE (	"+
				"PAGE_ID	VARCHAR2(100),"+
				"TITLE		VARCHAR2(100),"+
				"PARAM1	VARCHAR2(100),"+
				"PARAM2	VARCHAR2(100),"+
				"PARAM3	VARCHAR2(100),"+
				"PRIMARY KEY (PAGE_ID) )";
			
		String stmt2 = 
				"CREATE TABLE GENIE_PAGE_SQL (	"+
				"PAGE_ID	VARCHAR2(100)," +
				"SEQ		NUMBER(3),"+
				"TITLE		VARCHAR2(100),"+
				"SQL_STMT	VARCHAR2(1000),"+
				"INDENT	NUMBER(3)		DEFAULT 0,"+
				"PRIMARY KEY (PAGE_ID, SEQ),"+
				"FOREIGN KEY (PAGE_ID) REFERENCES GENIE_PAGE ON DELETE CASCADE)";

		Statement stmt = conn.createStatement();
		stmt.execute(stmt1);
		stmt.execute(stmt2);
		stmt.close();
		
		stmt = conn.createStatement();
		String sql = "INSERT INTO GENIE_PAGE VALUES ('TABLE','User Defined Page Sample','tname',null,null)";
		stmt.executeUpdate(sql);

		sql = "INSERT INTO GENIE_PAGE_SQL VALUES ('TABLE',1, 'Table Detail', 'SELECT * FROM USER_TABLES WHERE TABLE_NAME=upper(''[tname]'')',0)";
		stmt.executeUpdate(sql);

		sql = "INSERT INTO GENIE_PAGE_SQL VALUES ('TABLE',2, 'Column List', 'SELECT * FROM USER_TAB_COLUMNS WHERE TABLE_NAME=upper(''[tname]'') ORDER BY COLUMN_ID',30)";
		stmt.executeUpdate(sql);
		
		sql = "INSERT INTO GENIE_PAGE_SQL VALUES ('TABLE',3, 'Indexes', 'SELECT * FROM USER_INDEXES WHERE TABLE_NAME=upper(''[tname]'')',30)";
		stmt.executeUpdate(sql);
		
		stmt.close();		
        conn.setReadOnly(true);
	}

	public void createTable2() throws SQLException {
        conn.setReadOnly(false);
		String stmt1 = 
				"CREATE TABLE GENIE_SAVED_SQL (	"+
				"ID	VARCHAR2(100),"+
				"SQL_STMT	VARCHAR2(1000),"+
				"TIMESTAMP DATE DEFAULT SYSDATE, " +
				"PRIMARY KEY (ID) )";

		Statement stmt = conn.createStatement();
		stmt.execute(stmt1);
		stmt.close();
		
		stmt = conn.createStatement();
		String sql = "INSERT INTO GENIE_SAVED_SQL VALUES ('Demo','SELECT * FROM TAB', SYSDATE)";
		stmt.executeUpdate(sql);

		stmt.close();		
        conn.setReadOnly(true);
	}

	public void createLinkTable() throws SQLException {
		String cnt = this.queryOne("SELECT count(*) FROM USER_TABLES WHERE TABLE_NAME='GENIE_LINK'", false);
		if (!cnt.equals("0")) return;
        conn.setReadOnly(false);
		String stmt1 = 
				"CREATE TABLE GENIE_LINK (	"+
				"TNAME		VARCHAR2(30), " +
				"SQL_STMTS	VARCHAR2(4000), " +
				"PRIMARY KEY (TNAME) )";

		Statement stmt = conn.createStatement();
		stmt.execute(stmt1);
		stmt.close();
		
		stmt.close();		
        conn.setReadOnly(true);
        linkTableCreated = true;
        
        addToTableList("GENIE_LINK");
	}

	public void createPkg() throws SQLException {
		if (this.isTVS("GENIE_PA")) return; 

        conn.setReadOnly(false);
        
		String stmt1 = 
				"CREATE TABLE GENIE_PA (	"+
				"PACKAGE_NAME	VARCHAR2(30), " +
				"CREATED DATE, " +
				"PRIMARY KEY (PACKAGE_NAME) )";
		
		Statement stmt = conn.createStatement();
		stmt.execute(stmt1);
		
		stmt1 = 
				"CREATE TABLE GENIE_PA_TABLE (	"+
				"PACKAGE_NAME	VARCHAR2(30), " +
				"PROCEDURE_NAME	VARCHAR2(30), " +
				"TABLE_NAME	VARCHAR2(30), " +
				"OP_SELECT	CHAR(1), " +
				"OP_INSERT	CHAR(1), " +
				"OP_UPDATE	CHAR(1), " +
				"OP_DELETE	CHAR(1), " +
				"COLS_INSERT VARCHAR2(1000), " +
				"COLS_UPDATE VARCHAR2(1000), " +
				"COLS_DELETE VARCHAR2(1000), " +
				"PRIMARY KEY (PACKAGE_NAME, PROCEDURE_NAME, TABLE_NAME) )";
		
		stmt.execute(stmt1);
		stmt.execute("CREATE INDEX GENIE_PA_TABLE_IDX ON GENIE_PA_TABLE(TABLE_NAME)");

		stmt1 = 
				"CREATE TABLE GENIE_PA_DEPENDENCY (	"+
				"PACKAGE_NAME	VARCHAR2(30), " +
				"PROCEDURE_NAME	VARCHAR2(30), " +
				"TARGET_PKG_NAME	VARCHAR2(30), " +
				"TARGET_PROC_NAME	VARCHAR2(30), " +
				"PRIMARY KEY (PACKAGE_NAME, PROCEDURE_NAME, TARGET_PKG_NAME, TARGET_PROC_NAME) )";
		
		stmt.execute(stmt1);
		stmt.execute("CREATE INDEX GENIE_PA_DEPENDENCY_IDX ON GENIE_PA_DEPENDENCY(TARGET_PKG_NAME, TARGET_PROC_NAME)");

		stmt1 = 
				"CREATE TABLE GENIE_PA_PROCEDURE (	"+
				"PACKAGE_NAME	VARCHAR2(30), " +
				"PROCEDURE_NAME	VARCHAR2(30), " +
				"START_LINE     NUMBER, " +
				"END_LINE       NUMBER, " +
				"PROCEDURE_LABEL VARCHAR2(30), " +
				"PRIMARY KEY (PACKAGE_NAME, PROCEDURE_NAME, START_LINE, END_LINE) )";
		
		stmt.execute(stmt1);
		stmt.close();
        conn.setReadOnly(true);
        pkgProcCreated = true;
        
        addToTableList("GENIE_PA");
        addToTableList("GENIE_PA_TABLE");
        addToTableList("GENIE_PA_DEPENDENCY");
        addToTableList("GENIE_PA_PROCEDURE");
	}
	
	private void addToTableList(String tname) {
		this.tables.add(tname);
		this.tableSet.add(tname);
	}
	
	public void createTrg() throws SQLException {
		if (this.isTVS("GENIE_TR")) return; 

        conn.setReadOnly(false);
        
		String stmt1 = 
				"CREATE TABLE GENIE_TR (	"+
				"TRIGGER_NAME	VARCHAR2(30), " +
				"CREATED DATE, " +
				"PRIMARY KEY (TRIGGER_NAME) )";
		
		Statement stmt = conn.createStatement();
		stmt.execute(stmt1);
		
		stmt1 = 
				"CREATE TABLE GENIE_TR_TABLE (	"+
				"TRIGGER_NAME	VARCHAR2(30), " +
				"TABLE_NAME	VARCHAR2(30), " +
				"OP_SELECT	CHAR(1), " +
				"OP_INSERT	CHAR(1), " +
				"OP_UPDATE	CHAR(1), " +
				"OP_DELETE	CHAR(1), " +
				"COLS_INSERT VARCHAR2(1000), " +
				"COLS_UPDATE VARCHAR2(1000), " +
				"COLS_DELETE VARCHAR2(1000), " +
				"PRIMARY KEY (TRIGGER_NAME, TABLE_NAME) )";
		
		stmt.execute(stmt1);
		stmt.execute("CREATE INDEX GENIE_TR_TABLE_IDX ON GENIE_TR_TABLE(TABLE_NAME)");

		stmt.close();
        conn.setReadOnly(true);
        trgProcCreated = true;
        
        addToTableList("GENIE_TR");
        addToTableList("GENIE_TR_TABLE");
	}
	
	public void saveLink(String tname, String sqlStmt) throws SQLException {
		if (!linkTableCreated) createLinkTable();
		try {
	        conn.setReadOnly(false);

	        Statement stmt = conn.createStatement();
	        String sql = "DELETE FROM GENIE_LINK WHERE TNAME='" + Util.escapeQuote(tname) + "'";
	        stmt.executeUpdate(sql);
	        stmt.close();
	        
	        if (!sqlStmt.trim().equals("")) {
	        
	        	sql = "INSERT INTO GENIE_LINK VALUES (?,?)";
	        	PreparedStatement pstmt = conn.prepareStatement(sql);
	        
	        	pstmt.setString(1, tname);
	        	pstmt.setString(2, sqlStmt);
	        	pstmt.executeUpdate();
		        pstmt.close();
	        }
	        
	        conn.setReadOnly(true);

		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	
	public void createTable4WorkSheet() {
		String stmt1 = 
				"CREATE TABLE GENIE_WORK_SHEET (	"+
				"ID	VARCHAR2(100),"+
				"SQL_STMTS	VARCHAR2(4000),"+
				"COORDS		VARCHAR2(4000),"+
				"UPDATED    DATE DEFAULT SYSDATE,"+
				"PRIMARY KEY (ID) )";
			
		try {
	        conn.setReadOnly(false);
	        Statement stmt = conn.createStatement();
	        stmt.execute(stmt1);
	        stmt.close();
		
	        conn.setReadOnly(true);

	        stmt.close();
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			workSheetTableCreated = true;
		}
	}

	public void saveWorkSheet(String name, String sqls, String coords) {
		if (!workSheetTableCreated) createTable4WorkSheet();
		try {
	        conn.setReadOnly(false);

	        Statement stmt = conn.createStatement();
	        String sql = "DELETE FROM GENIE_WORK_SHEET WHERE ID='" + Util.escapeQuote(name) + "'";
	        stmt.executeUpdate(sql);
	        
	        sql = "INSERT INTO GENIE_WORK_SHEET VALUES (?,?,?, SYSDATE)";
	        PreparedStatement pstmt = conn.prepareStatement(sql);
	        
	        pstmt.setString(1, name);
	        pstmt.setString(2, sqls);
	        pstmt.setString(3, coords);
	        pstmt.executeUpdate();
	        
	        conn.setReadOnly(true);

	        stmt.close();
	        pstmt.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	public void deleteWorkSheet(String name) {
		try {
	        conn.setReadOnly(false);

	        Statement stmt = conn.createStatement();
	        String sql = "DELETE FROM GENIE_WORK_SHEET WHERE ID='" + Util.escapeQuote(name) + "'";
	        stmt.executeUpdate(sql);
//System.out.println(sql);	        
	        conn.setReadOnly(true);

	        stmt.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public String getTableRowCount(String tname) {
		if (tname != null && tname.indexOf(".") > 0) {
			int idx = tname.indexOf(".");
			String owner = tname.substring(0, idx);
			String tt = tname.substring(idx+1);
			return getTableRowCount(owner, tt);
		}
		
		String owner = schemaName.toUpperCase();
		String cacheKey = "ROWCOUNT." + owner + "." + tname;
/*		
		if (isSynonym(tname)) {
			cacheKey = "ROWCOUNT." + getSynonym(tname);
		}
		//if (this.targetSchema != null) owner = this.targetSchema; 
*/		
		String cacheValue = stringCache.get(cacheKey);
		if (cacheValue != null) return cacheValue;

		String synName = getSynonym(tname);
		if (synName != null && synName.length() > 3) {
			tname = synName;
			if (tname != null && tname.indexOf(".") > 0) {
				int idx = tname.indexOf(".");
				owner = tname.substring(0, idx);
				String tt = tname.substring(idx+1);
				return getTableRowCount(owner, tt);
			}
		}
		
		String numRows = null;
		String sql = "SELECT NUM_ROWS FROM USER_TABLES WHERE TABLE_NAME ='" + tname + "'";
		if (this.targetSchema != null)
			sql = "SELECT NUM_ROWS FROM ALL_TABLES WHERE OWNER='" + this.targetSchema + "' AND TABLE_NAME ='" + tname + "'";
		numRows = queryOne(sql);

		if (numRows==null) numRows = "";
		else {
			int n = Integer.parseInt(numRows);
			if (n < 1000) {
				numRows = numRows;
			} else if (n < 1000000) {
				numRows = Math.round(n /1000) + "K";
			} else {
				numRows = (Math.round(n /100000) / 10.0 )+ "M";
			}
		}
		
		stringCache.add(cacheKey, numRows);
		return numRows;
	}
	
	public String getTableRowCount(String owner, String tname) {
		//if (this.targetSchema != null) owner = this.targetSchema;
		String cacheKey = "ROWCOUNT." + owner + "." + tname;
		
		String cacheValue = stringCache.get(cacheKey);
		if (cacheValue != null) return cacheValue;
		
		String numRows = null;
		
		if (owner ==null || owner.equals("") || owner.equals(this.getSchemaName())) {
			return getTableRowCount(tname);
		}
		
		numRows = queryOne("SELECT NUM_ROWS FROM ALL_TABLES WHERE OWNER='" + owner + "' AND TABLE_NAME ='" + tname + "'");

		if (numRows==null) numRows = "";
		else {
			int n = Integer.parseInt(numRows);
			if (n < 1000) {
				numRows = numRows;
			} else if (n < 1000000) {
				numRows = Math.round(n /1000) + "K";
			} else {
				numRows = (Math.round(n /100000) / 10.0 )+ "M";
			}
		}
		
		stringCache.add(cacheKey, numRows);
		return numRows;
	}
	
	public void addJspLog(String log) {
		jsplog.add(log);
	}
	
	public ArrayList<String> getJspLog() {
		return jsplog;
	}
	
	public String getQuickLinks() {
		String res = "";
		int cnt=0;
		String lastType="";
		for (QuickLink q:qlink) {
			cnt++;
			if (!q.getType().equals(lastType)) {
					if (cnt > 1) res += "<br/>";
					res += q.getType() + "<br/>";
			}
			if (q.getType().equals("table")) {
				res += "<li><a href='Javascript:loadTable(\""+q.getName()+"\")'>" + q.getName() + "</a> <a href='Javascript:remQuickLink(\""+q.getName()+"\")'>x</a><br/>";
			} else if (q.getType().equals("view")) {
				res += "<li><a href='Javascript:loadView(\""+q.getName()+"\")'>" + q.getName() + "</a> <a href='Javascript:remQuickLink(\""+q.getName()+"\")'>x</a><br/>";
			} else if (q.getType().equals("synonym")) {
				res += "<li><a href='Javascript:loadSynonym(\""+q.getName()+"\")'>" + q.getName() + "</a> <a href='Javascript:remQuickLink(\""+q.getName()+"\")'>x</a><br/>";
			} else if (q.getType().equals("object")) {
				res += "<li><a href='Javascript:loadObject(\""+q.getName()+"\")'>" + q.getName() + "</a> <a href='Javascript:remQuickLink(\""+q.getName()+"\")'>x</a><br/>";
			} else if (q.getType().equals("package")) {
				res += "<li><a href='Javascript:loadPackage(\""+q.getName()+"\")'>" + q.getName() + "</a> <a href='Javascript:remQuickLink(\""+q.getName()+"\")'>x</a><br/>";
			} else if (q.getType().equals("tool")) {
				res += "<li><a href='Javascript:loadTool(\""+q.getName()+"\")'>" + q.getName() + "</a> <a href='Javascript:remQuickLink(\""+q.getName()+"\")'>x</a><br/>";
			} else if (q.getType().equals("search")) {
				res += "<li><a href='Javascript:globalSearch(\""+q.getName()+"\")'>" + q.getName() + "</a> <a href='Javascript:remQuickLink(\""+q.getName()+"\")'>x</a><br/>";
			}
			
			lastType = q.getType();
		}
		return res;
	}
	
	public String getQuickLinksText() {
		String res = "";
		int cnt=0;
		String lastType="";
		for (QuickLink q:qlink) {
			cnt++;
			if (!q.getType().equals(lastType)) {
					if (cnt > 1) res += "<br/>";
					res += q.getType() + "<br/>";
			}
			res += "<li>" + q.getName() + "<br/>";
			lastType = q.getType();
		}
		return res;
	}

	private String getTypeStr(String type) {
		if (type.equals("table")) return "1";
		if (type.equals("view")) return "2";
		if (type.equals("synonym")) return "3";
		if (type.equals("package")) return "4";
		if (type.equals("tool")) return "5";
		if (type.equals("search")) return "6";
		
		return "9";
	}
	
	public void addQuickLink(String type, String name) {
		if (type.equals("table")||type.equals("view")||type.equals("synonym")||type.equals("object"))
			name = name.toUpperCase();
		
		if (type.equals("object")) {
			if (tables.contains(name)) 
				type ="table";
			else if (views.contains(name))
				type = "view";
			else if (synonyms.contains(name))
				type = "synonym";
			else if (packages.contains(name))
				type = "package";
		}
		
		boolean found = false;
		for (QuickLink ql:qlink) {
			if (ql.type.equals(type) && ql.name.equals(name)) {
				ql.setTime();
				found = true;
				break;
			}
		}
		
		if (!found) {
			QuickLink ql = new QuickLink(type, name);
			qlink.add(ql);
		}
		
		int sizeQuickLink = 40;
		// keep the last 40 links only
		if (qlink.size() > sizeQuickLink) {
			Collections.sort(qlink, new Comparator<QuickLink>(){
	            public int compare(QuickLink o1, QuickLink o2) {
	        		return (o2.getTime().compareTo(o1.getTime()));
	            }
	        });			
			
			for (int i=qlink.size()-1; i >= sizeQuickLink;i--) {
				qlink.remove(i);
			}
		}
		
		Collections.sort(qlink, new Comparator<QuickLink>(){
			 
            public int compare(QuickLink o1, QuickLink o2) {


        		return (getTypeStr(o1.getType())+o1.getName()).compareTo(getTypeStr(o2.getType())+o2.getName());
            }
 
        });			
	}

	public void remQuickLink(String name) {
		QuickLink q0 = null;
		for (QuickLink q:qlink) {
			if (q.getName().equals(name)) {
				q0 = q;
				break;
			}
		}
		if (q0!= null) qlink.remove(q0);
		
	}
	
	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public int getCpasType() {
		return cu.getCpasType();
	}
	
	public String getCpasCodeValue(String tname, String cname, String code, Query q) {
		return cu.getCodeValue(tname, cname, code, q);
	}
	
	public String getCpasCodeCapt(String tname, String cname) {
		String comment = cu.getCodeCapt(tname, cname);
		if (comment != null && comment.startsWith("_")) return null;
		
		return comment;
	}
	
	public String getCpasComment(String tname) {
		String comment = cu.getCpasComment(tname);
		if (comment != null && comment.startsWith("_")) return "";
		if (tname.equalsIgnoreCase(comment)) return "";

		return comment;
	}
	
	public boolean isTempTable(String tname) {
		return temp_tables.contains(tname);
	}
	
	public String getCpasCodeGrup(String tname, String cname) {
		return cu.getCodeGrup(tname, cname);
	}
	
	public boolean hasCpas(String tname) {
		if (cu==null) return false;
		return cu.hasTable(tname);
	}
	
	public Date getLoginDate() {
		return this.loginDate;
	}

	public List<String[]> query(String qry) {
		return query(qry, 5000, true);
	}

	public List<String[]> query(String qry, boolean useCache) {
		return query(qry, 5000, useCache);
	}

	public List<String[]> query(String qry, int maxCount, boolean useCache) {
		
		List<String[]> list = null;
		if (useCache) {
			list = listCache2.getListObject(qry);
			if (list != null) return list;
		}
		
		
//		List<String[]>list = new ArrayList<String[]>();
		list = new ArrayList<String[]>();
		int cnt = 0;
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(qry);	

    		int cols = rs.getMetaData().getColumnCount();
    			
       		while (rs.next()) {
       			String res[] = new String[cols+1];
       			
       			for (int i=1; i<=cols;i++)
       				res[i] = rs.getString(i);
       			list.add(res);
       			cnt++;
       			if (cnt >= maxCount) break;
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("query - " + qry);
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		if (useCache) listCache2.addList(qry, list);
		return list;
	}

	public CpasUtil getCpasUtil() {
		return cu;
	}
	
	public boolean isCpas() {
		return this.isCpas;
	}
	
	public String getExplainPlan(String qry) {
		String res = "";
		
		String sql = "explain plan for "+ qry;
		
		Statement stmt;
		try {
			stmt = conn.createStatement();
			stmt.execute(sql);
			ResultSet rs = stmt.executeQuery("SELECT plan_table_output from table(dbms_xplan.display())");
			while (rs.next()) {
				res += rs.getString(1) + "\n";
			}
			rs.close();
			stmt.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			res = e.toString();
		}

		return res;
	}
	
	public void execute(String as) throws SQLException {
		CallableStatement call = conn.prepareCall(as);
		if (as.indexOf("?") != -1) {
            call.registerOutParameter(1, OracleTypes.BIGINT);
         }
		call.execute();
		call.close();
	}

	public boolean isTVS(String oname) {
		
		if (tableSet.contains(oname)) return true;
		if (viewSet.contains(oname)) return true;
		if (synonymSet.contains(oname)) return true;
		
		return false;
	}

	public boolean isPublicSynonym(String oname) {
		
		return psynonymSet.contains(oname);
	}
	
	public boolean isProcedure(String oname) {
		
		if (procedureSet.contains(oname)) return true;
		
		return false;
	} 
	
	public boolean isPackage(String name) {
		return packages.contains(name);
	}
	
	public boolean isSynonym(String name) {
		return synonymSet.contains(name);
	}
	
	public void addMessage(String msg) {
		connectMessage += msg + "<br/>";
		System.out.println(msg);
	}
	
	public String getConnectMessage() {
		return this.connectMessage +"<img src='image/loading.gif'/>";
	}
	
	public boolean isViewTable(String vname) {
		String tmp = viewTables.get(vname);
		
		return tmp != null;
	}
	
	public String getViewTableName(String vname) {
		String tmp = viewTables.get(vname);
		
		return tmp;
	}

	public String getTargetSchema() {
		return this.targetSchema;
	}
	
	public void AddPackageTable(String pkgName, HashMap<String, String> hm, HashMap<String, HashSet<String>> hmIns, HashMap<String, HashSet<String>> hmUpd, HashMap<String, HashSet<String>> hmDel) throws SQLException {
		if (!pkgProcCreated) createPkg();
		try {
	        conn.setReadOnly(false);

	        Statement stmt = conn.createStatement();
	        String sql = "DELETE FROM GENIE_PA_TABLE WHERE PACKAGE_NAME='" + pkgName + "'";
	        stmt.executeUpdate(sql);
	        stmt.close();

	        for (String key:hm.keySet()) {
	        	String value=hm.get(key);
				String[] temp = key.split("\\,");
				if(temp.length < 2) continue;
	        	sql = "INSERT INTO GENIE_PA_TABLE(PACKAGE_NAME, PROCEDURE_NAME, TABLE_NAME, OP_SELECT, OP_INSERT, OP_UPDATE, OP_DELETE, COLS_INSERT, COLS_UPDATE, COLS_DELETE) VALUES (?,?,?,?,?,?,?,?,?,?)";
	        	PreparedStatement pstmt = conn.prepareStatement(sql);
	        
	        	String opSelect = "0";
	        	String opInsert = "0";
	        	String opUpdate = "0";
	        	String opDelete = "0";
	        	if (value.contains("S")) opSelect = "1";
	        	if (value.contains("I")) opInsert = "1";
	        	if (value.contains("U")) opUpdate = "1";
	        	if (value.contains("D")) opDelete = "1";
	        	
	        	if (!this.isTVS(temp[1])) continue;
	        	if (!isPackage(pkgName)) continue;

	        	if (temp[1].length() > 30) {
	        		System.out.println("Table name too long: [" + temp[1] + "]");
	        		continue;
	        	}
//	        	System.out.println("hmIns="+hmIns.get(key));	        	
//	        	System.out.println("hmUpd="+hmUpd.get(key));	        	

	        	String colsInsert = null;
	        	HashSet<String> hs = hmIns.get(key);
	        	if (hs != null) {
	        		for (String col: hs) {
	        			if (colsInsert==null)
	        				colsInsert = "|" + col + "|";
	        			else
	        				colsInsert += col + "|";
	        		}
	        	}
	        	
	        	String colsUpdate = null;
	        	hs = hmUpd.get(key);
	        	if (hs != null) {
	        		for (String col: hs) {
	        			if (colsUpdate==null)
	        				colsUpdate = "|" + col + "|";
	        			else
	        				colsUpdate += col + "|";
	        		}
	        	}
	        	
	        	String colsDelete = null;
	        	hs = hmDel.get(key);
	        	if (hs != null) {
	        		for (String col: hs) {
	        			if (colsDelete==null)
	        				colsDelete = "|" + col + "|";
	        			else
	        				colsDelete += col + "|";
	        		}
	        	}
	        	pstmt.setString(1, pkgName);
	        	pstmt.setString(2, temp[0]);
	        	pstmt.setString(3, temp[1]);
	        	pstmt.setString(4, opSelect);
	        	pstmt.setString(5, opInsert);
	        	pstmt.setString(6, opUpdate);
	        	pstmt.setString(7, opDelete);
	        	pstmt.setString(8, colsInsert);
	        	pstmt.setString(9, colsUpdate);
	        	pstmt.setString(10,  colsDelete);
	        	try {
	        		pstmt.executeUpdate();
	        		pstmt.close();
	        	} catch (SQLException e) {
	        		e.printStackTrace();
	        		System.out.println(pkgName + "," + temp[0] +"," + temp[1] + "," + opSelect + opInsert + opUpdate + opDelete);
	        		pstmt.close();
	        	}
	        }
	        
	        conn.setReadOnly(true);

		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	public void AddTriggerTable(String trgName, HashMap<String, String> hm, HashMap<String, HashSet<String>> hmIns, HashMap<String, HashSet<String>> hmUpd, HashMap<String, HashSet<String>> hmDel) throws SQLException {
		if (!trgProcCreated) createTrg();
		try {
	        conn.setReadOnly(false);


	        Statement stmt = conn.createStatement();
	        String sql = "DELETE FROM GENIE_TR_TABLE WHERE TRIGGER_NAME='" + trgName + "'";
	        stmt.executeUpdate(sql);
	        
	        sql = "DELETE FROM GENIE_TR WHERE TRIGGER_NAME='" + trgName + "'";
	        stmt.executeUpdate(sql);

	        stmt.close();

	        for (String key:hm.keySet()) {
	        	String value=hm.get(key);

	        	sql = "INSERT INTO GENIE_TR_TABLE(TRIGGER_NAME, TABLE_NAME, OP_SELECT, OP_INSERT, OP_UPDATE, OP_DELETE, COLS_INSERT, COLS_UPDATE, COLS_DELETE) VALUES (?,?,?,?,?,?,?,?,?)";
	        	PreparedStatement pstmt = conn.prepareStatement(sql);
	        
	        	String opSelect = "0";
	        	String opInsert = "0";
	        	String opUpdate = "0";
	        	String opDelete = "0";
	        	if (value.contains("S")) opSelect = "1";
	        	if (value.contains("I")) opInsert = "1";
	        	if (value.contains("U")) opUpdate = "1";
	        	if (value.contains("D")) opDelete = "1";
//	        	System.out.println("hmIns="+hmIns.get(key));	        	
//	        	System.out.println("hmUpd="+hmUpd.get(key));	        	

	        	String colsInsert = null;
	        	HashSet<String> hs = hmIns.get(key);
	        	if (hs != null) {
	        		for (String col: hs) {
	        			if (colsInsert==null)
	        				colsInsert = "|" + col + "|";
	        			else
	        				colsInsert += col + "|";
	        		}
	        	}
	        	
	        	String colsUpdate = null;
	        	hs = hmUpd.get(key);
	        	if (hs != null) {
	        		for (String col: hs) {
	        			if (colsUpdate==null)
	        				colsUpdate = "|" + col + "|";
	        			else
	        				colsUpdate += col + "|";
	        		}
	        	}
	        	
	        	String colsDelete = null;
	        	hs = hmDel.get(key);
	        	if (hs != null) {
	        		for (String col: hs) {
	        			if (colsDelete==null)
	        				colsDelete = "|" + col + "|";
	        			else
	        				colsDelete += col + "|";
	        		}
	        	}	        	
	        	pstmt.setString(1, trgName);
	        	pstmt.setString(2, key);
	        	pstmt.setString(3, opSelect);
	        	pstmt.setString(4, opInsert);
	        	pstmt.setString(5, opUpdate);
	        	pstmt.setString(6, opDelete);
	        	pstmt.setString(7, colsInsert);
	        	pstmt.setString(8, colsUpdate);
	        	pstmt.setString(9, colsDelete);
	        	try {
	        		pstmt.executeUpdate();
	        		pstmt.close();
	        	} catch (SQLException e) {
	        		e.printStackTrace();
	        		System.out.println(trgName + "," + key + "," + opSelect + opInsert + opUpdate + opDelete);
	        		pstmt.close();
	        	}
	        }
	        
	        stmt = conn.createStatement();
	        sql = "INSERT INTO GENIE_TR (TRIGGER_NAME, CREATED) VALUES ('" + trgName + "', SYSDATE)";
	        stmt.executeUpdate(sql);
	        stmt.close();

	        conn.setReadOnly(true);

		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	public void AddPackageProc(String pkgName, HashSet<String> hs) throws SQLException {
		if (!pkgProcCreated) createPkg();
		try {
	        conn.setReadOnly(false);

	        Statement stmt = conn.createStatement();
	        String sql = "DELETE FROM GENIE_PA_DEPENDENCY WHERE PACKAGE_NAME='" + pkgName + "'";
	        stmt.executeUpdate(sql);

	        sql = "DELETE FROM GENIE_PA WHERE PACKAGE_NAME='" + pkgName + "'";
	        stmt.executeUpdate(sql);
	        
	        sql = "INSERT INTO GENIE_PA (PACKAGE_NAME, CREATED) VALUES ('" + pkgName + "', SYSDATE)";
	        stmt.executeUpdate(sql);
	        
	        stmt.close();

	        for (String str : hs) {
				String[] temp = str.split(" ");
				
	        	sql = "INSERT INTO GENIE_PA_DEPENDENCY (PACKAGE_NAME, PROCEDURE_NAME, TARGET_PKG_NAME, TARGET_PROC_NAME) VALUES (?,?,?,?)";
	        	PreparedStatement pstmt = conn.prepareStatement(sql);
	        
	        	String targetPkg = pkgName;
	        	String targetPrc = temp[1];
	        	String[] target = temp[1].split("\\.");
	        	if (target.length>2) continue;
	        	if (target.length>1) {
	        		targetPkg = target[0];
	        		targetPrc = target[1];
	        	}

	        	if (pkgName.equals(targetPkg) && temp[0].equals(targetPrc)) continue;
	        	if (!isPackage(targetPkg)) continue;
	        	
	        	try {
//System.out.println(pkgName + " " + temp[0] + " " + targetPkg + " " + targetPrc);
	        		pstmt.setString(1, pkgName);
	        		pstmt.setString(2, temp[0]);
	        		pstmt.setString(3, targetPkg);
	        		pstmt.setString(4, targetPrc);
	        		pstmt.executeUpdate();
	        		pstmt.close();
	        	} catch (SQLException e) {
	        		if (e.getErrorCode()!=1) {
	        			e.printStackTrace();
	        			System.out.println(e.getErrorCode() + "," +pkgName + "," + temp[0] +"," + targetPkg + "," + targetPrc);
	        		}
	        		pstmt.close();
	        	}
	        }
        
	        conn.setReadOnly(true);

		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	public void AddPackageProcDetail(String pkgName, ArrayList<ProcDetail> pd) throws SQLException {
		if (!pkgProcCreated) createPkg();
		try {
	        conn.setReadOnly(false);

	        Statement stmt = conn.createStatement();
	        String sql = "DELETE FROM GENIE_PA_PROCEDURE WHERE PACKAGE_NAME='" + pkgName + "'";
	        stmt.executeUpdate(sql);
	        stmt.close();

	        for (ProcDetail item : pd) {
	        	sql = "INSERT INTO GENIE_PA_PROCEDURE (PACKAGE_NAME, PROCEDURE_NAME, START_LINE, END_LINE, PROCEDURE_LABEL) VALUES (?,?,?,?,?)";
	        	PreparedStatement pstmt = conn.prepareStatement(sql);
	        
	        	try {
	        		pstmt.setString(1, pkgName);
	        		pstmt.setString(2, item.getProcedureName());
	        		pstmt.setInt(3, item.getStartLine());
	        		pstmt.setInt(4, item.getEndLine());
	        		pstmt.setString(5, item.getProcedureLabel());
	        		pstmt.executeUpdate();
	        		pstmt.close();
	        	} catch (SQLException e) {
	        		e.printStackTrace();
	        		System.out.println(pkgName + "," + item);
	        		pstmt.close();
	        	}
	        }
        
	        conn.setReadOnly(true);

		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	private void saveHistoryToFile() {
   		// Serialize
   		try{
   			//use buffering
   			String serFilename = (this.getIPAddress() + "-" + this.urlString).toLowerCase();
   			serFilename = serFilename.replaceAll("[^a-zA-Z0-9\\s]", "-") +  ".ser";
   			OutputStream file = new FileOutputStream( "/home/cpas-genie/" + serFilename );
   			OutputStream buffer = new BufferedOutputStream( file );
   			ObjectOutput output = new ObjectOutputStream( buffer );
   			try{
   				output.writeObject(queryLog);
   			}
   			finally{
   				output.close();
   			}
   			System.out.println("serialize " + serFilename + " " +queryLog.size());
   	    }  
   	    catch(IOException ex){
   	    	ex.printStackTrace();
   	    }

   		// Serialize
   		try{
   			//use buffering
   			String serFilename = (this.getIPAddress() + "-" + this.urlString).toLowerCase();
   			serFilename = serFilename.replaceAll("[^a-zA-Z0-9\\s]", "-") +  ".qlink";
   			OutputStream file = new FileOutputStream( "/home/cpas-genie/" + serFilename );
   			OutputStream buffer = new BufferedOutputStream( file );
   			ObjectOutput output = new ObjectOutputStream( buffer );
   			try{
   				output.writeObject(qlink);
   			}
   			finally{
   				output.close();
   			}
   			System.out.println("serialize2 " + serFilename + " " + qlink.size());
   	    }  
   	    catch(IOException ex){
   	    	ex.printStackTrace();
   	    }

	}

	private void loadHistoryFromFile() {
		
		try{
   			//use buffering
   			String serFilename = (this.getIPAddress() + "-" + this.urlString).toLowerCase();
   			serFilename = serFilename.replaceAll("[^a-zA-Z0-9\\s]", "-") +  ".ser";
	        InputStream file = new FileInputStream( "/home/cpas-genie/" + serFilename );
	        InputStream buffer = new BufferedInputStream( file );
	        ObjectInput input = new ObjectInputStream ( buffer );
	        try{
	        	//deserialize the Object
	        	queryLog = (HashMap<String, QueryLog>)input.readObject();
	        	System.out.println("deserialize " + serFilename + " " + queryLog.size());
/*
	          	for(String quark: recoveredQuarks){
	            	System.out.println("Recovered Quark: " + quark);
	          	}
*/	        }
	        finally{
	        	input.close();
	        }
		} catch(ClassNotFoundException ex){
	        ex.printStackTrace();
	    } catch(IOException ex){
	      	//ex.printStackTrace();
	    }

		try{
   			//use buffering
   			String serFilename = (this.getIPAddress() + "-" + this.urlString).toLowerCase();
   			serFilename = serFilename.replaceAll("[^a-zA-Z0-9\\s]", "-") +  ".qlink";
	        InputStream file = new FileInputStream( "/home/cpas-genie/" + serFilename );
	        InputStream buffer = new BufferedInputStream( file );
	        ObjectInput input = new ObjectInputStream ( buffer );
	        try{
	        	//deserialize the Object
	        	qlink = (ArrayList<QuickLink>)input.readObject();
	        }
	        finally{
	        	input.close();
	        }
		} catch(ClassNotFoundException ex){
	        ex.printStackTrace();
	    } catch(IOException ex){
	      	//ex.printStackTrace();
	    }
		
	}
}

