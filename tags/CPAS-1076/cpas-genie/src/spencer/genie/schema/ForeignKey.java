package spencer.genie.schema;

import java.util.ArrayList;

public class ForeignKey {
	String keyName;
	String owner;
	String tableName;
	String rOwner;
	String rKeyName;
	String deleteRule;
	
	ArrayList<String>cols = new ArrayList<String>();
}
