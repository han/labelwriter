prawn_document(:page_layout => :landscape, :page_size => "A4") do |pdf|
  pdf.font "Helvetica"
  @ids.each do |id|
    pdf.font_size 30
    delivery = Delivery.find(id)
    pdf.bounding_box([50, pdf.bounds.top - 20], :width => 300) do
      pdf.text "Purchase Order:"
      pdf.text "Fetim Article #:"
      pdf.text "Fetim Article Name:"
      pdf.text "Size (mm):"
      pdf.text "Boxes"
      pdf.text "Items"
    end
    pdf.bounding_box([50, pdf.bounds.top - 290], :width => 300) do
      pdf.text "Fetim EAN-code:"
    end
    pdf.bounding_box([50, pdf.bounds.top - 460], :width => 300) do
      pdf.text delivery.product.item_grp_code
    end
    pdf.bounding_box([400, pdf.bounds.top - 20], :width => 300) do
      pdf.text delivery.purchase_order, :align => :right
      pdf.text delivery.product.fetim_code, :align => :right
      pdf.text delivery.product.omlabel || ' ', :align => :right
      pdf.text delivery.product.diameter || ' ', :align => :right
      pdf.text delivery.product.num_in_buy.to_s, :align => :right
      pdf.text delivery.product.per_pack_un.to_s, :align => :right
    end
    pdf.bounding_box([400, pdf.bounds.top - 500], :width => 300) do
      delivery.product.barcode.annotate_pdf(pdf, :xdim => 3 , :unbleed => 0.3,  :height => 200, :print_code => true, :guard_bar_size => 15)
    end
    pdf.font_size 15
    pdf.bounding_box([50, pdf.bounds.top - 490], :width => 300) do
      pdf.text delivery.product.item_code
    end

    pdf.start_new_page
  end
  pdf.text "#{@ids.count} labels"
  pdf.text "generated at #{Time.now}"
end
