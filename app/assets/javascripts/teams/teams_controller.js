var PointGaming = PointGaming || {};

PointGaming.TeamsController = function(options){
  this.search_field_selector = 'input#user_username';

  this.registerHandlers();
};

PointGaming.TeamsController.prototype.registerHandlers = function() {
  var self = this,
    $modal = $('#ajax-modal');

  $(document).on('click', 'a[rel="modal:open:ajaxpost"]', function(event){
    var that = this;

    event.preventDefault();

    $('body').modalmanager('loading');

    var options = {};
    options.width = $(this).data('width') || 'auto';
    options.height = $(this).data('height') || 'auto';

    $modal.load($(that).attr('href'), '', function(){
      $modal.modal(options);
    });

    return false;
  });

  // configure the submit handler
  $(document).on('submit', '#ajax-modal form', function(){
    // save the current form
    var current_form = $(this);

    if (current_form.is('.typeahead')) {
        return;
    }

    // show the spinner
    $('body').modalmanager('loading');

    // send the ajax call
    $.ajax({
      type: this.method,
      url: this.action + '.json',
      data: $(this).serialize(),
      dataType: 'html',
      success: function(data) {
        // hide the spinner
        $('body').modalmanager('loading');

        // close the dialog
        $modal.modal('hide');

        window.location.reload();
      },
      error: function(data) {
        // hide the spinner
        $('body').modalmanager('loading');

        // remove the older error message
        current_form.find(".alert-error").remove()

        // parse the result
        var obj = jQuery.parseJSON(data.responseText);

        if (obj.length < 1) {
          obj = ['There was a problem submitting the form data.'];
        }

        $.each(obj, function(key, value){
          current_form.find('.modal-body').prepend('<div class="alert alert-error">'+ value + '</div>');
        });
      }
    });
    return false;
  });

  $(document).on('ajax:success', 'a[data-remote][data-modal]', function(data, status, xhr){
    // close the modal
    $modal.modal('hide');
  });

  $(document).on('click', this.search_field_selector, function(e){
    var self = this;
    $(this).typeahead({
      ajax: { url: '/users/search.json', triggerLength: 1, method: 'get' },
      display: 'username', 
      val: 'username'
    });
  });

};
