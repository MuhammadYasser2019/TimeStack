jQuery ($) ->	 
  $("tbody").on("change", ".default_project_id", ->
    console.log "Inside project change" + $(this).attr('id') +  " the value selected is " + $(this).val()
    task_select_id = "default_task_id"
    build_tasks(task_select_id, $(this).val())
    date = $(this).parent().siblings(".date1").children("label").text()
  )

  $("tbody").on("click", ".assign_project", ->
    
    console.log "Inside project change" + $(this).attr('id').split('_')[1]
    user_id = $(this).attr('id').split("_")[1]
    project_id = $("#project_id_"+user_id).val()
    $.get '/assign_project',
      async: false,
      project_id: project_id,
      user_id: user_id 
    return
  )
  


  $(document).off("click",".reset_reason")
  $(document).one("click", ".reset_reason", ->
    week_id = $(this).attr('id').split("_")[2]
    comment = $('#reset_text').val()
    console.log("Testing Comment" + comment + "Week_id" + week_id)
    $.post '/change_status',
      async: false,
      reason_for_reset: comment,
      week_id: week_id 
    return
  )
  $(document).off("change", ".default_user")
  $(document).on("change", ".default_user", -> 
    user_email = $(this).val()
    console.log("This show the value " + user_email )
    $.get '/default_week',
    user_email: user_email 
    return
  )
  $('.print-user-report').click ->
    console.log("in here")
    $('#hidden_print_report').val("true")
    $('#user_report_form').submit()

  $(document).off("keyup", ".r_comment")
  $(document).on("keyup", ".r_comment",  ->
    console.log("In the comment")
    if $(this).val().length >= 8
      $("button").prop('disabled',false); 
    return
  )

  $('#show_approved_form').click
	  
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
      #default_task_id = $('#'+field_id+' :selected').val()

  $("#feature_id").change ->
    console.log("You changed the feature "+ $(this).attr('id') + "the value is " + $(this).val())
    $('.success_message').empty()
    content_id = "cke_1_contents"
    build_task(content_id, $(this).val())

  build_task = (content_id, feature_id) ->
    $('#'+content_id).find('val').empty()
    console.log "Inside comment_id  " +  content_id +  "  " + feature_id
    my_url = '/available_data/'+feature_id
    $.ajax my_url,
    data: {}
    type: 'GET'
    dataType: 'json'
    success: (data, textStatus, jqXHR) ->
      $my_data = data
      for item in $my_data
        console.log "data is "+ item.feature_type
        if (item.feature_data)
          CKEDITOR.instances.feature_content_content.setData( item.feature_data)
        else
          CKEDITOR.instances.feature_content_content.setData('')
        

