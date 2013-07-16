(function(window){
  "use strict";

  window.PointGaming.controllers.tournament_payments = {

    init: function(){
      var workflow_widget = new window.PointGaming.views.tournament_workflow_widget();
    },

    new: function(){
      var form = new window.PointGaming.views.tournament_payment_form();
    }
    
  };

})(window);
