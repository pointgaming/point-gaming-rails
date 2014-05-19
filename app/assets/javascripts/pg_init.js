// This file sets up the basic object literals for the application.
(function (window) {
    "use strict";

    var body = window.document.body,
        PointGaming = window.PointGaming = window.PointGaming || {};

    // Set up the global PointGaming object with common elements
    PointGaming.controllers = {};
    PointGaming.helpers = {};
    PointGaming.views = {};
    PointGaming.currentPage = {
        controller: body.getAttribute("data-controller"),
        action: body.getAttribute("data-action")
    };

    PointGaming.extend = function (obj) {
        $.each(arguments, function (index, source) {
            var prop;

            if (source) {
                for (prop in source) {
                    if (source.hasOwnProperty(prop)) {
                        obj[prop] = source[prop];
                    }
                }
            }
        });
        return obj;
    };
}(window));
