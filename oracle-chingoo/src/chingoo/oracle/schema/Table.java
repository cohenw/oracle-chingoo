package chingoo.oracle.schema;

import java.util.ArrayList;

public class Table {
	String owner;
	String tableName;
	String numRows;

	ArrayList<Column>columns = new ArrayList<Column>();
	PrimaryKey primaryKey = null;
	
	public Table(String owner, String tableName, String numRows) {
		this.owner = owner;
		this.tableName = tableName;
		this.numRows = getNumRows(numRows);
	}
	
	public static String getNumRows (String numRows) {
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
		return numRows;
	}
	
	public String getOwner() {
		return owner;
	}

	public void setOwner(String owner) {
		this.owner = owner;
	}

	public String getTableName() {
		return tableName;
	}

	public void setTableName(String tableName) {
		this.tableName = tableName;
	}

	public String getNumRows() {
		return numRows;
	}

	public void setNumRows(String numRows) {
		this.numRows = numRows;
	}

	public ArrayList<Column> getColumns() {
		return columns;
	}

	public void setColumns(ArrayList<Column> columns) {
		this.columns = columns;
	}
	
	public void addColumn(Column c) {
		columns.add(c);
	}
	
	public String toString() {
		String res = this.owner + "." + this.tableName + " " + this.numRows + "\n" +
				"Columns=" + this.columns.size() + " pk=" + primaryKey;
		return res;
	}
	
	public void setPrimaryKey(PrimaryKey pk) {
		this.primaryKey = pk;
	}
}
