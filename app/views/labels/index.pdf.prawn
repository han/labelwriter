prawn_document(:page_layout => :landscape, :page_size => "A4") do |pdf|
  pdf.font "Helvetica"
  render :partial => 'label', :collection => @deliveries, :as => :delivery, :locals => {:pdf => pdf, :count => @deliveries.count}
end
