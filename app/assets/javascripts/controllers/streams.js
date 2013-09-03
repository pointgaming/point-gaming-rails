(function (window) {
    "use strict";

    window.PointGaming.controllers.streams = {
        index: function () {
            $(".stream-button").click(function () {
                if ($(this).data("game") === "all") {
                    var all = !!$("#stream-button-all").attr("src").match(/inset/);

                    if (all === false) {
                        $("#stream-button-all").attr("src", "/assets/stream-button-all-inset.png");
                        $("#stream-button-ql").attr("src", "/assets/stream-button-ql-inset.png");
                    } else {
                        $("#stream-button-all").attr("src", "/assets/stream-button-all.png");
                        $("#stream-button-ql").attr("src", "/assets/stream-button-ql.png");
                    }
                } else if ($(this).data("game") === "ql") {
                    if ($("#stream-button-ql").attr("src").match(/inset/)) {
                        $("#stream-button-ql").attr("src", "/assets/stream-button-ql.png");
                        $("#stream-button-all").attr("src", "/assets/stream-button-all.png");
                    } else {
                        $("#stream-button-ql").attr("src", "/assets/stream-button-ql-inset.png");
                    }
                }

                return false;
            });
        }
    };
})(window);
