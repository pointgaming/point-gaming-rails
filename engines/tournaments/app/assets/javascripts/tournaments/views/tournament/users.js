(function(window){
  "use strict";

  window.PointGaming.views.tournament_users = window.PointGaming.views.base.extend({

    initialize: function(){
      
    },
    
    bindEvents: function() {
      $(document).on('click', "[data-hook=collaborator-form] input.search-query", this.setupTypeahead);
      $(document).on('click', "[data-hook=invites-form] input.search-query", this.setupTypeahead);
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

  });

})(window);
