jQuery(function($) {
  $('#appendedInputButton').focus(function(){
    $(this).animate({
	    width: '+=50'
	  }, 500, function() {
	    // Animation complete.
	});

	$('.nav.primary li').animate({
	     width: '-=10'
	   }, 500, function() {
	     // Animation complete.
	 });

  });

  $('#appendedInputButton').blur(function(){
    $(this).animate({
	    width: '-=50'
	  }, 500, function() {
	    // Animation complete.
	});

	$('.nav.primary li').animate({
	     width: '+=10'
	   }, 500, function() {
	     // Animation complete.
	 });

  });
});
