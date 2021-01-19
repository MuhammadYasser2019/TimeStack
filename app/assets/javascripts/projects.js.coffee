# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ($) ->
  parse_row_id = (attr_val) ->
    row_id = attr_val.split("_")[2]
    return row_id
  $(document).on("click", ".add_comment", ->
    row_id = parse_row_id($(this).attr('id'))
    $("#comment_text_"+row_id).show()
    return
   )
   
  $(document).on('change', '.comment',  ->
    console.log("In the comment")
    if $(this).val().length >= 8
      row_id = parse_row_id($(this).attr('id'))
      $("#time_reject_" + row_id).show()
      $('.reject_div').show()
    return
   ) 
  $(document).on('click', '.reject_class', ->
    row_id = parse_row_id($(this).attr('id'))
    cotent = $('#comment_text_' + row_id).val()
    #project_url=$(location).attr('href')
    #project_id = parse_project_id(project_url)
    project_id = $("#project_id_"+row_id).val()
    $.post '/time_reject',
      id: $('#week_id_' + row_id).val(),
      project_id: project_id,
      comments: cotent,
      row_id: row_id
    return
   )
  parse_project_id = (attr_val) ->
    project_id = attr_val.split("/")[4]
    return project_id

  $(document).on("click", ".show-hours", ->
    #$('.show-hours').click ->
    row_id = parse_row_id($(this).attr('id'))
    #project_url=$(location).attr('href')
    #project_id = parse_project_id(project_url)
    project_id = $(this).parent().children("#project_id_"+row_id).val()
    console.log("THE PROJEC ID IS: " + project_id)
    $.post '/show_hours',
      user_id: $('#user_id_' + row_id).val(),
      project_id: project_id,
      week_id: $('#week_id_' + row_id).val()
    return
  )

  parse_user_id = (attr_val) ->
    user_id = attr_val.split("_")[2]
    return user_id

  $(document).on("click", ".pending-email", ->
    #$('.pending-email').click ->
    #row_id = parse_row_id($(this).attr('id'))
    #project_id = $(this).parent().children("#project_id_"+row_id).val()
    user_id = parse_user_id($(this).attr('id'))
    console.log("THE USER ID IS: " + user_id)
    $.post '/pending_email',
      user_id: user_id
    return
  )

  $(document).on("click", ".add-user-to-project", ->
  #$('.add-user-to-project').click ->
    console.log("check is clicked" +$(this).val())

    tr = $(this).parent()
    em = tr.find('.email-class').attr('value')

    console.log("em " + em)
    add_user_id = $(this).val()
    #project_url=$(location).attr('href')
    #project_id = parse_project_id(project_url)
    project_id = $(this).next('input').val()
    console.log("THE ID IS: " + project_id )
    $.get '/add_user_to_project',
      user_id: add_user_id,
      project_id: project_id
    return
  )
  $(document).on("change", ".select-project", ->
    p_id = $(this).val()
    console.log("click select-project- Your project id is:" + p_id)
    $.get '/dynamic_project_update',
      project_id: p_id,
      adhoc: $('#adhoc').val()
    return
  )


  $('#project_left_table').dataTable({
    dom: 'lfrtip',
    "info": false,
    "bLengthChange": false,
    "bFilter": false,
    "paging": false,
    "order" : [[0, 'desc']]
  })

  $('.show_all_projects').click ->
    ckbox = $("#show_all_projects")
    if ckbox.is(':checked')
        check = "true"
    else
        check ="false"
    console.log("click Show all Projects Your CHECK is:" + check)
    $.get '/show_all_projects',
      checked: check
    return

  $('#import_from_system_').click ->
    $('#create_new_project_').prop("checked", false)
    $('.import').show()
    $('.new_project').hide()

  $('#create_new_project_').click ->
    $('#import_from_system_').prop("checked", false)
    $('.new_project').show()
    $('.import').hide()


  $(document).on("change", ".fetch_project", ->
    console.log "Inside system change" + $(this).attr('id') +  " the value selected is " + $(this).val()    
    system_select_id = $(this).val()
    customer_id = $('#customer_id').val()
    build_project(system_select_id, $(this).val())
  )

  $(document).on("click", ".recommend", ->
    if ($('.recommend:checked').length <1)
      $('.pm_actions').hide();
    else
      $('.pm_actions').show();
      $('.pm_actions').css("display", "flex");
  )

  $(document).on("click", ".inventory-equipment-button", ->
    all_ids = []
    sel_users = []
    proj_id  = $('#project_id').val()
    $('.recommend:checked').map((i) ->
      all_ids[i] = $(this).val()
      sel_users[i] = $("#show_" +$(this).val()).text();
      return
    ).get().join ', '
    
    $.ajax
      url: 'set_selected_users'
      type: 'GET'
      data: invetory_users_ids: all_ids , inv_sel_users: sel_users, project_id: proj_id

  )

  $(document).on("click","#inventory_submit-tab", ->
    proj_id = $('#project_id').val()

    $.ajax
      url: 'add_multiple_user_inventory'
      type: 'GET'
      data:  project_id: proj_id
    
  )

 
  $(document).on("click", ".date-inv", -> 
   
    inventory = $(this).closest("tr").attr('id');
    date = $("#date_inventory_" + inventory).val()
     
    $.ajax
      url: 'set_inventory_submitted_date'
      type: 'GET'
      data:  inventory_dates: date, inventory_id: inventory
  )

  $(document).on("click", ".inv_close", -> 
    $("#inventoryModel").modal('hide');
  )

  build_project = (system_select_id, customer_id) ->
    
    my_url = '/show_projects/'+system_select_id
    $.ajax my_url,
      data: {}
      type: 'GET',
      async: false,
      dataType: 'json'
      success: (data, textStatus, jqXHR) ->
        $my_data = data
        console.log "data is  " + data.length + " my_data is  " + $my_data.length
        for item in $my_data
          console.log "data is "+item.name + "  "  + item.id
          $('#system_project').append($("<option></option>").attr("value",item.id).text(item.name))

  $(document).on("click", ".add_new_user", ->
    proj_id = $('#project_id').val();
    $.ajax
      url: 'toggle_shift'
      type: 'GET'
      data:  {project_id: proj_id, partial: 'add_user'}
    
  )
  $(document).on("click", ".change_shift", ->
    proj_id = $('#project_id').val();
    $.ajax
      url: '/toggle_shift'
      dataType: 'GET'
      data:  {project_id: proj_id, partial: 'add_shift'}
      
  )

  $(document).on("keyup", '#myInput', ->
    input = undefined
    filter = undefined
    table = undefined
    tr = undefined
    td = undefined
    i = undefined
    txtValue = undefined
    input = document.getElementById('myInput')
    filter = input.value.toUpperCase()
    table = document.getElementById('myTable')
    tr = table.getElementsByTagName('tr')
    i = 0
    while i < tr.length
      td = tr[i].getElementsByTagName('td')[1]
      if td
        txtValue = td.textContent or td.innerText
        if txtValue.toUpperCase().indexOf(filter) > -1
          tr[i].style.display = ''
        else
          tr[i].style.display = 'none'
      i++
    return
  )

  #$('.invite_user_button').click ->
#
 #   add_user_id = $(this).val()
  #  project_url=$(location).attr('href')
   # project_id = parse_project_id(project_url)
    #$.get '/add_user_to_project',
     # user_id: add_user_id,
      #project_id: project_id
    #return
  #$('#proj_report_start_date').fdatetimepicker
   # initialDate: '11-12-2016'
    #format: 'mm-dd-yyyy'
   # disableDblClickSelection: true
    #leftArrow: '<<'
    #rightArrow: '>>'
    #closeIcon: 'X'
    #closeButton: true
  #$('#proj_report_end_date').fdatetimepicker
   # initialDate: '11-12-2016'
    #format: 'mm-dd-yyyy'
    #disableDblClickSelection: true
    #leftArrow: '<<'
    #rightArrow: '>>'
    #closeIcon: 'X'
    #closeButton: true
    