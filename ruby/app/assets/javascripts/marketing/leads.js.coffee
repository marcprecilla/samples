$ ->
  return unless $('body#leads').length == 1

  $('#export-csv-form-submit').click  (event) ->
    event.preventDefault()
    event.stopPropagation()
    $('form').attr('action','/marketing/leads.csv')
    $('form').submit()
