scenario 'CD-24058 - Accounts: Acccount validation with free form/C15753' do
    supplier = FactoryGirl.create(:supplier)
    login_as admin_user1.login
    home_page.load
    wait_for_ajax
    home_page.write_tab.click
    home_page.write.supplier.set supplier.name
    click_autocomplete_row
    home_page.write.description.set "free form item"
    home_page.write.price.set "100"
    home_page.write.add_to_cart_button.click
    edit_page.load(id: RequisitionHeader.last.id)
    edit_page.editable_req_lines[0].account_picker.click
    edit_page.account_popup.segment[0].click
    edit_page.segment_1_result2.click
    edit_page.account_popup.segment[1].click
    edit_page.segment_2_result1.click
    edit_page.account_popup.choose.click
    expect(edit_page.req_cart_line.account_code).to have_content "#{lv_usa.external_ref_num}-#{lv_california.external_ref_num}"
  end
