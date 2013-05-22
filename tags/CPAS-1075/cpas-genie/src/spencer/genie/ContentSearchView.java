package spencer.genie;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;

public class ContentSearchView {

	private Connect cn;
	private static boolean running = false;
	private static String progressStr;
	
	private String searchKeyword;
	private int totalTableCount;
	private int currentTableIndex;
	private String currentTable;
	private int currentRow;

	private ContentSearchView() {
	}
	
	public static ContentSearchView getInstance() {
		return new ContentSearchView(); 
	}
	
	public List<String> search(Connect cn, String searchKeyword) {

		System.out.println("ContentSearchView searchKeyword=" + searchKeyword);
		
		this.cn = cn;
		
		this.searchKeyword = searchKeyword.toUpperCase();
		List<String> tables = new ArrayList<String>();
		
		String qry = "SELECT VIEW_NAME FROM USER_VIEWS ORDER BY 1";
		
		running = true;
		this.progressStr = "";
		
		List<String> tlist = cn.queryMulti(qry);
		totalTableCount = tlist.size();
		currentTableIndex = 0;
		for (String tname : tlist) {
			currentTableIndex ++;
			currentTable = tname;

			progressStr = tname + "<br/>" + progressStr;
			String foundColumn = searchTable(tname);
			if (foundColumn!=null) {
				//System.out.println(tname + "." + foundColumn);
				tables.add(tname);
				progressStr = "&nbsp;&nbsp;&nbsp;<b>" + tname + "." + foundColumn.toLowerCase() + "</b><br/>" + progressStr;
			}
			if (!running) break;
		}

		running = false;

		return tables;
	}
	
	public String searchTable(String tname) {
		String foundColumn = null;
		
		String qry = "SELECT TEXT FROM USER_VIEWS WHERE VIEW_NAME='" + tname + "'";
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
