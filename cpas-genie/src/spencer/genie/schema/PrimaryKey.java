package spencer.genie.schema;

import java.util.ArrayList;

public class PrimaryKey {
	String keyName;
	String owner;
	String tableName;
	
	ArrayList<String>cols = new ArrayList<String>();
	
	public PrimaryKey(String keyName) {
		this.keyName = keyName;
	}
	
	public String toString() {
		return this.keyName;
	}
}
