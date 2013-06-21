var PointGaming = PointGaming || {};

PointGaming.TournamentsController = function(options){
  this.registerHandlers();
};

PointGaming.TournamentsController.prototype.registerHandlers = function() {
  $(document).on("click", "[data-behavior~='datepicker']", this.showDateTimePicker);
  $(document).on("change", "select#tournament_game_id", this.updateGameTypeOptions);

  $(document).on('mouseenter', 'div[data-hook=sponsor]', function(){ $('ul.actions', this).show(); });
  $(document).on('mouseleave', 'div[data-hook=sponsor]', function(){ $('ul.actions', this).hide(); });

  $(document).on('keyup', 'input[data-hook=prizepool-field]', this.recalculatePrizepoolTotal);
  $(document).on('change', 'input[data-hook=prizepool-field]', this.recalculatePrizepoolTotal);

  $(document).on('change', '#payment-source-widget input[type=radio]', this.showPaymentSourceFields);

  // setup the modal events for Sponsors
  var $modal = $('#ajax-modal');
  $(document).on('click', 'a[rel="modal:open:ajaxpost"]:not([data-modal-target]):not([disabled])', PointGaming.ModalHelper.openModal($modal));
  $(document).on('submit', '#ajax-modal form', PointGaming.ModalHelper.toggleLoading);
  $(document).on('ajax:success', '#ajax-modal form', this.handleSuccessForSponsorModal);
  $(document).on('ajax:error', '#ajax-modal form', this.handleErrorsForSponsorModal);
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

PointGaming.TournamentsController.prototype.recalculatePrizepoolTotal = function() {
  var total = 0;
  $('input[data-hook=prizepool-field]').each(function(index, element) {
    total += parseFloat(accounting.toFixed($(element).val(), 2));
  });

  $('span[data-hook=prize-pool-total]').html(accounting.formatMoney(total));
};

PointGaming.TournamentsController.prototype.showPaymentSourceFields = function(){
  var payment_source = $(this).val() || "";
  $('[data-hook=payment-source-fields]').hide();
  $('#payment_source_fields_' + payment_source).show();
};

PointGaming.TournamentsController.prototype.handleSuccessForSponsorModal = function(){
  window.location.reload();
};

PointGaming.TournamentsController.prototype.handleErrorsForSponsorModal = function(event, response){
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
};
