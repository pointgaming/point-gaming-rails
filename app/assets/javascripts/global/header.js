jQuery(function($) {
  $('#appendedInputButton').focus(function(){
    $(this).addClass('focused');
    $('.nav.primary').addClass('focused');

  });

  $('#appendedInputButton').blur(function(){
    $(this).removeClass('focused');
    $('.nav.primary').removeClass('focused');

  });
});
