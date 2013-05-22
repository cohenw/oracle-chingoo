package spencer.genie.schema;

import java.util.ArrayList;

public class View {
	String owner;
	String viewName;

	ArrayList<Column>columns = new ArrayList<Column>();
	
	public View(String owner, String viewName) {
		this.owner = owner;
		this.viewName = viewName;
	}
	
	public String getOwner() {
		return owner;
	}

	public void setOwner(String owner) {
		this.owner = owner;
	}

	public String getViewName() {
		return viewName;
	}

	public void setViewName(String viewName) {
		this.viewName = viewName;
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
		String res = this.owner + "." + this.viewName + "\n" +
				"Columns=" + this.columns.size();
		return res;
	}

}
