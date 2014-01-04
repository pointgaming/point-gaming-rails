var PointGaming = PointGaming || {};

PointGaming.GroupsController = function(){
  this.container_selector = 'div#group-users';
  this.search_field_selector = 'input.search-query';

  this.registerHandlers();
};

PointGaming.GroupsController.prototype.registerHandlers = function() {
  var self = this;

  // setup typeahead functionality for the add users form
  setupAddCollaboratorsTypeahead($(this.container_selector + ' ' + this.search_field_selector));
};

var setupAddCollaboratorsTypeahead = function(elem){
  elem.typeahead({
    ajax: { url: '/users/search.json', triggerLength: 1, method: 'get' },
    display: 'username', 
    val: 'username',
    itemSelected: function(item, val, text){
      var current_form = elem.closest('form');
      current_form.submit();
    }
  });
};
