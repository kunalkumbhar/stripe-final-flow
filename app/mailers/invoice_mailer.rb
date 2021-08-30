class InvoiceMailer < ApplicationMailer
  def order_successful_email
    mail(
      to: params[:customer_email],
      subject: 'Order Successful'
    )
  end
end
