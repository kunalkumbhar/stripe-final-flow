# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  get 'welcome/index'
  root 'welcome#index'
  post '/checkout', to: 'stripe_payments#checkout'
  post '/pay', to: 'stripe_payments#pay'
  get '/history', to: 'stripe_payments#history'
  post '/subscribe', to: 'subscriptions#subscribe'
  get '/portal', to: 'stripe_payments#portal'
  post '/subscription_checkout', to: 'subscriptions#subscription_checkout'
  post '/pay_subscription', to: 'subscriptions#pay_subscription'
  get '/my_subscriptions', to: 'subscriptions#list_subscriptions'
  get '/cancel_subscription', to: 'subscriptions#cancel_subscription'
  get '/coupon', to: 'stripe_payments#apply_coupon'

  mount StripeEvent::Engine, at: '/webhooks'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
