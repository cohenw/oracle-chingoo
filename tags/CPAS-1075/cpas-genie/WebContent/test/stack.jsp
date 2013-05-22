<!DOCTYPE html>
<html>
<head>
        <link rel="stylesheet" href="../css/colorbox.css" />
        <script src="../script/jquery.js"></script>
        <script src="../script/jquery.colorbox-min.js"></script>

	<script type="text/javascript">
	var stack = [];
	
	function add() {
		var str = $("#x").val();
		stack.push(str);
		alert("Pushed: " + str);
	}
	
	function subtract() {
		if (stack.length==0) {
			alert('nothing to pop');
			return;
		}
		var str = stack.pop();
		alert("Poped: " + str);
	}
	
	function showSize() {
		alert(stack.length);
	}
	
	</script>
</head>
<body>
  

<div id="test-div">
123
</div>

<input id="x">
<a href="javascript:add()">push</a>
<a href="javascript:subtract()">pop</a>
<a href="javascript:showSize()">size?</a>

</body>
</html>