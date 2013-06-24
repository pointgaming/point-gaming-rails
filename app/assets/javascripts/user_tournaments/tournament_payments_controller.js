(function(window){
  "use strict";

  window.PointGaming.controllers.tournament_payments = {

    init: function(){
    },

    new: function(){
      $(document).on('change', '#payment-source-widget input[type=radio]', helpers.showPaymentSourceFields);
    }
    
  };

  var helpers = {

    showPaymentSourceFields: function(){
      var payment_source = $(this).val() || "";
      $('[data-hook=payment-source-fields]').hide();
      $('#payment_source_fields_' + payment_source).show();
    }

  };

})(window);
