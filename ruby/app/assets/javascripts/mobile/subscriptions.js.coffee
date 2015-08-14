# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  return unless $('body#subscriptions').length == 1

  $('#cc-form').submit (e) ->
    e.preventDefault()
    e.stopPropagation()
    $('#submit-cc-form').attr('disabled', true)
    processCard()

  processCard = ->
    Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))
    Stripe.createToken($('#cc-form'), stripeResponseHandler)

  stripeResponseHandler = (status, response) ->
    if status == 200
      $('#stripe_card_token').val(response['id'])
      $('#errors').hide()
      $('#cc-form')[0].submit()
    else
      $('#errors p').html(response.error.message)
      $('#errors').show()
      $('#submit-cc-form').attr('disabled', false)

  $('.btn-toggle').click (e) ->
    value = $(this).val()
    hidden_field = $($(this).data('hidden-field'))
    target = $($(this).data('target'))
    action = $(this).data('click')

    # copy this button's value into hidden field
    hidden_field.val(value)

    # execute click action
    switch action
      when 'show' then target.slideDown()
      when 'hide' then target.slideUp()
