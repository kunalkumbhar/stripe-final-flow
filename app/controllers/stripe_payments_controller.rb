# frozen_string_literal: true

require 'stripe'

class StripePaymentsController < ApplicationController
  # protect_from_forgery except: :pay

  def create_or_retrieve_payment_source(params)
    if $customer['default_source'].nil?
      Stripe::Customer.create_source(
        $customer['id'],
        { source: params['stripeToken'] }
      )
    else
      Stripe::Customer.retrieve_source(
        $customer['id'],
        $customer['default_source']
      )
    end
  end

  def retrieve_or_create_customer
    if current_user.cust_id.nil?
      $customer = Stripe::Customer.create({
                                            email: current_user.email
                                          })
      @user = User.find_by(email: current_user.email)
      @user.update(cust_id: $customer['id'])
    else
      $customer = Stripe::Customer.retrieve(current_user.cust_id)
    end
    $customer
  end

  def confirmation_failed
    @conf = {}
    @conf['status'] = 'failed'
    @conf['message'] = 'Unknown Error occured Please try again'
    @conf
  end

  def checkout
    @amount = 0
    retrieve_or_create_customer
    params['prod'].each do |i|
      $price = Stripe::Price.retrieve(i)
      Stripe::InvoiceItem.create({
                                   price: i,
                                   customer: $customer['id']
                                 })
      @amount += $price['unit_amount'].to_f
    end
  end

  def pay
    p params['coupon']
    invoice = if !params['coupon'].nil? && params['coupon'] != ''
                Stripe::Invoice.create({
                                         customer: $customer['id'],
                                         discounts: [
                                           { coupon: params['coupon'] }
                                         ]
                                       })
              else
                Stripe::Invoice.create({
                                         customer: $customer['id']
                                       })
              end

    Stripe::Invoice.finalize_invoice(
      invoice['id']
    )
    source = create_or_retrieve_payment_source(params)
    @pay = Stripe::Invoice.pay(
      invoice['id'],
      { source: source }
    )
    stripe_errors = [Stripe::RateLimitError, Stripe::InvalidRequestError, Stripe::AuthenticationError,
                     Stripe::APIConnectionError, Stripe::StripeError, StandardError]
  rescue Stripe::CardError => e
    @pay = confirmation_failed
    @pay['message'] = e.error.message
  rescue *stripe_errors
    @pay = confirmation_failed
  end

  def history
    retrieve_or_create_customer
    @invoices = Stripe::Invoice.list({
                                       customer: $customer['id']
                                     })
  end

  def portal
    retrieve_or_create_customer
    configuration = Stripe::BillingPortal::Configuration.create({
                                                                  features: {
                                                                    customer_update: {
                                                                      allowed_updates: %w[tax_id address],
                                                                      enabled: true
                                                                    },
                                                                    invoice_history: { enabled: true },
                                                                    payment_method_update: {
                                                                      enabled: true
                                                                    },
                                                                    subscription_cancel: {
                                                                      enabled: true,
                                                                      mode: 'immediately'
                                                                    }
                                                                  },
                                                                  business_profile: {
                                                                    privacy_policy_url: 'http://localhost:3000/success',
                                                                    terms_of_service_url: 'http://localhost:3000/'
                                                                  }
                                                                })
    portal_session = Stripe::BillingPortal::Session.create({
                                                             customer: $customer['id'],
                                                             return_url: 'http://localhost:3000/',
                                                             configuration: configuration['id']
                                                           })
    redirect_to portal_session['url']
  end

  def apply_coupon
    @coupon = Stripe::Coupon.retrieve(params['coupon'])
    render json: @coupon
  end
end
