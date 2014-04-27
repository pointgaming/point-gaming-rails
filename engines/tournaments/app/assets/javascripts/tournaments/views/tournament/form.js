(function(window){
  "use strict";

  window.PointGaming.views.tournament_form = window.PointGaming.views.base.extend({
 
    initialize: function(){
      
    },

    bindEvents: function() {
      $(document).on("click", "[data-behavior~='datepicker']", this.showDateTimePicker);
      $(document).on("change", "select#tournament_game_id", this.updateGameTypeOptions);
    },

    showDateTimePicker: function(event) {
      $(event.target).datetimepicker({format: 'mm/dd/yyyy HH:ii p', autoclose: true, todayHighlight: true, showMeridian: true}).focus();
    },

    updateGameTypeOptions: function(event) {
      var game_id = $(this).val(),
          select_wrapper = $('#game_type_wrapper'),
          url;

      $('select', select_wrapper).attr('disabled', true).val('');

      url = "/game_type_options?for=tournament&game_id=" + game_id;
      select_wrapper.load(url);
    }

  });

})(window);
