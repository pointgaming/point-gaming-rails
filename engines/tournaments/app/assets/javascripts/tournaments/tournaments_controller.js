(function (window) {
    "use strict";

    window.PointGaming.controllers.tournaments = {
        init: function () {
            $("a[disabled=disabled]").click(function () {
                return false;
            });

            if ($("#tournament-tabs").length) {
                $("#tournament-tabs a").click(function (e) {
                  e.preventDefault();
                  $(this).tab("show");
                })

                $("#tournament-tabs a:first").tab("show");
            }

            if ($("#time-left").length) {
                $("#time-left").countdown({
                    until: (new Date($("#time-left").html().trim())),
                    compact: true,
                    layout: "{hnn}:{mnn}:{snn}",
                    format: "HMS",
                    description: "",

                    onExpiry: function () {
                        $("#btn-checkin").removeClass("btn-disabled");
                        $("#btn-checkin").addClass("btn-info");
                    }
                });

                $("#time-left").show();
            }
        },

        new: function () {
            var form = new window.PointGaming.views.tournament_form();
        },

        edit: function () {
            var form = new window.PointGaming.views.tournament_form(),
                sponsors = new window.PointGaming.views.tournament_sponsors(),
                lastDetails = null,
                updateServer = function () {
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

            setInterval(function () {
                var currentDetails = $("#tournament_details").val();

                if (!lastDetails) {
                    lastDetails = currentDetails;
                }

                if (lastDetails !== currentDetails) {
                    lastDetails = currentDetails;
                    $.post("/tournaments/markdown", {
                        details: lastDetails
                    }, function (data) {
                        $("#details-preview").html(data);
                    });
                }
            }, 3000);

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
        },

        brackets: function () {
            $.ajax({
                method: "GET",
                data: { format: "json" },
                success: function (data) {
                    $("#tourney-brackets").bracket({
                        init: data,
                        skipSecondaryFinal: true
                    });
                }
            });
        },

        users: function(){
            new window.PointGaming.views.tournament_users();
        }
    };
})(window);
