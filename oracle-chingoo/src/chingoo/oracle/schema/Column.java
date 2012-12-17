package chingoo.oracle.schema;

public class Column {
	String id;
	String columnName;
	String dataType;
	String length;
	String precision;
	boolean nullable;
	String defaultValue;
	String comment;
	
	public Column(String id, String columnName, String dataType, String length, String precision, boolean nullable, String defaultValue) {
		this.id = id;
		this.columnName = columnName;
		this.dataType = dataType;
		this.length = length;
		this.precision = precision;
		this.nullable = nullable;
		this.defaultValue = defaultValue;
	}
}
