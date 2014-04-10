(function (window) {
    "use strict";

    window.PointGaming.controllers.seeds = {
        init: function () {

        },

        index: function () {
            var updateServer = function () {
                var seeds = [];

                $(".tourney-players li").each(function (i, e) {
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

            $(".sortable").disableSelection();
            $(".sortable").sortable({
                stop: updateServer
            });

            $(".remove-player").click(function () {
                var tournamentId = $(this).data("tournament-id"),
                    playerId = $(this).data("id");

                $.ajax({
                    url: "/tournaments/" + tournamentId + "/seeds/" + playerId,
                    method: "DELETE"
                });

                $(this).parent("li.draggable").remove();

                return false;
            });
        }
    };
})(window);
