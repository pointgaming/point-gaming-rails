(function (window) {
    "use strict";

    function tabs() {
        $(document).ready(function () {
            var url = document.location.toString();

            if (url.match("#")) {
                $(".nav-tabs a[href=#" + url.split("#")[1] + "]").tab("show");
            }

            $(".nav-tabs a").on("shown", function (e) {
                window.location.hash = e.target.hash;
            });
        });

        if ($("#tournament-tabs").length) {
            $("#tournament-tabs a").click(function (e) {
                e.preventDefault();
                $(this).tab("show");
            });

            $("#tournament-tabs a:first").tab("show");
        }
    }

    function datepicker() {
        $(document).on("click", "[data-behavior~='datepicker']", function (e) {
            $(e.target).datetimepicker({
                format: "mm/dd/yyyy HH:ii p",
                autoclose: true,
                todayHighlight: true,
                showMeridian: true
            }).focus();
        });
    }

    function countdown() {
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
    }

    function seeds() {
        var updateServerSeeds = function () {
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
        };

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
    }

    function editDetails() {
        var hasBeenEdited = false,
            currentDetails,
            lastDetails;

        window.onbeforeunload = function () {
            if (hasBeenEdited === true) {
                return "Your data has not been saved.";
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

        $(".tournament-save").click(function () {
            window.onbeforeunload = null;
        });
    }

    function searchFields() {
        var setTypeahead = function () {
                var self = this,
                    controller = $(this).data("controller"),
                    val = $(this).data("val");

                if (!this.typeaheadIsSetup) {
                    $(this).typeahead({
                        ajax: {
                            url: "/" + controller + "/search.json",
                            triggerLength: 1,
                            method: "get"
                        },
                        display: val,
                        val: val,
                        itemSelected: function (item, val, text) {
                            if (controller === "users") {
                                $(self).closest("form.typeahead").submit();
                            }
                        }
                    });

                    this.typeaheadIsSetup = true;
                }
            };

        $("input.search-query").click(setTypeahead);
    }

    window.PointGaming.controllers.tournaments = {
        init: function () {
            tabs();
            datepicker();
            countdown();
            seeds();
            searchFields();

            $("a[disabled=disabled]").click(function () {
                return false;
            });
        },

        "new": function () {
            $(document).on("change", "select#tournament_game_id", function (e) {
                var gameId = $(this).val(),
                    selectWrapper = $("#game_type_wrapper"),
                    url;

                $("select", selectWrapper).attr("disabled", true).val("");

                url = "/game_type_options?for=tournament&game_id=" + gameId;
                selectWrapper.load(url);
            });
        },

        edit: function () {
            editDetails();
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
