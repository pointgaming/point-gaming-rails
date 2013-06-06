var PointGaming = PointGaming || {};

PointGaming.TournamentsController = function(options){
  this.registerHandlers();
};

PointGaming.TournamentsController.prototype.registerHandlers = function() {
  $(document).on("click", "[data-behavior~='datepicker']", this.showDateTimePicker);
  $(document).on("change", "select#tournament_game_id", this.updateGameTypeOptions);

  $(document).on('mouseenter', 'div[data-hook=sponsor]', function(){ $('ul.actions', this).show(); });
  $(document).on('mouseleave', 'div[data-hook=sponsor]', function(){ $('ul.actions', this).hide(); });

  // setup the modal events for Demos
  var $modal = $('#ajax-modal');
  $(document).on('click', 'a[rel="modal:open:ajaxpost"]:not([data-modal-target]):not([disabled])', PointGaming.ModalHelper.openModal($modal));
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

PointGaming.TournamentsController.prototype.updateGameTypeOptions = function(event) {
  var game_id = $(this).val(),
      select_wrapper = $('#game_type_wrapper'),
      url;

  $('select', select_wrapper).attr('disabled', true).val('');

  url = "/game_type_options?for=tournament&game_id=" + game_id;
  select_wrapper.load(url);
};

PointGaming.TournamentsController.prototype.showDateTimePicker = function(event) {
  $(event.target).datetimepicker({format: 'mm/dd/yyyy HH:ii p', autoclose: true, todayHighlight: true, showMeridian: true}).focus();
};
