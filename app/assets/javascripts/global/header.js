jQuery(function($) {
  $('#navbar-search-button').focus(function(){
    $(this).addClass('focused');
    $('.nav.primary').addClass('focused');

  });

  $('#navbar-search-button').blur(function(){
    $(this).removeClass('focused');
    $('.nav.primary').removeClass('focused');

  });
});
