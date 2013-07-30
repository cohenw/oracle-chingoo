package spencer.genie;

import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.StringTokenizer;

public class PackageTableWorker {

	private Connect cn;
	private static boolean running = false;
	private static String progressStr;
	
	private int totalCount;
	private int currentIndex;
	private String currentPkg;

	private PackageTableWorker() {
	}
	
	public static PackageTableWorker getInstance() {
		return new PackageTableWorker(); 
	}
	
	public List<String> startWork(Connect cn) throws IOException, SQLException {

		System.out.println("PackageTableWorker started.");
		
		this.cn = cn;
		
		//List<String> packages = new ArrayList<String>();
		
		String q = "SELECT OBJECT_NAME FROM USER_OBJECTS WHERE OBJECT_TYPE='PACKAGE BODY' ORDER BY 1";
		if (cn.isTVS("GENIE_PA")) {
			q = "SELECT object_name FROM user_objects A where object_type='PACKAGE BODY' AND NOT EXISTS (SELECT 1 FROM GENIE_PA WHERE PACKAGE_NAME=A.OBJECT_NAME AND CREATED > A.LAST_DDL_TIME) ORDER BY 1";
		}
		
		running = true;
		this.progressStr = "";
		
		List<String[]> pkgs = cn.query(q, false);
		totalCount = pkgs.size();
		currentIndex = 0;
		for (int k=0;k<pkgs.size();k++) {
			currentIndex ++;
			currentPkg = pkgs.get(k)[1]; 
			System.out.println(currentPkg);

			progressStr = currentPkg + "<br/>" + progressStr;
			q = "SELECT TYPE, LINE, TEXT FROM USER_SOURCE WHERE NAME='" + currentPkg +"' AND TYPE = 'PACKAGE BODY' ORDER BY TYPE, LINE";
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
			PackageTable pt = new PackageTable(currentPkg, text);
			//System.out.println("text=[" + text + "]");
			cn.AddPackageTable(currentPkg, pt.getHM(), pt.getHMIns(), pt.getHMUpd(), pt.getHMDel());
			
			HyperSyntax hs = new HyperSyntax();
			String syntax = hs.getHyperSyntax(cn, text, "PACKAGE BODY", currentPkg);
			HashSet<String> packageProc = hs.getPackageProcedure();
//System.out.println(packageProc);

			cn.AddPackageProcDetail(currentPkg, pt.getPD());
			cn.AddPackageProc(currentPkg, packageProc);
			hs = null;
			list=null;
			
			if (!running) break;
		}

		running = false;
		cn.loadPackageTable();
		cn.loadPackageProc();
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
				currentPkg + "<br/>";

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
