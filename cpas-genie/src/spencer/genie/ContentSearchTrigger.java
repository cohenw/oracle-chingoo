package spencer.genie;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;

public class ContentSearchTrigger {

	private Connect cn;
	private static boolean running = false;
	private static String progressStr;
	
	private String searchKeyword;
	private int totalTableCount;
	private int currentTableIndex;
	private String currentTable;
	private int currentRow;

	private ContentSearchTrigger() {
	}
	
	public static ContentSearchTrigger getInstance() {
		return new ContentSearchTrigger(); 
	}
	
	public List<String> search(Connect cn, String searchKeyword) {

		System.out.println("ContentSearchTrigger searchKeyword=" + searchKeyword);
		
		this.cn = cn;
		
		this.searchKeyword = searchKeyword.toUpperCase();
		List<String> tables = new ArrayList<String>();
		
		String qry = "SELECT TRIGGER_NAME, TABLE_NAME FROM USER_TRIGGERS ORDER BY 1";
		
		running = true;
		this.progressStr = "";

		List<String[]> tlist = cn.query(qry);
		totalTableCount = tlist.size();
		currentTableIndex = 0;
		for (String[] row : tlist) {
			//String tname = row[2];
			String trgname = row[1];
			currentTableIndex ++;
			currentTable = trgname;

			progressStr = trgname + "<br/>" + progressStr;
			String foundColumn = searchTable(trgname);
			if (foundColumn!=null) {
				//System.out.println(tname + "." + foundColumn);
				tables.add(trgname);
				progressStr = "&nbsp;&nbsp;&nbsp;<b>" + trgname + "." + foundColumn.toLowerCase() + "</b><br/>" + progressStr;
			}
			if (!running) break;
		}

		running = false;
		return tables;
	}
	
	public String searchTable(String tname) {
		String foundColumn = null;
		
		String qry = "SELECT trigger_body FROM USER_TRIGGERS WHERE TRIGGER_NAME='" + tname + "'";
		//System.out.println("qry=" + qry);
		OldQuery q = new OldQuery(cn, qry, null);
		
		ResultSet rs = q.getResultSet();
		try {
			int cnt=0;
			while (rs !=null && rs.next() && cnt <= Def.MAX_SEARCH_ROWS) {
				if (!running) break; 
				cnt++;
				currentRow = cnt;
				for  (int i = 1; i<= rs.getMetaData().getColumnCount(); i++){
					String val = q.getValue(i);
					if (val==null || val.equals("")) continue;
					val = val.toUpperCase();
					
					//System.out.println(val + "," + searchKeyword);
					if (val.contains(searchKeyword)) {
						foundColumn = q.getColumnLabel(i);
						break;
					}
				}
			}
			q.close();
			
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
		
		return foundColumn;
	}
	
	public void cancel() {
		running = false; 
	}
	
	public String getProgress() {
		int percent = 0;
		
		if (totalTableCount >0)
			percent = (100 * currentTableIndex) / totalTableCount;
		
		String status = "Processing " + currentTableIndex + " of " + totalTableCount + "<br/>" +
				currentTable + " " + currentRow + "<br/>";

		if (!running)
			status = "Finished " + currentTableIndex + " of " + totalTableCount +
				"<br/>";
		
		status += 
				"<div class='meter-wrap' id='meter-ex1' style='cursor: pointer'>"+
				"<div class='meter-value' style='background-color: rgb(77, 164, 243); width: " + percent + "%; '>"+
				"<div class='meter-text'>" + percent + "%</div>" +
				"</div>" +
				"</div><br/>";	

		
		return status + progressStr;
		
	}
	
}
