(function (window) {
    "use strict";

    window.PointGaming.controllers.tournaments = {
        init: function () {
            var workflow_widget = new window.PointGaming.views.tournament_workflow_widget();
        },

        new: function () {
            var form = new window.PointGaming.views.tournament_form();
        },

        edit: function () {
            var form = new window.PointGaming.views.tournament_form(),
                sponsors = new window.PointGaming.views.tournament_sponsors();
        },

        prize_pool: function () {
            var form = new window.PointGaming.views.tournament_prizepool_form();
        },

        seeds: function () {
            var updateServer = function () {
                var seeds = [];

                $("#tourney-seeds li").each(function (i, e) {
                    if ($(e).data("id")) {
                        seeds.push($(e).data("id"));
                    }
                });

                $.ajax({
                    url: "seeds",
                    method: "PUT",
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

                    $("<li></li>").text(" " + username).data("id", ui.draggable.data("id")).prepend(link).appendTo($(this).find("ol"));
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

        brackets: function () {
            $.ajax({
                method: "GET",
                data: { format: "json" },
                success: function (data) {
                    $("#tourney-brackets").bracket({
                        init: data
                    });
                }
            });
        },

        users: function(){
            new window.PointGaming.views.tournament_users();
        }
    };
})(window);
