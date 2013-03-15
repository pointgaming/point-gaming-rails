// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery.remotipart
//= require twitter/bootstrap/bootstrap-dropdown
//= require twitter/bootstrap/bootstrap-tooltip
//= require twitter/bootstrap/bootstrap-popover
//= require bootstrap-datetimepicker
//= require bootstrap-modalmanager
//= require bootstrap-modal
//= require bootstrap-typeahead
//= require ./global/socket.io
//= require ./global/chatbox
//= require ./global/modal_helper
//= require ./global/toolbar_controller
//= require_tree ./global

$(function(){
  new PointGaming.ToolbarController();
});
