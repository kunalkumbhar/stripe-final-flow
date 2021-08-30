
var stripe = Stripe('pk_test_....');

var elements = stripe.elements();

// Set up Stripe.js and Elements to use in checkout form
var style = {
  base: {
    color: "#32325d",
    fontFamily: '"Helvetica Neue", Helvetica, sans-serif',
    fontSmoothing: "antialiased",
    fontSize: "16px",
    "::placeholder": {
      color: "#aab7c4"
    }
  },
  invalid: {
    color: "#fa755a",
    iconColor: "#fa755a"
  },
};

var apply_button = document.getElementById('apply_coupon');
var remove_button = document.getElementById('remove_coupon');

apply_button.addEventListener('click', function(e) {
  e.preventDefault();
  $.ajax({
      type: "GET",
      url: "/coupon",
      dataType:"json",
      data: { 
          coupon: $("#coupon").val()
      },
      success: function(result) {
        var amount = $("#amount").text().split(" ")
        var currency = amount[0]
        var amount = parseFloat(amount[amount.length -1])
        var amount = amount - (amount * result.percent_off)/100;
        $("#amount").text(currency+" => "+amount);
        $("#remove_coupon").show();
        $("#apply_coupon").hide();
      },
      error: function(result) {
          alert('Wrong Coupon Code');
      }
  });
});

remove_button.addEventListener('click', function(e) {
  e.preventDefault();
  var original_amount = $("#original_amount").val();
  $("#remove_coupon").hide();
  $("#apply_coupon").show();
  $("#coupon").val('');
  $("#amount").text(original_amount);
});

var form = document.getElementById('payment-form');

var cardElement = elements.create('card', {style: style});
cardElement.mount('#card-element');

form.addEventListener('submit', function(event) {
  event.preventDefault();
  var addressDetails = {
    address_city: document.getElementById("city").value, 
    address_state: document.getElementById("state").value,
    address_country: document.getElementById("country").value
  }
  stripe.createToken(cardElement, addressDetails).then(function(result) {
    if (result.error) {
      // Inform the customer that there was an error.
      var errorElement = document.getElementById('card-errors');
      errorElement.textContent = result.error.message;
    } else {
      // Send the token to your server.
      stripeTokenHandler(result.token);
    }
  });
});

function stripeTokenHandler(token) {
  // Insert the token ID into the form so it gets submitted to the server
  var form = document.getElementById('payment-form');
  var hiddenInput = document.createElement('input');
  hiddenInput.setAttribute('type', 'hidden');
  hiddenInput.setAttribute('name', 'stripeToken');
  hiddenInput.setAttribute('value', token.id);
  form.appendChild(hiddenInput);
  
  // Submit the form
  form.submit();
  
}