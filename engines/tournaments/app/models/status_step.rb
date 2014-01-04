class StatusStep
  attr_accessor :tournament, :step
  cattr_reader :steps

  @@steps = [:creation, :prizepool, :payment, :payment_verification, :activation]

  def initialize(params = {})
    self.tournament = params.fetch(:tournament)
    self.step = params.fetch(:step)
  end

  def is_completed?
    self.send("#{step}_completed?")
  end

  def is_current_step?
    self.send("#{step}_is_current_step?")
  end

  def display_name
    I18n.t(step, scope: [:models, :tournament_status_steps])
  end
  private

  def creation_completed?
    !tournament.new_record?
  end

  def creation_is_current_step?
    tournament.new_record?
  end

  def prizepool_completed?
    tournament.prizepool.present?
  end

  def prizepool_is_current_step?
    tournament.prizepool_required?
  end

  def payment_completed?
    tournament.payment.present?
  end

  def payment_is_current_step?
    tournament.payment_required?
  end

  def payment_verification_completed?
    tournament.activated?
  end

  def payment_verification_is_current_step?
    tournament.payment_pending?
  end

  def activation_completed?
    tournament.activated?
  end

  def activation_is_current_step?
    false
  end
end
