# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ($) ->

  $("tbody").on("change", ".task_id", ->
    console.log "Inside Task change" + $(this).attr('id') +  " the Task value selected is " + $(this).val()
    tokens = $(this).attr('id').split('_')
    task_id = $(this).val()
    console.log "token  sequence is  " + tokens[4]
    comment_select_id = "week_time_entries_attributes_" + tokens[4] + "_activity_log"
    tr = $(this).parent().parent("tr")
    console.log("tr: " + tr)
    $.get '/default_comment',
      id: task_id,
      row_id: tokens[4]
    return
  ) 


  $("tbody").on("change", ".project_id", ->
    console.log "Inside project change" + $(this).attr('id') +  " the value selected is " + $(this).val()
    tokens = $(this).attr('id').split('_')
    console.log "token  sequence is  " + tokens[4]
    task_select_id = "week_time_entries_attributes_" + tokens[4] + "_task_id"
    tr = $(this).parent().parent("tr")
    console.log("tr: " + tr)
    build_tasks(task_select_id, $(this).val())
    date = $(this).parent().siblings(".date1").children("label").text()
    check_holidays($(this).val(), date, tr)
  )
    
  build_tasks = (field_id, project_id) ->
    $('#'+field_id).find('option').remove()
    console.log "Inside  build_tasks  " +  field_id +  "  " + project_id
    my_url = '/available_tasks/'+project_id
    $.ajax my_url,
    data: {}
    type: 'GET'
    dataType: 'json'
    success: (data, textStatus, jqXHR) ->
      $my_data = data
      console.log "data is  " + data.length + " my_data is  " + $my_data.length
      for item in $my_data
        console.log "data is "+item.code + "  "  + item.description
        $('#'+field_id).append($("<option></option>").attr("value",item.id).text(item.description))
      #task_id = $('#'+field_id+' :selected').val()
  
  check_holidays = (project_id, date, tr) ->
    url = "/check_holidays/" + project_id
    console.log(tr)
    console.log "Are there checks? " + tr.find(".exception-check").is(":checked")
    console.log "date array: " + date
    $.ajax url,
    data: {}
    type: "GET"
    dataType: "json"
    success: (data) ->
        if data["holidays"][date] && $.inArray(date, data["holiday_exceptions"]) == -1
           console.log "exceptions: " + $.inArray(data["holidays"][date], data["holiday_exceptions"])
           console.log "iteration: " + date
           console.log "show me the data " + JSON.stringify(data["holidays"][date])
           dateclass = ".date-" + date
           $(dateclass).parent().parent("tr").find("textarea").text(data["holidays"][date])
           $(dateclass).parent().parent("tr").find(".hours-input,button,textarea").attr("disabled", "disabled");
           $(dateclass).parent().parent("tr").find(".hours-input").val(0)
           console.log "AFTER DISABLED"
        else if !tr.find(".exception-check").is(":checked")
           console.log "ELSE ELSE ELSE ELSE ELSE ELSE"
           dateclass = ".date-" + date
           $(dateclass).parent().parent("tr").find(".hours-input,button,textarea").removeAttr("disabled");
      	   
  value = 0
  count = 0

  $("tbody").on("click", ".add_row", ->
    t = $(this).parent().parent("tr")
    i = $(this).parent().parent("tr").next()
    copy = t.clone()
    r= copy.children(".date2").next()
    console.log("the value of r = " +r.attr('value'))
    hidden_field= r.remove()

    copy.children(".hour").children(".hours-field").remove()
    
    toggle_text = $(this).parent().children(".add-time").text()
    console.log("ADD ROW- Check toggle-text: " + toggle_text)

    remove_add_row = copy.children(".add").children(".add_row").remove()


    console.log(i.is("input"))
    if value == 0
      value = parseInt($("table input:last").attr("value")) + 1
    else
      value += 1
    if count == 0
      count = $("tbody tr").length
    else
      count += 1
    console.log("VALUEEEEEE: " + count)
#    input = $('<input type="hidden" id="week_time_entries_attributes_'+ count + '_id" name="week[time_entries_attributes][' + count + '][id]" >')
#    inputdate = $('<input type="hidden" id="week_time_entries_attributes_'+ count + '_date_of_activity" value="'+ count + '"  name="week[time_entries_attributes][' + count + '][date_of_activity]" >')
#    console.log(input)
    date_value = copy.children(".date1").children().text()
    console.log("this is a the date value" + date_value)
    date = $('<input type="hidden" value="' + date_value + '"  name="week[time_entries_attributes][' + count + '][date_of_activity]">')
    date.insertAfter(copy.children(".date:first").children())
    copy.children(".project").children().attr("name", "week[time_entries_attributes][" + count + "][project_id]")
    copy.children(".project").children().attr("id", "week_time_entries_attributes_" + count + "_project_id").val("")
    copy.children(".task").children().attr("name", "week[time_entries_attributes][" + count + "][task_id]")
    copy.children(".task").children().attr("id", "week_time_entries_attributes_" + count + "_task_id").val("")

    #copy.children(".hour").children(".hours-field").children().attr("name", "week[time_entries_attributes][" + count + "][hours]")
    #copy.children(".hour").children(".hours-field").children().attr("id", "week_time_entries_attributes_" + count + "_hours")

    if toggle_text == "Enter Hours"
      copy.children(".hour").append('<div class="toggle hours-field" style="display: none"><input class="form-control input-sm hours-input" type="text" name="week[time_entries_attributes][' + count + '][hours]" id="week_time_entries_attributes_' + count + '_hours"></div>')
    else
      copy.children(".hour").append('<div class="toggle hours-field" style="display: block"><input class="form-control input-sm hours-input" type="text" name="week[time_entries_attributes][' + count + '][hours]" id="week_time_entries_attributes_' + count + '_hours"></div>')

    copy.children(".hour").children(".enter_time").children("select:first").attr("name", "week[time_entries_attributes][" + count + "][time_in(4i)]")
    copy.children(".hour").children(".enter_time").children("select:first").attr("id", "week_time_entries_attributes_" + count + "_time_in_4i")

    copy.children(".hour").children(".enter_time").children("select:nth-child(3)").attr("name", "week[time_entries_attributes][" + count + "][time_in(5i)]")
    copy.children(".hour").children(".enter_time").children("select:nth-child(3)").attr("id", "week_time_entries_attributes_" + count + "_time_in_5i")

    copy.children(".hour").children(".enter_time").children("select:nth-child(5)").attr("name", "week[time_entries_attributes][" + count + "][time_out(4i)]")
    copy.children(".hour").children(".enter_time").children("select:nth-child(5)").attr("id", "week_time_entries_attributes_" + count + "_time_out_4i")

    copy.children(".hour").children(".enter_time").children("select:nth-child(6)").attr("name", "week[time_entries_attributes][" + count + "][time_out(5i)]")
    copy.children(".hour").children(".enter_time").children("select:nth-child(6)").attr("id", "week_time_entries_attributes_" + count + "_time_out_5i")


    copy.children(".activity_log").children().attr("name", "week[time_entries_attributes][" + count + "][activity_log]")
    copy.children(".activity_log").children().attr("id", "week_time_entries_attributes_" + count + "_activity_log").val("")
    copy.children(".activity_log").children(".char_count").attr("id", "week_time_entries_attributes_" + count + "_char_count").text("")
#    copy.children(".activity_log").children(".char_count")
#    copy.children(".date1").children().attr("for", "week[time_entries_attributes][" + count + "][date_of_activity]")
    copy.children(".date1").children().attr("for", "week_time_entries_attributes_" + count + "_" + date_value)
    copy.children(".date2").next().attr("id", "week_time_entries_attributes_" + count + "_date_of_activity" )
    copy.children(".date2").next().attr("name", "week[time_entries_attributes][" + count + "][date_of_activity]" )

    copy.insertAfter(t)
#    input.insertAfter(i.next())
  )
  $("tbody").on("click", ".exception-check", ->
    orig = $(this)
    console.log(orig.is(":checked"))
    console.log("exception-checkr?")
    tr = $(this).parent().parent().parent("tr")
    label = tr.find(".date1").children("label")
    console.log(label.text())
    date = label.text()
    console.log("count: " + tr.siblings().length)
    if orig.is(":checked")
      console.log("already checked")
      console.log("non-date: " + tr.next().next().find(".date1").children("label").text())
      console.log("date: " + date)
      result = confirm("This will remove any added rows to from this day. Proceed?");
   	  if result
   	   tr.find(".hours-input,button,textarea,select").attr("disabled", "disabled");
   	   tr.find(".hours-input").val(0)
   	   tr.find("a").hide()
   	   tr.siblings().each ->
   	    console.log("sibling")
        if $(this).find(".date1").children("label").text() == date
         $(this).remove()
      else
       orig.prop("checked", false)
      orig.removeAttr("disabled")
    else
      console.log("not checked")
      tr.find(".hours-input,button,textarea,select").removeAttr("disabled");
      tr.find("a").show()
  )

  $("tbody").on("change", ".vacation-change, .partial_day", ->
    orig = $(this)
    
    tr = orig.parent().parent("tr")
    label = tr.find(".date1").children("label")
    console.log(label.text())
    partial = tr.find(".partial_day").is(":checked")
    
    date = label.text()
    console.log("count: " + tr.siblings().length)
    
    if ($(this).attr('class') == 'vacation-change' && orig.val() != "" && !partial) || ($(this).attr('class') == 'partial_day' && tr.find(".vacation-change").val() != "" && !partial)
      console.log("already checked")
      console.log("non-date: " + tr.next().next().next().find(".date1").children("label").text())
      console.log("date: " + date)
      result = confirm("This will remove any added rows to from this day. Proceed?");
      if result
        
        tr.find(".hours-input,button,textarea,.partial_day,select:not(.vacation-change)").attr("disabled", "disabled");
        tr.find(".hours-input").val(0)
        tr.find("a").hide()
        tr.siblings().each ->
        console.log("sibling")
        if orig.find(".date1").children("label").text() == date
          orig.remove()
      else
        orig.val('')
        if !partial && $(this).attr('class') == 'partial_day'
          tr.find(".partial_day").prop("checked", true)
        orig.removeAttr("disabled")
    else
      console.log("not checked")
      tr.find(".hours-input,button,textarea,.partial_day,select").removeAttr("disabled");
      tr.find("a").show()
  )


  $("tbody").on("keydown", ".input-lg", ->
    text_length = $(this).val().length
    $(this).next('.char_count').html text_length + '/500'
  )

  $('.print-report').click ->
    $('#hidden_print_report').val("true")
    after =$('#hidden_print_report').attr('value')
    $('#report_form').submit()
    
  $(".project_id").each ->
    console.log "each"
    console.log "VALUE: " + $(this).val()
    tr = $(this).parent().parent("tr")
    console.log("tr: " + tr)
    unless $(this).val() == ""
	    date = $(this).parent().siblings(".date1").children("label").text()
	    check_holidays($(this).val(), date, tr)


  parse_user_id = (attr_val) ->
    user_id = attr_val.split("_")[2]
    return user_id

  $("tbody").on("click", ".previous_commment_icon", ->
    user_id = parse_user_id($(this).attr('id'))
    week_id = $(this).attr('id').split("_")[3]
    console.log("THE USER ID IS: " + user_id)
    $.post '/previous_comments',
      user_id: user_id,
      week_id: week_id
    return
  )

  $(document).on("click", ".expense_record_icon", ->
    user_id = parse_user_id($(this).attr('id'))
    week_id = $(this).attr('id').split("_")[3]
    console.log("THE EXPENSE recorD USER ID IS: " + user_id)
    $.get '/expense_records',
      user_id: user_id,
      week_id: week_id 
    return
  )


  $(document).on('click', '.delete_expense', ->
    console.log("weeks.js- Delete Expense")
    week_id = $(this).attr('id').split("_")[1]
    console.log("THE DELETE EXPENSE Week ID IS: " + week_id)
    expense = $(this).attr('id').split("_")[2]
    console.log("Weeks.js- DELETE ROW "+"expense-
    row_id: "+ expense )
    $.get "/delete_expense",
      week_id: week_id,
      expense: expense
    return
  )
  $(document).on('click', '.delete_attachment', ->
    console.log("weeks.js- Delete Expense")
    expense = $(this).attr('id').split("_")[1]
    console.log("THE DELETE EXPENSE  ATTACHEMENT expense ID IS: " + expense)
    expense_attachment = $(this).attr('id').split("_")[2]
    console.log("Weeks.js- DELETE ROW "+"Expense Attachment-
    row_id: "+ expense_attachment )
    $.get "/delete_attachment",
      expense: expense,
      expense_attachment: expense_attachment
    return
  )

  $(document).on('click', '.edit_expense', ->
    console.log("weeks.js- Edit Expense") 
    expense = $(this).attr('id').split("_")[2]  
    week_id = $(this).attr('id').split("_")[1]     
    $.get "/edit_expense",  
      week_id: week_id,    
      expense: expense
    return
  )


  $("tbody").on("click", ".add_button", ->
    console.log("BEFORE REVEAL")
    $("#userPreviousComments").bootstrap('show')
    console.log("AFTER REVEAL")
  )


  $("tbody").on("click", ".add-time", ->
    console.log("weeks.coffee add time")
    row = $(this).parent().parent("tr")
    hour_field = row.children(".hour").children('.toggle')
    console.log("the row is " + hour_field)
    hour_field.toggle()
    $(this).html if $(this).text() == 'Enter Time' then 'Enter Hours' else 'Enter Time'
    return
    )
  $("tbody").on("click", ".notification_dialog", ->
    notification_id = ($(this).attr('id')).split("_")[1]
    console.log("THE notif ID IS: " + notification_id)
    $.get '/get_notification',
      notification_id: notification_id
    return
  )

  $(document).on("click", "#add_time", ->
    bigArray = []
    smoothie = $('.smoothie')

    smoothie.each (index ) ->
      index = index
      lilArray = []

      hours = $('.hours-input')
      myhours = hours.find('.hours-input')
      console.log("Hours Worked", myhours.prevObject[index].value)
      hr = myhours.prevObject[index].value
      
      partial = $('.partial_day')
      mypartial = partial.find('mypartial')
      console.log("partial", mypartial.prevObject[index].checked)
      pr = mypartial.prevObject[index].checked

      if pr == false && hr == 0
        hr = 8 
      else 
        hr = 8 - hr
      console.log("hours used", hr)

      lilArray.push(hr)
      lilArray.push(pr)

      vacation_id = $('.vacation-change')
      myvac = vacation_id.find('vacation-change')
      console.log("VAC", myvac.prevObject[index].value)
      vcid = myvac.prevObject[index].value
      lilArray.push(vcid)
      bigArray.push(lilArray)
      lilArray = []
      console.log("did this work",bigArray) 

    url = "/weeks/"+ 2266
    $.ajax url,
    data: {bigArray}
    type: "POST"
    dataType: "json"
    
  )



