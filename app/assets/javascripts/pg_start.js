// IMPORTANT: This file should be loaded last in the DOM, after all
// page-specific controllers and libraries.
// 
// The page-specific triggering algorithm is heavily inspired by:
// http://www.viget.com/inspire/extending-paul-irishs-comprehensive-dom-ready-execution/
(function(window){
  "use strict";

  var UTIL = {};

  // Trigger the specified controller action function.
  UTIL.exec = function( controller, action ){
    var ns = window.PointGaming.controllers,
        action = (typeof action === "undefined") ? "init" : action;

    if (controller !== "" && ns[controller] && typeof ns[controller][action] == "function") {
      ns[controller][action]();
    }
  };

  // Trigger all 3 actions for the current page.
  UTIL.init = function(){
    UTIL.exec("common");
    UTIL.exec(PointGaming.currentPage.controller);
    UTIL.exec(PointGaming.currentPage.controller, PointGaming.currentPage.action);
  };

  // Call init on page load, using jQuery's way if available, or fallback
  // to native DOM events.
  if(!!window.jQuery){
    window.jQuery( window.document ).ready( UTIL.init() );
  } else {
    var timeout = window.setTimeout(function(){ UTIL.init() },2000);
    window.onload = function(){
      clearTimeout(timeout);
      UTIL.init();
    };
  }

})(window);
