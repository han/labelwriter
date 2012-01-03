prawn_document(:page_layout => :landscape, :page_size => "A4") do |pdf|
  pdf.font "Helvetica"
  pdf.font_size 30
  @ids.each do |id|
    delivery = Delivery.find(id)
    pdf.bounding_box([20, pdf.bounds.top - 20], :width => 300) do
      pdf.text "Item Code:"
      pdf.text "Fetim Code:"
      pdf.text "Name:"
      pdf.text "Purchase Order:"
      pdf.text "Ship Date:"
    end
    pdf.bounding_box([350, pdf.bounds.top - 20], :width => 300) do
      pdf.text delivery.product.item_code, :align => :right
      pdf.text delivery.product.fetim_code, :align => :right
      pdf.text delivery.product.fetim_name, :align => :right
      pdf.text delivery.purchase_order, :align => :right
      pdf.text delivery.shipped_at.to_s, :align => :right
    end
    delivery.product.barcode.annotate_pdf(pdf, :xdim => 3 , :unbleed => 0.3,  :height => 200, :print_code => true, :guard_bar_size => 15)
    pdf.start_new_page
  end
  pdf.text "#{@ids.count} labels"
  pdf.text "generated at #{Time.now}"
end
