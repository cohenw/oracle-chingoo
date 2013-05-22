package spencer.genie;

import java.util.Date;

/**
 * Record for query log
 * 
 * @author spencer.hwang
 *
 */
public class QueryLog {
	Date qryTime = new Date();	
	String qryString;
	int count;
	
	public QueryLog(String q, int cnt) {
		qryString = q;
		count= cnt;
	}
	
	public String getQueryString() {
		return qryString;
	}
	
	public Date getTime() {
		return qryTime;
	}
	
	public int getCount() {
		return count;
	}
}
