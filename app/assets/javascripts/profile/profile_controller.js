var PointGaming = PointGaming || {};

PointGaming.ProfileController = function(options){
  this.registerHandlers();
};

PointGaming.ProfileController.prototype.registerHandlers = function() {
  $('select#user_country').change(function(event) {
    var country_code = $(this).val(),
        select_wrapper = $('#user_state_wrapper'),
        url;

    $('select', select_wrapper).attr('disabled', true);

    url = "/users/subregion_options?parent_region=" + country_code;
    select_wrapper.load(url);
  });
};
