(function(window){
  "use strict";

  window.PointGaming.controllers.tournament_prizepool = {

    init: function(){
      var workflow_widget = new window.PointGaming.views.tournament_workflow_widget();
    },

    edit: function(){
      var form = new window.PointGaming.views.tournament_prizepool_form();
    }

  };

})(window);
