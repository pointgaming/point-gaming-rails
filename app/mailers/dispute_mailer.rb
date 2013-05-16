class DisputeMailer < ActionMailer::Base
  default from: "no-reply@pointgaming.com"

  def new_message(dispute_message)
    @dispute_message = dispute_message
    dispute_admin_email = SiteSetting.find_by(key: :dispute_admin_email)
    mail(:to => dispute_admin_email.value, :subject => "#{@dispute_message.user.username} has added a new message to a dispute")
  rescue
    # no big deal
  end
end
