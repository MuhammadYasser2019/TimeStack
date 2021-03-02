class PaymentPdf < Prawn::Document
	require "open-uri"	 
	def initialize(start_date,end_date,customer_detail,daily_invoice_details,total_amount)
		super(top_margin: 50)		
		customer_detail_write(start_date,end_date,customer_detail)
		@order = daily_invoice_details
		#reciept_detail()
		line_items
		total_price(total_amount)
		
		file_path ="invoice_#{Date.today.strftime("%m%y")}_#{customer_detail.id}.pdf"
		render_file "#{Rails.root}/public/#{file_path}"		
	 end 

	 def customer_detail_write(start_date,end_date,customer_detail)
	 	 if !customer_detail.logo.blank?
	 	  pigs = open("#{Rails.root}/public#{customer_detail.logo}")
	 	else
	 		pigs = open("#{Rails.root}/app/assets/images/RSILogo.png")
	 	end

  		image pigs, :at => [10,y-10], :width => 200
	 	move_down 20

	 	#text_box "Reciept No : ",style: :bold, at: [350,y-40]
	 	#text_box "fk6444646466466645", at:  [422,y-40]
	 	text_box "Invoice Date : ",style: :bold, at: [350,y-60]
	 	text_box Time.now.in_time_zone.strftime("%d-%m-%Y"), at:  [430,y-60]
	 	text_box "Start Date / End Date ",style: :bold, at: [350,y-80]	
	 	text_box "#{start_date.strftime("%d-%m-%Y")} / #{end_date.strftime("%d-%m-%Y")}", at: [350,y-95]	 	
	 	text customer_detail.name,size: 20, align: :left
	 	move_down 3	 	
	 	text customer_detail.address
	 	text "#{customer_detail.city},#{customer_detail.state},#{customer_detail.zipcode}"
	 	move_down 25
	 	stroke_horizontal_rule 

	 end

	 # def reciept_detail
	 # 	move_down 20
	 # 	move_down 20
	 # 	text "Bill To",size: 18, style: :bold
	 # 	move_down 10
	 # 	text "Your Customer Name",style: :bold
	 # 	text "your email address}"
	 # 	text "your billing address"
	 # 	text "your city , state,zipcode"
	 # 	move_down 20
	 # 	text "Ship To", style: :bold
	 # 	move_down 10
	 # 	text "Your Customer Name",style: :bold
	 # 	text "your email address}"
	 # 	text "your shipping address"
	 # 	text "your city , state,zipcode"
	 # 	move_down 20
	 	
	 #end

	 def line_items
	 	move_down 20	 

	 	move_down 20
		table line_item_rows do 
			row(0).font_style = :bold
			column(0).width = 300
			column(1).width = 80
			column(2).width = 80
			column(3).width = 80

			columns(1..3).align = :right
			self.row_colors =["DDDDDD","FFFFFF"]
			self.header = true
		end
	 	
	 end

	 def line_item_rows
	 	[["Date","Active User","User Price","Amount"]] +
		 @order.map do |item|
			 	["#{item.created_at.strftime("%d-%b-%Y")}","#{item.active_user}","$#{item.amount_per_user.round(2)}","$#{item.daily_amount.round(2)}"]
 		end
	 end

	 def total_price(total_amount)
	 	move_down 20
	 	text "Total Price",size: 15,style: :bold,align: :right
	 	text "$#{total_amount.round(2)}",size: 15,align: :right
	 end


end