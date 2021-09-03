require 'spec_helper'

describe InvoiceLinesController do
  include SharedHelper

  describe "Invoice Doc access based on Account group security" do
    let!(:red_lookup) { FactoryGirl.create(:lookup, name: 'Red', active: true) }
    let!(:red_lookup_values_details) { [{name: "Red 100", external_ref_num: '100'}, {name: "Red 200", external_ref_num: '200'}, {name: "Red 300", external_ref_num: '300'}, {name: "Red 400", external_ref_num: '400'}] }

    let!(:red_lookup_values) do
      red_lookup_values_details.each do |red_lookup_values_detail|
        FactoryGirl.create(:lookup_value, name: red_lookup_values_detail[:name],lookup_id: red_lookup.id, external_ref_num:red_lookup_values_detail[:external_ref_num])
      end
    end

    let!(:blue_lookup) { FactoryGirl.create(:lookup, name: 'Blue', active: true) }
    let!(:blue_lookup_values_details) { [{name: "Blue 100", external_ref_num: '100'}, {name: "Blue 200", external_ref_num: '200'}, {name: "Blue 300", external_ref_num: '300'}, {name: "Blue 400", external_ref_num: '400'}] }

    let!(:blue_lookup_values) do
      blue_lookup_values_details.each do |blue_lookup_values_detail|
        FactoryGirl.create(:lookup_value, name: blue_lookup_values_detail[:name],lookup_id: blue_lookup.id, external_ref_num:blue_lookup_values_detail[:external_ref_num])
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

    let!(:complete_billing_satisfying_ag2) { FactoryGirl.create(:account, name: "#{red_lookup_values[1][:name]}-#{red_lookup_values[0][:name]}-#{red_lookup_values[2][:name]}", account_type_id: coa_a.id, segment_1: red_lookup_values[1][:external_ref_num], segment_2: red_lookup_values[0][:external_ref_num], segment_3: red_lookup_values[2][:external_ref_num], code: "#{red_lookup_values[1][:external_ref_num]}-#{red_lookup_values[0][:external_ref_num]}-#{red_lookup_values[2][:external_ref_num]}", active: true) }
    let!(:complete_billing_not_satisfying_ag2) { FactoryGirl.create(:account, name: "#{red_lookup_values[2][:name]}-#{red_lookup_values[2][:name]}-#{red_lookup_values[2][:name]}", account_type_id: coa_a.id, segment_1: red_lookup_values[2][:external_ref_num], segment_2: red_lookup_values[2][:external_ref_num], segment_3: red_lookup_values[2][:external_ref_num], code: "#{red_lookup_values[2][:external_ref_num]}-#{red_lookup_values[2][:external_ref_num]}-#{red_lookup_values[2][:external_ref_num]}", active: true) }
    let!(:complete_billing_one_line_not_satisfying_ag2) { FactoryGirl.create(:account, name: "#{red_lookup_values[0][:name]}-#{red_lookup_values[2][:name]}-#{red_lookup_values[2][:name]}", account_type_id: coa_a.id, segment_1: red_lookup_values[0][:external_ref_num], segment_2: red_lookup_values[2][:external_ref_num], segment_3: red_lookup_values[2][:external_ref_num], code: "#{red_lookup_values[0][:external_ref_num]}-#{red_lookup_values[2][:external_ref_num]}-#{red_lookup_values[2][:external_ref_num]}", active: true) }
    let!(:complete_billing_one_line_satisfying_ag2) { FactoryGirl.create(:account, name: "#{red_lookup_values[0][:name]}-#{red_lookup_values[0][:name]}-#{red_lookup_values[2][:name]}", account_type_id: coa_a.id, segment_1: red_lookup_values[0][:external_ref_num], segment_2: red_lookup_values[0][:external_ref_num], segment_3: red_lookup_values[2][:external_ref_num], code: "#{red_lookup_values[0][:external_ref_num]}-#{red_lookup_values[0][:external_ref_num]}-#{red_lookup_values[2][:external_ref_num]}", active: true) }
    let!(:partial_billing_account_satisfying_AG2) { FactoryGirl.create(:account, name: "#{red_lookup_values[3][:name]}-#{red_lookup_values[0][:name]}-#{red_lookup_values[2][:name]}", account_type_id: coa_a.id, segment_1: red_lookup_values[3][:external_ref_num], segment_2: red_lookup_values[0][:external_ref_num], segment_3: red_lookup_values[2][:external_ref_num], code: "#{red_lookup_values[3][:external_ref_num]}-#{red_lookup_values[0][:external_ref_num]}-#{red_lookup_values[2][:external_ref_num]}", active: true) }
    let!(:partial_billing_account_not_satisfying_AG2) { FactoryGirl.create(:account, name: "#{red_lookup_values[3][:name]}-#{red_lookup_values[2][:name]}-#{red_lookup_values[2][:name]}", account_type_id: coa_a.id, segment_1: red_lookup_values[3][:external_ref_num], segment_2: red_lookup_values[2][:external_ref_num], segment_3: red_lookup_values[2][:external_ref_num], code: "#{red_lookup_values[3][:external_ref_num]}-#{red_lookup_values[2][:external_ref_num]}-#{red_lookup_values[2][:external_ref_num]}", active: true) }
    let!(:partial_blank_billing_satisfying_ag2) { FactoryGirl.create(:account, name: "#{red_lookup_values[1][:name]}-#{red_lookup_values[0][:name]}", account_type_id: coa_a.id, segment_1: red_lookup_values[1][:external_ref_num], segment_2: red_lookup_values[0][:external_ref_num], segment_3: " ", code: "#{red_lookup_values[1][:external_ref_num]}-#{red_lookup_values[0][:external_ref_num]}", active: true) }
    let!(:partial_blank_billing_not_satisfying_ag2) { FactoryGirl.create(:account, name: "#{red_lookup_values[2][:name]}-#{red_lookup_values[2][:name]}", account_type_id: coa_a.id, segment_1: red_lookup_values[2][:external_ref_num], segment_2: red_lookup_values[2][:external_ref_num], segment_3: " ", code: "#{red_lookup_values[2][:external_ref_num]}-#{red_lookup_values[2][:external_ref_num]}", active: true) }

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
    let!(:draft_inv_header_satisfying_AG2) { FactoryGirl.create(:invoice_header, status: "new", supplier_id: supplier.id, invoice_number: "draft_inv_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id) }
    let!(:draft_inv_line_satisfying_AG2) { FactoryGirl.create(:invoice_quantity_line, invoice_header_id: draft_inv_header_satisfying_AG2.id, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: complete_billing_satisfying_ag2.id) }
    #pending
    let!(:pending_inv_satisfying_AG2) do
      FactoryGirl.create(
        :invoice_header, status: "pending_approval", supplier_id: supplier.id, invoice_number: "pending_inv_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
        invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: complete_billing_satisfying_ag2.id)]
      )
    end
    #Approved
    let!(:approved_inv_satisfying_AG2) do
      FactoryGirl.create(
        :invoice_header, status: "approved", supplier_id: supplier.id, invoice_number: "approved_inv_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
        invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: complete_billing_satisfying_ag2.id)]
      )
    end

    # document creator creates 3 invoices(new/pending/approved) with complete billing without satisfying the account group AG2'
    #draft/new
    let!(:draft_inv_header_not_satisfying_AG2) { FactoryGirl.create(:invoice_header, status: "new", supplier_id: supplier.id, invoice_number: "draft_inv_not_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id) }
    let!(:draft_inv_line_not_satisfying_AG2) { FactoryGirl.create(:invoice_quantity_line, invoice_header_id: draft_inv_header_not_satisfying_AG2.id, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: complete_billing_not_satisfying_ag2.id) }
    #pending
    let!(:pending_inv_not_satisfying_AG2) do
      FactoryGirl.create(
        :invoice_header, status: "pending_approval", supplier_id: supplier.id, invoice_number: "pending_inv_not_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
        invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: complete_billing_not_satisfying_ag2.id)]
      )
    end
    #Approved
    let!(:approved_inv_not_satisfying_AG2) do
      FactoryGirl.create(
        :invoice_header, status: "approved", supplier_id: supplier.id, invoice_number: "approved_inv_not_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
        invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: complete_billing_not_satisfying_ag2.id)]
      )
    end

    # document creator creates 3 Invoice doc(with complete billing where one line satisfies AG2 and the other line does not satisfies the AG2
    #draft/new
    let!(:draft_inv_header_one_line_not_satisfying_AG2) { FactoryGirl.create(:invoice_header, status: "new", supplier_id: supplier.id, invoice_number: "draft_inv_one_line_not_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id) }
    let!(:draft_inv_line1_satisfying_AG2) { FactoryGirl.create(:invoice_quantity_line, invoice_header_id: draft_inv_header_one_line_not_satisfying_AG2.id, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: complete_billing_one_line_satisfying_ag2.id) }
    let!(:draft_inv_line2_not_satisfying_AG2) { FactoryGirl.create(:invoice_quantity_line, invoice_header_id: draft_inv_header_one_line_not_satisfying_AG2.id, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: complete_billing_one_line_not_satisfying_ag2.id) }
    #pending
    let!(:pending_inv_one_line_not_satisfying_AG2) do
      FactoryGirl.create(
        :invoice_header, status: "pending_approval", supplier_id: supplier.id, invoice_number: "pending_inv_one_line_not_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
        invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: complete_billing_one_line_satisfying_ag2.id), FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: complete_billing_one_line_not_satisfying_ag2.id)]
      )
    end
    #Approved
    let!(:approved_inv_one_line_not_satisfying_AG2) do
      FactoryGirl.create(
        :invoice_header, status: "approved", supplier_id: supplier.id, invoice_number: "approved_inv_one_line_not_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
        invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: complete_billing_one_line_satisfying_ag2.id), FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: complete_billing_one_line_not_satisfying_ag2.id) ]
      )
    end

    # document creator creates 3 Invoice doc(with complete split billing) satisfies AG2
    #draft/new
    let!(:draft_inv_header_split_billing_satisfying_AG2) { FactoryGirl.create(:invoice_header, status: "new", supplier_id: supplier.id, invoice_number: "draft_inv_split_billing_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id) }
    let!(:draft_inv_line1_split_billing_satisfying_AG2) { FactoryGirl.create(:invoice_quantity_line, invoice_header_id: draft_inv_header_split_billing_satisfying_AG2.id, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_type: coa_a) }
    let!(:draft_inv_allocations1) do
      FactoryGirl.create(:invoice_line_allocation, invoice_line: draft_inv_line1_split_billing_satisfying_AG2, pct: 50, account: complete_billing_satisfying_ag2)
      FactoryGirl.create(:invoice_line_allocation, invoice_line: draft_inv_line1_split_billing_satisfying_AG2, pct: 50, account: complete_billing_one_line_satisfying_ag2)
      draft_inv_header_split_billing_satisfying_AG2.reload
    end
    #pending
    let!(:pending_inv_split_billing_satisfying_AG2) do
      FactoryGirl.create(
        :invoice_header, status: "pending_approval", supplier_id: supplier.id, invoice_number: "pending_inv_split_billing_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
        invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_type: coa_a)]
      )
    end
    let!(:pending_inv_allocations1) do
      FactoryGirl.create(:invoice_line_allocation, invoice_line: pending_inv_split_billing_satisfying_AG2.invoice_lines[0], pct: 50, account: complete_billing_satisfying_ag2)
      FactoryGirl.create(:invoice_line_allocation, invoice_line: pending_inv_split_billing_satisfying_AG2.invoice_lines[0], pct: 50, account: complete_billing_one_line_satisfying_ag2)
      pending_inv_split_billing_satisfying_AG2.reload
    end
    #Approved
    let!(:approved_inv_split_billing_satisfying_AG2) do
      FactoryGirl.create(
        :invoice_header, status: "approved", supplier_id: supplier.id, invoice_number: "app_inv_split_billing_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
        invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_type: coa_a)]
      )
    end
    let!(:approved_inv_allocations1) do
      FactoryGirl.create(:invoice_line_allocation, invoice_line: approved_inv_split_billing_satisfying_AG2.invoice_lines[0], pct: 50, account: complete_billing_satisfying_ag2)
      FactoryGirl.create(:invoice_line_allocation, invoice_line: approved_inv_split_billing_satisfying_AG2.invoice_lines[0], pct: 50, account: complete_billing_one_line_satisfying_ag2)
      approved_inv_split_billing_satisfying_AG2.reload
    end

    # document creator creates 3 Invoice doc(with complete split billing) not satisfies AG2
    #draft/new
    let!(:draft_inv_header_split_billing_not_satisfying_AG2) { FactoryGirl.create(:invoice_header, status: "new", supplier_id: supplier.id, invoice_number: "draft_inv_split_bill_not_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id) }
    let!(:draft_inv_line1_split_billing_not_satisfying_AG2) { FactoryGirl.create(:invoice_quantity_line, invoice_header_id: draft_inv_header_split_billing_not_satisfying_AG2.id, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_type: coa_a) }
    let!(:draft_inv_allocations2) do
      FactoryGirl.create(:invoice_line_allocation, invoice_line: draft_inv_line1_split_billing_not_satisfying_AG2, pct: 50, account: complete_billing_not_satisfying_ag2)
      FactoryGirl.create(:invoice_line_allocation, invoice_line: draft_inv_line1_split_billing_not_satisfying_AG2, pct: 50, account: complete_billing_one_line_not_satisfying_ag2)
      draft_inv_header_split_billing_not_satisfying_AG2.reload
    end
    #pending
    let!(:pending_inv_split_billing_not_satisfying_AG2) do
      FactoryGirl.create(
        :invoice_header, status: "pending_approval", supplier_id: supplier.id, invoice_number: "pend_inv_split_bill_not_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
        invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_type: coa_a)]
      )
    end
    let!(:pending_inv_allocations3) do
      FactoryGirl.create(:invoice_line_allocation, invoice_line: pending_inv_split_billing_not_satisfying_AG2.invoice_lines[0], pct: 50, account: complete_billing_not_satisfying_ag2)
      FactoryGirl.create(:invoice_line_allocation, invoice_line: pending_inv_split_billing_not_satisfying_AG2.invoice_lines[0], pct: 50, account: complete_billing_one_line_not_satisfying_ag2)
      pending_inv_split_billing_not_satisfying_AG2.reload
    end
    #Approved
    let!(:approved_inv_split_billing_not_satisfying_AG2) do
      FactoryGirl.create(
        :invoice_header, status: "approved", supplier_id: supplier.id, invoice_number: "app_inv_split_bill_not_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
        invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_type: coa_a)]
      )
    end
    let!(:approved_inv_allocations2) do
      FactoryGirl.create(:invoice_line_allocation, invoice_line: approved_inv_split_billing_not_satisfying_AG2.invoice_lines[0], pct: 50, account: complete_billing_not_satisfying_ag2)
      FactoryGirl.create(:invoice_line_allocation, invoice_line: approved_inv_split_billing_not_satisfying_AG2.invoice_lines[0], pct: 50, account: complete_billing_one_line_not_satisfying_ag2)
      approved_inv_split_billing_not_satisfying_AG2.reload
    end

    # document creator creates 3 invoices(new/pending/approved) with partial(by inactivating the lookup value) billing with satisfying the account group AG2'
    let!(:draft_partial_inv_header_satisfying_AG2) { FactoryGirl.create(:invoice_header, status: "new", supplier_id: supplier.id, invoice_number: "draft_partial_inv_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id) }
    let!(:draft_partial_inv_line_satisfying_AG2) { FactoryGirl.create(:invoice_quantity_line, invoice_header_id: draft_partial_inv_header_satisfying_AG2.id, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: partial_billing_account_satisfying_AG2.id) }
    #pending
    let!(:pending_partial_inv_satisfying_AG2) do
      FactoryGirl.create(
        :invoice_header, status: "pending_approval", supplier_id: supplier.id, invoice_number: "pending_partial_inv_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
        invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: partial_billing_account_satisfying_AG2.id)]
      )
    end
    #Approved
    let!(:approved_partial_inv_satisfying_AG2) do
      FactoryGirl.create(
        :invoice_header, status: "approved", supplier_id: supplier.id, invoice_number: "approved_partial_inv_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
        invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: partial_billing_account_satisfying_AG2.id)]
      )
    end

    # document creator creates 3 invoices(new/pending/approved) with partial(by inactivating the lookup value) billing without satisfying the account group AG2'
    let!(:draft_partial_inv_header_not_satisfying_AG2) { FactoryGirl.create(:invoice_header, status: "new", supplier_id: supplier.id, invoice_number: "draft_partial_inv_not_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id) }
    let!(:draft_partial_inv_line_not_satisfying_AG2) { FactoryGirl.create(:invoice_quantity_line, invoice_header_id: draft_partial_inv_header_not_satisfying_AG2.id, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: partial_billing_account_not_satisfying_AG2.id) }
    #pending
    let!(:pending_partial_inv_not_satisfying_AG2) do
      FactoryGirl.create(
        :invoice_header, status: "pending_approval", supplier_id: supplier.id, invoice_number: "pending_partial_inv_not_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
        invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: partial_billing_account_not_satisfying_AG2.id)]
      )
    end
    #Approved
    let!(:approved_partial_inv_not_satisfying_AG2) do
      FactoryGirl.create(
        :invoice_header, status: "approved", supplier_id: supplier.id, invoice_number: "approved_partial_inv_not_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
        invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: partial_billing_account_not_satisfying_AG2.id)]
      )
    end

    # document creator creates 3 invoices(new/pending/approved) with partial(by left one segment as blank) billing with satisfying the account group AG2'
    let!(:draft_partial_blank_inv_header_satisfying_AG2) { FactoryGirl.create(:invoice_header, status: "new", supplier_id: supplier.id, invoice_number: "draft_partial_blank_inv_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id) }
    let!(:draft_partial_blank_inv_line_satisfying_AG2) { FactoryGirl.create(:invoice_quantity_line, invoice_header_id: draft_partial_blank_inv_header_satisfying_AG2.id, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: partial_blank_billing_satisfying_ag2.id) }
    #pending
    let!(:pending_partial_blank_inv_satisfying_AG2) do
      FactoryGirl.create(
        :invoice_header, status: "pending_approval", supplier_id: supplier.id, invoice_number: "pend_partial_blank_inv_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
        invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: partial_blank_billing_satisfying_ag2.id)]
      )
    end
    #Approved
    let!(:approved_partial_blank_inv_satisfying_AG2) do
      FactoryGirl.create(
        :invoice_header, status: "approved", supplier_id: supplier.id, invoice_number: "app_partial_blank_inv_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
        invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: partial_blank_billing_satisfying_ag2.id)]
      )
    end

    # document creator creates 3 invoices(new/pending/approved) with partial(by left one segment as blank) billing without satisfying the account group AG2'
    let!(:draft_partial_blank_inv_header_not_satisfying_AG2) { FactoryGirl.create(:invoice_header, status: "new", supplier_id: supplier.id, invoice_number: "dft_partl_blank_inv_not_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id) }
    let!(:draft_partial_blank_inv_line_not_satisfying_AG2) { FactoryGirl.create(:invoice_quantity_line, invoice_header_id: draft_partial_blank_inv_header_not_satisfying_AG2.id, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: partial_blank_billing_not_satisfying_ag2.id) }
    #pending
    let!(:pending_partial_blank_inv_not_satisfying_AG2) do
      FactoryGirl.create(
        :invoice_header, status: "pending_approval", supplier_id: supplier.id, invoice_number: "pend_partl_blank_inv_not_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
        invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: partial_blank_billing_not_satisfying_ag2.id)]
      )
    end
    #Approved
    let!(:approved_partial_blank_inv_not_satisfying_AG2) do
      FactoryGirl.create(
        :invoice_header, status: "approved", supplier_id: supplier.id, invoice_number: "app_partl_blank_inv_not_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
        invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: partial_blank_billing_not_satisfying_ag2.id)]
      )
    end

    # document creator creates an invoice with incomplete billing
    let!(:draft_incomplete_billing_inv_header) { FactoryGirl.create(:invoice_header, status: "new", supplier_id: supplier.id, invoice_number: "draft_incomplete_billing_inv2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id) }
    let!(:draft_incomplete_billing_inv_line) do
      line = FactoryGirl.create(:invoice_quantity_line, invoice_header_id: draft_incomplete_billing_inv_header.id, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1)
      line.account=nil
      line.save(validate:false)
      draft_incomplete_billing_inv_header.reload
    end

    context 'CD-251620: Document access based on Account group security' do
      before(:each) do
        lookup_value = LookupValue.find_by(name: red_lookup_values[3][:name])
        lookup_value.update(active: false)
      end
      context 'us user restricted the AG2 with segment rules and belongs to COA A' do
        before do
          ["off", "on"].each do |elastic_search|
            if elastic_search == "off"
              allow(User).to receive(:current_user).and_return(us_user)
              get :invoice_line_list_csv
            else 
              allow(User).to receive(:current_user).and_return(us_user)
              allow(Setup).to receive(:enable_elasticsearch?).and_return(true)
              allow(Setup).to receive(:lookup).and_call_original
              allow(Setup).to receive(:lookup).with('es_invoice_lines_invoice_line').and_return(true)
              get :invoice_line_list_csv
            end
          end
        end
        it 'Invoice doc(with complete/incomplete/partial billing) access based on account group restriction for the users Us User' do
          csv = CSV.parse(response.body, :headers => true)
          # invoices(new/pending/approved) with complete billing with satisfying the account group AG2
          expect(get_data_from_data_table_columns("Invoice #",draft_inv_header_satisfying_AG2.invoice_number, "Line #", csv)).to include draft_inv_line_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_inv_satisfying_AG2.invoice_number, "Line #", csv)).to include pending_inv_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_inv_satisfying_AG2.invoice_number, "Line #", csv)).to include approved_inv_satisfying_AG2.invoice_lines[0].line_num.to_s

          # Invoice doc(with complete billing where one line satisfies AG2 and the other line does not satisfies the AG2
          expect(get_data_from_data_table_columns("Invoice #",draft_inv_header_one_line_not_satisfying_AG2.invoice_number, "Line #", csv)).to include draft_inv_line1_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",draft_inv_header_one_line_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include draft_inv_line2_not_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_inv_one_line_not_satisfying_AG2.invoice_number, "Line #", csv)).to include pending_inv_one_line_not_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_inv_one_line_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include pending_inv_one_line_not_satisfying_AG2.invoice_lines[1].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_inv_one_line_not_satisfying_AG2.invoice_number, "Line #", csv)).to include approved_inv_one_line_not_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_inv_one_line_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include approved_inv_one_line_not_satisfying_AG2.invoice_lines[1].line_num.to_s

          # invoices(new/pending/approved) with complete billing without satisfying the account group AG2
          expect(get_data_from_data_table_columns("Invoice #",draft_inv_header_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include draft_inv_line_not_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_inv_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include pending_inv_not_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_inv_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include approved_inv_not_satisfying_AG2.invoice_lines[0].line_num.to_s

          # Invoice doc(with complete split billing) satisfies AG2
          expect(get_data_from_data_table_columns("Invoice #",draft_inv_header_split_billing_satisfying_AG2.invoice_number, "Line #", csv)).to include draft_inv_line1_split_billing_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_inv_split_billing_satisfying_AG2.invoice_number, "Line #", csv)).to include pending_inv_split_billing_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_inv_split_billing_satisfying_AG2.invoice_number, "Line #", csv)).to include approved_inv_split_billing_satisfying_AG2.invoice_lines[0].line_num.to_s

          # Invoice doc(with complete split billing) not satisfies AG2
          expect(get_data_from_data_table_columns("Invoice #",draft_inv_header_split_billing_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include draft_inv_line1_split_billing_not_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_inv_split_billing_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include pending_inv_split_billing_not_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_inv_split_billing_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include approved_inv_split_billing_not_satisfying_AG2.invoice_lines[0].line_num.to_s

          # Invoices(new/pending/approved) with partial(by left one segment as blank) billing with satisfying the account group AG2
          expect(get_data_from_data_table_columns("Invoice #",draft_partial_blank_inv_header_satisfying_AG2.invoice_number, "Line #", csv)).to include draft_partial_blank_inv_line_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_partial_blank_inv_satisfying_AG2.invoice_number, "Line #", csv)).to include pending_partial_blank_inv_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_partial_blank_inv_satisfying_AG2.invoice_number, "Line #", csv)).to include approved_partial_blank_inv_satisfying_AG2.invoice_lines[0].line_num.to_s

          # Invoices(new/pending/approved) with partial(by left one segment as blank) billing without satisfying the account group AG2'
          expect(get_data_from_data_table_columns("Invoice #",draft_partial_blank_inv_header_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include draft_partial_blank_inv_line_not_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_partial_blank_inv_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include pending_partial_blank_inv_not_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_partial_blank_inv_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include approved_partial_blank_inv_not_satisfying_AG2.invoice_lines[0].line_num.to_s

          # invoices(new/pending/approved) with partial(by inactivating the lookup value) billing with satisfying the account group AG2'
          expect(get_data_from_data_table_columns("Invoice #",draft_partial_inv_header_satisfying_AG2.invoice_number, "Line #", csv)).to include draft_partial_inv_line_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_partial_inv_satisfying_AG2.invoice_number, "Line #", csv)).to include pending_partial_inv_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_partial_inv_satisfying_AG2.invoice_number, "Line #", csv)).to include approved_partial_inv_satisfying_AG2.invoice_lines[0].line_num.to_s

          # invoices(new/pending/approved) with partial(by inactivating the lookup value) billing without satisfying the account group AG2
          expect(get_data_from_data_table_columns("Invoice #",draft_partial_inv_header_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include draft_partial_inv_line_not_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_partial_inv_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include pending_partial_inv_not_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_partial_inv_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include approved_partial_inv_not_satisfying_AG2.invoice_lines[0].line_num.to_s

          # Invoice with incomplete billing
          expect(get_data_from_data_table_columns("Invoice #",draft_incomplete_billing_inv_header.invoice_number, "Line #", csv)).to include draft_incomplete_billing_inv_header.invoice_lines[0].line_num.to_s
        end
      end

      context 'Taiwan user restricted the both AG2 and AG4 with segment rules where AG2 for COA A and AG4 for COA B' do
        before do
           ["off", "on"].each do |elastic_search|
            if elastic_search == "off"
              allow(User).to receive(:current_user).and_return(taiwan_user)
              get :invoice_line_list_csv
            else 
              allow(User).to receive(:current_user).and_return(taiwan_user)
              allow(Setup).to receive(:enable_elasticsearch?).and_return(true)
              allow(Setup).to receive(:lookup).and_call_original
              allow(Setup).to receive(:lookup).with('es_invoice_lines_invoice_line').and_return(true)
              get :invoice_line_list_csv
            end
          end
        end
        it 'Invoice doc(with complete/incomplete/partial billing) access based on account group restriction for the Taiwan User' do
          csv = CSV.parse(response.body, :headers => true)
          # invoices(new/pending/approved) with complete billing with satisfying the account group AG2
          expect(get_data_from_data_table_columns("Invoice #",draft_inv_header_satisfying_AG2.invoice_number, "Line #", csv)).to include draft_inv_line_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_inv_satisfying_AG2.invoice_number, "Line #", csv)).to include pending_inv_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_inv_satisfying_AG2.invoice_number, "Line #", csv)).to include approved_inv_satisfying_AG2.invoice_lines[0].line_num.to_s

          # Invoice doc(with complete billing where one line satisfies AG2 and the other line does not satisfies the AG2
          expect(get_data_from_data_table_columns("Invoice #",draft_inv_header_one_line_not_satisfying_AG2.invoice_number, "Line #", csv)).to include draft_inv_line1_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",draft_inv_header_one_line_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include draft_inv_line2_not_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_inv_one_line_not_satisfying_AG2.invoice_number, "Line #", csv)).to include pending_inv_one_line_not_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_inv_one_line_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include pending_inv_one_line_not_satisfying_AG2.invoice_lines[1].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_inv_one_line_not_satisfying_AG2.invoice_number, "Line #", csv)).to include approved_inv_one_line_not_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_inv_one_line_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include approved_inv_one_line_not_satisfying_AG2.invoice_lines[1].line_num.to_s

          # invoices(new/pending/approved) with complete billing without satisfying the account group AG2
          expect(get_data_from_data_table_columns("Invoice #",draft_inv_header_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include draft_inv_line_not_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_inv_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include pending_inv_not_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_inv_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include approved_inv_not_satisfying_AG2.invoice_lines[0].line_num.to_s

          # Invoice doc(with complete split billing) satisfies AG2
          expect(get_data_from_data_table_columns("Invoice #",draft_inv_header_split_billing_satisfying_AG2.invoice_number, "Line #", csv)).to include draft_inv_line1_split_billing_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_inv_split_billing_satisfying_AG2.invoice_number, "Line #", csv)).to include pending_inv_split_billing_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_inv_split_billing_satisfying_AG2.invoice_number, "Line #", csv)).to include approved_inv_split_billing_satisfying_AG2.invoice_lines[0].line_num.to_s

          # Invoice doc(with complete split billing) not satisfies AG2
          expect(get_data_from_data_table_columns("Invoice #",draft_inv_header_split_billing_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include draft_inv_line1_split_billing_not_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_inv_split_billing_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include pending_inv_split_billing_not_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_inv_split_billing_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include approved_inv_split_billing_not_satisfying_AG2.invoice_lines[0].line_num.to_s

          # Invoices(new/pending/approved) with partial(by left one segment as blank) billing with satisfying the account group AG2
          expect(get_data_from_data_table_columns("Invoice #",draft_partial_blank_inv_header_satisfying_AG2.invoice_number, "Line #", csv)).to include draft_partial_blank_inv_line_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_partial_blank_inv_satisfying_AG2.invoice_number, "Line #", csv)).to include pending_partial_blank_inv_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_partial_blank_inv_satisfying_AG2.invoice_number, "Line #", csv)).to include approved_partial_blank_inv_satisfying_AG2.invoice_lines[0].line_num.to_s

          # Invoices(new/pending/approved) with partial(by left one segment as blank) billing without satisfying the account group AG2'
          expect(get_data_from_data_table_columns("Invoice #",draft_partial_blank_inv_header_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include draft_partial_blank_inv_line_not_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_partial_blank_inv_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include pending_partial_blank_inv_not_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_partial_blank_inv_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include approved_partial_blank_inv_not_satisfying_AG2.invoice_lines[0].line_num.to_s

          # invoices(new/pending/approved) with partial(by inactivating the lookup value) billing with satisfying the account group AG2'
          expect(get_data_from_data_table_columns("Invoice #",draft_partial_inv_header_satisfying_AG2.invoice_number, "Line #", csv)).to include draft_partial_inv_line_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_partial_inv_satisfying_AG2.invoice_number, "Line #", csv)).to include pending_partial_inv_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_partial_inv_satisfying_AG2.invoice_number, "Line #", csv)).to include approved_partial_inv_satisfying_AG2.invoice_lines[0].line_num.to_s

          # invoices(new/pending/approved) with partial(by inactivating the lookup value) billing without satisfying the account group AG2
          expect(get_data_from_data_table_columns("Invoice #",draft_partial_inv_header_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include draft_partial_inv_line_not_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_partial_inv_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include pending_partial_inv_not_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_partial_inv_not_satisfying_AG2.invoice_number, "Line #", csv)).to_not include approved_partial_inv_not_satisfying_AG2.invoice_lines[0].line_num.to_s

          # Invoice with incomplete billing
          expect(get_data_from_data_table_columns("Invoice #",draft_incomplete_billing_inv_header.invoice_number, "Line #", csv)).to include draft_incomplete_billing_inv_header.invoice_lines[0].line_num.to_s
        end
      end
      context 'Austria User restricted the AG4 with segment rules and belongs to COA B' do
        before do
          ["off", "on"].each do |elastic_search|
            if elastic_search == "off"
              allow(User).to receive(:current_user).and_return(austria_user)
              get :invoice_line_list_csv
            else 
              allow(User).to receive(:current_user).and_return(austria_user)
              allow(Setup).to receive(:enable_elasticsearch?).and_return(true)
              allow(Setup).to receive(:lookup).and_call_original
              allow(Setup).to receive(:lookup).with('es_invoice_lines_invoice_line').and_return(true)
              get :invoice_line_list_csv
            end
          end
        end
        it 'Invoice doc(with complete/incomplete/partial billing) access based on account group restriction for the Austria User' do
          csv = CSV.parse(response.body, :headers => true)
          # Lines table should contain only 2 rows one is invoice line header and the other is incomplete billing line invoice line.
          # Here the user restricted to AG with segment rules belongs to another chart of account can see the incomplete billing line of another COA.
          # This issue will be fixed after the R32 AG security implementation.
          expect(csv.count).to eq 1
          # Invoice with incomplete billing
          expect(get_data_from_data_table_columns("Invoice #", draft_incomplete_billing_inv_header.invoice_number, "Line #", csv)).to include draft_incomplete_billing_inv_header.invoice_lines[0].line_num.to_s
        end
      end
      context 'Fiji User restricted to default chart of account(COA A) restriction' do
        before do
          ["off", "on"].each do |elastic_search|
            if elastic_search == "off"
              allow(User).to receive(:current_user).and_return(fiji_user)
              get :invoice_line_list_csv
            else 
              allow(User).to receive(:current_user).and_return(fiji_user)
              allow(Setup).to receive(:enable_elasticsearch?).and_return(true)
              allow(Setup).to receive(:lookup).and_call_original
              allow(Setup).to receive(:lookup).with('es_invoice_lines_invoice_line').and_return(true)
              get :invoice_line_list_csv
            end
          end
        end
        it 'Invoice doc(with complete/incomplete/partial billing) access based on account group restriction for the Fiji User' do
          csv = CSV.parse(response.body, :headers => true)
          # invoices(new/pending/approved) with complete billing with satisfying the account group AG2
          expect(get_data_from_data_table_columns("Invoice #",draft_inv_header_satisfying_AG2.invoice_number, "Line #", csv)).to include draft_inv_line_satisfying_AG2.line_num.to_s.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_inv_satisfying_AG2.invoice_number, "Line #", csv)).to include pending_inv_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_inv_satisfying_AG2.invoice_number, "Line #", csv)).to include approved_inv_satisfying_AG2.invoice_lines[0].line_num.to_s

          # Invoice doc(with complete billing where one line satisfies AG2 and the other line does not satisfies the AG2
          expect(get_data_from_data_table_columns("Invoice #",draft_inv_header_one_line_not_satisfying_AG2.invoice_number, "Line #", csv)).to include draft_inv_line1_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",draft_inv_header_one_line_not_satisfying_AG2.invoice_number, "Line #", csv)).to include draft_inv_line2_not_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_inv_one_line_not_satisfying_AG2.invoice_number, "Line #", csv)).to include pending_inv_one_line_not_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_inv_one_line_not_satisfying_AG2.invoice_number, "Line #", csv)).to include pending_inv_one_line_not_satisfying_AG2.invoice_lines[1].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_inv_one_line_not_satisfying_AG2.invoice_number, "Line #", csv)).to include approved_inv_one_line_not_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_inv_one_line_not_satisfying_AG2.invoice_number, "Line #", csv)).to include approved_inv_one_line_not_satisfying_AG2.invoice_lines[1].line_num.to_s

          # invoices(new/pending/approved) with complete billing without satisfying the account group AG2
          expect(get_data_from_data_table_columns("Invoice #",draft_inv_header_not_satisfying_AG2.invoice_number, "Line #", csv)).to include draft_inv_line_not_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_inv_not_satisfying_AG2.invoice_number, "Line #", csv)).to include pending_inv_not_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_inv_not_satisfying_AG2.invoice_number, "Line #", csv)).to include approved_inv_not_satisfying_AG2.invoice_lines[0].line_num.to_s

          # Invoice doc(with complete split billing) satisfies AG2
          expect(get_data_from_data_table_columns("Invoice #",draft_inv_header_split_billing_satisfying_AG2.invoice_number, "Line #", csv)).to include draft_inv_line1_split_billing_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_inv_split_billing_satisfying_AG2.invoice_number, "Line #", csv)).to include pending_inv_split_billing_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_inv_split_billing_satisfying_AG2.invoice_number, "Line #", csv)).to include approved_inv_split_billing_satisfying_AG2.invoice_lines[0].line_num.to_s

          # Invoice doc(with complete split billing) not satisfies AG2
          expect(get_data_from_data_table_columns("Invoice #",draft_inv_header_split_billing_not_satisfying_AG2.invoice_number, "Line #", csv)).to include draft_inv_line1_split_billing_not_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_inv_split_billing_not_satisfying_AG2.invoice_number, "Line #", csv)).to include pending_inv_split_billing_not_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_inv_split_billing_not_satisfying_AG2.invoice_number, "Line #", csv)).to include approved_inv_split_billing_not_satisfying_AG2.invoice_lines[0].line_num.to_s

          # Invoices(new/pending/approved) with partial(by left one segment as blank) billing with satisfying the account group AG2
          expect(get_data_from_data_table_columns("Invoice #",draft_partial_blank_inv_header_satisfying_AG2.invoice_number, "Line #", csv)).to include draft_partial_blank_inv_line_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_partial_blank_inv_satisfying_AG2.invoice_number, "Line #", csv)).to include pending_partial_blank_inv_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_partial_blank_inv_satisfying_AG2.invoice_number, "Line #", csv)).to include approved_partial_blank_inv_satisfying_AG2.invoice_lines[0].line_num.to_s

          # Invoices(new/pending/approved) with partial(by left one segment as blank) billing without satisfying the account group AG2'
          expect(get_data_from_data_table_columns("Invoice #",draft_partial_blank_inv_header_not_satisfying_AG2.invoice_number, "Line #", csv)).to include draft_partial_blank_inv_line_not_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_partial_blank_inv_not_satisfying_AG2.invoice_number, "Line #", csv)).to include pending_partial_blank_inv_not_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_partial_blank_inv_not_satisfying_AG2.invoice_number, "Line #", csv)).to include approved_partial_blank_inv_not_satisfying_AG2.invoice_lines[0].line_num.to_s

          # invoices(new/pending/approved) with partial(by inactivating the lookup value) billing with satisfying the account group AG2'
          expect(get_data_from_data_table_columns("Invoice #",draft_partial_inv_header_satisfying_AG2.invoice_number, "Line #", csv)).to include draft_partial_inv_line_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_partial_inv_satisfying_AG2.invoice_number, "Line #", csv)).to include pending_partial_inv_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_partial_inv_satisfying_AG2.invoice_number, "Line #", csv)).to include approved_partial_inv_satisfying_AG2.invoice_lines[0].line_num.to_s

          # invoices(new/pending/approved) with partial(by inactivating the lookup value) billing without satisfying the account group AG2
          expect(get_data_from_data_table_columns("Invoice #",draft_partial_inv_header_not_satisfying_AG2.invoice_number, "Line #", csv)).to include draft_partial_inv_line_not_satisfying_AG2.line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",pending_partial_inv_not_satisfying_AG2.invoice_number, "Line #", csv)).to include pending_partial_inv_not_satisfying_AG2.invoice_lines[0].line_num.to_s
          expect(get_data_from_data_table_columns("Invoice #",approved_partial_inv_not_satisfying_AG2.invoice_number, "Line #", csv)).to include approved_partial_inv_not_satisfying_AG2.invoice_lines[0].line_num.to_s

          # Invoice with incomplete billing
          expect(get_data_from_data_table_columns("Invoice #",draft_incomplete_billing_inv_header.invoice_number, "Line #", csv)).to include draft_incomplete_billing_inv_header.invoice_lines[0].line_num.to_s
        end
      end
      context 'Colombia User restricted to default chart of account(COA B) restriction' do
        before do
          ["off", "on"].each do |elastic_search|
            if elastic_search == "off"
              allow(User).to receive(:current_user).and_return(colombia_user)
              get :invoice_line_list_csv
            else 
              allow(User).to receive(:current_user).and_return(colombia_user)
              allow(Setup).to receive(:enable_elasticsearch?).and_return(true)
              allow(Setup).to receive(:lookup).and_call_original
              allow(Setup).to receive(:lookup).with('es_invoice_lines_invoice_line').and_return(true)
              get :invoice_line_list_csv
            end
          end
        end
        it 'Invoice doc(with complete/incomplete/partial billing) access based on account group restriction for the Colombia User' do
          csv = CSV.parse(response.body, :headers => true)
          # Lines table should contain only 1 rows that is the header row and this user cannot see any invoice lines belongs to COA A.
          # Since the colombia user is restricted to the default chart of account COA B.
          expect(csv.count).to eq 0
        end
      end
      def get_data_from_data_table_columns(header1, document_no , line_header, csv)
        rows = csv.select {|row| row[header1] == document_no}
        rows.map { |line| line[line_header] }
      end
    end
  end
end
