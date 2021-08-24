require 'spec_helper'

describe RequisitionHeadersController do
  include SharedHelper

  describe "Requisition Doc access based on Account group security" do
    let!(:red_lookup) { FactoryGirl.create(:lookup, name: 'Red', active: true) }
    let!(:red_lookup_values_details) { [{name: "Red 100", external_ref_num: '100'}, {name: "Red 200", external_ref_num: '200'}, {name: "Red 300", external_ref_num: '300'}, {name: "Red 400", external_ref_num: '400'}] }

    let!(:red_lookup_values) do
      red_lookup_values_details.each_index do |i|
        FactoryGirl.create(:lookup_value, name: red_lookup_values_details[i][:name],lookup_id: red_lookup.id, external_ref_num:red_lookup_values_details[i][:external_ref_num])
      end
    end

    let!(:blue_lookup) { FactoryGirl.create(:lookup, name: 'Blue', active: true) }
    let!(:blue_lookup_values_details) { [{name: "Blue 100", external_ref_num: '100'}, {name: "Blue 200", external_ref_num: '200'}, {name: "Blue 300", external_ref_num: '300'}, {name: "Blue 400", external_ref_num: '400'}] }

    let!(:blue_lookup_values) do
      blue_lookup_values_details.each_index do |i|
        FactoryGirl.create(:lookup_value, name: blue_lookup_values_details[i][:name],lookup_id: blue_lookup.id, external_ref_num:blue_lookup_values_details[i][:external_ref_num])
      end
    end

    let!(:field_type1) { FactoryGirl.create :account_field_type, name: 'Seg 1' }
    let!(:field_type2) { FactoryGirl.create :account_field_type, name: 'Seg 2' }
    let!(:field_type3) { FactoryGirl.create :account_field_type, name: 'Seg 3' }
    let!(:coa_a) { FactoryGirl.create(:account_type, name: "COA A", segment_1_field_type_id: field_type1.id, segment_1_lookup_id: red_lookup.id, segment_2_field_type_id: field_type2.id, segment_2_lookup_id: red_lookup.id, segment_3_field_type_id: field_type3.id, segment_3_lookup_id: red_lookup.id, dynamic_flag: true) }
    #account group without segment rules
    # let!(:ag1) { FactoryGirl.create(:account_group, account_type_id: coa_a.id, name: "AG1", created_by_id: 1, updated_by_id: 1) }
    #account group with segment rules
    let!(:ag2) { FactoryGirl.create(:account_group, account_type_id: coa_a.id, name: "AG2", created_by_id: 1, updated_by_id: 1, segment_1_col: "", segment_1_op: "", segment_1_val: "", segment_2_col: "", segment_2_op: "eq", segment_2_val: "100", segment_3_col: "", segment_3_op: "", segment_3_val: "") }
    let!(:coa_b) { FactoryGirl.create(:account_type, name: "COA B", segment_1_field_type_id: field_type1.id, segment_1_lookup_id: blue_lookup.id, segment_2_field_type_id: field_type2.id, segment_2_lookup_id: blue_lookup.id, segment_3_field_type_id: field_type3.id, segment_3_lookup_id: blue_lookup.id, dynamic_flag: true) }
    #account group without segment rules
    # let!(:ag3) { FactoryGirl.create(:account_group, account_type_id: coa_b.id, name: "AG3", created_by_id: 1, updated_by_id: 1) }
    #account group with segment rules
    let!(:ag4) { FactoryGirl.create(:account_group, account_type_id: coa_b.id, name: "AG4", created_by_id: 1, updated_by_id: 1, segment_1_col: "", segment_1_op: "", segment_1_val: "", segment_2_col: "", segment_2_op: "", segment_2_val: "", segment_3_col: "", segment_3_op: "eq", segment_3_val: "100") }

    let!(:complete_billing_satisfying_ag2) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[1][:name]}-#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[2][:name]}", account_type_id: coa_a.id, segment_1: red_lookup_values_details[1][:external_ref_num], segment_2: red_lookup_values_details[0][:external_ref_num], segment_3: red_lookup_values_details[2][:external_ref_num], code: "#{red_lookup_values_details[1][:external_ref_num]}-#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[2][:external_ref_num]}", active: true) }
    let!(:complete_billing_not_satisfying_ag2) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[2][:name]}-#{red_lookup_values_details[2][:name]}-#{red_lookup_values_details[2][:name]}", account_type_id: coa_a.id, segment_1: red_lookup_values_details[2][:external_ref_num], segment_2: red_lookup_values_details[2][:external_ref_num], segment_3: red_lookup_values_details[2][:external_ref_num], code: "#{red_lookup_values_details[2][:external_ref_num]}-#{red_lookup_values_details[2][:external_ref_num]}-#{red_lookup_values_details[2][:external_ref_num]}", active: true) }
    let!(:complete_billing_one_line_not_satisfying_ag2) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[2][:name]}-#{red_lookup_values_details[2][:name]}", account_type_id: coa_a.id, segment_1: red_lookup_values_details[0][:external_ref_num], segment_2: red_lookup_values_details[2][:external_ref_num], segment_3: red_lookup_values_details[2][:external_ref_num], code: "#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[2][:external_ref_num]}-#{red_lookup_values_details[2][:external_ref_num]}", active: true) }
    let!(:complete_billing_one_line_satisfying_ag2) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[2][:name]}", account_type_id: coa_a.id, segment_1: red_lookup_values_details[0][:external_ref_num], segment_2: red_lookup_values_details[0][:external_ref_num], segment_3: red_lookup_values_details[2][:external_ref_num], code: "#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[2][:external_ref_num]}", active: true) }
    let!(:partial_billing_account_satisfying_AG2) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[3][:name]}-#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[2][:name]}", account_type_id: coa_a.id, segment_1: red_lookup_values_details[3][:external_ref_num], segment_2: red_lookup_values_details[0][:external_ref_num], segment_3: red_lookup_values_details[2][:external_ref_num], code: "#{red_lookup_values_details[3][:external_ref_num]}-#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[2][:external_ref_num]}", active: true) }
    let!(:partial_billing_account_not_satisfying_AG2) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[3][:name]}-#{red_lookup_values_details[2][:name]}-#{red_lookup_values_details[2][:name]}", account_type_id: coa_a.id, segment_1: red_lookup_values_details[3][:external_ref_num], segment_2: red_lookup_values_details[2][:external_ref_num], segment_3: red_lookup_values_details[2][:external_ref_num], code: "#{red_lookup_values_details[3][:external_ref_num]}-#{red_lookup_values_details[2][:external_ref_num]}-#{red_lookup_values_details[2][:external_ref_num]}", active: true) }
    let!(:partial_blank_billing_satisfying_ag2) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[1][:name]}-#{red_lookup_values_details[0][:name]}", account_type_id: coa_a.id, segment_1: red_lookup_values_details[1][:external_ref_num], segment_2: red_lookup_values_details[0][:external_ref_num], segment_3: " ", code: "#{red_lookup_values_details[1][:external_ref_num]}-#{red_lookup_values_details[0][:external_ref_num]}", active: true) }
    let!(:partial_blank_billing_not_satisfying_ag2) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[2][:name]}-#{red_lookup_values_details[2][:name]}", account_type_id: coa_a.id, segment_1: red_lookup_values_details[2][:external_ref_num], segment_2: red_lookup_values_details[2][:external_ref_num], segment_3: " ", code: "#{red_lookup_values_details[2][:external_ref_num]}-#{red_lookup_values_details[2][:external_ref_num]}", active: true) }

    let!(:document_creator) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Admin", login: "Document Creator", business_group_security_type: 0, account_security_type: 0) }

    #List of Users restricted to AGs belongs to COA A:
    # let!(:india_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "India User", business_group_security_type: 0, account_security_type: 2, account_groups: [ag1]) }
    let!(:us_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "US User", business_group_security_type: 0, account_security_type: 2, account_groups: [ag2]) }
    # let!(:japan_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "Japan User", business_group_security_type: 0, account_security_type: 2, account_groups: [ag1,ag2]) }

    #List of Users restricted to AGs belongs to COA B:
    # let!(:china_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "China User", business_group_security_type: 0, account_security_type: 2, account_groups: [ag3]) }
    let!(:austria_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "Austria User", business_group_security_type: 0, account_security_type: 2, account_groups: [ag4]) }
    # let!(:poland_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "Poland User", business_group_security_type: 0, account_security_type: 2, account_groups: [ag3, ag4]) }

    #List of Users restricted to AGs belongs to both COA A and COA B:
    # let!(:greek_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "Greek User", business_group_security_type: 0, account_security_type: 2, account_groups: [ag1,ag3]) }
    let!(:taiwan_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "Taiwan User", business_group_security_type: 0, account_security_type: 2, account_groups: [ag2, ag4]) }
    # let!(:french_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "French User", business_group_security_type: 0, account_security_type: 2, account_groups: [ag1,ag4]) }
    # let!(:spanish_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "Spanish User", business_group_security_type: 0, account_security_type: 2, account_groups: [ag2,ag3]) }

    #Users restricted to default chart of account
    let!(:fiji_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "Fiji User", business_group_security_type: 0, account_security_type: 1, default_account_type_id: coa_a.id) }
    let!(:colombia_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "Colombia User", business_group_security_type: 0, account_security_type: 1, default_account_type_id: coa_b.id) }

    let!(:supplier) { FactoryGirl.create(:supplier, name: "Test Supplier") }

    # document creator creates 3 invoices(new/pending/approved) with complete billing with satisfying the account group AG2'
    #draft
    let!(:draft_req_header_satisfying_AG2) { FactoryGirl.create(:requisition_header, created_by: document_creator, requested_by_id: document_creator.id, status: "draft") }
    let!(:draft_req_line_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "draft_req_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: complete_billing_satisfying_ag2.id, unit_price: 101, quantity: 10, requisition_header: draft_req_header_satisfying_AG2) }
    #pending
    let!(:pending_req_header_satisfying_AG2) { FactoryGirl.create(:requisition_header,created_by: document_creator, requested_by_id: document_creator.id, status: "pending_approval") }
    let!(:pending_req_line_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "pending_req_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: complete_billing_satisfying_ag2.id, unit_price: 101, quantity: 10, requisition_header: pending_req_header_satisfying_AG2) }
    #Approved
    let!(:approved_req_header_satisfying_AG2) { FactoryGirl.create(:requisition_header,created_by: document_creator, requested_by_id: document_creator.id, status: "approved") }
    let!(:approved_req_line_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "Approved_req_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: complete_billing_satisfying_ag2.id, unit_price: 101, quantity: 10, requisition_header: approved_req_header_satisfying_AG2) }

    # document creator creates 3 invoices(new/pending/approved) with complete billing without satisfying the account group AG2'
    #draft
    let!(:draft_req_header_not_satisfying_AG2) { FactoryGirl.create(:requisition_header, created_by: document_creator, requested_by_id: document_creator.id, status: "draft") }
    let!(:draft_req_line_not_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "draft_req_header_not_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: complete_billing_not_satisfying_ag2.id, unit_price: 101, quantity: 10, requisition_header: draft_req_header_not_satisfying_AG2) }
    #pending
    let!(:pending_req_header_not_satisfying_AG2) { FactoryGirl.create(:requisition_header,created_by: document_creator, requested_by_id: document_creator.id, status: "pending_approval") }
    let!(:pending_req_line_not_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "pending_req_header_not_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: complete_billing_not_satisfying_ag2.id, unit_price: 101, quantity: 10, requisition_header: pending_req_header_not_satisfying_AG2) }
    #Approved
    let!(:approved_req_header_not_satisfying_AG2) { FactoryGirl.create(:requisition_header,created_by: document_creator, requested_by_id: document_creator.id, status: "approved") }
    let!(:approved_req_line_not_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "Approved_req_header_not_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: complete_billing_not_satisfying_ag2.id, unit_price: 101, quantity: 10, requisition_header: approved_req_header_not_satisfying_AG2) }

    # document creator creates 3 Invoice doc(with complete billing where one line satisfies AG2 and the other line does not satisfies the AG2
    #draft
    let!(:draft_req_header_one_line_not_satisfying_AG2) { FactoryGirl.create(:requisition_header, created_by: document_creator, requested_by_id: document_creator.id, status: "draft") }
    let!(:draft_req_line1_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "draft_req_line1_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: complete_billing_one_line_satisfying_ag2.id, unit_price: 101, quantity: 10, requisition_header: draft_req_header_one_line_not_satisfying_AG2) }
    let!(:draft_req_line2_not_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "draft_req_line2_not_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: complete_billing_one_line_not_satisfying_ag2.id, unit_price: 101, quantity: 10, requisition_header: draft_req_header_one_line_not_satisfying_AG2) }
    #pending
    let!(:pending_req_header_one_line_not_satisfying_AG2) { FactoryGirl.create(:requisition_header, created_by: document_creator, requested_by_id: document_creator.id, status: "pending_approval") }
    let!(:pending_req_line1_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "pending_req_line1_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: complete_billing_one_line_satisfying_ag2.id, unit_price: 101, quantity: 10, requisition_header: pending_req_header_one_line_not_satisfying_AG2) }
    let!(:pending_req_line2_not_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "pending_req_line2_not_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: complete_billing_one_line_not_satisfying_ag2.id, unit_price: 101, quantity: 10, requisition_header: pending_req_header_one_line_not_satisfying_AG2) }
    # #Approved
    let!(:approved_req_header_one_line_not_satisfying_AG2) { FactoryGirl.create(:requisition_header, created_by: document_creator, requested_by_id: document_creator.id, status: "approved") }
    let!(:approved_req_line1_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "approved_req_line1_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: complete_billing_one_line_satisfying_ag2.id, unit_price: 101, quantity: 10, requisition_header: approved_req_header_one_line_not_satisfying_AG2) }
    let!(:approved_req_line2_not_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "approved_req_line2_not_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: complete_billing_one_line_not_satisfying_ag2.id, unit_price: 101, quantity: 10, requisition_header: approved_req_header_one_line_not_satisfying_AG2) }

    # document creator creates 3 Invoice doc(with complete split billing) satisfies AG2
    #draft/new
    let!(:draft_req_header_split_billing_satisfying_AG2) { FactoryGirl.create(:requisition_header, created_by: document_creator, requested_by_id: document_creator.id, status: "draft") }
    let!(:draft_req_line1_split_billing_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "draft_req_header_split_bill_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: complete_billing_satisfying_ag2.id, unit_price: 101, quantity: 10, requisition_header: draft_req_header_split_billing_satisfying_AG2) }
    let!(:draft_req_allocations1) do
      FactoryGirl.create(:req_line_allocation, requisition_header: draft_req_header_split_billing_satisfying_AG2, requisition_line: draft_req_line1_split_billing_satisfying_AG2, pct: 50, account: complete_billing_satisfying_ag2)
      FactoryGirl.create(:req_line_allocation, requisition_header: draft_req_header_split_billing_satisfying_AG2, requisition_line: draft_req_line1_split_billing_satisfying_AG2, pct: 50, account: complete_billing_one_line_satisfying_ag2)
      draft_req_header_split_billing_satisfying_AG2.reload
    end
    #pending
    let!(:pend_req_header_split_billing_satisfying_AG2) { FactoryGirl.create(:requisition_header, created_by: document_creator, requested_by_id: document_creator.id, status: "pending_approval") }
    let!(:pend_req_line1_split_billing_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "pend_req_header_split_bill_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: complete_billing_satisfying_ag2.id, unit_price: 101, quantity: 10, requisition_header: pend_req_header_split_billing_satisfying_AG2) }
    let!(:pend_req_allocations1) do
      FactoryGirl.create(:req_line_allocation, requisition_header: pend_req_header_split_billing_satisfying_AG2, requisition_line: pend_req_line1_split_billing_satisfying_AG2, pct: 50, account: complete_billing_satisfying_ag2)
      FactoryGirl.create(:req_line_allocation, requisition_header: pend_req_header_split_billing_satisfying_AG2, requisition_line: pend_req_line1_split_billing_satisfying_AG2, pct: 50, account: complete_billing_one_line_satisfying_ag2)
      pend_req_header_split_billing_satisfying_AG2.reload
    end
    #Approved
    let!(:app_req_header_split_billing_satisfying_AG2) { FactoryGirl.create(:requisition_header, created_by: document_creator, requested_by_id: document_creator.id, status: "approved") }
    let!(:app_req_line1_split_billing_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "app_req_header_split_bill_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: complete_billing_satisfying_ag2.id, unit_price: 101, quantity: 10, requisition_header: app_req_header_split_billing_satisfying_AG2) }
    let!(:app_req_allocations1) do
      FactoryGirl.create(:req_line_allocation, requisition_header: app_req_header_split_billing_satisfying_AG2, requisition_line: app_req_line1_split_billing_satisfying_AG2, pct: 50, account: complete_billing_satisfying_ag2)
      FactoryGirl.create(:req_line_allocation, requisition_header: app_req_header_split_billing_satisfying_AG2, requisition_line: app_req_line1_split_billing_satisfying_AG2, pct: 50, account: complete_billing_one_line_satisfying_ag2)
      app_req_header_split_billing_satisfying_AG2.reload
    end

    # document creator creates 3 Invoice doc(with complete split billing) not satisfies AG2
    #draft/new
    let!(:draft_req_header_split_billing_not_satisfying_AG2) { FactoryGirl.create(:requisition_header, created_by: document_creator, requested_by_id: document_creator.id, status: "draft") }
    let!(:draft_req_line1_split_billing_not_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "draft_req_header_split_bill_not_satisfying_AG2", allocation_count: 2, uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, unit_price: 101, quantity: 10, requisition_header: draft_req_header_split_billing_not_satisfying_AG2) }
    let!(:draft_req_allocations2) do
      FactoryGirl.create(:req_line_allocation, requisition_header: draft_req_header_split_billing_not_satisfying_AG2, requisition_line: draft_req_line1_split_billing_not_satisfying_AG2, pct: 50, account: complete_billing_not_satisfying_ag2)
      FactoryGirl.create(:req_line_allocation, requisition_header: draft_req_header_split_billing_not_satisfying_AG2, requisition_line: draft_req_line1_split_billing_not_satisfying_AG2, pct: 50, account: complete_billing_one_line_not_satisfying_ag2)
      draft_req_header_split_billing_not_satisfying_AG2.reload
    end
    #pending
    let!(:pend_req_header_split_billing_not_satisfying_AG2) { FactoryGirl.create(:requisition_header, created_by: document_creator, requested_by_id: document_creator.id, status: "pending_approval") }
    let!(:pend_req_line1_split_billing_not_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "pend_req_header_split_bill_not_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, allocation_count: 2, unit_price: 101, quantity: 10, requisition_header:pend_req_header_split_billing_not_satisfying_AG2) }
    let!(:pend_req_allocations2) do
      FactoryGirl.create(:req_line_allocation, requisition_header: pend_req_header_split_billing_not_satisfying_AG2, requisition_line: pend_req_line1_split_billing_not_satisfying_AG2, pct: 50, account: complete_billing_not_satisfying_ag2)
      FactoryGirl.create(:req_line_allocation, requisition_header: pend_req_header_split_billing_not_satisfying_AG2, requisition_line: pend_req_line1_split_billing_not_satisfying_AG2, pct: 50, account: complete_billing_one_line_not_satisfying_ag2)
      pend_req_header_split_billing_not_satisfying_AG2.reload
    end
    #Approved
    let!(:app_req_header_split_billing_not_satisfying_AG2) { FactoryGirl.create(:requisition_header, created_by: document_creator, requested_by_id: document_creator.id, status: "draft") }
    let!(:app_req_line1_split_billing_not_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "app_req_header_split_bill_not_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, allocation_count:2, unit_price: 101, quantity: 10, requisition_header: app_req_header_split_billing_not_satisfying_AG2) }
    let!(:app_req_allocations2) do
      FactoryGirl.create(:req_line_allocation, requisition_header: app_req_header_split_billing_not_satisfying_AG2, requisition_line: app_req_line1_split_billing_not_satisfying_AG2, pct: 50, account: complete_billing_not_satisfying_ag2)
      FactoryGirl.create(:req_line_allocation, requisition_header: app_req_header_split_billing_not_satisfying_AG2, requisition_line: app_req_line1_split_billing_not_satisfying_AG2, pct: 50, account: complete_billing_one_line_not_satisfying_ag2)
      app_req_header_split_billing_not_satisfying_AG2.reload
    end

    # document creator creates 3 invoices(new/pending/approved) with partial(by inactivating the lookup value) billing with satisfying the account group AG2'
    #draft
    let!(:draft_partial_req_header_satisfying_AG2) { FactoryGirl.create(:requisition_header, created_by: document_creator, requested_by_id: document_creator.id, status: "draft") }
    let!(:draft_partial_req_line_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "draft_partial_req_header_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: partial_billing_account_satisfying_AG2.id, unit_price: 101, quantity: 10, requisition_header: draft_partial_req_header_satisfying_AG2) }
    #pending
    let!(:pending_partial_req_header_satisfying_AG2) { FactoryGirl.create(:requisition_header,created_by: document_creator, requested_by_id: document_creator.id, status: "pending_approval") }
    let!(:pending_partial_req_line_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "pending_partial_req_header_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: partial_billing_account_satisfying_AG2.id, unit_price: 101, quantity: 10, requisition_header: pending_partial_req_header_satisfying_AG2) }
    #Approved
    let!(:approved_partial_req_header_satisfying_AG2) { FactoryGirl.create(:requisition_header,created_by: document_creator, requested_by_id: document_creator.id, status: "approved") }
    let!(:approved_partial_req_line_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "approved_partial_req_header_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: partial_billing_account_satisfying_AG2.id, unit_price: 101, quantity: 10, requisition_header: approved_partial_req_header_satisfying_AG2) }
  
    # document creator creates 3 invoices(new/pending/approved) with partial(by inactivating the lookup value) billing without satisfying the account group AG2'
    #draft
    let!(:draft_partial_req_header_not_satisfying_AG2) { FactoryGirl.create(:requisition_header, created_by: document_creator, requested_by_id: document_creator.id, status: "draft") }
    let!(:draft_partial_req_line_not_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "draft_partial_req_header_not_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: partial_billing_account_not_satisfying_AG2.id, unit_price: 101, quantity: 10, requisition_header: draft_partial_req_header_not_satisfying_AG2) }
    #pending
    let!(:pending_partial_req_header_not_satisfying_AG2) { FactoryGirl.create(:requisition_header,created_by: document_creator, requested_by_id: document_creator.id, status: "pending_approval") }
    let!(:pending_partial_req_line_not_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "pend_partial_req_header_not_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: partial_billing_account_not_satisfying_AG2.id, unit_price: 101, quantity: 10, requisition_header: pending_partial_req_header_not_satisfying_AG2) }
    #Approved
    let!(:approved_partial_req_header_not_satisfying_AG2) { FactoryGirl.create(:requisition_header,created_by: document_creator, requested_by_id: document_creator.id, status: "approved") }
    let!(:approved_partial_req_line_not_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "app_partial_req_header_not_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: partial_billing_account_not_satisfying_AG2.id, unit_price: 101, quantity: 10, requisition_header: approved_partial_req_header_not_satisfying_AG2) }

    # document creator creates 3 invoices(new/pending/approved) with partial(by left one segment as blank) billing with satisfying the account group AG2'
    #draft
    let!(:draft_partial_blank_req_header_satisfying_AG2) { FactoryGirl.create(:requisition_header, created_by: document_creator, requested_by_id: document_creator.id, status: "draft") }
    let!(:draft_partial_blank_req_line_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "draft_partl_blk_req_header_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: partial_blank_billing_satisfying_ag2.id, unit_price: 101, quantity: 10, requisition_header: draft_partial_blank_req_header_satisfying_AG2) }
    #pending
    let!(:pending_partial_blank_req_header_satisfying_AG2) { FactoryGirl.create(:requisition_header,created_by: document_creator, requested_by_id: document_creator.id, status: "pending_approval") }
    let!(:pending_partial_blank_req_line_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "pend_partl_blk_req_header_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: partial_blank_billing_satisfying_ag2.id, unit_price: 101, quantity: 10, requisition_header: pending_partial_blank_req_header_satisfying_AG2) }
    #Approved
    let!(:approved_partial_blank_req_header_satisfying_AG2) { FactoryGirl.create(:requisition_header,created_by: document_creator, requested_by_id: document_creator.id, status: "approved") }
    let!(:approved_partial_blank_req_line_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "app_partl_blk_req_header_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: partial_blank_billing_satisfying_ag2.id, unit_price: 101, quantity: 10, requisition_header: approved_partial_blank_req_header_satisfying_AG2) }

    # document creator creates 3 invoices(new/pending/approved) with partial(by left one segment as blank) billing without satisfying the account group AG2'
    #draft
    let!(:draft_partial_blank_req_header_not_satisfying_AG2) { FactoryGirl.create(:requisition_header, created_by: document_creator, requested_by_id: document_creator.id, status: "draft") }
    let!(:draft_partial_blank_req_line_not_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "drt_prtl_blk_req_header_not_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: partial_blank_billing_not_satisfying_ag2.id, unit_price: 101, quantity: 10, requisition_header:draft_partial_blank_req_header_not_satisfying_AG2) }
    #pending
    let!(:pending_partial_blank_req_header_not_satisfying_AG2) { FactoryGirl.create(:requisition_header,created_by: document_creator, requested_by_id: document_creator.id, status: "pending_approval") }
    let!(:pending_partial_blank_req_line_not_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "pend_prtl_blk_req_header_not_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: partial_blank_billing_not_satisfying_ag2.id, unit_price: 101, quantity: 10, requisition_header: pending_partial_blank_req_header_not_satisfying_AG2) }
    #Approved
    let!(:approved_partial_blank_req_header_not_satisfying_AG2) { FactoryGirl.create(:requisition_header,created_by: document_creator, requested_by_id: document_creator.id, status: "approved") }
    let!(:approved_partial_blank_req_line_not_satisfying_AG2) { FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "app_prtl_blk_req_header_not_satisfying_AG2", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, account_id: partial_blank_billing_not_satisfying_ag2.id, unit_price: 101, quantity: 10, requisition_header: approved_partial_blank_req_header_not_satisfying_AG2) }

    # document creator creates an invoice with incomplete billing
    let!(:draft_incomplete_billing_req_header) { FactoryGirl.create(:requisition_header, created_by: document_creator, requested_by_id: document_creator.id, status: "draft") }
    let!(:draft_incomplete_billing_req_line) do
      line = FactoryGirl.create(:requisition_quantity_line, supplier: supplier.name, description: "draft_incomplete_billing_req_header", uom_id: Uom.where(code: 'EA').first.id, account_type: coa_a, unit_price: 101, quantity: 10, requisition_header: draft_incomplete_billing_req_header)
      line.account_type=nil
      line.save(validate:false)
      line.account=nil
      line.save(validate:false)
      draft_incomplete_billing_req_header.reload
    end

    let!(:view) do
      FactoryGirl.create(
        :data_table_view,
        data_table_id: "RequisitionHeadersController:requisition_header",
        name: "all view3",
        public: true,
        table_columns: ["id", "requested_by", "submitted_at", "status", "items", "total", "actions"],
        options:
        {
          :cond_op=>"all",
          :group_op=>"any",
          :sort_dir=>"ASC"
        },
        created_by_id: document_creator.id,
        updated_by_id: document_creator.id,
        based_on_filter: 0,
        editable: true
      )
    end

    context 'CD-251620: Document access based on Account group security' do
      context 'us user restricted the AG2 with segment rules and belongs to COA A' do
        before do
          allow(User).to receive(:current_user).and_return(us_user)
          lookup_value = LookupValue.find_by(name: red_lookup_values_details[3][:name])
          lookup_value.update(active: false)
          get :index, params: { filter: "-#{view.id}" }
          get :requisition_header_list_csv
        end
        it 'Requistiion doc(with complete/incomplete/partial billing) access based on account group restriction for the users Us User' do
          # Requisition (new/pending/approved) with complete billing with satisfying the account group AG2
          expect(get_data_from_column_on_requisition_table("Items", draft_req_line_satisfying_AG2.description, "Req #")).to include draft_req_header_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pending_req_line_satisfying_AG2.description, "Req #")).to include pending_req_header_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", approved_req_line_satisfying_AG2.description, "Req #")).to include approved_req_header_satisfying_AG2.id
          # Requisition doc(with complete billing where one line satisfies AG2 and the other line does not satisfies the AG2
          expect(get_data_from_column_on_requisition_table("Items", draft_req_line1_satisfying_AG2.description, "Req #")).to include draft_req_header_one_line_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", draft_req_line2_not_satisfying_AG2.description, "Req #")).to have_content draft_req_header_one_line_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pending_req_line1_satisfying_AG2.description, "Req #")).to have_content pending_req_header_one_line_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pending_req_line2_not_satisfying_AG2.description, "Req #")).to have_content pending_req_header_one_line_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", approved_req_line1_satisfying_AG2.description, "Req #")).to have_content approved_req_header_one_line_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", approved_req_line2_not_satisfying_AG2.description, "Req #")).to have_content approved_req_header_one_line_not_satisfying_AG2.id
          # Requisition (new/pending/approved) with complete billing without satisfying the account group AG2
          expect(get_data_from_column_on_requisition_table("Items", draft_req_line_not_satisfying_AG2.description, "Req #")).to have_no_content draft_req_header_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pending_req_line_not_satisfying_AG2.description, "Req #")).to have_no_content pending_req_header_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", approved_req_line_not_satisfying_AG2.description, "Req #")).to have_no_content approved_req_header_not_satisfying_AG2.id
          # Requisition doc(with complete split billing) satisfies AG2
          expect(get_data_from_column_on_requisition_table("Items", draft_req_line1_split_billing_satisfying_AG2.description, "Req #")).to have_content draft_req_header_split_billing_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pend_req_line1_split_billing_satisfying_AG2.description, "Req #")).to have_content pend_req_header_split_billing_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", app_req_line1_split_billing_satisfying_AG2.description, "Req #")).to have_content app_req_header_split_billing_satisfying_AG2.id         
          # Requisition doc(with complete split billing) not satisfies AG2
          expect(get_data_from_column_on_requisition_table("Items", draft_req_line1_split_billing_not_satisfying_AG2.description, "Req #")).to have_no_content draft_req_header_split_billing_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pend_req_line1_split_billing_not_satisfying_AG2.description, "Req #")).to have_no_content pend_req_header_split_billing_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", app_req_line1_split_billing_not_satisfying_AG2.description, "Req #")).to have_no_content app_req_header_split_billing_not_satisfying_AG2.id
          # Requisition (new/pending/approved) with partial(by left one segment as blank) billing with satisfying the account group AG2
          expect(get_data_from_column_on_requisition_table("Items", draft_partial_blank_req_line_satisfying_AG2.description, "Req #")).to have_content draft_partial_blank_req_header_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pending_partial_blank_req_line_satisfying_AG2.description, "Req #")).to have_content pending_partial_blank_req_header_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", approved_partial_blank_req_line_satisfying_AG2.description, "Req #")).to have_content approved_partial_blank_req_header_satisfying_AG2.id
          # Requisition (new/pending/approved) with partial(by left one segment as blank) billing without satisfying the account group AG2'
          expect(get_data_from_column_on_requisition_table("Items", draft_partial_blank_req_line_not_satisfying_AG2.description, "Req #")).to have_no_content draft_partial_blank_req_header_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pending_partial_blank_req_line_not_satisfying_AG2.description, "Req #")).to have_no_content pending_partial_blank_req_header_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", approved_partial_blank_req_line_not_satisfying_AG2.description, "Req #")).to have_no_content approved_partial_blank_req_header_not_satisfying_AG2.id   
          # Requisition (new/pending/approved) with partial(by inactivating the lookup value) billing with satisfying the account group AG2'
          expect(get_data_from_column_on_requisition_table("Items", draft_partial_req_line_satisfying_AG2.description, "Req #")).to have_content draft_partial_req_header_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pending_partial_req_line_satisfying_AG2.description, "Req #")).to have_content pending_partial_req_header_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", approved_partial_req_line_satisfying_AG2.description, "Req #")).to have_content approved_partial_req_header_satisfying_AG2.id  
          # Requisition (new/pending/approved) with partial(by inactivating the lookup value) billing without satisfying the account group AG2
          expect(get_data_from_column_on_requisition_table("Items", draft_partial_req_line_not_satisfying_AG2.description, "Req #")).to have_no_content draft_partial_req_header_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pending_partial_req_line_not_satisfying_AG2.description, "Req #")).to have_no_content pending_partial_req_header_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", approved_partial_req_line_not_satisfying_AG2.description, "Req #")).to have_no_content approved_partial_req_header_not_satisfying_AG2.id
          # Requisition with incomplete billing
          expect(get_data_from_column_on_requisition_table("Items", draft_incomplete_billing_req_header.requisition_lines.last.description, "Req #")).to have_content draft_incomplete_billing_req_header.id
        end
      end

      context 'Taiwan user restricted the both AG2 and AG4 with segment rules where AG2 for COA A and AG4 for COA B' do
        before do
          allow(User).to receive(:current_user).and_return(taiwan_user)
          lookup_value = LookupValue.find_by(name: red_lookup_values_details[3][:name])
          lookup_value.update(active: false)
          get :index, params: { filter: "-#{view.id}" }
          get :requisition_header_list_csv
        end
        it 'Requisition doc(with complete/incomplete/partial billing) access based on account group restriction for the Taiwan User' do
          # Requisition (new/pending/approved) with complete billing with satisfying the account group AG2
          expect(get_data_from_column_on_requisition_table("Items", draft_req_line_satisfying_AG2.description, "Req #")).to have_content draft_req_header_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pending_req_line_satisfying_AG2.description, "Req #")).to have_content pending_req_header_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", approved_req_line_satisfying_AG2.description, "Req #")).to have_content approved_req_header_satisfying_AG2.id
          # Requisition doc(with complete billing where one line satisfies AG2 and the other line does not satisfies the AG2
          expect(get_data_from_column_on_requisition_table("Items", draft_req_line1_satisfying_AG2.description, "Req #")).to have_content draft_req_header_one_line_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", draft_req_line2_not_satisfying_AG2.description, "Req #")).to have_content draft_req_header_one_line_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pending_req_line1_satisfying_AG2.description, "Req #")).to have_content pending_req_header_one_line_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pending_req_line2_not_satisfying_AG2.description, "Req #")).to have_content pending_req_header_one_line_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", approved_req_line1_satisfying_AG2.description, "Req #")).to have_content approved_req_header_one_line_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", approved_req_line2_not_satisfying_AG2.description, "Req #")).to have_content approved_req_header_one_line_not_satisfying_AG2.id
          # Requisition (new/pending/approved) with complete billing without satisfying the account group AG2
          expect(get_data_from_column_on_requisition_table("Items", draft_req_line_not_satisfying_AG2.description, "Req #")).to have_no_content draft_req_header_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pending_req_line_not_satisfying_AG2.description, "Req #")).to have_no_content pending_req_header_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", approved_req_line_not_satisfying_AG2.description, "Req #")).to have_no_content approved_req_header_not_satisfying_AG2.id
          # Requisition doc(with complete split billing) satisfies AG2
          expect(get_data_from_column_on_requisition_table("Items", draft_req_line1_split_billing_satisfying_AG2.description, "Req #")).to have_content draft_req_header_split_billing_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pend_req_line1_split_billing_satisfying_AG2.description, "Req #")).to have_content pend_req_header_split_billing_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", app_req_line1_split_billing_satisfying_AG2.description, "Req #")).to have_content app_req_header_split_billing_satisfying_AG2.id         
          # Requisition doc(with complete split billing) not satisfies AG2
          expect(get_data_from_column_on_requisition_table("Items", draft_req_line1_split_billing_not_satisfying_AG2.description, "Req #")).to have_no_content draft_req_header_split_billing_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pend_req_line1_split_billing_not_satisfying_AG2.description, "Req #")).to have_no_content pend_req_header_split_billing_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", app_req_line1_split_billing_not_satisfying_AG2.description, "Req #")).to have_no_content app_req_header_split_billing_not_satisfying_AG2.id
          # Requisition (new/pending/approved) with partial(by left one segment as blank) billing with satisfying the account group AG2
          expect(get_data_from_column_on_requisition_table("Items", draft_partial_blank_req_line_satisfying_AG2.description, "Req #")).to have_content draft_partial_blank_req_header_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pending_partial_blank_req_line_satisfying_AG2.description, "Req #")).to have_content pending_partial_blank_req_header_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", approved_partial_blank_req_line_satisfying_AG2.description, "Req #")).to have_content approved_partial_blank_req_header_satisfying_AG2.id
          # Requisition (new/pending/approved) with partial(by left one segment as blank) billing without satisfying the account group AG2'
          expect(get_data_from_column_on_requisition_table("Items", draft_partial_blank_req_line_not_satisfying_AG2.description, "Req #")).to have_no_content draft_partial_blank_req_header_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pending_partial_blank_req_line_not_satisfying_AG2.description, "Req #")).to have_no_content pending_partial_blank_req_header_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", approved_partial_blank_req_line_not_satisfying_AG2.description, "Req #")).to have_no_content approved_partial_blank_req_header_not_satisfying_AG2.id   
          # Requisition (new/pending/approved) with partial(by inactivating the lookup value) billing with satisfying the account group AG2'
          expect(get_data_from_column_on_requisition_table("Items", draft_partial_req_line_satisfying_AG2.description, "Req #")).to have_content draft_partial_req_header_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pending_partial_req_line_satisfying_AG2.description, "Req #")).to have_content pending_partial_req_header_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", approved_partial_req_line_satisfying_AG2.description, "Req #")).to have_content approved_partial_req_header_satisfying_AG2.id  
          # Requisition (new/pending/approved) with partial(by inactivating the lookup value) billing without satisfying the account group AG2
          expect(get_data_from_column_on_requisition_table("Items", draft_partial_req_line_not_satisfying_AG2.description, "Req #")).to have_no_content draft_partial_req_header_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pending_partial_req_line_not_satisfying_AG2.description, "Req #")).to have_no_content pending_partial_req_header_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", approved_partial_req_line_not_satisfying_AG2.description, "Req #")).to have_no_content approved_partial_req_header_not_satisfying_AG2.id
          # Requisition with incomplete billing
          expect(get_data_from_column_on_requisition_table("Items", draft_incomplete_billing_req_header.requisition_lines.last.description, "Req #")).to have_content draft_incomplete_billing_req_header.id
        end
      end
      context 'Austria User restricted the AG4 with segment rules and belongs to COA B' do
        before do
          allow(User).to receive(:current_user).and_return(austria_user)
          lookup_value = LookupValue.find_by(name: red_lookup_values_details[3][:name])
          lookup_value.update(active: false)
          get :index, params: { filter: "-#{view.id}" }
          get :requisition_header_list_csv
        end
        it 'Requisition doc(with complete/incomplete/partial billing) access based on account group restriction for the Austria User' do
          # Lines table should contain only 3 rows one is Requisition header,  other is incomplete billing line requisition line and the last is default draft cart row.
          # Here the user restricted to AG with segment rules belongs to another chart of account can see the incomplete billing line of another COA.
          # This issue will be fixed after the R32 AG security implementation.
          expect(response.body.count("\n")).to eq 3
          # Requisition with incomplete billing
          expect(get_data_from_column_on_requisition_table("Items", draft_incomplete_billing_req_header.requisition_lines.last.description, "Req #")).to have_content draft_incomplete_billing_req_header.id
        end
      end
      context 'Fiji User restricted to default chart of account(COA A) restriction' do
        before do
          allow(User).to receive(:current_user).and_return(fiji_user)
          lookup_value = LookupValue.find_by(name: red_lookup_values_details[3][:name])
          lookup_value.update(active: false)
          get :index, params: { filter: "-#{view.id}" }
          get :requisition_header_list_csv
        end
        it 'Requisition doc(with complete/incomplete/partial billing) access based on account group restriction for the Fiji User' do
          # Requisition (new/pending/approved) with complete billing with satisfying the account group AG2
          expect(get_data_from_column_on_requisition_table("Items", draft_req_line_satisfying_AG2.description, "Req #")).to have_content draft_req_header_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pending_req_line_satisfying_AG2.description, "Req #")).to have_content pending_req_header_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", approved_req_line_satisfying_AG2.description, "Req #")).to have_content approved_req_header_satisfying_AG2.id
          # Requisition doc(with complete billing where one line satisfies AG2 and the other line does not satisfies the AG2
          expect(get_data_from_column_on_requisition_table("Items", draft_req_line1_satisfying_AG2.description, "Req #")).to have_content draft_req_header_one_line_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", draft_req_line2_not_satisfying_AG2.description, "Req #")).to have_content draft_req_header_one_line_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pending_req_line1_satisfying_AG2.description, "Req #")).to have_content pending_req_header_one_line_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pending_req_line2_not_satisfying_AG2.description, "Req #")).to have_content pending_req_header_one_line_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", approved_req_line1_satisfying_AG2.description, "Req #")).to have_content approved_req_header_one_line_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", approved_req_line2_not_satisfying_AG2.description, "Req #")).to have_content approved_req_header_one_line_not_satisfying_AG2.id
          # Requisition (new/pending/approved) with complete billing without satisfying the account group AG2
          expect(get_data_from_column_on_requisition_table("Items", draft_req_line_not_satisfying_AG2.description, "Req #")).to have_content draft_req_header_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pending_req_line_not_satisfying_AG2.description, "Req #")).to have_content pending_req_header_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", approved_req_line_not_satisfying_AG2.description, "Req #")).to have_content approved_req_header_not_satisfying_AG2.id
          # Requisition doc(with complete split billing) satisfies AG2
          expect(get_data_from_column_on_requisition_table("Items", draft_req_line1_split_billing_satisfying_AG2.description, "Req #")).to have_content draft_req_header_split_billing_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pend_req_line1_split_billing_satisfying_AG2.description, "Req #")).to have_content pend_req_header_split_billing_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", app_req_line1_split_billing_satisfying_AG2.description, "Req #")).to have_content app_req_header_split_billing_satisfying_AG2.id         
          # Requisition doc(with complete split billing) not satisfies AG2
          expect(get_data_from_column_on_requisition_table("Items", draft_req_line1_split_billing_not_satisfying_AG2.description, "Req #")).to have_content draft_req_header_split_billing_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pend_req_line1_split_billing_not_satisfying_AG2.description, "Req #")).to have_content pend_req_header_split_billing_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", app_req_line1_split_billing_not_satisfying_AG2.description, "Req #")).to have_content app_req_header_split_billing_not_satisfying_AG2.id
          # Requisition (new/pending/approved) with partial(by left one segment as blank) billing with satisfying the account group AG2
          expect(get_data_from_column_on_requisition_table("Items", draft_partial_blank_req_line_satisfying_AG2.description, "Req #")).to have_content draft_partial_blank_req_header_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pending_partial_blank_req_line_satisfying_AG2.description, "Req #")).to have_content pending_partial_blank_req_header_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", approved_partial_blank_req_line_satisfying_AG2.description, "Req #")).to have_content approved_partial_blank_req_header_satisfying_AG2.id
          # Requisition (new/pending/approved) with partial(by left one segment as blank) billing without satisfying the account group AG2'
          expect(get_data_from_column_on_requisition_table("Items", draft_partial_blank_req_line_not_satisfying_AG2.description, "Req #")).to have_content draft_partial_blank_req_header_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pending_partial_blank_req_line_not_satisfying_AG2.description, "Req #")).to have_content pending_partial_blank_req_header_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", approved_partial_blank_req_line_not_satisfying_AG2.description, "Req #")).to have_content approved_partial_blank_req_header_not_satisfying_AG2.id   
          # Requisition (new/pending/approved) with partial(by inactivating the lookup value) billing with satisfying the account group AG2'
          expect(get_data_from_column_on_requisition_table("Items", draft_partial_req_line_satisfying_AG2.description, "Req #")).to have_content draft_partial_req_header_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pending_partial_req_line_satisfying_AG2.description, "Req #")).to have_content pending_partial_req_header_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", approved_partial_req_line_satisfying_AG2.description, "Req #")).to have_content approved_partial_req_header_satisfying_AG2.id  
          # Requisition (new/pending/approved) with partial(by inactivating the lookup value) billing without satisfying the account group AG2
          expect(get_data_from_column_on_requisition_table("Items", draft_partial_req_line_not_satisfying_AG2.description, "Req #")).to have_content draft_partial_req_header_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", pending_partial_req_line_not_satisfying_AG2.description, "Req #")).to have_content pending_partial_req_header_not_satisfying_AG2.id
          expect(get_data_from_column_on_requisition_table("Items", approved_partial_req_line_not_satisfying_AG2.description, "Req #")).to have_content approved_partial_req_header_not_satisfying_AG2.id
          # Requisition with incomplete billing
          expect(get_data_from_column_on_requisition_table("Items", draft_incomplete_billing_req_header.requisition_lines.last.description, "Req #")).to have_content draft_incomplete_billing_req_header.id
        end
      end
      context 'Colombia User restricted to default chart of account(COA B) restriction' do
        before do
          allow(User).to receive(:current_user).and_return(colombia_user)
          lookup_value = LookupValue.find_by(name: red_lookup_values_details[3][:name])
          lookup_value.update(active: false)
          get :index, params: { filter: "-#{view.id}" }
          get :requisition_header_list_csv
        end
        it 'Requisition doc(with complete/incomplete/partial billing) access based on account group restriction for the Colombia User' do
           # Lines table should contain only 3 rows one is Requisition header,other is incomplete billing line requisition line and the last is default draft cart row.
          expect(response.body.count("\n")).to eq 3
          expect(get_data_from_column_on_requisition_table("Items", draft_incomplete_billing_req_header.requisition_lines.last.description, "Req #")).to have_content draft_incomplete_billing_req_header.id
        end
      end
    end
  end
end


