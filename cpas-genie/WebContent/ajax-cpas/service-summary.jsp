<%@ page language="java" 
	import="java.util.*" 
	import="java.text.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	import="oracle.jdbc.OracleTypes"
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%!

public static long daysBetween(String date1, String date2) {
	 
	//HH converts hour in 24 hours format (0-23), day calculation
	SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");

	Date d1 = null;
	Date d2 = null;

	try {
		d1 = format.parse(date1);
		d2 = format.parse(date2);

		//in milliseconds
		long diff = d2.getTime() - d1.getTime();
		if (diff <0) diff = -diff;

		long diffSeconds = diff / 1000 % 60;
		long diffMinutes = diff / (60 * 1000) % 60;
		long diffHours = diff / (60 * 60 * 1000) % 24;
		long diffDays = diff / (24 * 60 * 60 * 1000);

		System.out.println(diffDays + " days, " + date1 + " : " + date2);
/* 		System.out.print(diffHours + " hours, ");
		System.out.print(diffMinutes + " minutes, ");
		System.out.print(diffSeconds + " seconds.");
 */
		return diffDays;
	} catch (Exception e) {
		e.printStackTrace();
	}

	return -1;
}
%>
<%
	int BASE=760;

	Connect cn = (Connect) session.getAttribute("CN");
	ArrayList<String[]> erkeys = new ArrayList<String[]>();
	ArrayList<String[]> srvlist = new ArrayList<String[]>();

	String clnt = request.getParameter("clnt");
	String mkey = request.getParameter("mkey");

	String min="", max="", today="";
	
	String qry = "select min(edate), max(edate), trunc(sysdate) from member_service where clnt='"+clnt+"' and mkey='"+mkey+"'";
	Query q = new Query(cn, qry, false);
	q.rewind(1000, 1);
	if (q.next()) {
		min = q.getValue(0);
		max = q.getValue(1);
		today = q.getValue(2);
		//out.println("min="+min + ",max="+max+",sysdate="+today);
	}

	qry = "select edate, srvcode, (select klass from client_service where clnt=a.clnt and srvcode=a.srvcode) klass " +
	 	"from member_service a where clnt='"+clnt+"' and mkey='"+mkey+"' and edate = " + 
	 	"(select max(edate) from member_service a where clnt='"+clnt+"' and mkey='"+mkey+"')";
	
	q = new Query(cn, qry, false);
	q.rewind(1000, 1);
	while (q.next()) {
		if (q.getValue(2).equals("P")||q.getValue(2).equals("L")) {
			// if the last servcode is Full time / Part time, extend the period
			max = today;
		}
	}
	//out.println("\nmin="+min + ",max="+max+",sysdate="+today);
	long totalDays= daysBetween(min, max);
	if (totalDays==0) totalDays = 1;
	
	qry = "select erkey, min(edate), max(edate) from member_service where clnt='"+clnt+"' and mkey='"+mkey+"' group by erkey order by 2";
	q = new Query(cn, qry, false);
	q.rewind(1000, 1);
	while (q.next()) {
		String erkey = q.getValue(0);
		String ername = cn.queryOne("select sname from employer where clnt='"+clnt+"' and erkey='"+erkey+"'");
		String[] eritem = {erkey, ername};
		erkeys.add(eritem);
		Util.p(q.getValue(0) + "," + q.getValue(1) + "," + q.getValue(2));
		
		String qry2="select edate, srvcode, (select klass from client_service where clnt=a.clnt and srvcode=a.srvcode) klass " +
		"from member_service a where clnt='"+clnt+"' and mkey='"+mkey+"' and erkey='" + erkey + "' order by edate";
		Query q2 = new Query(cn, qry2, false);
		q2.rewind(1000, 1);
		while (q2.next()) {
			Util.p(" * " + min + "," + q2.getValue(0) + "," + q2.getValue(1) + "," + q2.getValue(2) + " " + daysBetween(min, q2.getValue(0)));

			long d = daysBetween(min, q2.getValue(0));
			long dc = (d * BASE / totalDays);
			String item[] = {erkey, q2.getValue(0), q2.getValue(1), q2.getValue(2), ""+dc};
			srvlist.add(item);
		}
	}
	
%>
    <link rel='stylesheet' type='text/css' href='../css/style.css?<%= Util.getScriptionVersion() %>'>

clnt=<%= clnt %> mkey=<%=mkey%><br/>
min=<%=min %> max=<%= max %> day=<%= totalDays %><br/>

erkeys= <%= erkeys %><br/>


<%

 for (String item[]: srvlist) {
	out.println(item[0]+","+item[1]+","+item[2]+","+item[3]+","+item[4]+"<br/>");
}


int height = erkeys.size() * 60 + 40;
%>

<svg width="1000" height="<%= height %>">
  <rect width="1000" height="<%= height %>" style="fill:rgb(255,255,255);stroke-width:1;stroke:rgb(0,0,0)" />

<%
	int ercnt=0;
	int y = 0;
	for (String eritem[]: erkeys) {
		y = ercnt * 60 + 40;
%>
		<text x="10" y="<%= y %>" fill="black" style="font-size: 14px;"><%= eritem[0] %></text>
		<text x="10" y="<%= y + 15 %>" fill="black" style="font-size: 14px;"><%= eritem[1] %></text>
<%		
		// rectangle
		int prev = -1; int prevX = 0; String prevDate=""; String prevSrv = "";
		boolean started = false;
		String color = "red";
		for (int i=0;i<srvlist.size();i++) {
			String[] srv = srvlist.get(i);
%>

		<line x1="100" y1="<%=y %>" x2="<%= BASE + 100 %>" y2="<%= y %>" style="stroke:gray;stroke-width:1" />
	
<%
			if (!srv[0].equals(eritem[0])) {
				if (started) {
					Util.p("%%%%%%%%%%%%%%%%%%%%%%%%%%% prevSrv=" + prevSrv);
					// check if the last prev is active
					if (prevSrv.equals("P")||prevSrv.equals("L")) {
						long days=daysBetween(prevDate, today);
						long width= 100; //BASE - prevX;
%>						
						<rect x="<%=prevX + 100 %>" y="<%= y-3 %>" width="<%= width %>" height="5" style="fill:rgb(255,0,0);stroke-width:1;stroke:rgb(0,0,0)" />
						<text x="<%= prevX + 100 + 95 %>" y="<%= y-12 %>" fill="black" style="font-size: 12px;"><%= days %> days (<%= Math.round(days/3.65)/100.0 %> yr)</text>
<%
					}
				}
				continue;
			}
			started = true;
	
			if (srv[3].equals("P")) {  // full time
				prev = i;
				prevX = Integer.parseInt(srv[4]);
				prevDate = srv[1];
				prevSrv = srv[3];
				color = "red";
				continue;
			} else if (srv[3].equals("L")) { //part time
				prev = i;
				prevX = Integer.parseInt(srv[4]);
				prevDate = srv[1];
				prevSrv = srv[3];
				color = "yellow";
				continue;
			} else if (srv[3].equals("D") || srv[3].equals("H") || srv[3].equals("T")) { // term, leave, disablity
				prev = -1;
				prevSrv = "";
			}
			long days=daysBetween(prevDate, srv[1]);
//			long width= days * BASE / totalDays;
			long width= Integer.parseInt(srv[4]) - prevX;
%>
			<rect x="<%=prevX + 100 %>" y="<%= y-3 %>" width="<%= width %>" height="5" style="fill:rgb(255,0,0);stroke-width:1;stroke:rgb(0,0,0)" />
			<text x="<%= prevX + 100 + 95 %>" y="<%= y-12 %>" fill="black" style="font-size: 12px;"><%= days %> days (<%= Math.round(days/3.65)/100.0 %> yr)</text>
<%			
		}

		// last condition
		if (started) {
			Util.p("%%%%%%%%%%%%%%%%%%%%%%%%%%% prevSrv=" + prevSrv);
			// check if the last prev is active
			if (prevSrv.equals("P")||prevSrv.equals("L")) {
				long days=daysBetween(prevDate, today);
				long width= BASE - prevX;
%>						
				<rect x="<%=prevX + 100 %>" y="<%= y-3 %>" width="<%= width %>" height="5" style="fill:rgb(255,0,0);stroke-width:1;stroke:rgb(0,0,0)" />
				<text x="<%= prevX + 100 + 95 %>" y="<%= y-12 %>" fill="black" style="font-size: 12px;"><%= days %> days (<%= Math.round(days/3.65)/100.0 %> yr)</text>
<%
			}
		}

		// circle
		for (String srv[]: srvlist) {
			if (!srv[0].equals(eritem[0])) continue;
			
			int x = Integer.parseInt(srv[4]) + 100;
			color = "red";
			int textY = y - 12;
			int cy=y-3;
			String points = (x-3) + "," + (cy-7) + "," + (x+3) + ", " +  (cy-7) + "," + x + "," + (cy+5);
			
			 
			if (srv[3].equals("D")) {
				color = "black";
				textY = y + 22;
				cy=y+3;
				points = (x-3) + "," + (cy+7) + "," + (x+3) + ", " +  (cy+7) + "," + x + "," + (cy-5);
			}
%>
<%-- 		<circle cx="<%= x %>" cy="<%= cy %>" r="8" stroke="black" stroke-width="1" fill="<%= color %>" />
 --%>		<polygon points="<%= points %>" style="fill:lime;stroke:purple;stroke-width:1" />
		<text x="<%= x -5 %>" y="<%= textY %>" fill="black" style="font-size: 12px;"><%= srv[2] %> <%= srv[1] %></text>
<%			
		}

		ercnt++;
	}
%>
</svg>

