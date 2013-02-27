var PointGaming = PointGaming || {};

PointGaming.StreamAdminController = function(options){
  options = options || {};
  this.container_selector = options.container_selector || 'div#stream-admin-collaborators';
  this.search_field_selector = options.search_field_selector || 'input.search-query';
  this.playable_search_field_selector = options.playable_search_field_selector || 'input.playable-search';

  this.registerHandlers();
};

PointGaming.StreamAdminController.prototype.registerHandlers = function() {
  var self = this,
    $modal = $('#ajax-modal');

  // prevent the user from submitting the Stream Admin Collaborators form
  $(document).on('submit', this.container_selector + ' form', function(e){
    event.preventDefault();
    return false;
  });

  // setup typeahead functionality for the add collaborators form
  $(document).on('click', this.container_selector + ' ' + this.search_field_selector, function(e){
    var self = this;
    $(this).typeahead({
      ajax: { url: '/users/search.json', triggerLength: 1, method: 'get' },
      display: 'username', 
      val: 'username',
      itemSelected: function(item, val, text){
        var current_form = $(self).closest('form');

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
                $modal.modal('hide');
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
  });

  // clear the hidden id/type fields if the user starts to type
  $(document).on('change', this.playable_search_field_selector, function(e){
    var text_field = $(this),
        id_field = text_field.parent().find('input[name$="_id]"]'),
        type_field = text_field.parent().find('input[name$="type]"]');

    text_field.val('');
    id_field.val('');
    type_field.val('');
  });

  // setup typeahead functionality for the player or team 1/2 fields
  $(document).on('click', this.playable_search_field_selector, function(e){
    var self = this;

    $(this).typeahead({
      ajax: { url: '/search/playable.json', triggerLength: 0, method: 'get' },
      display: 'name', 
      itemSelected: function(item, val, text){
        var text_field = $(self),
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
