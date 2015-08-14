# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  return unless $('body#activity').length == 1

  $('.feedback-question .btn-jump').click  (event) ->
    $('input[name=user_enjoys]').val($(this).attr('data-user-enjoys'))
    $('input[name=user_values]').val($(this).attr('data-user-values'))

  if $('body#activity.show').length > 0
    window.showPoints()
    $('#summary-screen').bind('afterShowScreen', ->
      $('#title').text('Share');
    )

  $('#intervention-feedback-form-submit').click  (event) ->
    event.preventDefault()
    event.stopPropagation()
    $('#intervention-feedback-form').submit()
