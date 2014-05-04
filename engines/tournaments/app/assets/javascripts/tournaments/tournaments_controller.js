(function (window) {
    "use strict";

    window.PointGaming.controllers.tournaments = {
        init: function () {
            $(document).ready(function () {
                var url = document.location.toString();

                if (url.match("#")) {
                    $(".nav-tabs a[href=#" + url.split("#")[1] + "]").tab("show");
                }

                $(".nav-tabs a").on("shown", function (e) {
                    window.location.hash = e.target.hash;
                });
            });

            $("a[disabled=disabled]").click(function () {
                return false;
            });

            if ($("#tournament-tabs").length) {
                $("#tournament-tabs a").click(function (e) {
                    e.preventDefault();
                    $(this).tab("show");
                });

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

        "new": function () {
            var form = new window.PointGaming.views.tournament_form();
        },

        edit: function () {
            var form = new window.PointGaming.views.tournament_form(),
                sponsors = new window.PointGaming.views.tournament_sponsors(),
                lastDetails = null,
                hasBeenEdited = false,

                updateServerSeeds = function () {
                    var seeds = [];

                    $(".tourney-players tr").each(function (i, e) {
                        if ($(e).data("id")) {
                            seeds.push($(e).data("id"));
                        }
                    });

                    $.ajax({
                        url: "seeds",
                        method: "PUT",
                        data: { seeds: seeds }
                    });
                },
                
                setTypeahead = function () {
                    var self = this;

                    if (!this.typeaheadIsSetup) {
                        $(this).typeahead({
                            ajax: {
                                url: "/users/search.json",
                                triggerLength: 1,
                                method: "get"
                            },
                            display: "username",
                            val: "username",
                            itemSelected: function (item, val, text) {
                                $(self).closest("form.typeahead").submit();
                            }
                        });

                        this.typeaheadIsSetup = true;
                    }
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

            $("#tournament_details").bind("input propertychange", function () {
                hasBeenEdited = true;
            });

            $(".sortable").disableSelection();
            $(".sortable").sortable({
                stop: updateServerSeeds
            });

            $(".remove-player").click(function () {
                var tournamentId = $(this).data("tournament-id"),
                    playerId = $(this).data("id");

                if (confirm("Are you sure?")) {
                    $.ajax({
                        url: "/tournaments/" + tournamentId + "/seeds/" + playerId,
                        method: "DELETE"
                    });

                    $(this).parentsUntil("tbody", "tr.draggable").remove();
                }

                return false;
            });

            $("input.search-query").click(setTypeahead);

            window.onbeforeunload = function () {
                if (hasBeenEdited === true) {
                    return "Your data has not been saved.";
                }
            };
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
        }
    };
}(window));
