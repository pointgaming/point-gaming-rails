//= require ./stream/bets_controller
//= require ./stream/streams_controller
$(function(){
    var $modal = $('#ajax-modal');

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

        // show the spinner
        $('body').modalmanager('loading');

        // send the ajax call
        $.ajax({
            type: this.method,
            url: this.action + '.json',
            data: $(this).serialize(),
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
                   current_form.find("#"+ current_form.attr("id").split('_').pop()+ "_" + key).after('<span class="error">'+ value[0] + '</span>');
                });
            }
        });
        return false;
    });
});
