jQuery(function($) {
  $('#appendedInputButton').focus(function(){
    $(this).show("slide", { direction: "left" }, 1000);
  });
});
