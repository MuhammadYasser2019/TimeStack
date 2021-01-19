# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ($) -> 

	$(document).on("change", '#date_range', ->
		value = $(this).val()
		console.log("The value in the date range " + value)
		if value is "Current Week"
			current = new Date()
			f_day_w = ("0" + (current.getDate() - (current.getDay() - 1))).slice(-2)
			l_day_w = ("0" + (current.getDate()+ (current.getDay() - 1))).slice(-2)
			month = ("0" + (current.getMonth() + 1)).slice(-2)

			first = current.getFullYear()+"-"+(month)+"-"+(f_day_w)
			last = current.getFullYear()+"-"+(month)+"-"+(l_day_w)

			$('#analytics_report_start_date').val(first)
			$('#analytics_report_end_date').val(last)
			$('#analytics_report_start_date').attr('readonly', true)
			$('#analytics_report_end_date').attr('readonly', true)

		else if value is "Current Month"
			date = new Date()
			firstDay = new Date(date.getFullYear(), date.getMonth(), 1);
			lastDay = new Date(date.getFullYear(), date.getMonth() + 1, 0);

			f_day_m = ("0" + firstDay.getDate()).slice(-2)
			l_day_m = ("0" + lastDay.getDate()).slice(-2)

			firstofmonth = ("0" + (firstDay.getMonth() + 1)).slice(-2)
			lastofmonth = ("0" + (lastDay.getMonth() + 1)).slice(-2)

			firstDay = firstDay.getFullYear()+"-"+(firstofmonth)+"-"+f_day_m
			lastDay =  lastDay.getFullYear()+"-"+(lastofmonth)+"-"+l_day_m

			$('#analytics_report_start_date').val(firstDay)
			$('#analytics_report_end_date').val(lastDay)
			$('#analytics_report_start_date').attr('readonly', true)
			$('#analytics_report_end_date').attr('readonly', true)

		else if value is "Previous Month"
			date = new Date()
			firstDay = new Date(date.getFullYear(), date.getMonth()-1, 1);
			lastDay = new Date(date.getFullYear(), date.getMonth(), 0);

			f_day_m = ("0" + firstDay.getDate()).slice(-2)
			l_day_m = ("0" + lastDay.getDate()).slice(-2)

			firstofmonth = ("0" + (firstDay.getMonth() + 1)).slice(-2)
			lastofmonth = ("0" + (lastDay.getMonth() + 1)).slice(-2)

			firstDay = firstDay.getFullYear()+"-"+(firstofmonth)+"-"+f_day_m
			lastDay =  lastDay.getFullYear()+"-"+(lastofmonth)+"-"+l_day_m

			$('#analytics_report_start_date').val(firstDay)
			$('#analytics_report_end_date').val(lastDay)
			$('#analytics_report_start_date').attr('readonly', true)
			$('#analytics_report_end_date').attr('readonly', true)

		else if value is "Year to Date"
			date = new Date()
			firstDay = new Date(date.getFullYear(), 0,1);
			lastDay = new Date(date);

			f_day_m = ("0" + firstDay.getDate()).slice(-2)
			l_day_m = ("0" + lastDay.getDate()).slice(-2)

			firstofmonth = ("0" + (firstDay.getMonth() + 1)).slice(-2)
			lastofmonth = ("0" + (lastDay.getMonth() + 1)).slice(-2)

			firstDay = firstDay.getFullYear()+"-"+(firstofmonth)+"-"+f_day_m
			lastDay =  lastDay.getFullYear()+"-"+(lastofmonth)+"-"+l_day_m

			$('#analytics_report_start_date').val(firstDay)
			$('#analytics_report_end_date').val(lastDay)
			$('#analytics_report_start_date').attr('readonly', true)
			$('#analytics_report_end_date').attr('readonly', true)	

		else if value is "Previous Year"	
			date = new Date()
			firstDay = new Date(date.getFullYear()-1 ,0);
			lastDay = new Date(date.getFullYear()-1,11,31);

			f_day_m = ("0" + firstDay.getDate()).slice(-2)
			l_day_m = ("0" + lastDay.getDate()).slice(-2)

			firstofmonth = ("0" + (firstDay.getMonth() + 1)).slice(-2)
			lastofmonth = ("0" + (lastDay.getMonth() + 1)).slice(-2)

			firstDay = firstDay.getFullYear()+"-"+(firstofmonth)+"-"+f_day_m
			lastDay =  lastDay.getFullYear()+"-"+(lastofmonth)+"-"+l_day_m

			$('#analytics_report_start_date').val(firstDay)
			$('#analytics_report_end_date').val(lastDay)
			$('#analytics_report_start_date').attr('readonly', true)
			$('#analytics_report_end_date').attr('readonly', true)	
	)
	


	$('.bar-field, .table-field').on 'click', ->
  		$('.bar-field, .table-field').toggle()
  		return

  	$('.line_graph, .timesheets-table-field').on 'click', ->
  		$('.line_graph, .timesheets-table-field').toggle()
  		return

  	$('.user_details_link, .user_details_table').on 'click', ->
  		$('.user_details_link, .user_details_table').toggle()
  		return


  	$('.pie_employment_types, .employment_types_table').on 'click', ->
  		$('.pie_employment_types, .employment_types_table').toggle()
  		return

  	$('.vacation_request_bar, .vacation_request_table').on 'click', ->
  		$('.vacation_request_bar, .vacation_request_table').toggle()
  		return


	$('#show_vacation_reports').dataTable({
	    dom: 'lBfrtip',
	    "retrieve": true,
	    "order": [[ 2, "desc" ]]
	    buttons: [ 'excel', 'pdf']
	  
	})

	$('#show_vacation_summary').DataTable({
	  dom: 'lBfrtip', 
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


  

	

