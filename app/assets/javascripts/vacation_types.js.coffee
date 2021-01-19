jQuery ($) -> 
  $(document).ready ->
    if $("#paid_boolean").is(':checked') == true
      $('#active_display').show()

  $(document).on("click","#paid_c", ->
    paid_status = $("#paid_boolean").is(':checked')
    console.log("result", paid_status)
    if paid_status == false
      $('#active_display').hide()
    else
      $('#active_display').show()
  )

  $(document).on("click", "#accural", ->
    console.log("Testing Accural")
  )
  