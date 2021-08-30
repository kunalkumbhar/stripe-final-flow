# Sample Rails app to study Stripe APIs

This simple app is built to understand how Stripe APIs can be used in our projects. It mainly focuses on backend operations.

* Ruby version: 2.6.0

* Rails version: 6.1.4

## Prerequisites

* A [Stripe](https://stripe.com/en-in) Account.

* [Ngrok](https://ngrok.com/download) Setup (To test webhooks).

## Features of App

* Signup/Login

* Buy multiple products/single subscription

* Check history of successful payments

* Cancel subscription

* Hosted Portal

* Download Receipt/Invoice

## Application Setup

* Clone this repository

* Run the command: `EDITOR=nano rails credentials:edit`

* You will see the following:
![Credentails](./images/credentials.png)

* Paste your public and secret keys ( Do not worry about signing_secret for now ) from Stripe dashboard into the editor.

* Also add your email and password in the credentials file.

* Update your public key in [client.js](./public/js/client.js) (At the very beginning) file as well.

* Go to your Stripe Dashboard and create products. Eg: ![Products](./images/products.png)

* For subscription plans you can use same products with recurring price.

* Grab id of each price and place them in [index.html.erb](./app/views/welcome/index.html.erb) ( Replace price... with your price id ).

***`NOTE`** **: Do not paste product_id, you must paste price_id of each product in the above mentioned index file***
