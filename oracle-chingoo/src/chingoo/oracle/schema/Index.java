package chingoo.oracle.schema;

import java.util.ArrayList;

public class Index {
	String owner;
	String indexName;
	String tableName;
	String tableOwner;
	String indexType;
	String uniqueness;
	
	ArrayList<String>cols = new ArrayList<String>();
}
