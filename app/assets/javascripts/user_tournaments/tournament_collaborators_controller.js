var PointGaming = PointGaming || {};

PointGaming.TournamentCollaboratorsController = function(options){
  this.registerHandlers();
};

PointGaming.TournamentCollaboratorsController.prototype.registerHandlers = function() {
  $(document).on('click', "[data-hook=collaborator-form] input.search-query", this.setupTypeahead);
};

PointGaming.TournamentCollaboratorsController.prototype.setupTypeahead = function(e) {
    var self = this;
    $(this).typeahead({
      ajax: { url: '/users/search.json', triggerLength: 1, method: 'get' },
      display: 'username', 
      val: 'username',
      itemSelected: function(item, val, text){
        var current_form = $(self).closest('form');
        current_form.submit();
      }
    });
  });
};
