package chingoo.oracle;

import java.util.List;

public class SchemaDiff {

	Connect cn1;
	Connect cn2;
	String progressStr = "";
	String resultStr = "";

	boolean running = false;
	int totalCount = 0;
	int currentIndex = 0;
	String currentName = "";
	String incl;
	String excl;

	public SchemaDiff(Connect cn1, Connect cn2) {
		this.cn1 = cn1;
		this.cn2 = cn2;
	}

	public void startCompare(String object, String incl, String excl, String sql) {
		running = true;
		progressStr = "";
		resultStr = "";
		currentIndex = 0;

		this.incl = incl;
		this.excl = excl;

		if (object.equals("T"))
			compareTable();

		if (object.equals("V"))
			compareView();
		if (object.equals("S"))
			compareSynonym();
		if (object.equals("P"))
			compareProgram();
		if (object.equals("TR"))
			compareTrigger();

		if (object.equals("Q"))
			compareQuery(sql);

		addProgress("Done.");

		this.resultStr = "Finished <br/><br/>" + resultStr;

		// cn2.disconnect();
		running = false;
	}

	public void compareQuery(String sql) {
		// System.out.println(sql);

		List<String[]> c1 = cn1.query(sql, false);
		List<String[]> c2 = cn2.query(sql, false);

		boolean diff = false;

		if (c1.size() != c2.size())
			diff = true;
		for (int i = 0; c2.size() > 0 && i < c1.size(); i++) {
			String[] a1 = c1.get(i);
			String[] a2 = c2.get(i);

			for (int j = 0; j < a1.length; j++) {
				if (a1[j] == null) {
					if (a2[j] != null) {
						diff = true;
						break;
					}
				} else if (!a1[j].equals(a2[j])) {
					diff = true;
					break;
				}
			}

			if (diff)
				break;
		}

		if (diff) {
			addResult("RESULT", c1, c2);
		} else {
			resultStr = "Identical!";
		}
	}

	public void compareTable() {
		String qry1 = "SELECT table_name FROM user_tables where 1=1 ";

		if (incl != null && !incl.equals(""))
			qry1 += " and table_name like '%" + incl.toUpperCase() + "%'";
		if (excl != null && !excl.equals(""))
			qry1 += " and table_name not like '%" + excl.toUpperCase() + "%'";

		qry1 += " order by table_name";
		// System.out.println(qry1);

		List<String> t1 = cn1.queryMulti(qry1, false);
		List<String> t2 = cn2.queryMulti(qry1, false);

		addProgress("Schema 1 has " + t1.size() + " tables, Schema 2 has "
				+ t2.size() + " tables.");

		totalCount = t1.size();

		for (String tname : t1) {
			if (!running)
				break;
			currentIndex++;
			currentName = tname;
			addProgress(tname);

			// addProgress(tname);
			String qry2 = "SELECT column_id, column_name, data_type, data_length, data_precision, data_scale, nullable "
					+ "FROM user_tab_cols where table_name= '"
					+ tname
					+ "' order by column_id";

			List<String[]> c1 = cn1.query(qry2, false);
			List<String[]> c2 = cn2.query(qry2, false);

			boolean diff = false;
			if (c1.size() != c2.size()) {
				diff = true;
			} else {
				for (int i = 0; i < c1.size(); i++) {
					String[] a1 = c1.get(i);
					String[] a2 = c2.get(i);

					for (int j = 0; j < a1.length; j++) {
						if (a1[j] == null) {
							if (a2[j] != null) {
								diff = true;
								break;
							}
						} else if (!a1[j].equals(a2[j])) {
							diff = true;
							break;
						}
					}
					if (diff)
						break;
				}
			}
			if (diff) {
				addProgress("  <b>" + tname + "</b> is different");
				addResult(tname, c1, c2);
			}
		}
	}

	public void compareView() {
		String qry1 = "SELECT view_name from user_views where 1=1 ";

		if (incl != null && !incl.equals(""))
			qry1 += " and view_name like '%" + incl.toUpperCase() + "%'";
		if (excl != null && !excl.equals(""))
			qry1 += " and view_name not like '%" + excl.toUpperCase() + "%'";

		qry1 += " order by view_name";

		List<String> t1 = cn1.queryMulti(qry1, false);
		List<String> t2 = cn2.queryMulti(qry1, false);

		addProgress("Schema 1 has " + t1.size() + " views, Schema 2 has "
				+ t2.size() + " views.");

		totalCount = t1.size();
		currentIndex = 0;

		for (String tname : t1) {
			if (!running)
				break;
			currentIndex++;
			currentName = tname;
			addProgress(tname);

			// addProgress(tname);
			String qry2 = "SELECT text " + "FROM user_views where VIEW_NAME= '"
					+ tname + "'";

			List<String[]> c1 = cn1.query(qry2, false);
			List<String[]> c2 = cn2.query(qry2, false);

			boolean diff = false;
			if (c1.size() != c2.size()) {
				diff = true;
			} else {
				for (int i = 0; i < c1.size(); i++) {
					String[] a1 = c1.get(i);
					String[] a2 = c2.get(i);

					for (int j = 0; j < a1.length; j++) {
						if (a1[j] == null) {
							if (a2[j] != null) {
								diff = true;
								break;
							}
						} else if (!a1[j].trim().equals(a2[j].trim())) {
							diff = true;
							break;
						}
					}
					if (diff)
						break;
				}
			}
			if (diff) {
				addProgress("  <b>" + tname + "</b> is different");
				addResult(tname, c1, c2);
			}
		}
	}

	public void compareSynonym() {
		String qry1 = "SELECT synonym_name from user_synonyms where 1=1";

		if (incl != null && !incl.equals(""))
			qry1 += " and synonym_name like '%" + incl.toUpperCase() + "%'";
		if (excl != null && !excl.equals(""))
			qry1 += " and synonym_name not like '%" + excl.toUpperCase() + "%'";

		qry1 += " order by synonym_name";

		List<String> t1 = cn1.queryMulti(qry1, false);
		List<String> t2 = cn2.queryMulti(qry1, false);

		addProgress("Schema 1 has " + t1.size() + " synonyms, Schema 2 has "
				+ t2.size() + " synonyms.");

		totalCount = t1.size();
		currentIndex = 0;

		for (String tname : t1) {
			if (!running)
				break;
			currentIndex++;
			currentName = tname;
			addProgress(tname);

			// addProgress(tname);
			String qry2 = "SELECT table_name "
					+ "FROM user_synonyms where synonym_name = '" + tname + "'";

			List<String[]> c1 = cn1.query(qry2, false);
			List<String[]> c2 = cn2.query(qry2, false);

			boolean diff = false;
			if (c1.size() != c2.size()) {
				diff = true;
			} else {
				for (int i = 0; i < c1.size(); i++) {
					String[] a1 = c1.get(i);
					String[] a2 = c2.get(i);

					for (int j = 0; j < a1.length; j++) {
						if (a1[j] == null) {
							if (a2[j] != null) {
								diff = true;
								break;
							}
						} else if (!a1[j].equals(a2[j])) {
							diff = true;
							break;
						}
					}
					if (diff)
						break;
				}
				if (diff) {
					addProgress("  <b>" + tname + "</b> is different");
					addResult(tname, c1, c2);
				}

			}
		}
	}

	public void compareProgram() {
		String qry1 = "SELECT OBJECT_NAME FROM USER_OBJECTS WHERE object_type IN ('PACKAGE','PROCEDURE','FUNCTION','TYPE')";

		if (incl != null && !incl.equals(""))
			qry1 += " and OBJECT_NAME like '%" + incl.toUpperCase() + "%'";
		if (excl != null && !excl.equals(""))
			qry1 += " and OBJECT_NAME not like '%" + excl.toUpperCase() + "%'";

		qry1 += " order by OBJECT_NAME";

		List<String> t1 = cn1.queryMulti(qry1, false);
		List<String> t2 = cn2.queryMulti(qry1, false);

		addProgress("Schema 1 has " + t1.size() + " objects, Schema 2 has "
				+ t2.size() + " objects.");

		totalCount = t1.size();
		currentIndex = 0;

		for (String tname : t1) {
			if (!running)
				break;
			currentIndex++;
			currentName = tname;
			addProgress(tname);

			// addProgress(tname);
			String qry2 = "SELECT text FROM USER_SOURCE WHERE name='" + tname
					+ "' ORDER BY type, line";

			List<String[]> c1 = cn1.query(qry2, false);
			List<String[]> c2 = cn2.query(qry2, false);

			boolean diff = false;
			if (c1.size() != c2.size()) {
				diff = true;
				addProgress("  <b>" + tname + "</b> is different");
				addResult(tname, c1, c2);
			} else {

				for (int i = 0; i < c1.size(); i++) {
					String[] a1 = c1.get(i);
					String[] a2 = c2.get(i);

					for (int j = 0; j < a1.length; j++) {

						if (a1[j] != null)
							a1[j] = a1[j].trim();
						if (a2[j] != null)
							a2[j] = a2[j].trim();

						if (a1[j] == null) {
							if (a2[j] != null) {
								diff = true;
								break;
							}
						} else if (!a1[j].equals(a2[j])) {
							diff = true;
							break;
						}
					}
					if (diff)
						break;
				}
				if (diff) {
					addProgress("  <b>" + tname + "</b> is different");
					addResult(tname, c1, c2);
				}

			}
		}
	}

	public void compareTrigger() {
		String qry1 = "SELECT OBJECT_NAME FROM USER_OBJECTS WHERE object_type IN ('TRIGGER')";

		if (incl != null && !incl.equals(""))
			qry1 += " and OBJECT_NAME like '%" + incl.toUpperCase() + "%'";
		if (excl != null && !excl.equals(""))
			qry1 += " and OBJECT_NAME not like '%" + excl.toUpperCase() + "%'";

		qry1 += " order by OBJECT_NAME";

		List<String> t1 = cn1.queryMulti(qry1, false);
		List<String> t2 = cn2.queryMulti(qry1, false);

		addProgress("Schema 1 has " + t1.size() + " triggers, Schema 2 has "
				+ t2.size() + " triggers.");

		totalCount = t1.size();
		currentIndex = 0;

		for (String tname : t1) {
			if (!running)
				break;
			currentIndex++;
			currentName = tname;
			addProgress(tname);

			// addProgress(tname);
			String qry2 = "SELECT text FROM USER_SOURCE WHERE name='" + tname
					+ "' AND LINE > 1 ORDER BY type, line";

			List<String[]> c1 = cn1.query(qry2, false);
			List<String[]> c2 = cn2.query(qry2, false);

			boolean diff = false;
			if (c1.size() != c2.size()) {
				diff = true;
			} else {

				for (int i = 0; i < c1.size(); i++) {
					String[] a1 = c1.get(i);
					String[] a2 = c2.get(i);

					for (int j = 0; j < a1.length; j++) {
						if (a1[j] == null) {
							if (a2[j] != null) {
								diff = true;
								break;
							}
						} else if (!a1[j].equals(a2[j])) {
							diff = true;
							break;
						}
					}
					if (diff)
						break;
				}
				if (diff) {
					addProgress("  <b>" + tname + "</b> is different");
					addResult(tname, c1, c2);
				}

			}
		}
	}

	private void addProgress(String str) {
		progressStr = str + "<br/>" + progressStr;
	}

	private void addResult(String oname, List<String[]> c1, List<String[]> c2) {
		if (c2.size() == 0) {
			resultStr = resultStr + "<b>" + oname
					+ "</b> is missing in Schema 2.<br>";
			return;
		}

		String[] s1 = getTableData(c1);
		String[] s2 = getTableData(c2);

		String id = Util.getId();
		resultStr = resultStr + "<b>" + oname
				+ "</b> <a href='Javascript:toggleDiv(\"img-" + id
				+ "\",\"div-" + id + "\")'><img id='img-" + id
				+ "' border=0 src=\"image/minus.gif\"></a><br/>";
		resultStr += "<div id='div-" + id
				+ "' style='margin-left: 20px;'><pre style='font-family: Consolas;'>" + getDiff(s1, s2)
				+ "</pre></div>";
	}

	private String[] getTableData(List<String[]> c) {
		String[] res = new String[c.size()];
		String temp;
		for (int i = 0; i < c.size(); i++) {
			temp = "";
			String a[] = c.get(i);
			for (int j = 1; j < a.length; j++) {
				String str = a[j];
				if (temp.length() > 0)
					temp += ", ";
				temp += str;
			}
			res[i] = temp;
		}

		// One line String into Array
		if (res.length == 1) {
			String temp2 = res[0];
			res = temp2.split("\n");
		}

		return res;
	}

	public String getProgress() {
		int percent = 0;

		if (totalCount > 0)
			percent = (100 * currentIndex) / totalCount;

		String status = "Processing " + currentIndex + " of " + totalCount
				+ "<br/>" + currentName + "<br/>";

		if (!running)
			status = "Finished " + currentIndex + " of " + totalCount + "<br/>";

		status += "<div class='meter-wrap' id='meter-ex1' style='cursor: pointer'>"
				+ "<div class='meter-value' style='background-color: rgb(77, 164, 243); width: "
				+ percent
				+ "%; '>"
				+ "<div class='meter-text'>"
				+ percent
				+ "%</div>" + "</div>" + "</div><br/>";

		return status + progressStr;
	}

	public String getResult() {
		return resultStr;
	}

	public String getDiff(String[] x, String[] y) {

		String res = "";

		// number of lines of each file
		int M = x.length;
		int N = y.length;

		// opt[i][j] = length of LCS of x[i..M] and y[j..N]
		int[][] opt = new int[M + 1][N + 1];

		// compute length of LCS and all subproblems via dynamic programming
		for (int i = M - 1; i >= 0; i--) {
			for (int j = N - 1; j >= 0; j--) {
				if (x[i].equals(y[j]))
					opt[i][j] = opt[i + 1][j + 1] + 1;
				else
					opt[i][j] = Math.max(opt[i + 1][j], opt[i][j + 1]);
			}
		}

		// recover LCS itself and print out non-matching lines to standard
		// output
		int i = 0, j = 0;
		while (i < M && j < N) {
			if (x[i].equals(y[j])) {
				i++;
				j++;
			} else if (opt[i + 1][j] >= opt[i][j + 1])
				res += ("< <span style='color: #0000ff'>" + x[i++] + "</span><br>");

			else
				res += ("> " + y[j++] + "<br>");
		}

		// dump out one remainder of one string if the other is exhausted
		while (i < M || j < N) {
			if (i == M)
				res += ("> " + y[j++] + "<br>");
			else if (j == N)
				res += ("< <span style='color: #0000ff'>" + x[i++] + "</span><br>");
		}

		return res;
	}

	public void cancel() {
		this.running = false;

	}
}
