class SupportMailer < ApplicationMailer
  default to: "support@modelmention.ai"

  def contact_support(user, params)
    @user = user
    @message = params[:message]
    @subject = params[:subject]
    mail(
      subject: "[ModelMention Support] #{@subject}",
      from: "ModelMention <noreply@modelmention.ai>",
      reply_to: @user.email,
      cc: params[:send_copy] == "1" ? @user.email : nil
    )
  end
end
