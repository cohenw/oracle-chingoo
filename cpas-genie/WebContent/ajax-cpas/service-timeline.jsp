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
	int BASE=700;
	int LEFT= 20; 

	Connect cn = (Connect) session.getAttribute("CN");
	ArrayList<String[]> erkeys = new ArrayList<String[]>();


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
	}
	
%>
    <link rel='stylesheet' type='text/css' href='../css/style.css?<%= Util.getScriptionVersion() %>'>

<%-- clnt=<%= clnt %> mkey=<%=mkey%><br/>
min=<%=min %> max=<%= max %> day=<%= totalDays %><br/>

erkeys= <%= erkeys %><br/>
 --%>

<%
	int height = 140;
	int ercnt=0;
	int y = 70;
	for (String eritem[]: erkeys) {
		String erkey = eritem[0];
		String ername = eritem[1];
		
		ArrayList<String[]> srvlist = new ArrayList<String[]>();
		
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
		
		for (String item[]: srvlist) {
				System.out.println(item[0]+","+item[1]+","+item[2]+","+item[3]+","+item[4]+"<br/>");
		}
%>
[<%= erkey %>] <b><%= ername %></b><br/>
<svg width="800" height="<%= height %>" style="margin-left: 20px;">
  <rect width="800" height="<%= height %>" style="fill:rgb(255,255,255);stroke-width:0;stroke:rgb(0,0,0)" />

<%		
		// rectangle
		//int prev = -1; int prevX = 0; String prevDate=""; String prevSrv = "";
		boolean started = false;
		
/* 		for (int i=0;i<srvlist.size();i++) {
			String[] srv = srvlist.get(i);
 */%>

		<line x1="<%= LEFT %>" y1="<%=y %>" x2="<%= BASE + LEFT %>" y2="<%= y %>" style="stroke:gray;stroke-width:1" />
	
<%
		// marker
		int c=0;
		//int prevX= -100;
		
		int lastActiveX = 0; 
		String lastKlass = "";
		String lineColor = "";
		String prevDate=min;
		for (String srv[]: srvlist) {
			String srvname = cn.queryOne("select name from client_service where clnt='"+clnt+"' and srvcode='"+srv[2]+"'");
			int x = Integer.parseInt(srv[4]) + LEFT;
			
			int textY = y - 18;
			int textY2 = y - 36;
			int textY3 = y - 54;
			
			String color = "red";  // full time
			
			int cy=y;
			String points = (x-3) + "," + (cy-10) + "," + (x+3) + "," +  (cy-10) + "," + x + "," + (cy);
			System.out.println(points);
			 
			if (c%2==1) {
				textY = y + 25;
				textY2 = y + 41;
				textY3 = y + 60;
				cy=y;
				points = (x-3) + "," + (cy+10) + "," + (x+3) + ", " +  (cy+10) + "," + x + "," + (cy);
			}
			
			if (srv[3].equals("D")) {  // term
				color = "black";
			} else if (srv[3].equals("H")) {  // leave
				color = "gray";
			} else if (srv[3].equals("L")) {  // part time
				color = "yellow";
			} else if (srv[3].equals("P")) {  // full time
				color = "red";
			}
			
			boolean drawLine = false;
			if (srv[3].equals("D")||srv[3].equals("H")) {
				drawLine = true;
			} else if (srv[3].equals("P") && !lastKlass.equals("D") && !lastKlass.equals("")) {
				drawLine = true;
			} else if (srv[3].equals("L") && !lastKlass.equals("D")&& !lastKlass.equals("")) {
				drawLine = true;
			}
			lastKlass = srv[3];
			
%>
		<polygon points="<%= points %>" style="fill:<%=color%>;stroke:gray;stroke-width:1" />
 		<text x="<%= x-5 %>" y="<%= textY %>" fill="black" style="font-size: 12px;"><%= srv[2] %></text>
 		<text x="<%= x-5 %>" y="<%= textY2 %>" fill="gray" style="font-size: 12px;"><%= srvname %></text>
		<text x="<%= x-5 %>" y="<%= textY3 %>" fill="gray" style="font-size: 12px;"><%= srv[1] %></text>
<%
			if (drawLine && !lineColor.equals("black")) {
				long days=daysBetween(prevDate, srv[1]);
				int daysX = (lastActiveX + Integer.parseInt(srv[4]) ) /2;
				int periodWidth = Integer.parseInt(srv[4]) - lastActiveX;
%>		
		<line x1="<%= lastActiveX + LEFT %>" y1="<%=y %>" x2="<%= x %>" y2="<%= y %>" style="stroke:<%=lineColor %>;stroke-width:3" />
	<%  		if (periodWidth >= 50)  { %>		
		<text x="<%= daysX + LEFT - 22 %>" y="<%= y+16 %>" fill="<%=lineColor %>" style="font-size: 12px;"><%= days %> days</text>
		<text x="<%= daysX + LEFT - 22 %>" y="<%= y+32 %>" fill="<%=lineColor %>" style="font-size: 12px;">(<%= Math.round(days/3.65)/100.0 %> yrs)</text>

<%	
				}
			}
			lastActiveX = Integer.parseInt(srv[4]);
			if (srv[3].equals("L"))	lineColor = "purple";
			else if (srv[3].equals("P")) lineColor = "green";
			else if (srv[3].equals("D")) lineColor = "black";
			else if (srv[3].equals("H")) lineColor = "gray";

			prevDate = srv[1];

			c++;
		}

		ercnt++;
		
		// last condition
		if (lastKlass.equals("P")||lastKlass.equals("L")) {
			int x = BASE + LEFT;
			int cy = y;
			String points = (x-3) + "," + (cy+10) + "," + (x+3) + ", " +  (cy+10) + "," + x + "," + (cy);
			int textY = y + 25;
			int textY2 = y + 41;
			
			long days=daysBetween(prevDate, today);
			int daysX = (lastActiveX + BASE ) /2;
%>		
			<polygon points="<%= points %>" style="fill:yellow;stroke:gray;stroke-width:1" />
			<line x1="<%= lastActiveX + LEFT %>" y1="<%=y %>" x2="<%= BASE + LEFT%>" y2="<%= y %>" style="stroke:<%=lineColor %>;stroke-width:3" />
 			<text x="<%= x-5 %>" y="<%= textY %>" fill="black" style="font-size: 12px;"><%= "Today" %></text>
			<text x="<%= x-5 %>" y="<%= textY2 %>" fill="black" style="font-size: 12px;"><%= today %></text>
			
			<text x="<%= daysX + LEFT - 22 %>" y="<%= y+16 %>" fill="<%=lineColor %>" style="font-size: 12px;"><%= days %> days</text>
			<text x="<%= daysX + LEFT - 22 %>" y="<%= y+32 %>" fill="<%=lineColor %>" style="font-size: 12px;">(<%= Math.round(days/3.65)/100.0 %> yrs)</text>
			
<%			

		}
%>
</svg>
<br/>

<%		
	}
%>

