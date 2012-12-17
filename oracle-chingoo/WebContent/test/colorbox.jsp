<!doctype html>
<html>
    <head>
        <link rel="stylesheet" href="../css/colorbox.css" />
        <script src="../script/jquery.js"></script>
        <script src="../script/jquery.colorbox-min.js"></script>
        
		<script>
			$(document).ready(function(){
				//Examples of how to assign the ColorBox event to elements
				$(".iframe").colorbox({iframe:true, width:"600", height:"300"});
				$(".ajax").colorbox();
				//Example of preserving a JavaScript event for inline calls.
				$("#click").click(function(){ 
					$('#click').css({"background-color":"#f00", "color":"#fff", "cursor":"inherit"}).text("Open this window again and this message will still be here.");
					return false;
				});
			});
		</script>
    </head>
    <body>
        <a class='gallery' href='../image/genie2.jpg'>Photo_1</a>
        <a class='gallery' href='../image/lamp.png'>Photo_2</a>
        <a class='gallery' href='../image/small-genie.gif'>Photo_3</a>
        
        
        <a class='iframe' href="http://www.cnn.com/" title="Ajax">Outside HTML (Ajax)</a>
        
        <p><a class='ajax' href="../ajax/fk-lookup.jsp?table=PERSON&key=8538" title="Data">Outside HTML (Ajax)</a></p>
        
    </body>
</html>