$ ->
  return unless $('body#charges').length == 1

  $('#export-csv-form-submit').click  (event) ->
    event.preventDefault()
    event.stopPropagation()
    $('form').attr('action','/marketing/kpi.csv')
    $('form').submit()
