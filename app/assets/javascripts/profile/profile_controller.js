var PointGaming = PointGaming || {};

PointGaming.ProfileController = function(options){
  this.registerHandlers();
};

PointGaming.ProfileController.prototype.registerHandlers = function() {
  $(document).on("click", "[data-behavior~='datepicker']", this.showDateTimePicker);
  $(document).on("change", "select#user_country", this.updateStateOptions);
  $(document).on("change", "select#demo_game_id", this.updateGameTypeOptions);
  $(document).on("change", "input#user_birth_date", this.calculateUserAge.bind(this));

  $(document).on('mouseenter', 'div[data-hook=sponsor]', function(){ $('ul.actions', this).show(); });
  $(document).on('mouseleave', 'div[data-hook=sponsor]', function(){ $('ul.actions', this).hide(); });

  // setup the typeahead for all of the rig fields
  $(document).on('change', 'div[data-hook=rig_fields] input:text', this.clearRelatedUrlHiddenFields);
  this.setupStoreTypeahead();

  // setup the modal events for Demos
  var $modal = $('#ajax-modal');
  $(document).on('click', 'a[rel="modal:open:ajaxpost"]:not([data-modal-target]):not([disabled])', this.openModal($modal));
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

  // setup playable search fields
  $(document).on('change', '#ajax-modal input.playable-search', this.clearRelatedHiddenFields);
};

// this method will return the handler used to setup match modal windows.
PointGaming.ProfileController.prototype.openModal = function(modal){
  var self = this;

  // after opening the modal, this method will store the match_id that 
  // the user expects to be working with on the modal window for later use
  return function(e) {
    var match_id = $(this).data('match-id') || "",
        callback = function(){
          modal.data('match-id', match_id);
          self.setupModalTypeahead();
        };
    PointGaming.ModalHelper.openModal(modal, callback).bind(this)(e);
  };
};

// clears hidden id/type fields if the user changes the field value themself
PointGaming.ProfileController.prototype.clearRelatedHiddenFields = function(e){
    var text_field = $(this),
        id_field = text_field.parent().find('input[name$="_id]"]'),
        type_field = text_field.parent().find('input[name$="type]"]');

    text_field.val('');
    id_field.val('');
    type_field.val('');
};

// clears hidden id/type fields if the user changes the field value themself
PointGaming.ProfileController.prototype.clearRelatedUrlHiddenFields = function(e){
    var text_field = $(this),
        url_field = text_field.parent().find('input[name$="url]"]');

    url_field.val('');
};

PointGaming.ProfileController.prototype.updateStateOptions = function(event) {
  var country_code = $(this).val(),
      select_wrapper = $('#user_state_wrapper'),
      url;

  $('select', select_wrapper).attr('disabled', true);

  url = "/users/subregion_options?parent_region=" + country_code;
  select_wrapper.load(url);
};

PointGaming.ProfileController.prototype.updateGameTypeOptions = function(event) {
  var game_id = $(this).val(),
      select_wrapper = $('#demo_game_type_wrapper'),
      url;

  $('select', select_wrapper).attr('disabled', true).val('');

  url = "/demos/game_type_options?game_id=" + game_id;
  select_wrapper.load(url);
};

PointGaming.ProfileController.prototype.showDateTimePicker = function(event) {
  $(event.target).datetimepicker({format: 'mm/dd/yyyy', autoclose: true, minView: 2, todayHighlight: true}).focus();
};

PointGaming.ProfileController.prototype.getAge = function(dateString) {
  var today = new Date(),
    birthDate = new Date(dateString),
    age = today.getFullYear() - birthDate.getFullYear(),
    m = today.getMonth() - birthDate.getMonth();

  if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
    age--;
  }

  return age;
};

PointGaming.ProfileController.prototype.calculateUserAge = function(event) {
  $('input#user_age').val(this.getAge($(event.target).val()));
};

// configures typeahead functionality for the player or team fields
PointGaming.ProfileController.prototype.setupModalTypeahead = function(){
  var elements = $('#ajax-modal input.playable-search');

  elements.each(function(index, elem){
    elem = $(elem);
    elem.typeahead({
      ajax: { url: '/search/playable.json', triggerLength: 0, method: 'get' },
      display: 'name', 
      itemSelected: function(item, val, text){
        var text_field = elem,
            id_field = text_field.parent().find('input[name$="_id]"]'),
            type_field = text_field.parent().find('input[name$="type]"]');

        text_field.val(text);
        id_field.val(val);
        type_field.val($(item).data('type'));
      },
      val: '_id',
      // We will create a custom render function so that we can store the items type (for use in itemSelected)
      render: function (items) {
        var that = this;

        items = $(items).map(function (i, item) {
          i = $(that.options.item).attr('data-value', item[that.options.val])
                                  .attr('data-type', item['type']);
          i.find('a').html(that.highlighter(item[that.options.display], item));
          return i[0];
        });

        items.first().addClass('active');
        this.$menu.html(items);
        return this;
      }
    });
  });
};

// configures typeahead functionality to search the store
PointGaming.ProfileController.prototype.setupStoreTypeahead = function(){
  var elements = $('div[data-hook="rig_fields"] input:text');

  elements.each(function(index, elem){
    elem = $(elem);
    elem.typeahead({
      ajax: { url: '/search/store.json', triggerLength: 0, method: 'get' },
      display: 'name', 
      itemSelected: function(item, val, text){
        var text_field = elem,
            url_field = text_field.parent().find('input[type=hidden]');

        text_field.val(text);
        url_field.val($(item).data('url'));
      },
      val: '_id',
      // We will create a custom render function so that we can store the items type (for use in itemSelected)
      render: function (items) {
        var that = this;

        items = $(items).map(function (i, item) {
          i = $(that.options.item).attr('data-value', item[that.options.val])
                                  .attr('data-url', item['url']);
          i.find('a').html(that.highlighter(item[that.options.display], item));
          return i[0];
        });

        items.first().addClass('active');
        this.$menu.html(items);
        return this;
      }
    });
  });
};
