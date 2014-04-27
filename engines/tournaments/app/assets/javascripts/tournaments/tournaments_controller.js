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
                lastDetails = null;

            setInterval(function () {
                var currentDetails = $("#tournament_details").val();

                if (!lastDetails) {
                    lastDetails = currentDetails;
                }

                if (lastDetails !== currentDetails) {
                    lastDetails = currentDetails;
                    console.log("Updating preview.");
                }
            }, 5000);
        },

        prize_pool: function () {
            var inputsPath = "input[data-hook=prizepool-field]";
            $(inputsPath).on("change", function () {
                var total = 0;

                $(inputsPath).each(function (index, element) {
                    total += parseFloat(accounting.toFixed($(element).val(), 2));
                });

                $("span[data-hook=prize-pool-total]").html(accounting.formatMoney(total));
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
