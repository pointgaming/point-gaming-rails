//= require ./stream/bets_controller
//= require ./stream/streams_controller
//= require ./stream/match_controller
//= require ./stream/stream_admin_controller
//= require ./stream/match_admin_controller
$(function(){
    var $modal = $('#ajax-modal');

    $(document).on('click', 'a[rel="modal:open:ajaxpost"]:not([data-modal-target])', PointGaming.ModalHelper.openModal($modal));
    $(document).on('submit', '#ajax-modal form', PointGaming.ModalHelper.submitModalForm($modal));

    $(document).on('ajax:success', 'a[data-remote][data-modal]:not([data-modal-target])', $modal.modal.bind($modal, 'hide') );
});
