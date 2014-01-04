(function(window){
  "use strict";

  window.PointGaming.views.tournament_sponsors = window.PointGaming.views.base.extend({

    initialize: function(){
      
    },

    bindEvents: function() {
      $(document).on('mouseenter', 'div[data-hook=sponsor]', this.showActions);
      $(document).on('mouseleave', 'div[data-hook=sponsor]', this.hideActions);

      // setup the modal events
      var $modal = $('#ajax-modal');
      $(document).on('click', 'a[rel="modal:open:ajaxpost"]:not([data-modal-target]):not([disabled])', PointGaming.ModalHelper.openModal($modal));
      $(document).on('submit', '#ajax-modal form', PointGaming.ModalHelper.toggleLoading);
      $(document).on('ajax:success', '#ajax-modal form', this.handleSuccessForSponsorModal);
      $(document).on('ajax:error', '#ajax-modal form', this.handleErrorsForSponsorModal);
    },

    showActions: function(){
      $('ul.actions', this).show();
    },

    hideActions: function(){
      $('ul.actions', this).hide();
    },

    handleSuccessForSponsorModal: function(){
      window.location.reload();
    },

    handleErrorsForSponsorModal: function(event, response){
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
    }

  });

})(window);
