(function(window){
  "use strict";

  window.PointGaming.controllers.user_tournaments = {

    init: function(){
    },

    new: function(){
      $(document).on("click", "[data-behavior~='datepicker']", helpers.showDateTimePicker);
      $(document).on("change", "select#tournament_game_id", helpers.updateGameTypeOptions);
    },
    
    edit: function(){
      $(document).on("click", "[data-behavior~='datepicker']", helpers.showDateTimePicker);
      $(document).on("change", "select#tournament_game_id", helpers.updateGameTypeOptions);

      $(document).on('mouseenter', 'div[data-hook=sponsor]', function(){ $('ul.actions', this).show(); });
      $(document).on('mouseleave', 'div[data-hook=sponsor]', function(){ $('ul.actions', this).hide(); });

      // setup the modal events for Sponsors
      var $modal = $('#ajax-modal');
      $(document).on('click', 'a[rel="modal:open:ajaxpost"]:not([data-modal-target]):not([disabled])', PointGaming.ModalHelper.openModal($modal));
      $(document).on('submit', '#ajax-modal form', PointGaming.ModalHelper.toggleLoading);
      $(document).on('ajax:success', '#ajax-modal form', helpers.handleSuccessForSponsorModal);
      $(document).on('ajax:error', '#ajax-modal form', helpers.handleErrorsForSponsorModal);
    },

    prize_pool: function(){
      $(document).on('keyup', 'input[data-hook=prizepool-field]', helpers.recalculatePrizepoolTotal);
      $(document).on('change', 'input[data-hook=prizepool-field]', helpers.recalculatePrizepoolTotal);
    },

    users: function(){
      $(document).on('click', "[data-hook=collaborator-form] input.search-query", helpers.setupTypeahead);
      $(document).on('click', "[data-hook=invites-form] input.search-query", helpers.setupTypeahead);
    }

  };

  var helpers = {

    updateGameTypeOptions: function(event) {
      var game_id = $(this).val(),
          select_wrapper = $('#game_type_wrapper'),
          url;

      $('select', select_wrapper).attr('disabled', true).val('');

      url = "/game_type_options?for=tournament&game_id=" + game_id;
      select_wrapper.load(url);
    },

    showDateTimePicker: function(event) {
      $(event.target).datetimepicker({format: 'mm/dd/yyyy HH:ii p', autoclose: true, todayHighlight: true, showMeridian: true}).focus();
    },

    recalculatePrizepoolTotal: function() {
      var total = 0;
      $('input[data-hook=prizepool-field]').each(function(index, element) {
        total += parseFloat(accounting.toFixed($(element).val(), 2));
      });

      $('span[data-hook=prize-pool-total]').html(accounting.formatMoney(total));
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
    },

    setupTypeahead: function(e) {
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
    }

  };

})(window);
