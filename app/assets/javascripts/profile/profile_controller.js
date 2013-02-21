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

  $(document).on("click", "[data-behavior~='datepicker']", function(event) {
    $(event.target).datetimepicker({format: 'yyyy/mm/dd', autoclose: true, minView: 2, todayHighlight: true}).focus();
  });

  var getAge = function(dateString) {
    var today = new Date(),
      birthDate = new Date(dateString),
      age = today.getFullYear() - birthDate.getFullYear(),
      m = today.getMonth() - birthDate.getMonth();

    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }

    return age;
  }

  $(document).on("change", "input#user_birth_date", function(event) {
    $('input#user_age').val(getAge($(event.target).val()));
  });
};
