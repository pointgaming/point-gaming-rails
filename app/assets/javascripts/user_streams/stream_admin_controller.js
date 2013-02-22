var PointGaming = PointGaming || {};

PointGaming.StreamAdminController = function(options){
  options = options || {};
  this.container_selector = options.container_selector || 'div#stream-admin-collaborators';
  this.search_field_selector = options.search_field_selector || 'input.search-query';

  this.registerHandlers();
};

PointGaming.StreamAdminController.prototype.registerHandlers = function() {
  var self = this,
    $modal = $('#ajax-modal');

  $(document).on('click', this.container_selector + ' ' + this.search_field_selector, function(e){
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
