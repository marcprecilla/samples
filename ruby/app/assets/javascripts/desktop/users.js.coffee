# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  return unless $('body#users').length == 1
  container_obj = $('body#users')

  container_obj.find('.btn-toggle').click (e) ->
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

