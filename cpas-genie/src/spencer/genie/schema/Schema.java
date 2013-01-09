package spencer.genie.schema;

import java.util.ArrayList;
import java.util.Hashtable;

public class Schema {
	ArrayList<Table> tables = new ArrayList<Table>();
	Hashtable<String,Table>htTable = new Hashtable<String,Table>(); 

	ArrayList<View> views = new ArrayList<View>();
	Hashtable<String,View>htView = new Hashtable<String,View>(); 

	public void addTable(Table t) {
		tables.add(t);
		
		String key = t.getOwner() + "." + t.getTableName();
		htTable.put(key, t);
	}

	public void addView(View v) {
		views.add(v);
		
		String key = v.getOwner() + "." + v.getViewName();
		htView.put(key, v);
	}

	public ArrayList<Table> getTables() {
		return this.tables;
	}
	
	public ArrayList<View> getViews() {
		return this.views;
	}
	
	public void addColumn(String owner, String tname, Column c) {
		String key = owner + "." + tname;
		Table t = htTable.get(key);
		
		if (t != null) {
			t.addColumn(c);
		} else {
			View v = htView.get(key);
			if (v != null) {
				v.addColumn(c);
			} else 
				System.out.println("not found " + key);
		}
	}
	
	public void addPrimaryKey(String owner, String tname, PrimaryKey pk) {
		String key = owner + "." + tname;
		Table t = htTable.get(key);
		
		if (t != null) {
			t.setPrimaryKey(pk);
		}
	}
	
}
