jQuery(function($) {
  Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'));

  var stripeResponseHandler = function (_status, response) {
    var form = $("#credit-card-form");

    if (response.error) {
      form.find(".payment-errors").text(response.error.message);
      form.find("button").prop("disabled", false);

      $('body').modalmanager('loading');
    } else {
      // token contains id, last4, and card type
      var token = response.id;
      form.append($('<input type="hidden" name="stripeToken" />').val(token));
      form.first().submit();
    }
  };

  $("#credit-card-form").submit(function () {
    var form = $(this),
        use_payment_profile_field = $('input[name="use_payment_profile"]', form);

    if (use_payment_profile_field.length && use_payment_profile_field.is(':checked')) {
      return true;
    } else if (form.children("input[name=stripeToken]").length === 1) {
      return true;
    } else {
      $('body').modalmanager('loading');
      form.find("button").prop("disabled", true);
      Stripe.createToken(form, stripeResponseHandler);

      return false;
    }
  });

  $('body').on('change', '[data-hook=use-payment-profile]', function() {
    if ($(this).is(':checked')) {
      $("input[data-stripe]").attr('disabled', 'disabled');
    } else {
      $("input[data-stripe]").removeAttr('disabled');
    }   
  }); 
});
