<%@ page language="java" 
	import="java.util.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
/*
		"http://www.walltor.com/images/wallpaper/autumn-149.jpg",
		"http://4.bp.blogspot.com/_LANuzRARDf4/TKKPO3TwA9I/AAAAAAAAAT8/mF4Dblgbqjw/s1600/Autumn_Forest_in_the_Sun.jpg",
		"http://attachments.techguy.org/attachments/151479d1243586439/fall-scene-mn-9-07.jpg",
		"http://www.johnnyjet.com/wp-content/uploads/2011/12/Lindsay-Taub-Spokane-Fall-2011-23.jpg"
*/

	String imgList[] = {
		"http://goodtaste.tv/wp-content/uploads/2012/10/breckenridge-autumn-ale_preview-640x480.jpg",
		"http://cache.virtualtourist.com/6/4578346-Autumn_Foliage_at_Guinsa_Temple_South_Korea.jpg",
		"http://attachments.techguy.org/attachments/151479d1243586439/fall-scene-mn-9-07.jpg",
		"http://www.johnnyjet.com/wp-content/uploads/2011/12/Lindsay-Taub-Spokane-Fall-2011-23.jpg",
		"http://4.bp.blogspot.com/_LANuzRARDf4/TKKPO3TwA9I/AAAAAAAAAT8/mF4Dblgbqjw/s1600/Autumn_Forest_in_the_Sun.jpg"
	};


	String url = request.getParameter("url");
	String username = request.getParameter("username");
	String password = request.getParameter("password");
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <title>Slide Show</title>
    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'> 
    <link rel='stylesheet' type='text/css' href='css/slideshow.css?<%= Util.getScriptionVersion() %>'> 
    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>

<script type="text/javascript">
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
    setInterval( "slideSwitch()", 2000 );
});

</script>
    
  </head>
  
  <body>

<img src="image/waiting_big.gif" class="waitontop">  
<div id="slideshow">
<!--     <img src="image/nature1.jpg" alt="" class="active" />
    <img src="image/nature2.jpg" alt=""/>
    <img src="image/nature3.jpg" alt=""/>
    <img src="image/nature4.jpg" alt=""/>
    <img src="image/nature5.jpg" alt=""/>
 -->
    <img src="<%= imgList[0] %>" alt="" class="active" />
    <img src="<%= imgList[1] %>" alt="" class="active" />
    <img src="<%= imgList[2] %>" alt="" class="active" />
    <img src="<%= imgList[3] %>" alt="" class="active" />
    <img src="<%= imgList[4] %>" alt="" class="active" />
</div>
<img id="waitimg" src="image/waiting_big.gif">  


  </body>
</html>



