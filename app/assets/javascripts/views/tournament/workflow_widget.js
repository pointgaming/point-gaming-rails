(function(window){
  "use strict";

  window.PointGaming.views.tournament_workflow_widget = window.PointGaming.views.base.extend({

    initialize: function(){
      
    },
    
    bindEvents: function() {
      $(document).on("click", "ul.nav-tabs li.disabled a", this.preventLinkFromWorking);
    },

    preventLinkFromWorking: function(e) {
      e.preventDefault();
      return false;
    }

  });

})(window);
