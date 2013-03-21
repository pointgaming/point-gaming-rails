var PointGaming = PointGaming || {};

PointGaming.ModalHelper = {
  openModal: function(modal, callback) {
    return function(e) {
      var elem = $(this),
          options = {};

      e.preventDefault();

      $('body').modalmanager('loading');

      options.width = elem.data('width') || 'auto';
      options.height = elem.data('height') || 'auto';

      modal.load(elem.attr('href'), '', function(){
        modal.modal(options);
        if (typeof(callback) === 'function'){
          callback();
        }
      });

      return false;
    };
  },

  // hides the model if it is currently open, then reopens it using the href 
  // and method of the scoped element
  reopenModal: function(modal, callback) {
    var self = this;

    return function(e) {
      modal.modal('hide');
      self.openModal(modal, callback).bind(this)(e);
    }
  },

  submitModalForm: function(modal) {
    return function(){
      var current_form = $(this);
      if (current_form.is('.typeahead')) {
        return;
      }

      // show the spinner
      $('body').modalmanager('loading');

      // send the ajax call
      $.ajax({
        type: this.method,
        url: this.action + '.json',
        data: current_form.serialize(),
        dataType: 'html',
        success: function(data) {
          // hide the spinner
          $('body').modalmanager('loading');

          // close the dialog
          modal.modal('hide');
        },
        error: function(data) {
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
    };
  }

};