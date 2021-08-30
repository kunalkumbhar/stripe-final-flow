require 'stripe'

StripeEvent.signing_secret = Rails.application.credentials.stripe[:development][:signing_secret]

StripeEvent.configure do |events|
  events.subscribe 'invoice.paid' do |event|
    InvoiceMailer.with({ "customer_email": event.data.object.customer_email }).order_successful_email.deliver_now
  end
end
