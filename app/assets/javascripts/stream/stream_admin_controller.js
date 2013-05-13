var PointGaming = PointGaming || {};

PointGaming.StreamAdminController = function(options){
  options = options || {};
  this.container_selector = options.container_selector || 'div#stream-admin-collaborators';
  this.search_field_selector = options.search_field_selector || 'input.search-query';
  this.modal = $('#ajax-modal');

  this.registerHandlers();
};

PointGaming.StreamAdminController.prototype.registerHandlers = function() {
  var self = this,
      $modal = $('#ajax-modal');

  $(document).on('click', 'a[rel="modal:open:ajaxpost"]:not([data-modal-target])', PointGaming.ModalHelper.openModal($modal));
  $(document).on('submit', '#ajax-modal form', function(){ $('body').modalmanager('loading'); });
  $(document).on('ajax:success', '#ajax-modal form', function(){
    $('body').modalmanager('loading');
    $modal.modal('hide');
  });
  $(document).on('ajax:error', '#ajax-modal form', function(event, response, status_text){
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

  // prevent the user from submitting the Stream Admin Collaborators form
  $(document).on('submit', this.container_selector + ' form', preventFormSubmission.bind(this));

  // setup typeahead functionality for the add collaborators form
  $(document).on('click', this.container_selector + ' ' + this.search_field_selector, function() {
    setupAddCollaboratorsTypeahead.bind(self, $(this))();
  });
};

var preventFormSubmission = function(e){
  event.preventDefault();
  return false;
};

var setupAddCollaboratorsTypeahead = function(elem){
  var self = this;

  elem.typeahead({
    ajax: { url: '/users/search.json', triggerLength: 1, method: 'get' },
    display: 'username', 
    val: 'username',
    itemSelected: function(item, val, text){
      var current_form = elem.closest('form');

      // show the spinner
      $('body').modalmanager('loading');

      // send the ajax call
      $.ajax({
        type: current_form.attr('method'),
        url: current_form.attr('action') + '.json',
        data: current_form.serialize(),
        dataType: 'html',
        success: function(data)
        {
          // hide the spinner
          $('body').modalmanager('loading');

          // close the dialog
          self.modal.modal('hide');
        },
        error: function(data)
        {
          // hide the spinner
          $('body').modalmanager('loading');

          // remove the older error message
          current_form.find(".error").remove()

          // parse the result
          var obj = jQuery.parseJSON(data.responseText);

          $.each(obj, function(key, value){
            current_form.prepend('<span class="error">'+ value[0] + '</span>');
          });
        }
      });
    }
  });
};
