# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ($) ->
  
  $(document).on("change", ".pm_project_id", ->
    console.log "Inside project change" + $(this).attr('id') +  " the value selected is " + $(this).val()    
    user_select_id = "adhoc_pm_id"
    tr = $(this).parent().parent("tr")
    console.log("tr: " + tr)
    build_users(user_select_id, $(this).val())
  )

  build_users = (user_id, project_id) ->
    $('#'+user_id).find('option').remove()
    console.log "Inside  build_tasks  " +  user_id +  "  " + project_id
    my_url = '/available_users/'+project_id
    $.ajax my_url,
      data: {}
      type: 'GET',
      async: false,
      dataType: 'json'
      success: (data, textStatus, jqXHR) ->
        $my_data = data
        console.log "data is  " + data.length + " my_data is  " + $my_data.length
        for item in $my_data
          console.log "data is "+item.code + "  "  + item.description
          $('#'+user_id).append($("<option></option>").attr("value",item.id).text(item.email))

  $('#report').hide()

  parse_row_id = (attr_val) ->
    row_id = attr_val.split("_")[4]
    return row_id

  parse_customer_row_id = (attr_val) ->
    row_id = attr_val.split("_")[0]
    return row_id

  parse_user_id = (attr_val) ->
    user_id = attr_val.split("_")[1]
    return user_id

  parse_vacation_request_id = (attr_val) ->
    row_id = attr_val.split("_")[3]
    return row_id

  parse_customer_id = (attr_val) ->
    customer_id = attr_val.split("/")[4]
    return customer_id

  $('.select-customer').click ->
    c_id = $(this).val()
    console.log("click select-customer- Your customer id is:" + c_id)
    $.get '/dynamic_customer_update',
      customer_id: c_id
    return


  $(document).on('click', '.resend_vacation_request', ->
    console.log("REQUEST")
    vacation_request_row_id = parse_row_id($(this).attr('id'))
    console.log("VR ROW ID: " + vacation_request_row_id)
    vacation_request_id = parse_vacation_request_id($(this).attr('id'))
    console.log(vacation_request_id)

    start = $('#vacation_start_' + vacation_request_row_id).attr('value')
    end = $('#vacation_end_' + vacation_request_row_id).attr('value')
    $('#vacation_comment_' + vacation_request_row_id).text("hi")
    #$('#vacation_comment_' + vacation_request_row_id).trigger
    c = $('#vacation_comment_' + vacation_request_row_id).text()

    console.log("START :" + start + "END :" + end + "COMMENT" + c)
    $.get "/resend_vacation_request",
      vacation_request_id: vacation_request_id,
      vacation_start: start,
      vacation_end: end
    return
  )

  parse_email_user_id = (attr_val) ->
   user_id = attr_val.split("_")[2]
   return user_id

  $(document).on("click", ".customers-pending-email", ->
    #$('.pending-email').click ->
    #row_id = parse_row_id($(this).attr('id'))
    #project_id = $(this).parent().children("#project_id_"+row_id).val()
    user_id = parse_email_user_id($(this).attr('id'))
    console.log("THE USER ID IS: " + user_id)
    $.post '/customers_pending_email',
      user_id: user_id
    return
  )

  $(document).on("click", ".announce_popup", ->    
    announcement_id = $(this).attr('id')
    console.log("THE USER ID IS: " + announcement_id)
    $.post '/update_announcement',
      id: announcement_id
    return
  )

  $(document).on("click", ".announce_edit", ->
    announcement_id = $(this).attr('id')
    console.log("THE USER ID IS: " + announcement_id)
    $.get '/announcements/'+announcement_id+'/edit'
    return
  )

  $(document).on('click', '.remove-user-from-customer', ->
    console.log("customers.js- romove customer")
    user_id = parse_user_id($(this).attr('id'))
    console.log("customer.js- remove form customer "+"user_id: "+ $(this).attr('id'))
    row = parse_customer_row_id($(this).attr('id'))
    console.log("customer.js- remove from customer "+"row_id: "+ row )
    customer_url=$(location).attr('href')
    customer_id = parse_customer_id(customer_url)
    $.get "/remove_user_from_customer",
      user_id: user_id,
      customer_id: customer_id,
      row: row
    return
  )

  $(document).on('click', '.remove-emp-type', ->
    console.log("customers.js- romove employment")
    v_id = $(this).attr('id').split("_")[0]
    e_id = $(this).attr('id').split("_")[1]
    console.log("customer.js- remove form customer "+"v: "+ $(this).attr('id'))
    row = $(this).parent().parent().attr('id')
    console.log("customer.js- remove from customer "+"row_id: "+ row )
    customer_url=$(location).attr('href')
    customer_id = parse_customer_id(customer_url)
    $.get "/remove_emp_from_vacation",
      emp_id: e_id,
      vacation_id: v_id,
      row: row
    return
  )

  parse_customer_id = (attr_val) ->
   customer_id = attr_val.split("_")[2]
   return customer_id

  parse_shared_user_id = (attr_val) ->
   shared_user_id = attr_val.split("_")[5]
   return shared_user_id

  $(document).on("click", ".shared_user", ->
    console.log("check is clicked" +$(this).val())
    customer_id = parse_customer_id($(this).attr('id'))
    console.log("customer id is " + customer_id)
    shared_user_id = parse_shared_user_id($(this).attr('id'))
    $.get '/shared_user',
      user_id: shared_user_id,
      customer_id: customer_id
  )

  $(document).on("click", ".shared_customer", ->
    console.log("customers check is clicked" +$(this).val())

    shared_customer_id = $(this).val()
    user_id = $('#user_id').val()
    $.get '/add_shared_users',
      async: false,
      customer_id: shared_customer_id,
      user_id: user_id
  )

  $(document).on("click", ".add_pm_role", ->
    console.log("check is clicked" +$(this).val())

    user_id = $(this).val()
    $.get '/add_pm_role',
      user_id: user_id,
  )
  customer_name = -> 
    console.log("checking for customer_name")
    c_name =  $("#customer_id").attr("value")
    p_name = $("#project_name").attr("value")
    console.log("name is " + c_name)
    console.log("Project name is " + p_name)
    if p_name?
      console.log("Project is undefined")
      c = "#{c_name} - Time Tracking System - #{p_name}"
    else
      c = "#{c_name} - Time Tracking System" 
    return c

  $(document).on("click", ".assign_proxy_role", ->
    console.log("check is clicked" +$(this).val())

    user_id = $(this).val()
    $.get '/assign_proxy_role',
      user_id: user_id,
  )

  $(document).on("click", ".assign_cm_proxy_role", ->
    console.log("check is clicked" +$(this).val())

    user_id = $(this).val()
    $.get '/assign_cm_proxy_role',
      user_id: user_id,
  )

  $(document).on("click", ".hours-approved", ->
    console.log($('#proj_report_end_date').val());
    start_date = $('#proj_report_start_date').val();
    end_date = $('#proj_report_end_date').val();
    type = $(this).attr("id").split("_")[0]
    project_id = $(this).attr("id").split("_")[2];
    task_id = $(this).attr("id").split("_")[6];
    shift_id=  $(this).attr("id").split("_")[4];

    console.log("THE PROJEC ID IS: " + project_id)
    $.ajax
      url: '/hours_approved',
      type: 'POST'
      data:  {project_id: project_id, task_id: task_id, shift_id: shift_id, type: type, start_date: start_date, end_date: end_date}
  )

  $(document).on("click", ".users-on-project", ->
    project_id = $(this).attr("id").split("_")[1];
    
    console.log("THE PROJEC ID IS: " + project_id)
    $.ajax
      url: '/users_on_project',
      type: 'GET'
      data:  {project_id: project_id}
  )

  $(document).on("click", ".project_for_pm", ->
    user_id = $(this).attr("id").split("_")[1];
    
    console.log("THE USER ID IS: " + user_id)
    $.ajax
      url: '/show_pm_projects',
      type: 'GET'
      data:  {user_id: user_id}
  )
  
  $(document).on("click", ".open_previous_week", ->
    $(this).attr("id").split("_")
    user_id = $(this).attr("id").split("_")[1];
    console.log("THE USER ID IS: " + user_id)
    $.ajax
      url: '/open_previous_week_modal',
      type: 'POST'
      data: { user_id: user_id }
  )

  $(document).on("click", ".open_edit_customer", ->
    $(this).attr("id").split("_")
    user_id = $(this).attr("id").split("_")[1];
    console.log("THE USER ID IS: " + user_id)
    $.ajax
      url: '/open_edit_customer_modal',
      type: 'POST'
      data: { user_id: user_id }
  )



  


  $('#show_reports').DataTable({
    dom: 'lBfrtip',
    "retrieve": true,
    buttons: [
      {
        extend: 'excel',
        title: customer_name,
      },
      {
        extend: 'pdf',
        title: customer_name,
        orientation:'landscape',
        pageSize: 'TABLOID'
      }
    ]
  })

  $('#shift_report').DataTable({
    dom: 'lBfrtip',
    "retrieve": true,
    buttons: [
      {
        extend: 'excel',
        title: "Shift Report",
      },
      {
        extend: 'pdf',
        title: "Shift Report",
        orientation:'landscape',
        pageSize: 'TABLOID'
      }
    ]
  })

  $('#show_project_reports').DataTable({
    dom: 'lBfrtip',
    "retrieve": true,
    "ordering": false,
    buttons: [
      {
        extend: 'excel',
        title: "Project Report",
      },
      {
        extend: 'pdf',
        title: "Project Report",
        orientation:'landscape',
        pageSize: 'TABLOID'
      }
    ]
  })

  $('#inventory_reports').DataTable({
    dom: 'lBfrtip',
    "retrieve": true,
    buttons: [
      {
        extend: 'excel',
        title: customer_name
      },
      {
        extend: 'pdf',
        title: customer_name
        orientation:'landscape',
        pageSize: 'TABLOID'
      }
    ]
  })


  $('#show_weekly_reports').DataTable({
    dom: 'lBfrtip',
    searching: false, 
    paging: false, 
    info: false,
    ordering: false
    buttons: [
      {
        extend: 'excel',
      },
      {
        extend: 'pdf',
        orientation:'landscape',
        pageSize: 'TABLOID'
      }
    ]
  })


  $(document).on("change", ".pm_user_id", ->
    console.log "Inside user change" + $(this).attr('id') +  " the value selected is " + $(this).val()  
    pm_user_id = $(this).val() 
    project_id = $(this).closest('tr').attr('id')
    $("#pm_user_id_"+project_id).val(pm_user_id)
  )

  $(document).on('click', '.assign_pm', (event)->
    event.preventDefault()
    customer_id = $('#customer_id').val()
    project_id = $(this).closest('tr').attr('id')
   
    my_url = '/assign_pm/'+customer_id

    $.post my_url,

      "project_id": project_id,
      "user_id": $("#pm_user_id_"+project_id).val(),
  )
   
  $("tbody").on("change", "#current_month", ->
    
    if ($(this).val() =="current_month" || $(this).val() =="last_month" || $(this).val() =="current_week" || $('#current_week').is(":checked"))

      date = new Date()
      
      if $(this).val() =="current_month"
        firstDay = new Date(date.getFullYear(), date.getMonth(), 1);
        lastDay = new Date(date.getFullYear(), date.getMonth() + 1, 0);

        f_day_m = ("0" + firstDay.getDate()).slice(-2)
        l_day_m = ("0" + lastDay.getDate()).slice(-2)

        firstofmonth = ("0" + (firstDay.getMonth() + 1)).slice(-2)
        lastofmonth = ("0" + (lastDay.getMonth() + 1)).slice(-2)

        firstDay = firstDay.getFullYear()+"-"+(firstofmonth)+"-"+f_day_m
        lastDay =  lastDay.getFullYear()+"-"+(lastofmonth)+"-"+l_day_m
      else if $(this).val() =="last_month"
        firstDay = new Date(date.getFullYear(), date.getMonth()-1, 1);
        lastDay = new Date(date.getFullYear(), date.getMonth(), 0);

        f_day_m = ("0" + firstDay.getDate()).slice(-2)
        l_day_m = ("0" + lastDay.getDate()).slice(-2)

        
        firstofmonth = ("0" + (firstDay.getMonth() + 1)).slice(-2)
        lastofmonth = ("0" + (lastDay.getMonth() + 1)).slice(-2)
        
        firstDay = firstDay.getFullYear()+"-"+(firstofmonth)+"-"+f_day_m
        lastDay =  lastDay.getFullYear()+"-"+(lastofmonth)+"-"+l_day_m
      else if $(this).val() =="current_week"
        current = new Date()
        f_day_w = ("0" + (current.getDate() - (current.getDay() - 1))).slice(-2)
        l_day_w = ("0" + (current.getDate() - (current.getDay() - 7))).slice(-2)
    
        month = ("0" + (current.getMonth() + 1)).slice(-2)

        firstDay = current.getFullYear()+"-"+(month)+"-"+(f_day_w)
        lastDay = current.getFullYear()+"-"+(month)+"-"+(l_day_w)
  
      $('#proj_report_start_date').val(firstDay)
      $('#proj_report_end_date').val(lastDay)
      $('#proj_report_start_date').attr('readonly', true)
      $('#proj_report_end_date').attr('readonly', true)
      $('#current_week').attr('checked', false)
    else
      $('#proj_report_start_date').attr('readonly', false)
      $('#proj_report_end_date').attr('readonly', false)
  )

  $(document).on('click', '#current_week', ->
    if ($(this).is(":checked") || $(this).val() =="current_month" || $(this).val() =="last_month")
      
      current = new Date()
      f_day_w = ("0" + (current.getDate() - (current.getDay() - 1))).slice(-2)
      l_day_w = ("0" + (current.getDate() - (current.getDay() - 7))).slice(-2)
    
      month = ("0" + (current.getMonth() + 1)).slice(-2)

      first = current.getFullYear()+"-"+(month)+"-"+(f_day_w)
      last = current.getFullYear()+"-"+(month)+"-"+(l_day_w)

      $('#proj_report_start_date').val(first)
      $('#proj_report_end_date').val(last)
      $('#proj_report_start_date').attr('readonly', true)
      $('#proj_report_end_date').attr('readonly', true)
      $('#current_month').val('')
      
    else
      $('#proj_report_start_date').attr('readonly', false)
      $('#proj_report_end_date').attr('readonly', false)
  )

  $(document).on("change", '#vacation_type_id', ->
    console.log("You changed the vacation "+ $(this).attr('id') + "the value is " + $(this).val())
    emp_id = "employment_type_"

    $("input[id^='employment_type_']").each ->
      console.log(this.id)
      $('#'+this.id).removeAttr('checked')    

    build_task(emp_id, $(this).val())
  )

  $(document).off("change")
  $(document).on("change", '.vc_end', ->
    start_date = new Date($('.vc_start').val());
    end_date = new Date($('.vc_end').val());

    if (start_date > end_date)
      $('.vc_end').val('');
      alert("end date should be greater than start date");
    else
      console.log("wtf", $('.vc_start').val())
      start = $('.vc_start').val().split('-')[2]
      console.log("wtf", $('.vc_end').val())
      end = $('.vc_end').val().split('-')[2]
      console.log("start", start, "end", end )
      console.log("days requested", end - start)
      days_requested = (end - start)

    if $('.vc_start').val() == '' || $('#vacation_type_id').val() == ''
      alert('All three vacation fields are required')
      $('.vc_end').val('')
    else
      $.get "/pre_vacation_request",
        days_requested: days_requested,
        start_date: $('.vc_start').val(),
        end_date: $('.vc_end').val(),
        vacation_type_id: $('#vacation_type_id').val()
  ) 

  $(document).on("change", '.vc_start', ->
    console.log("wtf")
    $('.vc_end').val('')
  )

  $(document).on("change", '#vacation_type_id', ->
    console.log("wtf")
    $('.vc_end').val('')
  )

  $(document).on("click", '.cancel_vacation_request', ->
    vacation_request_row_id = parse_row_id($(this).attr('id'))
    console.log("VR ROW ID: " + vacation_request_row_id)
    vacation_request_id = parse_vacation_request_id($(this).attr('id'))
    console.log("This is the ID", vacation_request_id)
    $.get "/cancel_vacation_request",
      vacation_id: vacation_request_id
  )

  build_task = (content_id, vacation_id) ->
    my_url = '/get_employment'
    $.ajax my_url,
    data: {
      vacation_id: vacation_id,
    },
    type: 'GET',
    dataType: 'json',
    success: (data, textStatus, jqXHR) ->
      $my_data = data

      for item in $my_data
        console.log "data is "+ item.name
        $('#'+content_id+item.id).prop('checked', true)

  $(document).on('click', '#hideshow', ->
    $('#show_hide').css("display", "block")
    $('#hideshow').css("display", "none")
  )

  $(document).on('click', '#hideall', ->
    $('#show_hide').css("display", "none")
    $('#hide_button').css("display", "block")
  )

  $(document).on("change", "#shift_project_id", ->
    console.log "Inside project change" + $(this).attr('id') +  " the value selected is " + $(this).val()    
    shift_type = "project_shift_type_id"
    tr = $(this).parent().parent("tr")
    console.log("tr: " + tr)
    build_shifts(shift_type, $(this).val())
  )

  build_shifts = (shift_type, project_id) ->
    $('#'+shift_type).find('option').remove()
    console.log "Inside  build_shift  "  +  "  " + project_id
    my_url = '/shift_request/'
    $.ajax my_url,
      data: {project_id: project_id},
      type: 'GET',
      async: false,
      dataType: 'json'
      success: (data, textStatus, jqXHR) ->
        console.log "Inside  build_tasks2  "  +  data
        $my_data = data
        console.log "data is  " + data.length + " my_data is  " + $my_data.length
        $('#current_project_shift_type_id').html($("<option></option>").attr("value",$my_data[0][1]).text($my_data[0][0])) 
        i = 1
        while i < $my_data.length
          $('#'+shift_type).append($("<option></option>").attr("value",$my_data[i][1]).text($my_data[i][0])) 
          i++

  $('#project-select').selectpicker()

  all = $('option[value=all]')
  $('.selectpicker').change ->
    all = $('option[value=all]')
    thisVal = all.html()
    if all.is(':selected')
      $('#project-select').selectpicker 'deselectAll'
      $('ul.dropdown-menu > li[rel=0]').addClass 'selected'
      $('span.filter-option').html thisVal
    else
      $('ul.dropdown-menu > li[rel=0]').removeClass 'selected'
    return
 