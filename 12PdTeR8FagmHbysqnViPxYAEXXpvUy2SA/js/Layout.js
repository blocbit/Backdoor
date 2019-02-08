$(window).resize(function() {

  if ($(this).width() < 420) {

    $('#votetime').css({"position": "absolute", "top": "-35px", "height": "50px", "width": "170px", "right": "30px"});
	$('#votego').css({"right": "180px", "top": "-80px"});
	$('#votediv').css({"right": "30px", "top": "-60px"});
	$('sat').css("padding-left", "55px");

  } else {

    $('#votetime').removeAttr("style");
	$('sat').removeAttr("style");
  $('#votediv').css({"right": "225px", "top": "-27px"});
	$('#votego').css({"right": "225px", "top": "-45px"});

    }

});


/*appends an "active" class to .popup and .popup-content when the "Open" button is clicked
$(".open").on("click", function(){
  $(".popup-overlay, .popup-content").addClass("active");
});

//removes the "active" class to .popup and .popup-content when the "Close" button is clicked 
$(".close, .popup-overlay").on("click", function(){
  $(".popup-overlay, .popup-content").removeClass("active");
});*/


$(document).on('click','.myBtn',function(){
	var myTargetModal =  $(this).attr('href');
	$('#myModal').hide();
	$('.modal-content').hide();
	
	$('#myModal').fadeIn();
	$(myTargetModal).fadeIn();
  return false;
});

$("body" ).on( "click",".close", function() {
  	$('#myModal').hide();
	$('.modal-content').hide();
});



function flip() {
    $('.card').toggleClass('flipped');
}

function closeNav() {
	$("#bottom").removeAttr("style");
}
	
function openNav() {
	$("#bottom").css("bottom", "0");
}

$("fixbutton").removeAttr("style");

/*
window.onresize = function() {
    if (window.innerWidth >= 400) {  
	document.getElementById("left").style.visibility = "visible";
	document.getElementById("openbtn").style.visibility = "hidden";
  document.getElementById("right").style.marginLeft= "240px"; }
      if (window.innerWidth <= 400) { 
	  document.getElementById("left").style.visibility = "hidden";
	  document.getElementById("openbtn").style.visibility = "visible";
  document.getElementById("right").style.marginLeft = "20px"; }
};

function toggleNav() {
  var x = document.getElementById("bottom");
  if (x.style.bottom = "-310px") {
    x.removeAttr("style");
  } else {
    x.style.bottom = "-310px";
  }
}

function openNav() {
	$("#bottom").removeAttr("style");}/*
	 document.getElementById("left").removeAttr("style");
	document.getElementById("left").style.visibility = "visible";
	document.getElementById("openbtn").style.visibility = "hidden";
	document.getElementById("closebtn").style.visibility = "visible";
  document.getElementById("left").removeAttr("style");
}

function closeNav() {
	$("#bottom").css("bottom", "-310px");}/*
	document.getElementById("left").style.visibility = "hidden";
	document.getElementById("openbtn").style.visibility = "visible";
	document.getElementById("closebtn").style.visibility = "hidden";
  document.getElementById("right").style.marginLeft= "20px";
}


window.onresize = function() {
    if (window.innerWidth >= 400) {  
	document.getElementById("left").style.visibility = "visible";
	document.getElementById("openbtn").style.visibility = "hidden";
  document.getElementById("right").style.marginLeft= "240px"; }
      if (window.innerWidth <= 400) { 
	  document.getElementById("left").style.visibility = "hidden";
	  document.getElementById("openbtn").style.visibility = "visible";
  document.getElementById("right").style.marginLeft = "20px"; }
};

function flip() {
    $('.wall').toggleClass('flipped');
}

$("h1").removeAttr("style");
*/