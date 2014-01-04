if Rails.env.production?
  # these are the live keys
#  Stripe.api_key = "sk_live_pnKA3pG4ODdBL103NS8UO46R"
#  STRIPE_PUBLISHABLE_KEY = "pk_live_Fmmd0sbvT1aJiOA8ZzDBeLYE"

  # these are test keys
  Stripe.api_key = "sk_test_u1CTPLATlk9TyV3gEnKGxdqM"
  STRIPE_PUBLISHABLE_KEY = "pk_test_sXskiXgaQ3naJXko3ErPET4S"
else
  # these are test keys
  Stripe.api_key = "sk_test_u1CTPLATlk9TyV3gEnKGxdqM"
  STRIPE_PUBLISHABLE_KEY = "pk_test_sXskiXgaQ3naJXko3ErPET4S"
end
