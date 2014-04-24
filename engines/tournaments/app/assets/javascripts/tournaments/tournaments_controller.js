(function (window) {
    "use strict";

    window.PointGaming.controllers.tournaments = {
        init: function () {
            var workflowWidget = new window.PointGaming.views.tournament_workflow_widget();

            $("a[disabled=disabled]").click(function () {
                return false;
            });

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
                sponsors = new window.PointGaming.views.tournament_sponsors();
        },

        prize_pool: function () {
            var inputsPath = "input[data-hook=prizepool-field]";
            $(inputsPath).on("change", function () {
                var total = 0;

                $(inputsPath).each(function(index, element) {
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
