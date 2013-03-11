<%@ page language="java" 
	import="java.util.*" 
	import="chingoo.oracle.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"	
%>

<%
String imgList[] = {
		"http://attachments.techguy.org/attachments/151479d1243586439/fall-scene-mn-9-07.jpg",
		"http://www.johnnyjet.com/wp-content/uploads/2011/12/Lindsay-Taub-Spokane-Fall-2011-23.jpg",
		"http://4.bp.blogspot.com/_LANuzRARDf4/TKKPO3TwA9I/AAAAAAAAAT8/mF4Dblgbqjw/s1600/Autumn_Forest_in_the_Sun.jpg",
		"http://goodtaste.tv/wp-content/uploads/2012/10/breckenridge-autumn-ale_preview-640x480.jpg",
		"http://cache.virtualtourist.com/6/4578346-Autumn_Foliage_at_Guinsa_Temple_South_Korea.jpg",
	};

	Connect cn = (Connect) session.getAttribute("CN");
	// if connected, redirect to home
	if (cn!=null && cn.isConnected()) {
		response.sendRedirect("index.jsp");
		return;
	}

	String url = request.getParameter("url");
	String username = request.getParameter("username");
	String password = request.getParameter("password");
	String email = request.getParameter("email");
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <title>Chingoo</title>
    <link rel='stylesheet' type='text/css' href='css/style.css'> 
    <link rel='stylesheet' type='text/css' href='css/slideshow.css'> 
	<link rel="icon" type="image/png" href="image/chingoo-icon.png">
    
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    
<script type="text/javascript">
var to2;

$(document).ready(function(){
//	$("#loadingDiv").append("<div id='wait'><img src='image/loading_big.gif'/></div>");
	$.ajax({
		type: 'POST',
		url: "connect_behind.jsp?",
		data: $("#form0").serialize(),
		success: function(data){
			$("#loadingDiv").append(data);
//			$("#wait").remove();
			if (data.indexOf("Connected.") != -1) {
				$(location).attr('href',"index.jsp");
			} else {
				stopShow();
			}
		},
        error:function (jqXHR, textStatus, errorThrown){
        	alert(jqXHR.status + " " + errorThrown);
        }  
	});	
})

    function checkConnectProgress() {
    	clearTimeout(to2);
    	var current = $("#connectProgress").html();
		$.ajax({
			type: 'POST',
			url: "ajax/connect-progress.jsp",
			success: function(data){
				if (current != data) {
	    			$("#connectProgress").html(data);
				}
				
				if (data.indexOf("Finished ") < 0) {
					to2 = setTimeout("checkConnectProgress()",1000);
				}
			},
            error:function (jqXHR, textStatus, errorThrown){
                alert(jqXHR.status + " " + errorThrown);
            }  
		});	    	
    }	
    
function slideSwitch() {
    var $active = $('#slideshow IMG.active');

    if ( $active.length == 0 ) $active = $('#slideshow IMG:last');

    var $next =  $active.next().length ? $active.next()
        : $('#slideshow IMG:first');

    $active.addClass('last-active');

    $next.css({opacity: 0.0})
        .addClass('active')
        .animate({opacity: 1.0}, 1000, function() {
            $active.removeClass('active last-active');
        });
}

$(function() {
    setInterval( "slideSwitch()", 2500 );
    setInterval( "checkConnectProgress()", 1000 );
});

function stopShow() {
	$("#slideshow").html('');
//	$("#waiting").hide();
}

</script>
    
  </head>
  
  <body>
  
  <form id="form0" name="form0">
  	<input name="url" type="hidden" value="<%= url %>">
  	<input name="username" type="hidden" value="<%= username %>">
  	<input name="password" type="hidden" value="<%= password %>">
  	<input name="email" type="hidden" value="<%= email %>">
  </form>
  
  <img src="image/chingoo.png"/>
    <h2>Connecting &amp; Loading Database Objects...</h2>

	<div id="loadingDiv" style="font-size:18px;"></div>
	
	<br/>
	Chingoo is loading data dictionary.
	- Tables, Comments, Constraints, Primary &amp; Foreign keys.
	
<div id="connectProgress"></div>
<div id="slideshow">

	<img src="image/nature1.jpg" alt="" class="active" />
    <img src="image/nature2.jpg" alt=""/>
    <img src="image/nature3.jpg" alt=""/>
    <img src="image/nature4.jpg" alt=""/>
    <img src="image/nature5.jpg" alt=""/>

 <%-- 
    <img src="<%= imgList[0] %>" alt="" class="active" />
    <img src="<%= imgList[1] %>" />
    <img src="<%= imgList[2] %>" />
    <img src="<%= imgList[3] %>" />
    <img src="<%= imgList[4] %>" />
 --%>
 </div>

<%--
<img id="waiting" src="image/waiting_big.gif" class="waitontop">  
--%>
	
  </body>
</html>
