(function(window){
  "use strict";

  window.PointGaming.controllers.user_tournaments = {

    init: function(){
      var workflow_widget = new window.PointGaming.views.tournament_workflow_widget(),

          updateServer = function () {
              var seeds = [];
              
              $("#tourney-seeds li").each(function (i, e) {
                  if ($(e).data("id")) {
                      seeds.push($(e).data("id"));
                  }
              });

              $.ajax({
                  url: "seeds",
                  method: "put",
                  data: { seeds: seeds }
              });
          };

      $("li.draggable").draggable({
          appendTo: "body",
          helper: "clone"
      });
      $("#tourney-seeds").droppable({
          drop: function (e, ui) {
              var username = ui.draggable.text(),
                  link;

              if ($(this).find("li:contains('" + username + "')").length) {
                  return false;
              }

              link = $("<a></a>").text("[x]").attr("href", "#").addClass("remove-seed");

              $("<li></li>").text(" " + username).data("id", ui.draggable.data("id")).prepend(link).appendTo(this);
              updateServer();
          }
      }).sortable({
          update: updateServer
      });
      $("#tourney-seeds").on("click", "a", function () {
         $(this).parent("li").remove();
         updateServer();
         return false;
      });
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
    },

    users: function(){
      new window.PointGaming.views.tournament_users();
    }

  };

})(window);
