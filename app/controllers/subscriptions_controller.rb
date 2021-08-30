# frozen_string_literal: true

require 'stripe'

class SubscriptionsController < ApplicationController
  # protect_from_forgery except: :pay

  def retrieve_or_create_customer
    if current_user.cust_id.nil?
      $customer = Stripe::Customer.create({
                                            email: current_user.email
                                          })
      user = User.find_by(email: current_user.email)
      user.update(cust_id: $customer['id'])
    else
      $customer = Stripe::Customer.retrieve(current_user.cust_id)
    end
  end

  def subscription_checkout
    retrieve_or_create_customer
    $price = Stripe::Price.retrieve(params['plan'])
    @amount = $price['unit_amount']
  end

  def pay_subscription
    @subs = subscribe(params['coupon'])
  end

  def subscribe(coupon)
    items = [{ price: $price }]
    retrieve_or_create_customer
    if !coupon.nil? && coupon !=''
      Stripe::Subscription.create({
        customer: $customer['id'],
        items: items,
        coupon: coupon
      })
    else
      Stripe::Subscription.create({
        customer: $customer['id'],
        items: items
      })
    end
  end

  def list_subscriptions
    retrieve_or_create_customer
    @list = Stripe::Subscription.list({
                                        customer: $customer['id']
                                      })
    @list.data.each do |list|
      list.items.data.each do |item|
        @product = item.price.product
      end
    end
    @product = Stripe::Product.retrieve(@product) if @product
  end

  def cancel_subscription
    @cancel = Stripe::Subscription.delete(params['id'])
  end
end
