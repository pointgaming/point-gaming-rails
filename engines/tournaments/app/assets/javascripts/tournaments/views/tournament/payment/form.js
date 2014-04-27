(function(window){
  "use strict";

  window.PointGaming.views.tournament_payment_form = window.PointGaming.views.base.extend({

    initialize: function(){
      
    },

    bindEvents: function() {
      $(document).on('change', '#payment-source-widget input[type=radio]', this.showPaymentSourceFields);
    },

    showPaymentSourceFields: function(){
      var payment_source = $(this).val() || "";
      $('[data-hook=payment-source-fields]').hide();
      $('#payment_source_fields_' + payment_source).show();
    }

  });

})(window);
