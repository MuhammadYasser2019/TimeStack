window.setDateTimepickers = ->
  if $( '.timepicker' ).length > 0
    $( '.timepicker' ).datetimepicker
      format: 'LT'
      allowInputToggle: true

  if $( '.datetimepicker' ).length > 0
    pickr = $( '.datetimepicker' ).datetimepicker
      format: I18n.t('js.time.formats.american_time_short')
      allowInputToggle: true

  if $('.range_date_time_picker').length > 0
    range_pickers = $('.range_date_time_picker')
    range_pickers.on('dp.change', '.from_date', (e)->
      to_date = $(this).parents('.range_date_time_picker').find('.datetimepicker.to_date input')
      if not to_date.val() || new Date(to_date.val()) < e.date
        to_date.val(e.date.format(I18n.t('js.time.formats.american_time_short')))
    )

