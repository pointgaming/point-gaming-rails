(function(window){
  "use strict";

  window.PointGaming.controllers.tournaments = {

    init: function(){
      var workflow_widget = new window.PointGaming.views.tournament_workflow_widget();
    },

    new: function(){
      var form = new window.PointGaming.views.tournament_form();
    },
    
    edit: function(){
      var form = new window.PointGaming.views.tournament_form()
        , sponsors = new window.PointGaming.views.tournament_sponsors();
    },

    prize_pool: function(){
      var form = new window.PointGaming.views.tournament_prizepool_form();
    }

  };

})(window);
