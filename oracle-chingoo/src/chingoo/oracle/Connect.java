package chingoo.oracle;

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
import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInput;
import java.io.ObjectInputStream;
import java.io.ObjectOutput;
import java.io.ObjectOutputStream;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
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

public class Connect implements HttpSessionBindingListener {

//	public int QRY_ROWS = 1000;
	
	private HttpSession sn = null;
	private Connection conn = null;
	private String urlString = null;
	private String message = "";

	private HashSet<String> comment_tables = new HashSet<String>();
	
	private Hashtable<String,String> comments;

	private List<String> schemas;
	private String schemaName;
	private String ipAddress;
	private String userAgent;
	
	//private Hashtable<String, String> pkColumn;
	private HashMap<String, String> queryResult;
	private HashMap<String, QueryLog> queryLog;
	private HashMap<String, ArrayList<String>> pkMap;
//	private Stack<String> history;
	private ArrayList<QuickLink> qlink;
	private ArrayList<String> jsplog;
	
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
	private boolean pkgProcCreated = false;
	private boolean trgProcCreated = false;
	
	private String email = "";
	private String url = "";

	private Date loginDate; 
	private Date lastDate;
	public String pwd;
	
	public String connectMessage = "";
	
	public HashSet<String> tempSet;
	
	public CacheSchema cs;
	private long lastMillis = System.currentTimeMillis(); 

	public int tabToSpace = 3;
	public String getTabSpace() {
		String res = "          ";
		
		return res.substring(0,tabToSpace);
	}
	
	/**
	 * Constructor
	 * 
	 * @param url jdbc url
	 * @param userName	database user name
	 * @param password	database password
	 * @param ipAddress	user's local ip address
	 */
    public Connect(HttpSession session, String url, String userName, String password, String ipAddress, boolean loadData)
    {
    	//pkColumn = new Hashtable<String, String>();
    	queryResult = new HashMap<String, String>();
    	pkMap = new HashMap<String, ArrayList<String>>();
    	
    	loginDate = new Date();
    	lastDate = new Date();
    	pwd = password;
    	
//    	history = new Stack<String>();
    	
    	this.ipAddress = ipAddress;
        try
        {
        	sn = session;
            Class.forName ("oracle.jdbc.driver.OracleDriver").newInstance ();
            conn = DriverManager.getConnection (url, userName, password);
            conn.setReadOnly(true);
            
            urlString = userName + "@" + url;  
            addMessage("Database connection established for " + urlString + " @" + (new Date()) + " " + ipAddress);
            if (loadData) session.setAttribute("CN", this);
            
            if (!loadData) return; 
            	
            comments = new Hashtable<String, String>();

            schemas = new Vector<String>();
            queryLog = new HashMap<String, QueryLog>();
            qlink = new ArrayList<QuickLink>();
            jsplog = new ArrayList<String>();
            
//       		this.schemaName = conn.getCatalog();
       		this.schemaName = userName;
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
            
            cs = CacheManager.getInstance().getCacheSchema(this, urlString, schemaName);
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
    	this(session, url, userName, password, ipAddress, true);
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
		ChingooManager.getInstance().removeSession(this);
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
    	return cs.getTables();
    }

    public String getTable(int idx) {
    	return cs.getTable(idx);
    }
    
    public String getUrlString() {
    	return urlString;
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
    	
		saveHistoryToFile();
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
		
		loadSchema();
		loadTableRowCount();
	}

	private synchronized void loadSchema() {
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select username from USER_USERS");	

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

	public String getProcedureLabel(String pkg, String prc) {
		return getProcedureLabel(pkg+"."+prc);
	}
	
	public boolean isPackageProc(String key) {
		String value = cs.packageProc.get(key.toUpperCase());
		return (value!=null);
	}
	
	public String getProcedureLabel(String key) {
		String value = cs.packageProc.get(key);
		if(value==null) {
			String temp[] = key.split("\\.");
			value = temp[1];
		}
		
		return value;
	}
	
	public String getCRUD(String packageName, String tableName) {
		String key = packageName + "," + tableName;
		String op = cs.packageTables.get(key);
		if (op==null) return "";
		
		return "<span style='color: red; font-weight: bold;'>" + op + "</span>";
	}
	
	public String getCRUD(String packageName, String procedureName, String tableName) {
		String key = packageName+"."+procedureName + "," + tableName;
		String op = cs.packageProcTables.get(key);
		if (op==null) return "";
		
		return "<span style='color: red; font-weight: bold;'>" + op + "</span>";
	}
	
	public String getTriggerCRUD(String triggerName, String tableName) {
		String key = triggerName + "," + tableName;
		String op = cs.triggerTables.get(key);
		if (op==null) return "";
		
		return "<span style='color: red; font-weight: bold;'>" + op + "</span>";
	}
	
	private synchronized void loadTableRowCount() {
		int cnt=0;
		// column comments
		try {
       		Statement stmt = conn.createStatement();
//       		ResultSet rs = stmt.executeQuery("select owner, table_name, num_rows from ALL_TABLES");
       		
       		String sql = "SELECT owner, table_name, num_rows from ALL_TABLES where (owner=user or owner in (SELECT table_owner from user_synonyms))";
       		
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
	
	public ArrayList<String> getPrimaryKeys(String tname)  {
		return getPrimaryKeys(null, tname);
	}
	
	public synchronized ArrayList<String> getPrimaryKeys(String catalog, String tname)  {
		ArrayList pk = null;
		String colName = "";
		
		String tmp = cs.viewTables.get(tname);
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
		lastDate = new Date();
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
		
		String tmp = cs.viewTables.get(tname);
		if (tmp!=null) tname = tmp;  // viewTable

		String pkName = cs.pkByTab.get(tname.toUpperCase());
		
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
		String tName = cs.pkByCon.get(kname.toUpperCase());
		
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
       		ResultSet rs = stmt.executeQuery("select column_name from all_cons_columns where " +
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
		
		String cols = cs.constraints.get(cname.toUpperCase());
		
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
		
		for (int i=0; i<cs.foreignKeys.size(); i++) {
			ForeignKey fk = cs.foreignKeys.get(i);
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
       		ResultSet rs = stmt.executeQuery("select * from all_constraints where CONSTRAINT_TYPE = 'R' " +
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
             System.err.println ("7 Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		return list;
	}

	public synchronized List<String> getReferencedTables(String tname) {
		
		if (this.isSynonym(tname)) {
			tname = this.getSynonym(tname);
		}
		
		if (tname.contains(".")) {
			String[] temp = tname.split("\\.");
			return getReferencedTables(temp[0], temp[1]);
		}
		
		List<String> list = new ArrayList<String>();

		String pkName = getPrimaryKeyName(tname);
		if (pkName == null) return list;
		
		for (int i=0; i<cs.foreignKeys.size(); i++) {
			ForeignKey fk = cs.foreignKeys.get(i);
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
				"R_OWNER='" + owner + "' AND R_CONSTRAINT_NAME='" + pkName +"' ORDER BY TABLE_NAME";
		
		return this.queryMultiUnique(qry);
	}
	
	public synchronized List<String> getReferencedPackages(String owner, String tname) {
		if (owner==null) return getReferencedPackages(tname);
		List<String> list = new ArrayList<String>();

		String sql = "SELECT distinct OWNER, NAME from all_dependencies WHERE REFERENCED_OWNER='" + owner + "' AND REFERENCED_NAME='" + tname + "' AND TYPE IN ('TYPE BODY','PACKAGE BODY','PACKAGE','TYPE','PROCEDURE','FUNCTION') ORDER BY NAME";
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(sql);	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String own = rs.getString("OWNER");
       			String name = rs.getString("NAME");
       			list.add(own + "." + name);
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

	public synchronized List<String> getReferencedPackages(String tname) {
		List<String> list = new ArrayList<String>();

		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select distinct NAME from user_dependencies WHERE REFERENCED_NAME='" + tname + "' AND TYPE IN ('TYPE BODY','PACKAGE BODY','PACKAGE','TYPE','PROCEDURE','FUNCTION') ORDER BY NAME");	

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

		if (!this.isTVS("CHINGOO_PA_TABLE")) return list;
		
		String sql = "SELECT PACKAGE_NAME, PROCEDURE_NAME FROM CHINGOO_PA_TABLE WHERE TABLE_NAME='" + tname + "' ORDER BY 1,2";
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
	

	public synchronized List<String> getReferencedViews(String owner, String tname) {
		if (owner==null) return getReferencedViews(tname);
		
		List<String> list = new ArrayList<String>();

		String sql = "SELECT distinct OWNER, NAME from all_dependencies WHERE REFERENCED_OWNER='" + owner + "' AND REFERENCED_NAME='" + tname + "' AND TYPE IN ('VIEW') ORDER BY NAME";
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(sql);	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String own = rs.getString("OWNER");
       			String name = rs.getString("NAME");
       			list.add(owner+"."+name);
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

		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select distinct NAME from user_dependencies WHERE REFERENCED_NAME='" + tname + "' AND TYPE IN ('VIEW') ORDER BY NAME");	

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
	
	public synchronized List<String> getReferencedTriggers(String owner, String tname) {
		if(owner==null) return getReferencedTriggers(tname);
		List<String> list = new ArrayList<String>();

		String sql = "SELECT distinct OWNER, NAME from all_dependencies WHERE REFERENCED_OWNER='"+owner+"' AND REFERENCED_NAME='" + tname + "' AND TYPE IN ('TRIGGER') ORDER BY NAME";

		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(sql);	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String own = rs.getString("OWNER");
       			String name = rs.getString("NAME");
       			list.add(own+"."+name);
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

	public synchronized List<String> getReferencedTriggers(String tname) {
		List<String> list = new ArrayList<String>();

		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select distinct NAME from user_dependencies WHERE REFERENCED_NAME='" + tname + "' AND TYPE IN ('TRIGGER') ORDER BY NAME");	

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
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select * from ALL_IND_COLUMNS WHERE " +
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
       		ResultSet rs = stmt.executeQuery("select distinct REFERENCED_OWNER, REFERENCED_NAME, REFERENCED_TYPE from all_dependencies WHERE OWNER='" + owner + "' AND NAME='" + name + "' AND REFERENCED_TYPE IN ('PACKAGE','PACKAGE BODY','FUNCTION','PROCEDURE','TYPE') AND REFERENCED_OWNER != 'PUBLIC' ORDER BY REFERENCED_NAME");	

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
       		ResultSet rs = stmt.executeQuery("select distinct REFERENCED_OWNER, REFERENCED_NAME, REFERENCED_TYPE from all_dependencies WHERE OWNER='" + owner + "' and NAME='" + name + "' AND REFERENCED_TYPE IN ('TABLE') AND REFERENCED_OWNER != 'PUBLIC' ORDER BY REFERENCED_NAME");	

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
       		ResultSet rs = stmt.executeQuery("select distinct REFERENCED_OWNER, REFERENCED_NAME, REFERENCED_TYPE from all_dependencies WHERE OWNER='" + owner + "' AND NAME='" + name + "' AND REFERENCED_TYPE IN ('VIEW') AND REFERENCED_OWNER != 'PUBLIC' ORDER BY REFERENCED_NAME");	

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
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select distinct REFERENCED_OWNER, REFERENCED_NAME, REFERENCED_TYPE from all_dependencies WHERE OWNER='" + owner + "' and NAME='" + name + "' AND REFERENCED_TYPE IN ('SYNONYM') AND REFERENCED_OWNER != 'PUBLIC' ORDER BY REFERENCED_NAME");	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String rowner = rs.getString("REFERENCED_OWNER");
       			String rname = rs.getString("REFERENCED_NAME");
       			String rtype = rs.getString("REFERENCED_TYPE");
       			
       			if(!rowner.equalsIgnoreCase(this.getSchemaName()))
       				rname = rowner + "." + rname;

       			String qry = "SELECT TABLE_OWNER, TABLE_NAME FROM USER_SYNONYMS WHERE SYNONYM_NAME='" + rname + "'"; 	
       			List<String[]> list = query(qry);
       			
       			String crud = this.getCRUD(name, rname);
       			
       			if (list.size() > 0)
       			res += "<a href='javascript:loadSynonym(\""+ rname + "\")'>" + rname + "</a>&nbsp;&nbsp;<span class='rowcountstyle'>" + getTableRowCount(list.get(0)[1], list.get(0)[2]) + "</span> " + crud + "<br/>";
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
		
		String res = this.queryOne(qry, false);
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
		qry += " WHERE " + condition;
		
		return qry;
	}
	public String getObjectType(String oname) {
		if (oname.contains(".")) {
			String[] temp = oname.split("\\.");
			return getObjectType(temp[0], temp[1]);
		}
		
		String qry = "SELECT OBJECT_TYPE FROM USER_OBJECTS WHERE OBJECT_NAME='" + oname + "'";
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

	public boolean hasColumn(String tname, String cname) {
		List<TableCol> cols;
		try {
			cols = getTableDetail(tname);
			boolean hasCol = false;
			for (TableCol col: cols) {
				if (col.name.equalsIgnoreCase(cname)) {
					hasCol = true;
					break;
				}
			}
			return hasCol;
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

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
			if (cs.getTables().contains(tname)||cs.getViews().contains(tname)) {
				owner = schemaName.toUpperCase();
			} else {
				String syn = this.getSynonym(tname);
				if (syn != null) {
					String[] temp = syn.split("\\.");
					owner = temp[0];
					tname = temp[1];
				}
			}
			if (cs.psynonymSet.contains(tname)) owner = "PUBLIC";
		}
/*		
		if (owner==null) {
			return getTableDetail2(owner, tname);
		}
*/
		if (owner==null) owner = this.schemaName;
		
		List<TableCol> list = tableDetailCache.get(owner, tname); 
		if (list != null ) return list;
		
		// primary key
		ArrayList<String> pk = getPrimaryKeys(owner, tname);
		
		// for view/Table
		if (pk==null) {
			String tmp = cs.viewTables.get(tname);
			if (tmp!=null) {
				pk = getPrimaryKeys(owner, tmp);
				System.out.println("***pk=" + pk);
			}
		}
		
		list = new ArrayList<TableCol>();
		
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
				else if (dataSize > 0 && decimalDigits > 0)
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
	
	public void reloadCacheSchema() throws SQLException {
		cs.reload(this);
	}
	
	public void createTable() throws SQLException {
        conn.setReadOnly(false);
		String stmt1 = 
				"CREATE TABLE CHINGOO_PAGE (	"+
				"PAGE_ID	VARCHAR2(100),"+
				"TITLE		VARCHAR2(100),"+
				"PARAM1	VARCHAR2(100),"+
				"PARAM2	VARCHAR2(100),"+
				"PARAM3	VARCHAR2(100),"+
				"PRIMARY KEY (PAGE_ID) )";
			
		String stmt2 = 
				"CREATE TABLE CHINGOO_PAGE_SQL (	"+
				"PAGE_ID	VARCHAR2(100)," +
				"SEQ		NUMBER(3),"+
				"TITLE		VARCHAR2(100),"+
				"SQL_STMT	VARCHAR2(1000),"+
				"INDENT	NUMBER(3)		DEFAULT 0,"+
				"PRIMARY KEY (PAGE_ID, SEQ),"+
				"FOREIGN KEY (PAGE_ID) REFERENCES CHINGOO_PAGE ON DELETE CASCADE)";

		Statement stmt = conn.createStatement();
		stmt.execute(stmt1);
		stmt.execute(stmt2);
		stmt.close();
		
		stmt = conn.createStatement();
		String sql = "INSERT INTO CHINGOO_PAGE VALUES ('TABLE','User Defined Page Sample','tname',null,null)";
		stmt.executeUpdate(sql);

		sql = "INSERT INTO CHINGOO_PAGE_SQL VALUES ('TABLE',1, 'Table Detail', 'SELECT * FROM USER_TABLES WHERE TABLE_NAME=upper(''[tname]'')',0)";
		stmt.executeUpdate(sql);

		sql = "INSERT INTO CHINGOO_PAGE_SQL VALUES ('TABLE',2, 'Column List', 'SELECT * FROM USER_TAB_COLUMNS WHERE TABLE_NAME=upper(''[tname]'') ORDER BY COLUMN_ID',30)";
		stmt.executeUpdate(sql);
		
		sql = "INSERT INTO CHINGOO_PAGE_SQL VALUES ('TABLE',3, 'Indexes', 'SELECT * FROM USER_INDEXES WHERE TABLE_NAME=upper(''[tname]'')',30)";
		stmt.executeUpdate(sql);
		
		stmt.close();		
        conn.setReadOnly(true);
	}

	public void createTable2() throws SQLException {
        conn.setReadOnly(false);
		String stmt1 = 
				"CREATE TABLE CHINGOO_SAVED_SQL (	"+
				"ID	VARCHAR2(100),"+
				"SQL_STMT	VARCHAR2(1000),"+
				"TIMESTAMP DATE DEFAULT SYSDATE, " +
				"PRIMARY KEY (ID) )";

		Statement stmt = conn.createStatement();
		stmt.execute(stmt1);
		stmt.close();
		
		stmt = conn.createStatement();
		String sql = "INSERT INTO CHINGOO_SAVED_SQL VALUES ('Demo','SELECT * FROM TAB', SYSDATE)";
		stmt.executeUpdate(sql);

		stmt.close();		
        conn.setReadOnly(true);
	}

	public void createLinkTable() throws SQLException {
		String cnt = this.queryOne("SELECT count(*) FROM USER_TABLES WHERE TABLE_NAME='CHINGOO_LINK'", false);
		if (!cnt.equals("0")) return;
        conn.setReadOnly(false);
		String stmt1 = 
				"CREATE TABLE CHINGOO_LINK (	"+
				"TNAME		VARCHAR2(30), " +
				"SQL_STMTS	VARCHAR2(4000), " +
				"PRIMARY KEY (TNAME) )";

		Statement stmt = conn.createStatement();
		stmt.execute(stmt1);
		stmt.close();
		
		stmt.close();		
        conn.setReadOnly(true);
        linkTableCreated = true;
        
        addToTableList("CHINGOO_LINK");
	}

	public void createPkg() throws SQLException {
		if (this.isTVS("CHINGOO_PA")) return; 

        conn.setReadOnly(false);
        
		String stmt1 = 
				"CREATE TABLE CHINGOO_PA (	"+
				"PACKAGE_NAME	VARCHAR2(30), " +
				"CREATED DATE, " +
				"PRIMARY KEY (PACKAGE_NAME) )";
		
		Statement stmt = conn.createStatement();
		stmt.execute(stmt1);
		
		stmt1 = 
				"CREATE TABLE CHINGOO_PA_TABLE (	"+
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
		stmt.execute("CREATE INDEX CHINGOO_PA_TABLE_IDX ON CHINGOO_PA_TABLE(TABLE_NAME)");

		stmt1 = 
				"CREATE TABLE CHINGOO_PA_DEPENDENCY (	"+
				"PACKAGE_NAME	VARCHAR2(30), " +
				"PROCEDURE_NAME	VARCHAR2(30), " +
				"TARGET_PKG_NAME	VARCHAR2(30), " +
				"TARGET_PROC_NAME	VARCHAR2(30), " +
				"PRIMARY KEY (PACKAGE_NAME, PROCEDURE_NAME, TARGET_PKG_NAME, TARGET_PROC_NAME) )";
		
		stmt.execute(stmt1);
		stmt.execute("CREATE INDEX CHINGOO_PA_DEPENDENCY_IDX ON CHINGOO_PA_DEPENDENCY(TARGET_PKG_NAME, TARGET_PROC_NAME)");

		stmt1 = 
				"CREATE TABLE CHINGOO_PA_PROCEDURE (	"+
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

        addToTableList("CHINGOO_PA");
        addToTableList("CHINGOO_PA_TABLE");
        addToTableList("CHINGOO_PA_DEPENDENCY");
        addToTableList("CHINGOO_PA_PROCEDURE");
	}
	
	private void addToTableList(String tname) {
		cs.tables.add(tname);
		cs.tableSet.add(tname);
	}
	
	public void createTrg() throws SQLException {
		if (this.isTVS("CHINGOO_TR")) return; 

        conn.setReadOnly(false);
        
		String stmt1 = 
				"CREATE TABLE CHINGOO_TR (	"+
				"TRIGGER_NAME	VARCHAR2(30), " +
				"CREATED DATE, " +
				"PRIMARY KEY (TRIGGER_NAME) )";
		
		Statement stmt = conn.createStatement();
		stmt.execute(stmt1);
		
		stmt1 = 
				"CREATE TABLE CHINGOO_TR_TABLE (	"+
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
		stmt.execute("CREATE INDEX CHINGOO_TR_TABLE_IDX ON CHINGOO_TR_TABLE(TABLE_NAME)");

		stmt.close();
        conn.setReadOnly(true);
        trgProcCreated = true;
        
        addToTableList("CHINGOO_TR");
        addToTableList("CHINGOO_TR_TABLE");
	}
	
	public void createTrg2() throws SQLException {
		if (this.isTVS("CHINGOO_TR_DEPENDENCY")) return; 

        conn.setReadOnly(false);
        
		String stmt1 = 
				"CREATE TABLE CHINGOO_TR_DEPENDENCY (	"+
				"TRIGGER_NAME	VARCHAR2(30), " +
				"TARGET_PKG_NAME	VARCHAR2(30), " +
				"TARGET_PROC_NAME	VARCHAR2(30), " +
				"PRIMARY KEY (TRIGGER_NAME,TARGET_PKG_NAME, TARGET_PROC_NAME) )";
		
		Statement stmt = conn.createStatement();
		stmt.execute(stmt1);
		stmt.execute("CREATE INDEX CHINGOO_TR_DEPENDENCY_IDX ON CHINGOO_TR_DEPENDENCY(TARGET_PKG_NAME, TARGET_PROC_NAME)");
		stmt.close();

		conn.setReadOnly(true);
		trgProcCreated = true;
        
        addToTableList("CHINGOO_TR_DEPENDENCY");
	}

	public void saveLink(String tname, String sqlStmt) throws SQLException {
		if (!linkTableCreated) createLinkTable();
		try {
	        conn.setReadOnly(false);

	        Statement stmt = conn.createStatement();
	        String sql = "DELETE FROM CHINGOO_LINK WHERE TNAME='" + Util.escapeQuote(tname) + "'";
	        stmt.executeUpdate(sql);
	        stmt.close();
	        
	        if (!sqlStmt.trim().equals("")) {
	        
	        	sql = "INSERT INTO CHINGOO_LINK VALUES (?,?)";
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
				"CREATE TABLE CHINGOO_WORK_SHEET (	"+
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
	        String sql = "DELETE FROM CHINGOO_WORK_SHEET WHERE ID='" + Util.escapeQuote(name) + "'";
	        stmt.executeUpdate(sql);
	        
	        sql = "INSERT INTO CHINGOO_WORK_SHEET VALUES (?,?,?, SYSDATE)";
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
	        String sql = "DELETE FROM CHINGOO_WORK_SHEET WHERE ID='" + Util.escapeQuote(name) + "'";
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

		numRows = queryOne("SELECT NUM_ROWS FROM USER_TABLES WHERE TABLE_NAME ='" + tname + "'");

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
		if (qlink==null) return "";
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
			if (cs.tables.contains(name)) 
				type ="table";
			else if (cs.views.contains(name))
				type = "view";
			else if (cs.synonyms.contains(name))
				type = "synonym";
			else if (cs.packages.contains(name))
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
		lastDate = new Date();
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
	
	public boolean isTempTable(String tname) {
		return cs.temptableSet.contains(tname);
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

	public Date getLoginDate() {
		return this.loginDate;
	}

	public Date getLastDate() {
		return this.lastDate;
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

	public String getExplainPlan(String qry) {
		String res = "";
		
		String sql = "explain plan for "+ qry;
		
		Statement stmt;
		try {
			stmt = conn.createStatement();
			stmt.execute(sql);
			ResultSet rs = stmt.executeQuery("select plan_table_output from table(dbms_xplan.display())");
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
	
	public boolean isTVS(String oname) {
		return cs.isTVS(oname);
	}

	public boolean isType(String oname) {
		return cs.isType(oname);
	}

	public boolean isPublicSynonym(String oname) {
		
		return cs.psynonymSet.contains(oname);
	}

	public boolean isProcedure(String oname) {
		
		if (cs.procedureSet.contains(oname)) return true;
		
		return false;
	} 
	
	public boolean isPackageType(String name) {
		return cs.packages.contains(name) || cs.types.contains(name);
	}
	
	public boolean isPackage(String name) {
		return cs.packages.contains(name);
	}
	
	public boolean isSynonym(String name) {
		return cs.synonymSet.contains(name);
	}
	
	public void addMessage(String msg) {
		connectMessage += msg + "<br/>";
		long currentMillis = System.currentTimeMillis();
		
		System.out.println(msg + " " + (currentMillis - lastMillis));
		lastMillis = currentMillis;
	}
	
	public String getConnectMessage() {
		return this.connectMessage +"<img src='image/loading.gif'/>";
	}
	
	public boolean isViewTable(String vname) {
		String tmp = cs.viewTables.get(vname);
		
		return tmp != null;
	}
	
	public String getViewTableName(String vname) {
		String tmp = cs.viewTables.get(vname);
		
		return tmp;
	}
	
	public void AddPackageTable(String pkgName, HashMap<String, String> hm, HashMap<String, HashSet<String>> hmIns, HashMap<String, HashSet<String>> hmUpd, HashMap<String, HashSet<String>> hmDel) throws SQLException {
		if (!pkgProcCreated) createPkg();
		try {
	        conn.setReadOnly(false);

	        Statement stmt = conn.createStatement();
	        String sql = "DELETE FROM CHINGOO_PA_TABLE WHERE PACKAGE_NAME='" + pkgName + "'";
	        stmt.executeUpdate(sql);
	        stmt.close();

	        for (String key:hm.keySet()) {
	        	String value=hm.get(key);
				String[] temp = key.split("\\,");
				if(temp.length < 2) continue;
	        	sql = "INSERT INTO CHINGOO_PA_TABLE(PACKAGE_NAME, PROCEDURE_NAME, TABLE_NAME, OP_SELECT, OP_INSERT, OP_UPDATE, OP_DELETE, COLS_INSERT, COLS_UPDATE, COLS_DELETE) VALUES (?,?,?,?,?,?,?,?,?,?)";
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
	        	if (!isPackageType(pkgName)) continue;

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
	        String sql = "DELETE FROM CHINGOO_TR_TABLE WHERE TRIGGER_NAME='" + trgName + "'";
	        stmt.executeUpdate(sql);

	        sql = "DELETE FROM CHINGOO_TR WHERE TRIGGER_NAME='" + trgName + "'";
	        stmt.executeUpdate(sql);
	        stmt.close();

	        for (String key:hm.keySet()) {
	        	String value=hm.get(key);

	        	sql = "INSERT INTO CHINGOO_TR_TABLE(TRIGGER_NAME, TABLE_NAME, OP_SELECT, OP_INSERT, OP_UPDATE, OP_DELETE, COLS_INSERT, COLS_UPDATE, COLS_DELETE) VALUES (?,?,?,?,?,?,?,?,?)";
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
	        sql = "INSERT INTO CHINGOO_TR (TRIGGER_NAME, CREATED) VALUES ('" + trgName + "', SYSDATE)";
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
	        String sql = "DELETE FROM CHINGOO_PA_DEPENDENCY WHERE PACKAGE_NAME='" + pkgName + "'";
	        stmt.executeUpdate(sql);

	        sql = "DELETE FROM CHINGOO_PA WHERE PACKAGE_NAME='" + pkgName + "'";
	        stmt.executeUpdate(sql);
	        
	        sql = "INSERT INTO CHINGOO_PA (PACKAGE_NAME, CREATED) VALUES ('" + pkgName + "', SYSDATE)";
	        stmt.executeUpdate(sql);
	        
	        stmt.close();

	        for (String str : hs) {
				String[] temp = str.split(" ");
				
	        	sql = "INSERT INTO CHINGOO_PA_DEPENDENCY (PACKAGE_NAME, PROCEDURE_NAME, TARGET_PKG_NAME, TARGET_PROC_NAME) VALUES (?,?,?,?)";
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
	        	if (!isPackageType(targetPkg)) continue;
	        	
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
	        String sql = "DELETE FROM CHINGOO_PA_PROCEDURE WHERE PACKAGE_NAME='" + pkgName + "'";
	        stmt.executeUpdate(sql);
	        stmt.close();

	        for (ProcDetail item : pd) {
	        	sql = "INSERT INTO CHINGOO_PA_PROCEDURE (PACKAGE_NAME, PROCEDURE_NAME, START_LINE, END_LINE, PROCEDURE_LABEL) VALUES (?,?,?,?,?)";
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
	
	public void AddTriggerProc(String trgName, HashSet<String> hs) throws SQLException {
		createTrg2();
		try {
	        conn.setReadOnly(false);

	        Statement stmt = conn.createStatement();
	        String sql = "DELETE FROM CHINGOO_TR_DEPENDENCY WHERE TRIGGER_NAME='" + trgName + "'";
	        stmt.executeUpdate(sql);

	        stmt.close();

	        for (String str : hs) {
				String[] temp = str.split(" ");
				
	        	sql = "INSERT INTO CHINGOO_TR_DEPENDENCY (TRIGGER_NAME,TARGET_PKG_NAME, TARGET_PROC_NAME) VALUES (?,?,?)";
	        	PreparedStatement pstmt = conn.prepareStatement(sql);
	        
	        	String targetPkg = temp[0];
	        	String targetPrc = temp[1];
	        	String[] target = temp[1].split("\\.");
	        	if (target.length>2) continue;
	        	if (target.length>1) {
	        		targetPkg = target[0];
	        		targetPrc = target[1];
	        	}

	        	if (!isPackageType(targetPkg)) continue;
	        	
	        	try {
//System.out.println(pkgName + " " + temp[0] + " " + targetPkg + " " + targetPrc);
	        		pstmt.setString(1, trgName);
	        		pstmt.setString(2, targetPkg);
	        		pstmt.setString(3, targetPrc);
	        		pstmt.executeUpdate();
	        		pstmt.close();
	        	} catch (SQLException e) {
	        		if (e.getErrorCode()!=1) {
	        			e.printStackTrace();
	        			System.out.println(e.getErrorCode() + "," +trgName + "," + targetPkg + "," + targetPrc);
	        		}
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
   			OutputStream file = new FileOutputStream( "/tmp/oracle-chingoo/" + serFilename );
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
   			OutputStream file = new FileOutputStream( "/tmp/oracle-chingoo/" + serFilename );
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
	        InputStream file = new FileInputStream( "/tmp/oracle-chingoo/" + serFilename );
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
	        InputStream file = new FileInputStream( "/tmp/oracle-chingoo/" + serFilename );
	        InputStream buffer = new BufferedInputStream( file );
	        ObjectInput input = new ObjectInputStream ( buffer );
	        try{
	        	//deserialize the Object
	        	qlink = (ArrayList<QuickLink>)input.readObject();
	        	//System.out.println("deserialize " + serFilename + " " + queryLog.size());
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
		
	}
	
	public void loadPackageTable() {
		cs.loadPackageTable(conn);
	}
	
	public void loadPackageProc() {
		cs.loadPackageProc(conn);
	}
	
	public void loadTriggerTable() {
		cs.loadTriggerTable(conn);
	}
}
