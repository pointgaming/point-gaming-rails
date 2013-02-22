var PointGaming = PointGaming || {};

PointGaming.StreamAdminController = function(options){
  options = options || {};
  this.container_selector = options.container_selector || 'div#stream-admin-collaborators';
  this.search_field_selector = options.search_field_selector || 'input.search-query';

  this.registerHandlers();
};

PointGaming.StreamAdminController.prototype.registerHandlers = function() {
  var self = this,
    $modal = $('#ajax-modal');

  $(document).on('submit', this.container_selector + ' form', function(e){
    event.preventDefault();
    return false;
  });

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
};
