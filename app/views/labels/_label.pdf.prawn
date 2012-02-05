num_labels = delivery.pallets_needed
1.upto(num_labels) do |i|
  pdf.font_size 30
  pdf.bounding_box([30, pdf.bounds.top - 20], :width => 300) do
    pdf.text "Purchase Order:"
    pdf.text "Fetim Article #:"
    pdf.text "Fetim Article Name:"
    pdf.text "Size:"
    pdf.text "Boxes"
    pdf.text "Items"
  end
  pdf.bounding_box([30, pdf.bounds.top - 460], :width => 300) do
    pdf.text delivery.product.item_grp_code
  end
  pdf.bounding_box([340, pdf.bounds.top - 20], :width => 400) do
    pdf.text delivery.purchase_order, :align => :right
    pdf.text delivery.product.fetim_code, :align => :right
    pdf.text delivery.product.omlabel || ' ', :align => :right
    pdf.text delivery.product.size || ' ', :align => :right
    pdf.text delivery.num_boxes.to_s, :align => :right
    pdf.text delivery.quantity.to_s, :align => :right
  end
  if delivery.product.code_bars.present?
    pdf.bounding_box([30, pdf.bounds.top - 290], :width => 300) do
      pdf.text "Fetim EAN-code:"
    end
    pdf.bounding_box([440, pdf.bounds.top - 500], :width => 300) do
      delivery.product.barcode.annotate_pdf(pdf, :xdim => 3 , :unbleed => 0.3,  :height => 200, :print_code => true, :guard_bar_size => 15)
    end
  end
  pdf.font_size 15
  pdf.bounding_box([30, pdf.bounds.top - 490], :width => 300) do
    pdf.text "#{delivery.product.item_code} (#{i} of #{num_labels})"
  end

  pdf.start_new_page unless delivery_counter == count-1 && i == num_labels
end

