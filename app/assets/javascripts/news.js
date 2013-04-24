$(function(){
    $(document).on('mouseenter', 'div.comment', function(){
      $('ul.actions', this).show();
    });

    $(document).on('mouseleave', 'div.comment', function(){
      $('ul.actions', this).hide();
    });
});
