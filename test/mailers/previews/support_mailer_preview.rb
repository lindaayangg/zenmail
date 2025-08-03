class SupportMailerPreview < ActionMailer::Preview
  def contact_support
    user = User.first || User.new(email: "test@example.com", name: "Test User")
    params = {
      subject: "Technical Issue",
      message: "I am having trouble with the app.",
      send_copy: "1"
    }
    SupportMailer.contact_support(user, params)
  end
end
