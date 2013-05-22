package spencer.genie;

import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.StringTokenizer;

public class TriggerTableWorker {

	private Connect cn;
	private static boolean running = false;
	private static String progressStr;
	
	private int totalCount;
	private int currentIndex;
	private String currentTrg;

	private TriggerTableWorker() {
	}
	
	public static TriggerTableWorker getInstance() {
		return new TriggerTableWorker(); 
	}
	
	public List<String> startWork(Connect cn) throws IOException, SQLException {

		System.out.println("TriggerTableWorker started.");
		
		this.cn = cn;
		
		//List<String> packages = new ArrayList<String>();
		
		String q = "SELECT OBJECT_NAME FROM USER_OBJECTS WHERE OBJECT_TYPE='TRIGGER' ORDER BY 1";
		if (cn.isTVS("GENIE_TR")) {
			q = "SELECT object_name FROM user_objects A where object_type='TRIGGER' AND NOT EXISTS (SELECT 1 FROM GENIE_TR WHERE TRIGGER_NAME=A.OBJECT_NAME AND CREATED > A.LAST_DDL_TIME) ORDER BY 1";
		}
		
		running = true;
		this.progressStr = "";
		
		List<String[]> pkgs = cn.query(q, false);
		totalCount = pkgs.size();
		currentIndex = 0;
		for (int k=0;k<pkgs.size();k++) {
			currentIndex ++;
			currentTrg = pkgs.get(k)[1]; 
			System.out.println(currentTrg);

			progressStr = currentTrg + "<br/>" + progressStr;
			q = "SELECT TYPE, LINE, TEXT FROM USER_SOURCE WHERE NAME='" + currentTrg +"' AND TYPE = 'TRIGGER' ORDER BY TYPE, LINE";
			List<String[]> list = cn.query(q, 20000, false);
			
			String text = "";
			int line = 0;
			for (int i=0;i<list.size();i++) {
				String ln = list.get(i)[3];
				line = Integer.parseInt(list.get(i)[2]);
				if (!ln.endsWith("\n")) ln += "\n";
				//text += Util.escapeHtml(ln);
				text += ln;
				
			}
			
			// remove the header - search declare or begin
			text = text.toUpperCase();
			int idx1 = text.indexOf("DECLARE");
			int idx2 = text.indexOf("BEGIN");
			int idx = idx1;
			if (idx < 0) idx = idx2;
			if (idx > 0)
				text = text.substring(idx);
			
			TriggerTable tt = new TriggerTable(currentTrg, text);
			//System.out.println("text=[" + text + "]");
			System.out.println("tt.getHM()="+ tt.getHM());
			cn.AddTriggerTable(currentTrg, tt.getHM());
/*			
			HyperSyntax hs = new HyperSyntax();
			String syntax = hs.getHyperSyntax(cn, text, "PACKAGE BODY", currentPkg);
			HashSet<String> packageProc = hs.getPackageProcedure();
//System.out.println(packageProc);

			cn.AddPackageProcDetail(currentPkg, pt.getPD());
			cn.AddPackageProc(currentPkg, packageProc);
			hs = null;
			list=null;
*/			
			if (!running) break;
		}

		running = false;
		cn.loadTriggerTable();
		return null;
	}
	
	public void cancel() {
		running = false; 
	}
	
	public String getProgress() {
		int percent = 0;
		
		if (totalCount >0)
			percent = (100 * currentIndex) / totalCount;
		
		String status = "Processing " + currentIndex + " of " + totalCount + "<br/>" +
				currentTrg + "<br/>";

		if (!running)
			status = "Finished " + currentIndex + " of " + totalCount +
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
