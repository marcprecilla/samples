$ ->
  return unless $('body#charges').length == 1

  $('#export-csv-form-submit').click  (event) ->
    event.preventDefault()
    event.stopPropagation()
    $('form').attr('action','/marketing/lifetime_value.csv')
    $('form').submit()
