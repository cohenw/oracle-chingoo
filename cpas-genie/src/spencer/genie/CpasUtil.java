package spencer.genie;

import java.sql.Connection;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.List;

public class CpasUtil {
	private Connect cn = null;
	public Hashtable<String, String> htCode = new Hashtable<String, String>();
	public Hashtable<String, String> htCapt = new Hashtable<String, String>();
	public HashSet<String> hsTable = new HashSet<String>();
	public HashSet<String> hsTableLoaded = new HashSet<String>();
	boolean isCpas = false;
	int cpasType = 1;
	public String buildNo;

	String planTable = "SV_PLAN";
	
	String[] exceptions = { 
			"MEMBER_STATUS.VALUE", 
			"PLAN_STATUS.VALUE",
			"EMPLOYER_STATUS.VALUE", 
			"MEMBER_EMPLOYER_STATUS.VALUE",
			"MEMBER_PLAN_STATUS.VALUE", 
			"PERSON_STATUS.VALUE", 
			"CALC_STATUS.VALU",
			"-MEMBER_SERVICE.SRVCODE" 
	};
	
	// default code group setting
	String[][] defaultCode = {
			{"CALC.STATUS", "CS"},
			{"CALC.CPAS_PTATUS", "CPAS_PS"},
			{"CALC.CCLASS", "CPAS_CTYPE"},
			{"FORMULA.PAGE", "PG"}
	};

	String calcStage[][] = {
			{"AA", "Request"},
			{"SA", "Saving"},
			{"ZZ", "Processed"},
			{"CC", "Cancelled"},
			{"RR", "Recalculated"},
			{"FF", "Finalizing"}
	};

	String rqStatus[][] = {
			{"R", "Reprocess"},
			{"P", "Pending"},
			{"B", "Building"},
			{"X", "Executing"},
			{"W", "Waiting"},
			{"F", "Finished"},
			{"E", "Error"},
			{"C", "Cancelled"}
	};
	
	String tranId[][] = {
			{"EO", "Row Edited"},
			{"PE", "Post Error"},
			{"PO", "Post OK"},
			{"PR", "Post Reversed"},
			{"TE", "Test Error"},
			{"TI", "Test Imported"},
			{"TO", "Test OK"},
			{"TW", "Test Warning"},
			{"TU", "Test Unknown"}
	};
	
	String accountClass[][] = {
			{"AR", "Receivable"},
			{"AP", "Payable"},
			{"C", "DC"},
			{"P", "DB"},
			{"B", "GB"},
			{"MP", "Portfolio"}
	};

	String fireWhen[][] = {
			{"A", "Always"},
			{"N", "Never"},
			{"S", "Made Submit"},
			{"F", "Failed Submit"},
			{"B", "Aborted Edit"},
			{"C", "Condition"},
			{"E", "Browser Commit"}
	};

	public String logicalLink2[][] = {
			{"MKEY", "CLNT", "MEMBER"},
			{"ERKEY", "CLNT", "EMPLOYER"},
			{"PLAN", "CLNT", "SV_PLAN"},
			{"PAYMENTID", "PENID", "PENSIONER_PAYMENT"},
			{"SPROCESSID", "PROCESSID", "BATCH_QUEUE"},
			{"TASKKEY", "BATCHKEY", "BATCHCAT_TASK"},
			{"EVENT", "PROCESS", "CPAS_PROCESS_EVENT"}
	};
			
	public String logicalLink[][] = {
			{"PROCESSID", "BATCH"},
			{"PROCESSKEY", "BATCH"},
			{"BATCHRUNID", "BATCH"},
			{"FEED_PROCESSID", "BATCH"},
			{"PENID", "PENSIONER"},
			{"PERSONID", "PERSON"},
			{"ACCOUNTID", "ACCOUNT"},
			{"CALCID", "CALC"},
			{"ERRORID", "ERRORCAT"},
			{"REQUESTID", "REQUEST"},
			{"BATCHKEY", "BATCHCAT"},
			{"REPORTID", "CPAS_REPORT"},
			//{"REPORTID", "REPORTCAT"},
			{"REQUESTKEY", "REQUESTCAT"},
			{"FUND", "FUND"},
			{"CTYPE", "CPAS_CALCTYPE"},
			{"SESSIONID", "CPASSESSION"},
			{"CHEQUEID", "CHEQUE"},
			{"TAXID", "TAX"},
			{"LUMPSUMID", "LUMPSUM"},
			{"GLID", "GL_ACCOUNT"},
			{"ORGID", "ORGANIZATION"},
			{"COUNTRY", "COUNTRY"},
			{"CURRENCY", "CURRENCY"},
			{"JMLFILEID", "CPAS_DEFLOB"},
			{"TAXTYPE", "TAXTYPE"},
			{"REMARKID", "REMARK"},
			{"CLNT", "CLIENT"},
			{"RULEID", "RULE"},
			{"CODE", "CPAS_CODE"},
			{"CODE2", "CPAS_CODE"},
			{"PROCESS", "CPAS_PROCESS"},
			{"FKEY", "FORMULA"},
			{"WIZARD", "CPAS_WIZARD"}
	};

	// for special case (with table name)
	public String logicalLinkSpec[][] = {
			{"REPORTCAT.FILEID", "SYSBINFILE"},
			{"CPAS_WIZARD_PAGE_WEB.FORMNAME", "CPAS_JML"}
	};
	
	public CpasUtil(Connect cn) {
		this.cn = cn;

		for (String ex : exceptions) {
			int idx = ex.indexOf(".");
			String tname = ex.substring(0, idx);
			String cname = ex.substring(idx + 1);

			htCode.put(tname + "." + cname, "");
			htCapt.put(tname + "." + cname, "");
			hsTable.add(tname);
		}
		
		if (cn.isTVS("CPAS_TABLE")) { 
			String qry = "SELECT distinct table_name FROM user_tab_cols where column_name in ('CLNT','ERKEY','CTYPE') UNION  "
					+ "SELECT TNAME FROM CPAS_TABLE A WHERE EXISTS (SELECT 1 FROM TAB WHERE TNAME=A.TNAME)";
			if (cn.getTargetSchema() != null)
				qry = "SELECT distinct table_name FROM all_tab_cols where owner = '" + cn.getTargetSchema()+ "' and column_name in ('CLNT','ERKEY','CTYPE') UNION  "
						+ "SELECT TNAME FROM CPAS_TABLE A WHERE EXISTS (SELECT 1 FROM TAB WHERE TNAME=A.TNAME)";
			
			List<String> tbls = cn.queryMulti(qry);
			for (String tbl : tbls) {
				hsTable.add(tbl);
				isCpas = true;
				cpasType = 1;
				
				// check if there is CPAS_TAB table
			}
		}
		
		if (cn.isTVS("ADD$TABLE")) { 
			if (!isCpas) {
				String qry = "SELECT distinct table_name FROM user_tab_cols where column_name in ('CLNT','ERKEY','CTYPE') UNION  "
						+ "SELECT TNAME FROM ADD$TABLE A WHERE EXISTS (SELECT 1 FROM TAB WHERE TNAME=A.TNAME)";
				List<String> tbls = cn.queryMulti(qry);
				for (String tbl : tbls) {
					hsTable.add(tbl);
					isCpas = true;
					cpasType = 5;
				}
			}
		}
		
		if (cpasType==1) {
			// check for CPAS_TAB table
			String qry = "SELECT COUNT(*) FROM USER_OBJECTS WHERE OBJECT_NAME='CPAS_TAB'";
			if (cn.getTargetSchema() != null)
				qry = "SELECT COUNT(*) FROM ALL_OBJECTS WHERE OWNER = '" + cn.getTargetSchema() + "' AND OBJECT_NAME='CPAS_TAB'";
			String tmp = cn.queryOne(qry);
			if (tmp.equals("0")) cpasType = 2;
		}
		
		String qry = "SELECT COUNT(*) FROM USER_OBJECTS WHERE OBJECT_NAME='SV_PLAN'";
		if (cn.getTargetSchema() != null)
			qry = "SELECT COUNT(*) FROM ALL_OBJECTS WHERE OWNER = '" + cn.getTargetSchema() + "' AND OBJECT_NAME='SV_PLAN'";
		
		String tmp = cn.queryOne(qry);
		if (tmp.equals("0")) {
			this.planTable = "PLAN";
			logicalLink2[2][2] = "PLAN";
		}
		
		if (cn.isTVS("SV_MEMBER")) {
			logicalLink2[0][2] = "SV_MEMBER";
		}
		
		if (!cn.isTVS("CPAS_REPORT")) {
			logicalLink[9][1] = "REPORTCAT"; 
		}
		
		System.out.println("isCpas="+isCpas);
		System.out.println("cpasType="+cpasType);
		System.out.println("plan table=" + planTable);
		
		if (cn.isTVS("CPAS_VERSION")) {
			buildNo = cn.queryOne("SELECT MAX(BUILD_NO) FROM CPAS_VERSION");
			if (buildNo != null && buildNo.length()>4) buildNo = buildNo.substring(0,4);
			//System.out.println("BuildNo=" + buildNo);
		}
	}
/*
	public String getCodeValueCustom(String tname, String cname, String value, Query q) {
		// exception handling
		String temp = tname + "." + cname;

		// handle exception
		if (temp.equals("CALC.STAGE")) {
			for (int i=0; i<calcStage.length;i++) {
				if (value.equals(calcStage[i][0])) return calcStage[i][1];
			}
			return null;
		} else if (temp.equals("BATCH_QUEUE.TASKKEY")) {
			String qry = "SELECT TASKNAME FROM BATCHCAT_TASK WHERE BATCHKEY='" + q.getValue("BATCHKEY") + "' AND TASKKEY = '" + value + "'";
			
			return cn.queryOne(qry);
		}
		
		return null;
	}
*/
	
	public String getCodeValue(String tname, String cname, String value, Query q) {
		if (!isCpas)
			return "";

		loadTable(tname);
		if (value == null || value.equals(""))
			return null;

		// exception handling
		String temp = tname + "." + cname;
		for (String ex : exceptions) {
			if (temp.equals(ex)) {
				String grup = q.getValue("GRUP");

				return getGrupValue(grup, value, q);
			}
		}

		// handle exception
		if (temp.equals("CALC.STAGE")) {
			for (int i=0; i<calcStage.length;i++) {
				if (value.equals(calcStage[i][0])) return calcStage[i][1];
			}
			return null;
		} else if (temp.endsWith(".ACCTCLASS")) {
			for (int i=0; i<accountClass.length;i++) {
				if (value.equals(accountClass[i][0])) return accountClass[i][1];
			}
			return null;
/*			
		} else if (temp.endsWith(".FIREWHEN")) {
			for (int i=0; i<fireWhen.length;i++) {
				if (value.equals(fireWhen[i][0])) return fireWhen[i][1];
			}
			return null;
*/			
		} else if (temp.equals("REQUEST.STATUS")||temp.equals("REQUEST_TASK.STATUS")) {
			for (int i=0; i<rqStatus.length;i++) {
				if (value.equals(rqStatus[i][0])) return rqStatus[i][1];
			}
			return null;
		} else if (temp.equals("BATCH_QUEUE.TASKKEY") || temp.equals("REPORTHISTORY_TASK") || temp.equals("BATCHSCHEDULE_TASK")) {
			String qry = "SELECT TASKNAME FROM BATCHCAT_TASK WHERE BATCHKEY='" + q.getValue("BATCHKEY") + "' AND TASKKEY = '" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.equals("REQUEST_TASK.TASKKEY")) {
			String qry = "SELECT TASKNAME FROM TASKCAT WHERE TASKKEY='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".TASKKEY")) {
			String qry = "SELECT TASKNAME FROM BATCHCAT_TASK WHERE BATCHKEY='" + q.getValue("BATCHKEY") + "' AND TASKKEY = '" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.equals("CALC_DATE.RDATE") /* && value.startsWith("1800")*/ ) {
			String qry = "SELECT NAME FROM CPAS_DATE WHERE RDATE= TO_DATE('" + value + "','YYYY-MM-DD')";
			return cn.queryOne(qry);
		} else if (temp.equals("TASK.TTYPE")) {
			String qry = "SELECT CAPT FROM CPAS_TASKTYPE WHERE TTYPE='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.equals("MEMBER_RELATION.OWNER")) {
			String qry = "SELECT UNAME FROM PERSON WHERE PERSONID='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".PLAN") && !tname.equals(planTable) && q.getValue("CLNT") !=null && !q.getValue("CLNT").equals("") && planTable.equals("SV_PLAN")) {
			String qry = "SELECT SNAME FROM " + planTable +" WHERE CLNT='"+ q.getValue("CLNT") +"' AND PLAN='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".REPORTID") && !tname.equals("CPAS_REPORT")) {
			String qry = "SELECT DESCRIPTION FROM CPAS_REPORT WHERE REPORTID='" + value + "'";
			if (!cn.isTVS("CPAS_REPORT"))
				qry = "SELECT DESCRIPTION FROM REPORTCAT WHERE REPORTID='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".KITCODE") && !tname.equals("CPAS_KIT")) {
			String qry = "SELECT KITNAME FROM CPAS_KIT WHERE KITCODE='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".CLNT") && !tname.equals("CLIENT") && cn.hasColumn("CLIENT", "SNAME")) {
			String qry = "SELECT SNAME FROM CLIENT WHERE CLNT='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".VKEY") && !tname.equals("CPAS_VALIDATION")) {
			String qry = "SELECT CAPTION FROM CPAS_VALIDATION WHERE VKEY='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".BATCHKEY") && !tname.equals("BATCHCAT")) {
			String qry = "SELECT BATCHNAME FROM BATCHCAT WHERE BATCHKEY='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".GLID") && !tname.equals("GL_ACCOUNT")) {
			String qry = "SELECT DESCR FROM GL_ACCOUNT WHERE GLID='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".ORGID") && !tname.equals("ORGANIZATION")) {
			String qry = "SELECT SNAME FROM ORGANIZATION WHERE ORGID='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".COUNTRY") && !tname.equals("COUNTRY")) {
			String qry = "SELECT NAME FROM COUNTRY WHERE COUNTRY='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".CURRENCY") && !tname.equals("CURRENCY")) {
			String qry = "SELECT LNAME FROM CURRENCY WHERE CURRENCY='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".TAXTYPE") && !tname.equals("TAXTYPE")) {
			String qry = "SELECT NAME FROM TAXTYPE WHERE TAXTYPE='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".FUND") && !tname.equals("FUND")) {
			String qry = "SELECT SNAME FROM FUND WHERE FUND='" + value + "'";
			if (!cn.isTVS("FUND") && cn.isTVS("PLAN_FUND_NAME"))
				qry = "SELECT NAME FROM PLAN_FUND_NAME WHERE FUND='" + value + "' AND ROWNUM=1";  // for APS
			return cn.queryOne(qry);
		} else if (temp.endsWith(".PERSONID") && !tname.equals("PERSON")) {
			String qry = "SELECT UNAME FROM PERSON WHERE PERSONID='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith("PERSONID") && !tname.equals("PERSON")) {
			String qry = "SELECT UNAME FROM PERSON WHERE PERSONID='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".ERRORID") && !tname.equals("ERRORCAT")) {
			String qry = "SELECT SHORTDESC FROM ERRORCAT WHERE ERRORID='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".REQUESTKEY") && !tname.equals("REQUESTCAT")) {
			String qry = "SELECT REQUESTNAME FROM REQUESTCAT WHERE REQUESTKEY='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith("REPORTCAT.FILEID")) {
			String qry = "SELECT FILENAME FROM SYSBINFILE WHERE FILEID='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".PROCESS") && !tname.equals("CPAS_PROCESS")) {
			String qry = "SELECT NAME FROM CPAS_PROCESS WHERE PROCESS='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".EVENT") && !tname.equals("CPAS_PROCESS_EVENT")) {
			String qry = "SELECT NAME FROM CPAS_PROCESS_EVENT WHERE PROCESS='" + q.getValue("PROCESS") + "' AND EVENT = '" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".TRANID") && tname.startsWith("BATCH_BUF")) {
			for (int i=0; i<tranId.length;i++) {
				if (value.equals(tranId[i][0])) return tranId[i][1];
			}
			return null;
		} else if (temp.endsWith(".CODE") && !tname.equals("CPAS_CODE")) {
			String qry = "SELECT CAPTION FROM CPAS_CODE WHERE GRUP='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".FKEY") && !tname.equals("FORMULA")) {
			String qry = "SELECT FDESC FROM FORMULA WHERE FKEY='" + value + "' AND ROWNUM=1";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".PENTYPE") && !tname.equals("PLAN_PENSIONTYPE")) {
			String qry = "SELECT NAME FROM PLAN_PENSIONTYPE WHERE PENTYPE='" + value + "' AND ROWNUM=1";
			return cn.queryOne(qry);
		} else if (temp.equals("CALC_CUSTOM.KEY")) {
			String qry = "SELECT NAME FROM PLAN_CALCTYPE_CUSTOM WHERE KEY='" + value + "' AND ROWNUM=1";
			return cn.queryOne(qry);
		} else if (temp.equals("CPAS_TABLE_COL.CODE2")) {
			String qry = "SELECT CAPTION FROM CPAS_CODE WHERE GRUP='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.equals("CALC_REPORT_FIELD.FIELD")) {
			String qry = "SELECT DESCR FROM PLAN_CALCTYPE_REPFIELD WHERE FIELD='" + value + "' AND ROWNUM=1";
			return cn.queryOne(qry);
		} else if (temp.equals("CALC_REPORT_DATE.FIELD")) {
			String qry = "SELECT DESCR FROM PLAN_CALCTYPE_REPDATE WHERE FIELD='" + value + "' AND ROWNUM=1";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".PROCESSID")||temp.endsWith(".BATCHRUNID")) {
			String qry = "SELECT BATCHKEY FROM BATCH WHERE PROCESSID='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".TTYPE")) {
			String qry = "SELECT CAPT FROM CPAS_TASKTYPE WHERE TTYPE='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".WIZARD")) {
			String qry = "SELECT CAPTION FROM CPAS_WIZARD WHERE WIZARD='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith("CONNSESSION_PROCESS.PROCESSKEY")) {
			String qry = "SELECT NAME FROM CPAS_PROCESS WHERE PROCESS='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.startsWith("CPAS_CALCTYPE.DEFAULT_") && temp.endsWith("DATE")) {
			String qry = "SELECT NAME FROM CPAS_DATE WHERE RDATE=to_date('" + value.substring(0,10) + "','yyyy-mm-dd')";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".RDATE") && value.startsWith("1800")) {
			String qry = "SELECT NAME FROM CPAS_DATE WHERE RDATE=to_date('" + value.substring(0,10) + "','yyyy-mm-dd')";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".RULETYPE") && !tname.equals("EXPOSE_RULE")) {
			String qry = "SELECT CAPTION||'-'||NAME FROM EXPOSE_RULE WHERE RULETYPE='" + value + "'";
			return cn.queryOne(qry);
		} else if (temp.endsWith(".GRUP") && !tname.equals("CPAS_CODE")) {
			String qry = "SELECT CAPTION FROM CPAS_CODE WHERE GRUP='" + value + "'";
			return cn.queryOne(qry);
		}
		
		String key = (tname + "." + cname).toUpperCase();
		if (key.equals("MEMBER_STATUS.GRUP") || key.equals("CALC_STATUS.GRUP")) {
			String qry = "SELECT CAPTION FROM CPAS_CODE WHERE grup = '" + value + "'";
			if (cpasType==5) 
				qry = "SELECT CAPT FROM CODE_CAPTION WHERE grup = '" + value + "'";
//			System.out.println("**** " + qry);
			
			return cn.queryOne(qry);
		}
		
		String grup = htCode.get(key);

		if (grup == null) {
			if (cname.equals("CLNT"))
				grup = "CL";
			if (cname.equals("ERKEY"))
				grup = "ER";
			if (cname.equals("CTYPE"))
				grup = "CTC";
		}

		// override
		// override if there is data in GENIE_TABLE_COL
		String qry2 = "SELECT CPAS_CODE FROM GENIE_TABLE_COL WHERE TNAME='" + tname + "' AND CNAME='"+cname+"'";
		String res = cn.queryOne(qry2, false);
		if (res != null && !res.equals(""))
			grup = res;
		
		
		String qry = "SELECT SOURCE, SELECTSTMT FROM CPAS_CODE WHERE GRUP='"
				+ grup + "'";
		if (cpasType == 5)
			qry = "SELECT TYPE, (SELECT STMTCODE FROM CODE_SELECT WHERE GRUP=A.GRUP) STMT FROM CODE A WHERE GRUP='"
					+ grup + "'";
		List<String[]> list = cn.query(qry);
//System.out.println(qry);

		if (list.size() < 1) {
			return null;
		}
		
		String source = list.get(0)[1];
		String selectstmt = list.get(0)[2];

		if (source.equals("P")) {  // procedure call
			if (grup.equals("FN")) {
				grup = "FND";
			
				qry = "SELECT SOURCE, SELECTSTMT FROM CPAS_CODE WHERE GRUP='" + grup + "'";
				if (cpasType == 5)
					qry = "SELECT TYPE, (SELECT STMTCODE FROM CODE_SELECT WHERE GRUP=A.GRUP) STMT FROM CODE A WHERE GRUP='"
						+ grup + "'";
				list = cn.query(qry);

				if (list.size() < 1) return null;
				source = list.get(0)[1];
				selectstmt = list.get(0)[2];
			}
			if (cpasType ==5) {
				qry = "SELECT SOURCE, SELECTSTMT FROM CPAS_CODE WHERE GRUP='" + grup + "'";
				if (cpasType == 5)
					qry = "SELECT TYPE, (SELECT STMTCODE FROM CODE_SELECT WHERE GRUP=A.GRUP) STMT FROM CODE A WHERE GRUP='"
						+ grup + "'";
				list = cn.query(qry);

				if (list.size() < 1) return null;
				source = list.get(0)[1];
				selectstmt = list.get(0)[2];
			}
		}
		
//System.out.println("source=" + source);
		if (source.equals("T")) {
			qry = "SELECT NAME FROM CPAS_CODE_VALUE WHERE GRUP='" + grup
					+ "' AND VALU='" + value + "'";
			String name = cn.queryOne(qry);
			return name;
		}

		if (source.equals("S") || source.equals("3") || source.equals("A")) {
			qry = getQryStr(selectstmt, value, q);
			return qry;
		}

		if (cpasType == 5) {
			if (source.equals("C") || source.equals("P")) {
				qry = getQryStr(selectstmt, value, q);
				return qry;
			}
			
			qry = "SELECT NAME FROM CODE_VALUE_NAME WHERE GRUP='" + grup
					+ "' AND VALU='" + value + "'";
			String name = cn.queryOne(qry);
			return name;
		}

		return source;
	}

	public String getGrupValue(String grup, String value, Query q) {
		if (value == null || value.equals(""))
			return null;

		String qry = "SELECT SOURCE, SELECTSTMT FROM CPAS_CODE WHERE GRUP='"
				+ grup + "'";
		if (cpasType == 5)
			qry = "SELECT TYPE, (SELECT STMTCODE FROM CODE_SELECT WHERE GRUP=A.GRUP) STMT FROM CODE A WHERE GRUP='"
					+ grup + "'";
		List<String[]> list = cn.query(qry);

		if (list.size() < 1)
			return null;
		String source = list.get(0)[1];
		String selectstmt = list.get(0)[2];

		if (source.equals("T")) {
			qry = "SELECT NAME FROM CPAS_CODE_VALUE WHERE GRUP='" + grup
					+ "' AND VALU='" + value + "'";
			String name = cn.queryOne(qry);
			return name;
		}

		if (source.equals("S")) {
			qry = getQryStr(selectstmt, value, q);
			return qry;
		}
		if (source.equals("3")) {  // 3 column
			qry = getQryStr(selectstmt, value, q);
			return qry;
		}

		if (source.equals("U")) {
			selectstmt = "SELECT NAME FROM CODE_VALUE_NAME WHERE GRUP='" + grup +"' AND VALU ='" + value + "'";
			qry = cn.queryOne(selectstmt);
			return qry;
		}

		return source;
	}

	public String getCodeCapt(String tname, String cname) {
		loadTable(tname);
		String key = tname + "." + cname;

		// exception handling
		for (String ex : exceptions) {
			if (key.equals(ex)) {
				return "code/value for GRUP";
			}
		}
		String capt = htCapt.get(key);

		// override if there is data in GENIE_TABLE_COL
		String qry = "SELECT CAPT FROM GENIE_TABLE_COL WHERE TNAME='" + tname + "' AND CNAME='"+cname+"'";
		String res = cn.queryOne(qry, false);
		if (res != null && !res.equals(""))
			return res;
		
		return capt;
	}

	public String getCpasComment(String tname) {
		if (!isCpas)
			return "";
		String qry = "SELECT DESCR FROM CPAS_TABLE WHERE TNAME='" + tname + "' AND GNAME IN ('SYSTEM','BATCH','RULES','ACTIVEDD')";
		if (cpasType == 5)
			qry = "SELECT DESCR FROM ADD$TABLE WHERE TNAME='" + tname + "'";

		String res = cn.queryOne(qry);

		if (res == null)
			res = "";
		return res;
	}

	public String getCodeGrup(String tname, String cname) {
		loadTable(tname);

		String key = tname + "." + cname;
		String grup = htCode.get(key);

		if (grup == null) {
			if (cname.equals("CLNT"))
				grup = "CL";
			if (cname.equals("ERKEY"))
				grup = "ER";
			if (cname.equals("CTYPE"))
				grup = "CTC";
/*			if (tname.equals("CALC") && cname.equals("STATUS"))
				grup = "CS";
			if (tname.equals("CALC") && cname.equals("CPAS_PTATUS"))
				grup = "CPAS_PS";
			if (tname.equals("CALC") && cname.equals("CCLASS"))
				grup = "CPAS_CTYPE";
*/		}
		
		// override if there is data in GENIE_TABLE_COL
		String qry = "SELECT CPAS_CODE FROM GENIE_TABLE_COL WHERE TNAME='" + tname + "' AND CNAME='"+cname+"'";
		String res = cn.queryOne(qry, false);
		if (res != null && !res.equals(""))
			return res;
		
		return grup;
	}

	public String getQryStr(String selectstmt, String value, Query q) {
		if (selectstmt == null || q==null)
			return null;
		String qry = selectstmt.replaceAll("\n", " ");

		String dynamic[] = { ":CLNT", ":MKEY", ":PLAN", ":ERKEY", ":LANG", ":GRUP" };
		// :CLNT, :MKEY
		if (qry.indexOf(":") > 0) {
			for (String token : dynamic) {
				int idx = qry.indexOf(token);
				if (idx > 0) {
					String col = token.substring(1);
					String val = q.getValue(col);
					if (col.equals("LANG"))
						val = "E"; // English
					if (val != null && !val.startsWith("Out of Index")) {
						if (val.equals("")) {
							qry = qry.replaceAll(token, token.substring(1));
						} else {
							qry = qry.replaceAll(token, "'" + val + "'");
						}
					} else
						qry = qry.replaceAll(token, col);
				}
			}
			// System.out.println(qry);
		}

		// if qry contains :, discard
		if (qry.indexOf(":") > 0) {
			qry = qry.replaceAll(":", "");
			//return qry;
			//return null;
		}
//System.out.println(qry);
		// remove order by
		int idx = qry.indexOf(" ORDER BY ");
		if (idx > 0)
			qry = qry.substring(0, idx);

		List<String[]> list = cn.query(qry);
		if (list.size() < 1)
			return null;

		for (int i = 0; i < list.size(); i++) {
			String code = list.get(i)[1];
			if (code != null && code.equals(value))
				return list.get(i)[2];
		}
		return null;
	}

	public boolean hasTable(String tname) {
		if (!isCpas)
			return false;
		loadTable(tname);
		return hsTableLoaded.contains(tname);
	}

	public void loadTable(String tname) {
		if (!isCpas)
			return;
		if (hsTableLoaded.contains(tname))
			return;

		String qry = "SELECT TNAME, CNAME, CODE, CAPT FROM CPAS_TABLE_COL WHERE (TNAME = '"
				+ tname + "' OR TNAME = 'ARRAY$" + tname + "') AND (CODE IS NOT NULL OR CAPT IS NOT NULL)";
		if (cpasType == 5)
			qry = "SELECT TNAME, CNAME, CODE, CAPT FROM ADD$TABLE_COL WHERE TNAME = '"
					+ tname
					+ "' "
					+ " AND (CODE IS NOT NULL OR CAPT IS NOT NULL)";

		List<String[]> list = cn.query(qry);

		// recover by TREEVIEW
		if (/*list.size()==0 */ cn.isTVS("TREEACTION_STMT") && cn.isTVS("CPAS_TABLE_COL")) {
			
			String tmp = "SELECT actionstmt from TREEACTION_STMT WHERE (sdi, schema, actionid) in ( " +
						"SELECT sdi, schema, actionid FROM TREEACTION_STMT WHERE actiontype='MS' AND actionstmt like '%FROM " + tname + " %') and actiontype='MT' and actionstmt not like 'SELECT%'" +
						"union " +
						"SELECT actionstmt from TREEACTION_STMT where (sdi, schema, actionid) in ( " +
						"SELECT sdi, schema, actionid FROM TREEACTION_STMT WHERE actiontype='DS' AND actionstmt like '%FROM " + tname + " %') and actiontype='DT' and actionstmt not like 'SELECT%'";		
			
			qry = "SELECT TNAME, CNAME, CODE, CAPT FROM CPAS_TABLE_COL WHERE (TNAME IN ( " + tmp + " ))" +
					" AND (CODE IS NOT NULL OR CAPT IS NOT NULL)";
			list = cn.query(qry);
		}
		
		for (String[] row : list) {
			String cname = row[2];
			String code = row[3];
			String capt = row[4];

			String key = tname + "." + cname;
			if (code != null && !code.equals(""))
				htCode.put(key, code);
			if (capt != null && !capt.equals(""))
				htCapt.put(key, capt);
		}
		
		// add default code group
		for (String[] row : defaultCode) {
			htCode.put(row[0], row[1]);
		}
		
		hsTableLoaded.add(tname);
	}

	public String getQryReplaced(String qry) {
		// get the maximum sessionid
		String sid = cn.queryOne("SELECT MAX(SESSIONID) FROM CONNSESSION",
				false);
		String clnt = cn
				.queryOne("SELECT tagcvalue FROM CONNSESSION_DATA WHERE SESSIONID = "
						+ sid + " AND tagname='CLNT'");
		String mkey = cn
				.queryOne("SELECT tagcvalue FROM CONNSESSION_DATA WHERE SESSIONID = "
						+ sid + " AND tagname='MKEY'");
		String plan = cn
				.queryOne("SELECT tagcvalue FROM CONNSESSION_DATA WHERE SESSIONID = "
						+ sid + " AND tagname='PLAN'");
		String personid = cn
				.queryOne("SELECT tagnvalue FROM CONNSESSION_DATA WHERE SESSIONID = "
						+ sid + " AND tagname='PERSONID'");

		String q = qry;
		q = q.replaceAll(":S.CLNT", "'" + clnt + "'");
		q = q.replaceAll(":S.MKEY", "'" + mkey + "'");
		q = q.replaceAll(":S.PLAN", "'" + plan + "'");
		q = q.replaceAll(":S.PERSONID", "'" + personid + "'");

		return q;
	}

	public String getColumnCaption(String tname, String cname) {
		String qry = "SELECT CAPT FROM CPAS_TABLE_COL WHERE TNAME='" + tname
				+ "' AND CNAME='" + cname + "'";
		if (cpasType == 5)
			qry = "SELECT CAPT FROM ADD$TABLE_COL WHERE TNAME='" + tname
					+ "' AND CNAME='" + cname + "'";
		String caption = cn.queryOne(qry);

		return caption;
	}

	public String getColumnType(String tname, String cname) {
		String qry = "SELECT TYPE FROM CPAS_TABLE_COL WHERE TNAME='" + tname
				+ "' AND CNAME='" + cname + "'";
		if (cpasType == 5)
			qry = "SELECT TYPE FROM ADD$TABLE_COL WHERE TNAME='" + tname
					+ "' AND CNAME='" + cname + "'";
		String type = cn.queryOne(qry);

		return type;
	}

	public String getColumnPict(String tname, String cname) {
		String qry = "SELECT PICT FROM CPAS_TABLE_COL WHERE TNAME='" + tname
				+ "' AND CNAME='" + cname + "'";
		if (cpasType == 5)
			qry = "SELECT PICT FROM ADD$TABLE_COL WHERE TNAME='" + tname
					+ "' AND CNAME='" + cname + "'";
		String pict = cn.queryOne(qry);

		return pict;
	}

	public boolean isCpas() {
		return this.isCpas;
	}
	
	public String getCpasCodeTable() {
		if (cpasType<5) return "CPAS_CODE";
		if (cpasType==5) return "CODE";
		
		return "CPAS_CODE";
	}
	
	public int getCpasType() {
		return cpasType;
	}

	public String getLinkedTable(String tname, String colName) {
		for (int j=0; j < logicalLink.length; j++) {
			if (colName.equals(logicalLink[j][0]) && !tname.equals(logicalLink[j][1])) {
				String lname = logicalLink[j][1];
				if (lname.equals("BATCH") && tname.startsWith("PROCESS")) lname = null;
				return lname;
			}
		}
		
		// override logical link for GENIE_TABLE_COL
		return getLogicalLink(tname, colName);
		
		//return null;
	}
	
	public String getLogicalLink(String tname, String cname) {
		// override if there is data in GENIE_TABLE_COL
		String qry2 = "SELECT LINK_TO FROM GENIE_TABLE_COL WHERE TNAME='" + tname + "' AND CNAME='"+cname+"'";
		String res = cn.queryOne(qry2, false);
		return res;
	}
}
