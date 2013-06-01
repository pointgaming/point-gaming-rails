var PointGaming = PointGaming || {};

PointGaming.DisputesController = function(options){
  this.registerHandlers();
};

PointGaming.DisputesController.prototype.registerHandlers = function() {
  $(document).on('change', 'input[name="dispute[reason]"]', function(){
    if ($('input[data-hook=toggle-cheater]').is(':checked')) {
      $('div[data-hook=cheater-container]').show();
    } else {
      $('div[data-hook=cheater-container]').hide();
    }
  });
};
