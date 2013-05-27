var PointGaming = PointGaming || {};

PointGaming.TeamsController = function(options){
  this.search_field_selector = 'input#user_username';

  this.registerHandlers();
};

PointGaming.TeamsController.prototype.registerHandlers = function() {
  var self = this,
    $modal = $('#ajax-modal');

  $(document).on('mouseenter', 'div[data-hook=sponsor]', function(){ $('ul.actions', this).show(); });
  $(document).on('mouseleave', 'div[data-hook=sponsor]', function(){ $('ul.actions', this).hide(); });

  $(document).on('click', 'a[rel="modal:open:ajaxpost"][data-typeahead-modal]:not([disabled])', this.openModal($modal));
  $(document).on('click', 'a[rel="modal:open:ajaxpost"]:not([data-typeahead-modal]):not([disabled])', PointGaming.ModalHelper.openModal($modal));
  $(document).on('submit', '#ajax-modal form', function(){ $('body').modalmanager('loading'); });
  $(document).on('ajax:success', '#ajax-modal form', function(){ window.location.reload(); });
  $(document).on('ajax:error', '#ajax-modal form', function(event, response){
    var form = $(event.target),
        container = form.find('div.modal-body'),
        errors;
    form.find(".alert-error").remove()

    $('body').modalmanager('loading');

    if (response.status === 500) {
      container.prepend('<div class="alert alert-error">Internal Server Error</div>');
    } else {
      errors = $.parseJSON(response.responseText).errors;
      $.each(errors, function(key, value){
        container.prepend('<div class="alert alert-error">'+ value + '</div>');
      });
    }
  });
};

// this method will return a handler used to open a modal window and setup 
// typeahead functionality
PointGaming.TeamsController.prototype.openModal = function(modal){
  var self = this;

  return function(e) {
    var callback = function(){
          self.setupModalTypeahead();
        };
    PointGaming.ModalHelper.openModal(modal, callback).bind(this)(e);
  };
};


// configures typeahead functionality for the player or team fields
PointGaming.TeamsController.prototype.setupModalTypeahead = function(){
  var elements = $(this.search_field_selector);

  elements.each(function(index, elem){
    elem = $(elem);
    elem.typeahead({
      ajax: { url: '/users/search.json', triggerLength: 0, method: 'get' },
      display: 'username', 
      val: 'username', 
    });
  });
};
