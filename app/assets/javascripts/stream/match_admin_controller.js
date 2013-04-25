var PointGaming = PointGaming || {};

PointGaming.MatchAdminController = function(match, options){
  this.match = match;
  this.options = options || {};

  this.options.match_admin_actions_container = 'div#match-admin-actions';
  this.registerHandlers();
};

PointGaming.MatchAdminController.prototype.registerHandlers = function() {
  var modal = $('#match-modal');

  $(document).on('change', '#match-modal input.playable-search', this.clearRelatedHiddenFields);

  $(document).on('click', 'a[rel="modal:open:ajaxpost"][data-modal-target="#match-modal"]', this.openModal(modal));
  $(document).on('submit', '#match-modal form', PointGaming.ModalHelper.submitModalForm(modal));

  $(document).on('ajax:success', '#match-modal a[data-remote][data-dismiss-modal]', modal.modal.bind(modal, 'hide'));

  $(document).on('click', '#match-modal a[data-modal-follow-link]', PointGaming.ModalHelper.reopenModal(modal));

  PointGaming.socket.on("Match.new", this.handleMatchCreated.bind(this));
  PointGaming.socket.on("Match.update", this.handleMatchUpdated.bind(this));
};

// this method will return the handler used to setup match modal windows.
PointGaming.MatchAdminController.prototype.openModal = function(modal){
  var self = this;

  // after opening the modal, this method will store the match_id that 
  // the user expects to be working with on the modal window for later use
  return function(e) {
    var match_id = $(this).data('match-id') || "",
        callback = function(){
          modal.data('match-id', match_id);
          self.setupTypeahead();
        };
    PointGaming.ModalHelper.openModal(modal, callback).bind(this)(e);
  };
};

PointGaming.MatchAdminController.prototype.handleMatchCreated = function(data){
    this.addAlertToModal("A new match has been created by another user.", 'alert-info');

    this.removeNewMatchLink();
    this.addManageMatchLink(data);
    this.addStartMatchLink(data);
    this.addCancelMatchLink(data);
    this.removeFinalizeMatchLink();
};

PointGaming.MatchAdminController.prototype.handleMatchUpdated = function(data){
  var changed_trigger,
      key,
      oldValue;

  for (key in data.match) {
    if (data.match.hasOwnProperty(key)) {
      if (this.match[key] !== data.match[key]) {
        // stash old value
        oldValue = this.match[key];

        // update value to reflect changes
        this.match[key] = data.match[key];

        // TODO: switch this to an event emitter
        // called changed method, if exists
        changed_trigger = key + "_changed";
        if (typeof(this[changed_trigger]) === "function") {
          this[changed_trigger](oldValue, data.match[key], data);
        }
      }
    }
  }

  console.log( $('#match-modal').data('match-id') );
  this.addAlertToModal("The match has been updated by another user.", 'alert-info');
};

PointGaming.MatchAdminController.prototype.state_changed = function(old_value, new_value, data) {
    if (new_value === 'cancelled' || new_value === 'finalized') {
        this.addNewMatchLink();
        this.removeManageMatchLink();
        this.removeStartMatchLink();
        this.removeCancelMatchLink();
        this.removeFinalizeMatchLink();
    } else if (new_value === 'started') {
        this.removeNewMatchLink();
        this.removeManageMatchLink();
        this.removeStartMatchLink();
        this.removeCancelMatchLink(data);
        this.addFinalizeMatchLink(data);
    }
};

PointGaming.MatchAdminController.prototype.addNewMatchLink = function(data){
    this.removeNewMatchLink();

    $('<a id="new-match" class="btn" data-modal-target="#match-modal" rel="modal:open:ajaxpost"></a>').data('match-id', '')
        .attr('href', this.options.new_match_path)
        .html('New Match')
        .appendTo($(this.options.match_admin_actions_container)).after(" ");
};

PointGaming.MatchAdminController.prototype.addManageMatchLink = function(data){
    this.removeManageMatchLink();

    $('<a id="manage-match" class="btn" data-modal-target="#match-modal" rel="modal:open:ajaxpost"></a>').data('match-id', data.match._id)
        .attr('href', this.options.polymorphic_match_path.replace(':match_id', data.match._id))
        .html('Manage Match')
        .appendTo($(this.options.match_admin_actions_container)).after(" ");
};

PointGaming.MatchAdminController.prototype.addStartMatchLink = function(data){
    this.removeStartMatchLink();

    $('<a id="start-match" class="btn btn-success" data-method="put" data-remote="true" data-type="json"></a>')
        .attr('href', this.options.match_path.replace(':match_id', data.match._id) + "/start")
        .html('Start Match')
        .appendTo($(this.options.match_admin_actions_container)).after(" ");
};

PointGaming.MatchAdminController.prototype.addCancelMatchLink = function(data){
    this.removeCancelMatchLink();

    $('<a id="cancel-match" class="btn btn-danger" data-method="put" data-remote="true" data-type="json"></a>')
        .attr('href', this.options.match_path.replace(':match_id', data.match._id) + "/cancel")
        .html('Cancel Match')
        .appendTo($(this.options.match_admin_actions_container)).after(" ");
};

PointGaming.MatchAdminController.prototype.addFinalizeMatchLink = function(data){
    this.removeFinalizeMatchLink();

    $('<a id="finalize-match" class="btn" data-modal-target="#match-modal" rel="modal:open:ajaxpost"></a>')
        .attr('href', this.options.match_path.replace(':match_id', data.match._id) + "/edit")
        .html('Finalize Match')
        .appendTo($(this.options.match_admin_actions_container)).after(" ");
};

PointGaming.MatchAdminController.prototype.removeNewMatchLink = function(){
    $('a#new-match').remove();
};

PointGaming.MatchAdminController.prototype.removeManageMatchLink = function(){
    $('a#manage-match').remove();
};

PointGaming.MatchAdminController.prototype.removeStartMatchLink = function(){
    $('a#start-match').remove();
};

PointGaming.MatchAdminController.prototype.removeCancelMatchLink = function(){
    $('a#cancel-match').remove();
};

PointGaming.MatchAdminController.prototype.removeFinalizeMatchLink = function(){
    $('a#finalize-match').remove();
};

PointGaming.MatchAdminController.prototype.addAlertToModal = function(message, additional_class){
  var modal_body = $('div.modal-body', '#match-modal');

  $('div.alert', modal_body).remove();

  $('<div class="alert ' + additional_class + '"></div>').html(message).prependTo(modal_body);
};

// clears hidden id/type fields if the user changes the field value themself
PointGaming.MatchAdminController.prototype.clearRelatedHiddenFields = function(e){
    var text_field = $(this),
        id_field = text_field.parent().find('input[name$="_id]"]'),
        type_field = text_field.parent().find('input[name$="type]"]');

    text_field.val('');
    id_field.val('');
    type_field.val('');
};

// configures typeahead functionality for the player or team fields
PointGaming.MatchAdminController.prototype.setupTypeahead = function(){
  var elements = $('#match-modal input.playable-search');

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
