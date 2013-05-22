<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	String text = request.getParameter("q");

%>

<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" 
  "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg width="6cm" height="5cm" viewBox="0 0 600 500"
     xmlns="http://www.w3.org/2000/svg" version="1.1">
  <desc>Example script01 - invoke an ECMAScript function from an onclick event
  </desc>
  <!-- ECMAScript to change the radius with each click -->
  <script type="application/ecmascript"> <![CDATA[
    function circle_click(evt) {
      var circle = evt.target;
      var currentRadius = circle.getAttribute("r");
      if (currentRadius == 100) {
        circle.setAttribute("r", currentRadius*2);
      } else {
        circle.setAttribute("r", currentRadius*0.5);
      }
    }

    function circle_over(evt) {
      var circle = evt.target;
      circle.setAttribute("fill", "green");
    }

    function circle_out(evt) {
      var circle = evt.target;
      circle.setAttribute("fill", "red");
    }
  ]]> </script>

  <!-- Outline the drawing area with a blue line -->
  <rect x="1" y="1" width="598" height="498" fill="none" stroke="blue"/>

  <!-- Act on each click event -->
  <circle onclick="circle_click(evt)" onmouseover="circle_over(evt)" onmouseout="circle_out(evt)" cx="300" cy="225" r="100"
          fill="red"/>

  <circle onclick="circle_click(evt)" onmouseover="circle_over(evt)" onmouseout="circle_out(evt)" cx="500" cy="325" r="60" fill="red"/>

  <circle onclick="circle_click(evt)" onmouseover="circle_over(evt)" onmouseout="circle_out(evt)" cx="100" cy="125" r="120" fill="red"/>

  <text x="300" y="480" 
        font-family="Verdana" font-size="35" text-anchor="middle">
    Click on circle to  <%= text %>
  </text>
</svg>
