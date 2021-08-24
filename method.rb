def get_data_from_column_on_requisition_table(req_header1, req_description, req_header2)
    csv = CSV.parse(response.body, :headers => true)
    row = csv.find_all {|row| row[req_header1].include? req_description} 
    row.split("/n")
    line_count = row.count
    line_num = []
    line_count.times do |index|
      line_num << row[index-1][req_header2]
    end
    line_num
  end
