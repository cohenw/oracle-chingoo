package chingoo.oracle;

import java.io.*;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.List;

public class CacheSchema implements Serializable {

	private static final long serialVersionUID = 2L;
	
	public String dbUrl = null;
	private transient Connect cn = null;
	private transient Connection conn = null;
	private String message = "";
	
	public String schemaName;
	public String connectMessage = "";
	public Date loadDate;
	private long lastMillis = System.currentTimeMillis(); 

	public ArrayList<String> tables = new ArrayList<String>();
	public ArrayList<String> views = new ArrayList<String>();
	public ArrayList<String> synonyms = new ArrayList<String>();
	public ArrayList<String> packages = new ArrayList<String>();
	public ArrayList<String> types = new ArrayList<String>();
	
	public ArrayList<String> procedures = new ArrayList<String>();
	public ArrayList<String> psynonyms = new ArrayList<String>();
	public ArrayList<String> temptables = new ArrayList<String>();

	public transient HashSet<String> tableSet = new HashSet<String>();
	public transient HashSet<String> viewSet = new HashSet<String>();
	public transient HashSet<String> synonymSet = new HashSet<String>();
	public transient HashSet<String> procedureSet = new HashSet<String>();
	public transient HashSet<String> psynonymSet = new HashSet<String>();
	public transient HashSet<String> packageSet = new HashSet<String>();
	public transient HashSet<String> typeSet = new HashSet<String>();
	
	public transient HashSet<String> temptableSet = new HashSet<String>();
	public Hashtable<String,String> constraints = new Hashtable<String, String>();

	public Hashtable<String,String> pkByTab = new Hashtable<String, String>(); 
	public Hashtable<String,String> pkByCon = new Hashtable<String, String>();
	public List<ForeignKey> foreignKeys = new ArrayList<ForeignKey>();

	public HashMap<String, String> viewTables = new HashMap<String, String>();
	public HashMap<String, String> packageTables = new HashMap<String, String>();
	public HashMap<String, String> packageProcTables = new HashMap<String, String>();
	public HashMap<String,String> packageProc = new HashMap<String, String>();
	public HashMap<String, String> triggerTables = new HashMap<String, String>();

	public CacheSchema() {
	}
	
	public CacheSchema(Connect cn, String databaseUrl, String schemaName) throws SQLException {
		this.cn = cn;
		this.conn = cn.getConnection();
		this.schemaName = schemaName.toUpperCase();
		dbUrl = databaseUrl.toLowerCase();
		
		loadData();
	}
	
	public void reload(Connect cn) throws SQLException {
		this.cn = cn;
		this.conn = cn.getConnection();
		
		loadData();
	}
	
	private void loadData() throws SQLException {
		clear();

		loadTVS();
		loadConstraints();
		loadPrimaryKeys();
		loadForeignKeys();

		loadTempTables();
		loadViewTables();
		this.buildHashSets();

		loadPackageTable(conn);
		loadPackageProc(conn);
		loadTriggerTable(conn);
		
		loadDate = new Date();
	}
	
	public void clear() {
		tables.clear();
		views.clear();
		synonyms.clear();
		packages.clear();
		types.clear();
		
		tableSet.clear();
		viewSet.clear();
		synonymSet.clear();
		packageSet.clear();
		types.clear();
		procedureSet.clear();

		psynonymSet.clear();
		temptables.clear();
	}
	
	public void addMessage(String msg) {
		if (cn!=null)
			cn.addMessage(msg);
	}

    public String getSchemaName() {
    	return this.schemaName;
    }

	private synchronized void loadTVS() throws SQLException {
		addMessage("Loading Database Objects...");

		tables.clear();
		views.clear();
		synonyms.clear();
		packages.clear();
		types.clear();
		
		Statement stmt = conn.createStatement();
//		String qry = "SELECT object_name, object_type FROM user_objects WHERE object_type in ('TABLE','VIEW','SYNONYM', 'PACKAGE', 'PROCEDURE','FUNCTION','TYPE')";
		String qry = "SELECT object_name, object_type, owner FROM all_objects WHERE owner not in ('PUBLIC') and object_type in ('TABLE','VIEW','SYNONYM', 'PACKAGE', 'PROCEDURE','FUNCTION') " +
				"union all select object_name, object_type, owner FROM all_objects WHERE owner ='" + this.schemaName.toUpperCase() + "' and object_type='TYPE'";
		ResultSet rs = stmt.executeQuery(qry);
		while (rs.next()){
			String name = rs.getString(1);
			String type = rs.getString(2);
			String owner = rs.getString(3);

			String fname = name;
			if (!owner.equalsIgnoreCase(this.getSchemaName())) fname = owner +"." + name;
			
			if (type.equals("TABLE")) tables.add(fname);
			else if (type.equals("VIEW")) views.add(fname);
			else if (type.equals("SYNONYM")) synonyms.add(fname);
			else if (type.equals("PACKAGE")) packages.add(fname);
			else if (type.equals("TYPE") && owner.equals(schemaName)) types.add(fname);
			else if (type.equals("PROCEDURE")||type.equals("FUNCTION")) procedures.add(fname);
		}
		
		rs.close();
		stmt.close();
		
		addMessage("Loaded Tables " + tables.size());
		addMessage("Loaded Views " + views.size());
		addMessage("Loaded Synonyms " + synonyms.size());
		addMessage("Loaded Packages " + packages.size());
		addMessage("Loaded Types " + types.size());
		addMessage("Loaded Procedure/Functions " + procedureSet.size());

		psynonyms.clear();
		stmt = conn.createStatement();
		qry = "SELECT synonym_name FROM all_synonyms WHERE owner='PUBLIC' AND table_owner = 'SYS' AND synonym_name > 'A' AND synonym_name < 'a'";
		rs = stmt.executeQuery(qry);
		while (rs.next()){
			String name = rs.getString(1);

			psynonyms.add(name);
		}
		
		rs.close();
		stmt.close();
		
		addMessage("Loaded Public Synonyms " + psynonymSet.size());
	}
	
	public void buildHashSets() {
		
		tableSet.clear();
		viewSet.clear();
		synonymSet.clear();
		procedureSet.clear();
		psynonymSet.clear();
		temptableSet.clear();
		packageSet.clear();
		typeSet.clear();

		tableSet.addAll(tables);
		viewSet.addAll(views);
		synonymSet.addAll(synonyms);
		procedureSet.addAll(procedures);
		psynonymSet.addAll(psynonyms);
		temptableSet.addAll(temptables);
		packageSet.addAll(packages);
		typeSet.addAll(types);
		
	}
	private synchronized void loadConstraints() {
		constraints.clear();
		try {
       		Statement stmt = conn.createStatement();
       		String sql = "SELECT CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, POSITION from user_cons_columns where position is not null order by 1,2,4";
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

	private synchronized void loadPrimaryKeys() {
		pkByTab.clear();
		pkByCon.clear();
		try {
       		Statement stmt = conn.createStatement();
       		String sql = "SELECT CONSTRAINT_NAME, TABLE_NAME  from user_constraints where CONSTRAINT_TYPE = 'P'";
       				
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
	
	public synchronized String getTableNameByPrimaryKey(String kname) {
		String tName = pkByCon.get(kname.toUpperCase());
		
		// check for other owner
		if (tName == null) {
			String owner = cn.queryOne("SELECT OWNER FROM ALL_CONSTRAINTS WHERE CONSTRAINT_NAME='" + kname +"'");
			if (owner != null)
				return getTableNameByPrimaryKey(owner, kname);
		}
		
		return tName;
	}

	public synchronized String getTableNameByPrimaryKey(String owner, String kname) {
		if (owner==null) return this.getTableNameByPrimaryKey(kname);

		String qry = "SELECT OWNER||'.'||TABLE_NAME FROM ALL_CONSTRAINTS WHERE OWNER='" +
				owner + "' AND CONSTRAINT_NAME='" + kname + "'";
		return cn.queryOne(qry);
	}

	private synchronized void loadTempTables() {
		temptables.clear();
		String sql = "SELECT TABLE_NAME FROM USER_TABLES WHERE TEMPORARY='Y'";
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(sql);	

       		while (rs.next()) {
       			String tabName = rs.getString(1);
       			temptables.add(tabName);
       		}
       		rs.close();
       		stmt.close();

		} catch (SQLException e) {
             System.err.println ("loadTempTables");
             e.printStackTrace();
             message = e.getMessage();
 		}
		addMessage("Loaded Temp Tabels " + temptables.size());

	}

	private synchronized void loadViewTables() {
		viewTables.clear();
		
		String sql = "SELECT NAME, REFERENCED_NAME from user_dependencies " +
   				"where name in ( " +
   				"SELECT name  from user_dependencies " + 
   				"WHERE type='VIEW' AND REFERENCED_TYPE IN ('TABLE') " + 
   				"group by name having count(*)=1 " +
   				") AND REFERENCED_NAME NOT IN ('DUAL','STANDARD') AND REFERENCED_TYPE IN ('TABLE')";
		
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

	public synchronized void loadPackageTable(Connection conn) {
		packageTables.clear();
		packageProcTables.clear();
		if (!this.isTVS("CHINGOO_PA_TABLE")) return;
		
		String sql = "SELECT PACKAGE_NAME, TABLE_NAME, SUM(OP_SELECT), SUM(OP_INSERT), SUM(OP_UPDATE), SUM(OP_DELETE) FROM CHINGOO_PA_TABLE GROUP BY PACKAGE_NAME, TABLE_NAME";
		
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

		sql = "SELECT PACKAGE_NAME||'.'||PROCEDURE_NAME, TABLE_NAME, OP_SELECT, OP_INSERT, OP_UPDATE, OP_DELETE FROM CHINGOO_PA_TABLE";
		
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
	
	public synchronized void loadTriggerTable(Connection conn) {
		triggerTables.clear();
		if (!this.isTVS("CHINGOO_TR_TABLE")) return;
		
		String sql = "SELECT TRIGGER_NAME, TABLE_NAME, OP_SELECT, OP_INSERT, OP_UPDATE, OP_DELETE FROM CHINGOO_TR_TABLE";
		
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
	
	public synchronized void loadPackageProc(Connection conn) {
		packageProc.clear();
		
		if (!this.isTVS("CHINGOO_PA_PROCEDURE")) return;
		
		String sql = "SELECT PACKAGE_NAME||'.'||PROCEDURE_NAME KEY, PROCEDURE_LABEL FROM CHINGOO_PA_PROCEDURE";
		
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

	public boolean isTVS(String oname) {
		
		if (tableSet.contains(oname)) return true;
		if (viewSet.contains(oname)) return true;
		if (synonymSet.contains(oname)) return true;
		
		return false;
	}

	public boolean isType(String oname) {
		return typeSet.contains(oname);
	}
    public List<String> getTables() {
    	return this.tables;
    }

    public String getTable(int idx) {
    	return (String) tables.get(idx);
    }

    public List<String> getViews() {
    	return this.views;
    }
   
}
