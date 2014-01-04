(function(window){
  "use strict";

  window.PointGaming.views.tournament_prizepool_form = window.PointGaming.views.base.extend({

    initialize: function(){
      
    },
    
    bindEvents: function() {
      $(document).on('keyup', 'input[data-hook=prizepool-field]', this.recalculatePrizepoolTotal);
      $(document).on('change', 'input[data-hook=prizepool-field]', this.recalculatePrizepoolTotal);
    },

    recalculatePrizepoolTotal: function() {
      var total = 0;
      $('input[data-hook=prizepool-field]').each(function(index, element) {
        total += parseFloat(accounting.toFixed($(element).val(), 2));
      });

      $('span[data-hook=prize-pool-total]').html(accounting.formatMoney(total));
    }

  });

})(window);
