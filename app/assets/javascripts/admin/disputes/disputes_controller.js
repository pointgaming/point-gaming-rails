var PointGaming = PointGaming || {};

PointGaming.DisputesController = function(){
  this.registerHandlers();
};

PointGaming.DisputesController.prototype.registerHandlers = function() {
  var modal = $('#ajax-modal');

  $(document).on('click', 'a[rel="modal:open:ajaxpost"]:not([data-modal-target])', PointGaming.ModalHelper.openModal(modal));
  $(document).on('submit', '#ajax-modal form', function(){
    $('body').modalmanager('loading');
  });
  $(document).on('ajax:success', '#ajax-modal form', function(){
    window.location.reload();
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

};
