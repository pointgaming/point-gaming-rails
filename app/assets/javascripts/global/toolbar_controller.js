var PointGaming = PointGaming || {};

PointGaming.ToolbarController = function(options){
  options = options || {};
  this.toolbar_selector = options.toolbar_selector || 'div#main-toolbar';
  this.search_field_selector = options.search_field_selector || 'input.search-query';

  this.registerHandlers();
};

PointGaming.ToolbarController.prototype.registerHandlers = function() {
  var self = this;

  $(this.search_field_selector, this.toolbar_selector).typeahead({
    ajax: { url: '/users/search.json', triggerLength: 1, method: 'get' },
    display: 'username', 
    val: 'profile_url',
    itemSelected: function(item, val, text){
      window.location.href = val;
    }
  });
};
