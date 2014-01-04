var PointGaming = PointGaming || {};

PointGaming.GameTypesController = function(){
  this.registerHandlers();
};

PointGaming.GameTypesController.prototype.registerHandlers = function() {
  $(document).on('change', 'select[name="game[id]"]', function(e) {
    var game_id = $(this).val(),
        search;

    search = game_id ? 'game_id=' + game_id : '';
    window.location.search = search;
  });
};
