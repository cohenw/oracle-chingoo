package chingoo.oracle;

import java.io.Serializable;
import java.util.Date;

public class QuickLink implements Serializable {

	Date time = new Date();	
	String type;
	String name;

	public QuickLink(String type, String name) {
		this.type = type;
		this.name = name;
	}
	
	public Date getTime() {
		return time;
	}

	public void setTime() {
		this.time = new Date();
	}

	public String getType() {
		return type;
	}

	public String getName() {
		return name;
	}

}