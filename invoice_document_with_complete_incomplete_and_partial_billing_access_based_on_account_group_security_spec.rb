require 'spec_helper'
feature 'CD-251620: Document access based on Account group security', type: :feature, js: true, accounts: true, account_security: true do
  include SessionHelper
  include SharedHelper
  include ExpenseLiteHelper

  let(:invoice_index) { InvoicesPage::Index.new }
  let(:invoice_line) { InvoiceLinesPage::Index.new }
  let(:req_index) { RequisitionsPage::Index.new }
  let(:req_show) { RequisitionsPage::Show.new }
  let(:po_page) { OrdersPage::Index.new }
  let(:expense_report) { ExpensesPage::Reports.new }

  given!(:red_lookup) { FactoryGirl.create(:lookup, name: 'Red', active: true) }
  given(:red_lookup_values_details) { [{name: "Red 100", external_ref_num: '100'}, {name: "Red 200", external_ref_num: '200'}, {name: "Red 300", external_ref_num: '300'}, {name: "Red 400", external_ref_num: '400'}] }

  given!(:red_lookup_values) do
    red_lookup_values_details.each_index do |i|
      FactoryGirl.create(:lookup_value, name: red_lookup_values_details[i][:name],lookup_id: red_lookup.id, external_ref_num:red_lookup_values_details[i][:external_ref_num])
    end
  end

  given!(:blue_lookup) { FactoryGirl.create(:lookup, name: 'Blue', active: true) }
  given!(:blue_lookup_values_details) { [{name: "Blue 100", external_ref_num: '100'}, {name: "Blue 200", external_ref_num: '200'}, {name: "Blue 300", external_ref_num: '300'}, {name: "Blue 400", external_ref_num: '400'}] }

  given!(:blue_lookup_values) do
    blue_lookup_values_details.each_index do |i|
      FactoryGirl.create(:lookup_value, name: blue_lookup_values_details[i][:name],lookup_id: blue_lookup.id, external_ref_num:blue_lookup_values_details[i][:external_ref_num])
    end
  end

  given!(:field_type1) { FactoryGirl.create :account_field_type, name: 'Seg 1' }
  given!(:field_type2) { FactoryGirl.create :account_field_type, name: 'Seg 2' }
  given!(:field_type3) { FactoryGirl.create :account_field_type, name: 'Seg 3' }
  given!(:coa_a) { FactoryGirl.create(:account_type, name: "COA A", segment_1_field_type_id: field_type1.id, segment_1_lookup_id: red_lookup.id, segment_2_field_type_id: field_type2.id, segment_2_lookup_id: red_lookup.id, segment_3_field_type_id: field_type3.id, segment_3_lookup_id: red_lookup.id, dynamic_flag: true) }
  #account group without segment rules
  # given!(:ag1) { FactoryGirl.create(:account_group, account_type_id: coa_a.id, name: "AG1", created_by_id: 1, updated_by_id: 1) }
  #account group with segment rules
  given!(:ag2) { FactoryGirl.create(:account_group, account_type_id: coa_a.id, name: "AG2", created_by_id: 1, updated_by_id: 1, segment_1_col: "", segment_1_op: "", segment_1_val: "", segment_2_col: "", segment_2_op: "eq", segment_2_val: "100", segment_3_col: "", segment_3_op: "", segment_3_val: "") }
  given!(:coa_b) { FactoryGirl.create(:account_type, name: "COA B", segment_1_field_type_id: field_type1.id, segment_1_lookup_id: blue_lookup.id, segment_2_field_type_id: field_type2.id, segment_2_lookup_id: blue_lookup.id, segment_3_field_type_id: field_type3.id, segment_3_lookup_id: blue_lookup.id, dynamic_flag: true) }
  #account group without segment rules
  # given!(:ag3) { FactoryGirl.create(:account_group, account_type_id: coa_b.id, name: "AG3", created_by_id: 1, updated_by_id: 1) }
  #account group with segment rules
  given!(:ag4) { FactoryGirl.create(:account_group, account_type_id: coa_b.id, name: "AG4", created_by_id: 1, updated_by_id: 1, segment_1_col: "", segment_1_op: "", segment_1_val: "", segment_2_col: "", segment_2_op: "", segment_2_val: "", segment_3_col: "", segment_3_op: "eq", segment_3_val: "100") }

  given!(:complete_billing_satisfies_ag2) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[1][:name]}-#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[2][:name]}", account_type_id: coa_a.id, segment_1: red_lookup_values_details[1][:external_ref_num], segment_2: red_lookup_values_details[0][:external_ref_num], segment_3: red_lookup_values_details[2][:external_ref_num], code: "#{red_lookup_values_details[1][:external_ref_num]}-#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[2][:external_ref_num]}", active: true) }
  given!(:complete_billing_not_satisfying_ag2) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[2][:name]}-#{red_lookup_values_details[2][:name]}-#{red_lookup_values_details[2][:name]}", account_type_id: coa_a.id, segment_1: red_lookup_values_details[2][:external_ref_num], segment_2: red_lookup_values_details[2][:external_ref_num], segment_3: red_lookup_values_details[2][:external_ref_num], code: "#{red_lookup_values_details[2][:external_ref_num]}-#{red_lookup_values_details[2][:external_ref_num]}-#{red_lookup_values_details[2][:external_ref_num]}", active: true) }
  given!(:complete_billing_one_line_not_satisfying_ag2) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[2][:name]}-#{red_lookup_values_details[2][:name]}", account_type_id: coa_a.id, segment_1: red_lookup_values_details[0][:external_ref_num], segment_2: red_lookup_values_details[2][:external_ref_num], segment_3: red_lookup_values_details[2][:external_ref_num], code: "#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[2][:external_ref_num]}-#{red_lookup_values_details[2][:external_ref_num]}", active: true) }
  given!(:complete_billing_one_line_satisfies_ag2) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[2][:name]}", account_type_id: coa_a.id, segment_1: red_lookup_values_details[0][:external_ref_num], segment_2: red_lookup_values_details[0][:external_ref_num], segment_3: red_lookup_values_details[2][:external_ref_num], code: "#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[2][:external_ref_num]}", active: true) }
  given!(:partial_billing_account_satisfies_AG2) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[3][:name]}-#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[2][:name]}", account_type_id: coa_a.id, segment_1: red_lookup_values_details[3][:external_ref_num], segment_2: red_lookup_values_details[0][:external_ref_num], segment_3: red_lookup_values_details[2][:external_ref_num], code: "#{red_lookup_values_details[3][:external_ref_num]}-#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[2][:external_ref_num]}", active: true) }
  given!(:partial_billing_account_not_satisfies_AG2) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[3][:name]}-#{red_lookup_values_details[2][:name]}-#{red_lookup_values_details[2][:name]}", account_type_id: coa_a.id, segment_1: red_lookup_values_details[3][:external_ref_num], segment_2: red_lookup_values_details[2][:external_ref_num], segment_3: red_lookup_values_details[2][:external_ref_num], code: "#{red_lookup_values_details[3][:external_ref_num]}-#{red_lookup_values_details[2][:external_ref_num]}-#{red_lookup_values_details[2][:external_ref_num]}", active: true) }
  given!(:partial_blank_billing_satisfies_ag2) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[1][:name]}-#{red_lookup_values_details[0][:name]}", account_type_id: coa_a.id, segment_1: red_lookup_values_details[1][:external_ref_num], segment_2: red_lookup_values_details[0][:external_ref_num], segment_3: " ", code: "#{red_lookup_values_details[1][:external_ref_num]}-#{red_lookup_values_details[0][:external_ref_num]}", active: true) }
  given!(:partial_blank_billing_not_satisfying_ag2) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[2][:name]}-#{red_lookup_values_details[2][:name]}", account_type_id: coa_a.id, segment_1: red_lookup_values_details[2][:external_ref_num], segment_2: red_lookup_values_details[2][:external_ref_num], segment_3: " ", code: "#{red_lookup_values_details[2][:external_ref_num]}-#{red_lookup_values_details[2][:external_ref_num]}", active: true) }

  given!(:document_creator) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Admin", login: "Document Creator", business_group_security_type: 0, account_security_type: 0) }

  #List of Users restricted to AGs belongs to COA A:
  # given!(:india_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "India User", business_group_security_type: 0, account_security_type: 2, account_groups: [ag1]) }
  given!(:us_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "US User", business_group_security_type: 0, account_security_type: 2, account_groups: [ag2]) }
  # given!(:japan_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "Japan User", business_group_security_type: 0, account_security_type: 2, account_groups: [ag1,ag2]) }

  #List of Users restricted to AGs belongs to COA B:
  # given!(:china_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "China User", business_group_security_type: 0, account_security_type: 2, account_groups: [ag3]) }
  given!(:austria_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "Austria User", business_group_security_type: 0, account_security_type: 2, account_groups: [ag4]) }
  # given!(:poland_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "Poland User", business_group_security_type: 0, account_security_type: 2, account_groups: [ag3, ag4]) }

  #List of Users restricted to AGs belongs to both COA A and COA B:
  # given!(:greek_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "Greek User", business_group_security_type: 0, account_security_type: 2, account_groups: [ag1,ag3]) }
  given!(:taiwan_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "Taiwan User", business_group_security_type: 0, account_security_type: 2, account_groups: [ag2, ag4]) }
  # given!(:french_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "French User", business_group_security_type: 0, account_security_type: 2, account_groups: [ag1,ag4]) }
  # given!(:spanish_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "Spanish User", business_group_security_type: 0, account_security_type: 2, account_groups: [ag2,ag3]) }

  #Users restricted to default chart of account
  given!(:fiji_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "Fiji User", business_group_security_type: 0, account_security_type: 1, default_account_type_id: coa_a.id) }
  given!(:colombia_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "Colombia User", business_group_security_type: 0, account_security_type: 1, default_account_type_id: coa_b.id) }

  given!(:supplier) { FactoryGirl.create(:supplier, name: "Test Supplier") }

  # document creator creates 3 invoices(new/pending/approved) with complete billing with satisfying the account group AG2'
  given!(:draft_inv_header_satisfies_AG2) { FactoryGirl.create(:invoice_header, status: "new", supplier_id: supplier.id, invoice_number: "draft_inv_satisfies_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id) }
  given!(:draft_inv_line_satisfies_AG2) { FactoryGirl.create(:invoice_quantity_line, invoice_header_id: draft_inv_header_satisfies_AG2.id, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: complete_billing_satisfies_ag2.id) }
  #pending
  given!(:pending_inv_satisfies_AG2) do
    FactoryGirl.create(
      :invoice_header, status: "pending_approval", supplier_id: supplier.id, invoice_number: "pending_inv_satisfies_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
      invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: complete_billing_satisfies_ag2.id)]
    )
  end
  #Approved
  given!(:approved_inv_satisfies_AG2) do
    FactoryGirl.create(
      :invoice_header, status: "approved", supplier_id: supplier.id, invoice_number: "approved_inv_satisfies_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
      invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: complete_billing_satisfies_ag2.id)]
    )
  end

  # document creator creates 3 invoices(new/pending/approved) with complete billing without satisfying the account group AG2'
  #draft/new
  given!(:draft_inv_header_not_satisfies_AG2) { FactoryGirl.create(:invoice_header, status: "new", supplier_id: supplier.id, invoice_number: "draft_inv_not_satisfies_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id) }
  given!(:draft_inv_line_not_satisfies_AG2) { FactoryGirl.create(:invoice_quantity_line, invoice_header_id: draft_inv_header_not_satisfies_AG2.id, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: complete_billing_not_satisfying_ag2.id) }
  #pending
  given!(:pending_inv_not_satisfies_AG2) do
    FactoryGirl.create(
      :invoice_header, status: "pending_approval", supplier_id: supplier.id, invoice_number: "pending_inv_not_satisfies_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
      invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: complete_billing_not_satisfying_ag2.id)]
    )
  end
  #Approved
  given!(:approved_inv_not_satisfies_AG2) do
    FactoryGirl.create(
      :invoice_header, status: "approved", supplier_id: supplier.id, invoice_number: "approved_inv_not_satisfies_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
      invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: complete_billing_not_satisfying_ag2.id)]
    )
  end

  # document creator creates 3 Invoice doc(with complete billing where one line satisfies AG2 and the other line does not satisfies the AG2
  #draft/new
  given!(:draft_inv_header_one_line_not_satisfies_AG2) { FactoryGirl.create(:invoice_header, status: "new", supplier_id: supplier.id, invoice_number: "draft_inv_one_line_not_satisfies_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id) }
  given!(:draft_inv_line1_satisfies_AG2) { FactoryGirl.create(:invoice_quantity_line, invoice_header_id: draft_inv_header_one_line_not_satisfies_AG2.id, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: complete_billing_one_line_satisfies_ag2.id) }
  given!(:draft_inv_line2_not_satisfies_AG2) { FactoryGirl.create(:invoice_quantity_line, invoice_header_id: draft_inv_header_one_line_not_satisfies_AG2.id, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: complete_billing_one_line_not_satisfying_ag2.id) }
  #pending
  given!(:pending_inv_one_line_not_satisfies_AG2) do
    FactoryGirl.create(
      :invoice_header, status: "pending_approval", supplier_id: supplier.id, invoice_number: "pending_inv_one_line_not_satisfies_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
      invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: complete_billing_one_line_satisfies_ag2.id), FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: complete_billing_one_line_not_satisfying_ag2.id)]
    )
  end
  #Approved
  given!(:approved_inv_one_line_not_satisfies_AG2) do
    FactoryGirl.create(
      :invoice_header, status: "approved", supplier_id: supplier.id, invoice_number: "approved_inv_one_line_not_satisfies_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
      invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: complete_billing_one_line_satisfies_ag2.id), FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: complete_billing_one_line_not_satisfying_ag2.id) ]
    )
  end

  # document creator creates 3 Invoice doc(with complete split billing) satisfies AG2
  #draft/new
  given!(:draft_inv_header_split_billing_satisfies_AG2) { FactoryGirl.create(:invoice_header, status: "new", supplier_id: supplier.id, invoice_number: "draft_inv_split_billing_satisfies_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id) }
  given!(:draft_inv_line1_split_billing_satisfies_AG2) { FactoryGirl.create(:invoice_quantity_line, invoice_header_id: draft_inv_header_split_billing_satisfies_AG2.id, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_type: coa_a) }
  given!(:draft_inv_allocations1) do
    FactoryGirl.create(:invoice_line_allocation, invoice_line: draft_inv_line1_split_billing_satisfies_AG2, pct: 50, account: complete_billing_satisfies_ag2)
    FactoryGirl.create(:invoice_line_allocation, invoice_line: draft_inv_line1_split_billing_satisfies_AG2, pct: 50, account: complete_billing_one_line_satisfies_ag2)
    draft_inv_header_split_billing_satisfies_AG2.reload
  end
  #pending
  given!(:pending_inv_split_billing_satisfies_AG2) do
    FactoryGirl.create(
      :invoice_header, status: "pending_approval", supplier_id: supplier.id, invoice_number: "pending_inv_split_billing_satisfies_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
      invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_type: coa_a)]
    )
  end
  given!(:pending_inv_allocations1) do
    FactoryGirl.create(:invoice_line_allocation, invoice_line: pending_inv_split_billing_satisfies_AG2.invoice_lines[0], pct: 50, account: complete_billing_satisfies_ag2)
    FactoryGirl.create(:invoice_line_allocation, invoice_line: pending_inv_split_billing_satisfies_AG2.invoice_lines[0], pct: 50, account: complete_billing_one_line_satisfies_ag2)
    pending_inv_split_billing_satisfies_AG2.reload
  end
  #Approved
  given!(:approved_inv_split_billing_satisfies_AG2) do
    FactoryGirl.create(
      :invoice_header, status: "approved", supplier_id: supplier.id, invoice_number: "approved_inv_split_billing_satisfies_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
      invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_type: coa_a)]
    )
  end
  given!(:approved_inv_allocations1) do
    FactoryGirl.create(:invoice_line_allocation, invoice_line: approved_inv_split_billing_satisfies_AG2.invoice_lines[0], pct: 50, account: complete_billing_satisfies_ag2)
    FactoryGirl.create(:invoice_line_allocation, invoice_line: approved_inv_split_billing_satisfies_AG2.invoice_lines[0], pct: 50, account: complete_billing_one_line_satisfies_ag2)
    approved_inv_split_billing_satisfies_AG2.reload
  end

  # document creator creates 3 Invoice doc(with complete split billing) not satisfies AG2
  #draft/new
  given!(:draft_inv_header_split_billing_not_satisfies_AG2) { FactoryGirl.create(:invoice_header, status: "new", supplier_id: supplier.id, invoice_number: "draft_inv_split_bill_not_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id) }
  given!(:draft_inv_line1_split_billing_not_satisfies_AG2) { FactoryGirl.create(:invoice_quantity_line, invoice_header_id: draft_inv_header_split_billing_not_satisfies_AG2.id, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_type: coa_a) }
  given!(:draft_inv_allocations2) do
    FactoryGirl.create(:invoice_line_allocation, invoice_line: draft_inv_line1_split_billing_not_satisfies_AG2, pct: 50, account: complete_billing_not_satisfying_ag2)
    FactoryGirl.create(:invoice_line_allocation, invoice_line: draft_inv_line1_split_billing_not_satisfies_AG2, pct: 50, account: complete_billing_one_line_not_satisfying_ag2)
    draft_inv_header_split_billing_not_satisfies_AG2.reload
  end
  #pending
  given!(:pending_inv_split_billing_not_satisfies_AG2) do
    FactoryGirl.create(
      :invoice_header, status: "pending_approval", supplier_id: supplier.id, invoice_number: "pend_inv_split_bill_not_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
      invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_type: coa_a)]
    )
  end
  given!(:pending_inv_allocations3) do
    FactoryGirl.create(:invoice_line_allocation, invoice_line: pending_inv_split_billing_not_satisfies_AG2.invoice_lines[0], pct: 50, account: complete_billing_not_satisfying_ag2)
    FactoryGirl.create(:invoice_line_allocation, invoice_line: pending_inv_split_billing_not_satisfies_AG2.invoice_lines[0], pct: 50, account: complete_billing_one_line_not_satisfying_ag2)
    pending_inv_split_billing_not_satisfies_AG2.reload
  end
  #Approved
  given!(:approved_inv_split_billing_not_satisfies_AG2) do
    FactoryGirl.create(
      :invoice_header, status: "approved", supplier_id: supplier.id, invoice_number: "app_inv_split_bill_not_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
      invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_type: coa_a)]
    )
  end
  given!(:approved_inv_allocations2) do
    FactoryGirl.create(:invoice_line_allocation, invoice_line: approved_inv_split_billing_not_satisfies_AG2.invoice_lines[0], pct: 50, account: complete_billing_not_satisfying_ag2)
    FactoryGirl.create(:invoice_line_allocation, invoice_line: approved_inv_split_billing_not_satisfies_AG2.invoice_lines[0], pct: 50, account: complete_billing_one_line_not_satisfying_ag2)
    approved_inv_split_billing_not_satisfies_AG2.reload
  end

  # document creator creates 3 invoices(new/pending/approved) with partial(by inactivating the lookup value) billing with satisfying the account group AG2'
  given!(:draft_partial_inv_header_satisfies_AG2) { FactoryGirl.create(:invoice_header, status: "new", supplier_id: supplier.id, invoice_number: "draft_partial_inv_satisfies_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id) }
  given!(:draft_partial_inv_line_satisfies_AG2) { FactoryGirl.create(:invoice_quantity_line, invoice_header_id: draft_partial_inv_header_satisfies_AG2.id, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: partial_billing_account_satisfies_AG2.id) }
  #pending
  given!(:pending_partial_inv_satisfies_AG2) do
    FactoryGirl.create(
      :invoice_header, status: "pending_approval", supplier_id: supplier.id, invoice_number: "pending_partial_inv_satisfies_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
      invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: partial_billing_account_satisfies_AG2.id)]
    )
  end
  #Approved
  given!(:approved_partial_inv_satisfies_AG2) do
    FactoryGirl.create(
      :invoice_header, status: "approved", supplier_id: supplier.id, invoice_number: "approved_partial_inv_satisfies_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
      invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: partial_billing_account_satisfies_AG2.id)]
    )
  end

  # document creator creates 3 invoices(new/pending/approved) with partial(by inactivating the lookup value) billing without satisfying the account group AG2'
  given!(:draft_partial_inv_header_not_satisfies_AG2) { FactoryGirl.create(:invoice_header, status: "new", supplier_id: supplier.id, invoice_number: "draft_partial_inv_not_satisfies_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id) }
  given!(:draft_partial_inv_line_not_satisfies_AG2) { FactoryGirl.create(:invoice_quantity_line, invoice_header_id: draft_partial_inv_header_not_satisfies_AG2.id, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: partial_billing_account_not_satisfies_AG2.id) }
  #pending
  given!(:pending_partial_inv_not_satisfies_AG2) do
    FactoryGirl.create(
      :invoice_header, status: "pending_approval", supplier_id: supplier.id, invoice_number: "pending_partial_inv_not_satisfies_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
      invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: partial_billing_account_not_satisfies_AG2.id)]
    )
  end
  #Approved
  given!(:approved_partial_inv_not_satisfies_AG2) do
    FactoryGirl.create(
      :invoice_header, status: "approved", supplier_id: supplier.id, invoice_number: "approved_partial_inv_not_satisfies_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
      invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: partial_billing_account_not_satisfies_AG2.id)]
    )
  end

  # document creator creates 3 invoices(new/pending/approved) with partial(by left one segment as blank) billing with satisfying the account group AG2'
  given!(:draft_partial_blank_inv_header_satisfies_AG2) { FactoryGirl.create(:invoice_header, status: "new", supplier_id: supplier.id, invoice_number: "draft_partial_blank_inv_satisfies_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id) }
  given!(:draft_partial_blank_inv_line_satisfies_AG2) { FactoryGirl.create(:invoice_quantity_line, invoice_header_id: draft_partial_blank_inv_header_satisfies_AG2.id, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: partial_blank_billing_satisfies_ag2.id) }
  #pending
  given!(:pending_partial_blank_inv_satisfies_AG2) do
    FactoryGirl.create(
      :invoice_header, status: "pending_approval", supplier_id: supplier.id, invoice_number: "pend_partial_blank_inv_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
      invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: partial_blank_billing_satisfies_ag2.id)]
    )
  end
  #Approved
  given!(:approved_partial_blank_inv_satisfies_AG2) do
    FactoryGirl.create(
      :invoice_header, status: "approved", supplier_id: supplier.id, invoice_number: "app_partial_blank_inv_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
      invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: partial_blank_billing_satisfies_ag2.id)]
    )
  end

  # document creator creates 3 invoices(new/pending/approved) with partial(by left one segment as blank) billing without satisfying the account group AG2'
  given!(:draft_partial_blank_inv_header_not_satisfies_AG2) { FactoryGirl.create(:invoice_header, status: "new", supplier_id: supplier.id, invoice_number: "dft_partl_blank_inv_not_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id) }
  given!(:draft_partial_blank_inv_line_not_satisfies_AG2) { FactoryGirl.create(:invoice_quantity_line, invoice_header_id: draft_partial_blank_inv_header_not_satisfies_AG2.id, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: partial_blank_billing_not_satisfying_ag2.id) }
  #pending
  given!(:pending_partial_blank_inv_not_satisfies_AG2) do
    FactoryGirl.create(
      :invoice_header, status: "pending_approval", supplier_id: supplier.id, invoice_number: "pend_partl_blank_inv_not_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
      invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: partial_blank_billing_not_satisfying_ag2.id)]
    )
  end
  #Approved
  given!(:approved_partial_blank_inv_not_satisfies_AG2) do
    FactoryGirl.create(
      :invoice_header, status: "approved", supplier_id: supplier.id, invoice_number: "app_partl_blank_inv_not_satisfying_AG2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id,
      invoice_lines: [FactoryGirl.create(:invoice_quantity_line, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1, account_id: partial_blank_billing_not_satisfying_ag2.id)]
    )
  end

  # document creator creates an invoice with incomplete billing
  given!(:draft_incomplete_billing_inv_header) { FactoryGirl.create(:invoice_header, status: "new", supplier_id: supplier.id, invoice_number: "draft_incomplete_billing_inv2", currency_id: 1, created_by_id: document_creator.id, updated_by_id: document_creator.id, account_type_id: coa_a.id) }
  given!(:draft_incomplete_billing_inv_line) do
    line = FactoryGirl.create(:invoice_quantity_line, invoice_header_id: draft_incomplete_billing_inv_header.id, description: "dhgqejhg", uom_id: 1, quantity: 12.0, price: 10.0, currency_id: 1)
    line.account=nil
    line.save(validate:false)
    draft_incomplete_billing_inv_header.reload
  end
  scenario 'Invoice doc(with complete/incomplete/partial billing) access based on account group restriction for the users (Us User, Taiwan User)' do
    [us_user, taiwan_user].each do |user|
      lookup_value = LookupValue.find_by(name: red_lookup_values_details[3][:name])
      lookup_value.update(active: false)
      login_as user.login
      #### us user and taiwan user can see only the invoice with billing string which satisfies AG2 on the invoice Header ####
      invoice_index.load
      invoice_index.per_page_45.click
      # invoices(new/pending/approved) with complete billing with satisfying the account group AG2
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_content draft_inv_header_satisfies_AG2.invoice_number
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_content pending_inv_satisfies_AG2.invoice_number
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_content approved_inv_satisfies_AG2.invoice_number
      # Invoice doc(with complete billing where one line satisfies AG2 and the other line does not satisfies the AG2
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_content draft_inv_header_one_line_not_satisfies_AG2.invoice_number
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_content pending_inv_one_line_not_satisfies_AG2.invoice_number
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_content approved_inv_one_line_not_satisfies_AG2.invoice_number
      # invoices(new/pending/approved) with complete billing without satisfying the account group AG2
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content draft_inv_header_not_satisfies_AG2.invoice_number
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content pending_inv_not_satisfies_AG2.invoice_number
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content approved_inv_not_satisfies_AG2.invoice_number
      # Invoice doc(with complete split billing) satisfies AG2
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_content draft_inv_header_split_billing_satisfies_AG2.invoice_number
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_content pending_inv_split_billing_satisfies_AG2.invoice_number
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_content approved_inv_split_billing_satisfies_AG2.invoice_number
      # Invoice doc(with complete split billing) not satisfies AG2
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content draft_inv_header_split_billing_not_satisfies_AG2.invoice_number
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content pending_inv_split_billing_not_satisfies_AG2.invoice_number
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content approved_inv_split_billing_not_satisfies_AG2.invoice_number
      # Invoices(new/pending/approved) with partial(by left one segment as blank) billing with satisfying the account group AG2
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_content draft_partial_blank_inv_header_satisfies_AG2.invoice_number
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_content pending_partial_blank_inv_satisfies_AG2.invoice_number
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_content approved_partial_blank_inv_satisfies_AG2.invoice_number

      # Invoices(new/pending/approved) with partial(by left one segment as blank) billing without satisfying the account group AG2'
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content draft_partial_blank_inv_header_not_satisfies_AG2.invoice_number
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content pending_partial_blank_inv_not_satisfies_AG2.invoice_number
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content approved_partial_blank_inv_not_satisfies_AG2.invoice_number

      # invoices(new/pending/approved) with partial(by inactivating the lookup value) billing with satisfying the account group AG2'
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_content draft_partial_inv_header_satisfies_AG2.invoice_number
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_content pending_partial_inv_satisfies_AG2.invoice_number
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_content approved_partial_inv_satisfies_AG2.invoice_number

      # invoices(new/pending/approved) with partial(by inactivating the lookup value) billing without satisfying the account group AG2'
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content draft_partial_inv_header_not_satisfies_AG2.invoice_number
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content pending_partial_inv_not_satisfies_AG2.invoice_number
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content approved_partial_inv_not_satisfies_AG2.invoice_number

      # Invoice with incomplete billing
      expect(get_data_from_column(invoice_index, "Invoice #")).to have_content draft_incomplete_billing_inv_header.invoice_number

      #### us user and taiwan user can see only the invoice lines with billing string which satisfies AG2 on the invoice lines table ####
      invoice_line.load
      invoice_line.per_page_45.click
      # invoices(new/pending/approved) with complete billing with satisfying the account group AG2
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",draft_inv_header_satisfies_AG2.invoice_number, "Line #")).to have_content draft_inv_line_satisfies_AG2.line_num
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",pending_inv_satisfies_AG2.invoice_number, "Line #")).to have_content pending_inv_satisfies_AG2.invoice_lines[0].line_num
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",approved_inv_satisfies_AG2.invoice_number, "Line #")).to have_content approved_inv_satisfies_AG2.invoice_lines[0].line_num

      # Invoice doc(with complete billing where one line satisfies AG2 and the other line does not satisfies the AG2
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",draft_inv_header_one_line_not_satisfies_AG2.invoice_number, "Line #")).to have_content draft_inv_line1_satisfies_AG2.line_num
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",draft_inv_header_one_line_not_satisfies_AG2.invoice_number, "Line #")).to have_no_content draft_inv_line2_not_satisfies_AG2.line_num
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",pending_inv_one_line_not_satisfies_AG2.invoice_number, "Line #")).to have_content pending_inv_one_line_not_satisfies_AG2.invoice_lines[0].line_num
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",pending_inv_one_line_not_satisfies_AG2.invoice_number, "Line #")).to have_no_content pending_inv_one_line_not_satisfies_AG2.invoice_lines[1].line_num
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",approved_inv_one_line_not_satisfies_AG2.invoice_number, "Line #")).to have_content approved_inv_one_line_not_satisfies_AG2.invoice_lines[0].line_num
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",approved_inv_one_line_not_satisfies_AG2.invoice_number, "Line #")).to have_no_content approved_inv_one_line_not_satisfies_AG2.invoice_lines[1].line_num

      # invoices(new/pending/approved) with complete billing without satisfying the account group AG2
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",draft_inv_header_not_satisfies_AG2.invoice_number, "Line #")).to have_no_content draft_inv_line_not_satisfies_AG2.line_num
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",pending_inv_not_satisfies_AG2.invoice_number, "Line #")).to have_no_content pending_inv_not_satisfies_AG2.invoice_lines[0].line_num
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",approved_inv_not_satisfies_AG2.invoice_number, "Line #")).to have_no_content approved_inv_not_satisfies_AG2.invoice_lines[0].line_num

      # Invoice doc(with complete split billing) satisfies AG2
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",draft_inv_header_split_billing_satisfies_AG2.invoice_number, "Line #")).to have_content draft_inv_line1_split_billing_satisfies_AG2.line_num
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",pending_inv_split_billing_satisfies_AG2.invoice_number, "Line #")).to have_content pending_inv_split_billing_satisfies_AG2.invoice_lines[0].line_num
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",approved_inv_split_billing_satisfies_AG2.invoice_number, "Line #")).to have_content approved_inv_split_billing_satisfies_AG2.invoice_lines[0].line_num

      # Invoice doc(with complete split billing) not satisfies AG2
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",draft_inv_header_split_billing_not_satisfies_AG2.invoice_number, "Line #")).to have_no_content draft_inv_line1_split_billing_not_satisfies_AG2.line_num
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",pending_inv_split_billing_not_satisfies_AG2.invoice_number, "Line #")).to have_no_content pending_inv_split_billing_not_satisfies_AG2.invoice_lines[0].line_num
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",approved_inv_split_billing_not_satisfies_AG2.invoice_number, "Line #")).to have_no_content approved_inv_split_billing_not_satisfies_AG2.invoice_lines[0].line_num

      # Invoices(new/pending/approved) with partial(by left one segment as blank) billing with satisfying the account group AG2
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",draft_partial_blank_inv_header_satisfies_AG2.invoice_number, "Line #")).to have_content draft_partial_blank_inv_line_satisfies_AG2.line_num
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",pending_partial_blank_inv_satisfies_AG2.invoice_number, "Line #")).to have_content pending_partial_blank_inv_satisfies_AG2.invoice_lines[0].line_num
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",approved_partial_blank_inv_satisfies_AG2.invoice_number, "Line #")).to have_content approved_partial_blank_inv_satisfies_AG2.invoice_lines[0].line_num

      # Invoices(new/pending/approved) with partial(by left one segment as blank) billing without satisfying the account group AG2'
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",draft_partial_blank_inv_header_not_satisfies_AG2.invoice_number, "Line #")).to have_no_content draft_partial_blank_inv_line_not_satisfies_AG2.line_num
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",pending_partial_blank_inv_not_satisfies_AG2.invoice_number, "Line #")).to have_no_content pending_partial_blank_inv_not_satisfies_AG2.invoice_lines[0].line_num
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",approved_partial_blank_inv_not_satisfies_AG2.invoice_number, "Line #")).to have_no_content approved_partial_blank_inv_not_satisfies_AG2.invoice_lines[0].line_num

      # invoices(new/pending/approved) with partial(by inactivating the lookup value) billing with satisfying the account group AG2'
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",draft_partial_inv_header_satisfies_AG2.invoice_number, "Line #")).to have_content draft_partial_inv_line_satisfies_AG2.line_num
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",pending_partial_inv_satisfies_AG2.invoice_number, "Line #")).to have_content pending_partial_inv_satisfies_AG2.invoice_lines[0].line_num
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",approved_partial_inv_satisfies_AG2.invoice_number, "Line #")).to have_content approved_partial_inv_satisfies_AG2.invoice_lines[0].line_num

      # invoices(new/pending/approved) with partial(by inactivating the lookup value) billing without satisfying the account group AG2
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",draft_partial_inv_header_not_satisfies_AG2.invoice_number, "Line #")).to have_no_content draft_partial_inv_line_not_satisfies_AG2.line_num
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",pending_partial_inv_not_satisfies_AG2.invoice_number, "Line #")).to have_no_content pending_partial_inv_not_satisfies_AG2.invoice_lines[0].line_num
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",approved_partial_inv_not_satisfies_AG2.invoice_number, "Line #")).to have_no_content approved_partial_inv_not_satisfies_AG2.invoice_lines[0].line_num

      # Invoice with incomplete billing
      expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",draft_incomplete_billing_inv_header.invoice_number, "Line #")).to have_content draft_incomplete_billing_inv_header.invoice_lines[0].line_num
    end
  end

  scenario 'Invoice doc(with complete/incomplete/partial billing) access based on account group restriction for the Austria User' do
    login_as austria_user.login
    lookup_value = LookupValue.find_by(name: red_lookup_values_details[3][:name])
    lookup_value.update(active: false)
    invoice_index.load
    invoice_index.per_page_45.click
    #### Austria User cannot see the invoices belongs to AG2 ####
    # invoices(new/pending/approved) with complete billing with satisfying the account group AG2
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content draft_inv_header_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content pending_inv_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content approved_inv_satisfies_AG2.invoice_number
    # Invoice doc(with complete billing where one line satisfies AG2 and the other line does not satisfies the AG2
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content draft_inv_header_one_line_not_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content pending_inv_one_line_not_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content approved_inv_one_line_not_satisfies_AG2.invoice_number
    # invoices(new/pending/approved) with complete billing without satisfying the account group AG2
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content draft_inv_header_not_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content pending_inv_not_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content approved_inv_not_satisfies_AG2.invoice_number
    # Invoice doc(with complete split billing) satisfies AG2
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content draft_inv_header_split_billing_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content pending_inv_split_billing_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content approved_inv_split_billing_satisfies_AG2.invoice_number
    # Invoice doc(with complete split billing) not satisfies AG2
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content draft_inv_header_split_billing_not_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content pending_inv_split_billing_not_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content approved_inv_split_billing_not_satisfies_AG2.invoice_number
    # Invoices(new/pending/approved) with partial(by left one segment as blank) billing with satisfying the account group AG2
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content draft_partial_blank_inv_header_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content pending_partial_blank_inv_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content approved_partial_blank_inv_satisfies_AG2.invoice_number

    # Invoices(new/pending/approved) with partial(by left one segment as blank) billing without satisfying the account group AG2'
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content draft_partial_blank_inv_header_not_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content pending_partial_blank_inv_not_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content approved_partial_blank_inv_not_satisfies_AG2.invoice_number

    # invoices(new/pending/approved) with partial(by inactivating the lookup value) billing with satisfying the account group AG2'
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content draft_partial_inv_header_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content pending_partial_inv_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content approved_partial_inv_satisfies_AG2.invoice_number

    # invoices(new/pending/approved) with partial(by inactivating the lookup value) billing without satisfying the account group AG2'
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content draft_partial_inv_header_not_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content pending_partial_inv_not_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_no_content approved_partial_inv_not_satisfies_AG2.invoice_number

    # Invoice with incomplete billing
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content draft_incomplete_billing_inv_header.invoice_number

    #### Austria User cannot see any invoice lines belongs to AG2 ####
    invoice_line.load
    expect(invoice_line.data_table.lines.count).to eq 1
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",draft_incomplete_billing_inv_header.invoice_number, "Line #")).to have_content draft_incomplete_billing_inv_header.invoice_lines[0].line_num
  end

  scenario 'Invoice doc(with complete/incomplete/partial billing) access based on account group restriction for the Fiji User' do
    login_as fiji_user.login
    lookup_value = LookupValue.find_by(name: red_lookup_values_details[3][:name])
    lookup_value.update(active: false)
    #### fiji User see the invoices belongs to COA A. ####
    invoice_index.load
    invoice_index.per_page_90.click
    # invoices(new/pending/approved) with complete billing with satisfying the account group AG2
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content draft_inv_header_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content pending_inv_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content approved_inv_satisfies_AG2.invoice_number

    # Invoice doc(with complete billing where one line satisfies AG2 and the other line does not satisfies the AG2
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content draft_inv_header_one_line_not_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content pending_inv_one_line_not_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content approved_inv_one_line_not_satisfies_AG2.invoice_number

    # invoices(new/pending/approved) with complete billing without satisfying the account group AG2
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content draft_inv_header_not_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content pending_inv_not_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content approved_inv_not_satisfies_AG2.invoice_number

    # Invoice doc(with complete split billing) satisfies AG2
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content draft_inv_header_split_billing_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content pending_inv_split_billing_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content approved_inv_split_billing_satisfies_AG2.invoice_number

    # Invoice doc(with complete split billing) not satisfies AG2
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content draft_inv_header_split_billing_not_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content pending_inv_split_billing_not_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content approved_inv_split_billing_not_satisfies_AG2.invoice_number

    # Invoices(new/pending/approved) with partial(by left one segment as blank) billing with satisfying the account group AG2
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content draft_partial_blank_inv_header_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content pending_partial_blank_inv_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content approved_partial_blank_inv_satisfies_AG2.invoice_number

    # Invoices(new/pending/approved) with partial(by left one segment as blank) billing without satisfying the account group AG2'
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content draft_partial_blank_inv_header_not_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content pending_partial_blank_inv_not_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content approved_partial_blank_inv_not_satisfies_AG2.invoice_number

    # invoices(new/pending/approved) with partial(by inactivating the lookup value) billing with satisfying the account group AG2'
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content draft_partial_inv_header_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content pending_partial_inv_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content approved_partial_inv_satisfies_AG2.invoice_number

    # invoices(new/pending/approved) with partial(by inactivating the lookup value) billing without satisfying the account group AG2'
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content draft_partial_inv_header_not_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content pending_partial_inv_not_satisfies_AG2.invoice_number
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content approved_partial_inv_not_satisfies_AG2.invoice_number

    # Invoice with incomplete billing
    expect(get_data_from_column(invoice_index, "Invoice #")).to have_content draft_incomplete_billing_inv_header.invoice_number

    #### fiji User see the invoice lines belongs to COA A. ####
    invoice_line.load
    invoice_line.per_page_90.click
    # invoices(new/pending/approved) with complete billing with satisfying the account group AG2
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",draft_inv_header_satisfies_AG2.invoice_number, "Line #")).to have_content draft_inv_line_satisfies_AG2.line_num
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",pending_inv_satisfies_AG2.invoice_number, "Line #")).to have_content pending_inv_satisfies_AG2.invoice_lines[0].line_num
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",approved_inv_satisfies_AG2.invoice_number, "Line #")).to have_content approved_inv_satisfies_AG2.invoice_lines[0].line_num

    # Invoice doc(with complete billing where one line satisfies AG2 and the other line does not satisfies the AG2
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",draft_inv_header_one_line_not_satisfies_AG2.invoice_number, "Line #")).to have_content draft_inv_line1_satisfies_AG2.line_num
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",draft_inv_header_one_line_not_satisfies_AG2.invoice_number, "Line #")).to have_content draft_inv_line2_not_satisfies_AG2.line_num
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",pending_inv_one_line_not_satisfies_AG2.invoice_number, "Line #")).to have_content pending_inv_one_line_not_satisfies_AG2.invoice_lines[0].line_num
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",pending_inv_one_line_not_satisfies_AG2.invoice_number, "Line #")).to have_content pending_inv_one_line_not_satisfies_AG2.invoice_lines[1].line_num
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",approved_inv_one_line_not_satisfies_AG2.invoice_number, "Line #")).to have_content approved_inv_one_line_not_satisfies_AG2.invoice_lines[0].line_num
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",approved_inv_one_line_not_satisfies_AG2.invoice_number, "Line #")).to have_content approved_inv_one_line_not_satisfies_AG2.invoice_lines[1].line_num

    # invoices(new/pending/approved) with complete billing without satisfying the account group AG2
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",draft_inv_header_not_satisfies_AG2.invoice_number, "Line #")).to have_content draft_inv_line_not_satisfies_AG2.line_num
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",pending_inv_not_satisfies_AG2.invoice_number, "Line #")).to have_content pending_inv_not_satisfies_AG2.invoice_lines[0].line_num
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",approved_inv_not_satisfies_AG2.invoice_number, "Line #")).to have_content approved_inv_not_satisfies_AG2.invoice_lines[0].line_num

    # Invoice doc(with complete split billing) satisfies AG2
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",draft_inv_header_split_billing_satisfies_AG2.invoice_number, "Line #")).to have_content draft_inv_line1_split_billing_satisfies_AG2.line_num
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",pending_inv_split_billing_satisfies_AG2.invoice_number, "Line #")).to have_content pending_inv_split_billing_satisfies_AG2.invoice_lines[0].line_num
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",approved_inv_split_billing_satisfies_AG2.invoice_number, "Line #")).to have_content approved_inv_split_billing_satisfies_AG2.invoice_lines[0].line_num

    # Invoice doc(with complete split billing) not satisfies AG2
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",draft_inv_header_split_billing_not_satisfies_AG2.invoice_number, "Line #")).to have_content draft_inv_line1_split_billing_not_satisfies_AG2.line_num
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",pending_inv_split_billing_not_satisfies_AG2.invoice_number, "Line #")).to have_content pending_inv_split_billing_not_satisfies_AG2.invoice_lines[0].line_num
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",approved_inv_split_billing_not_satisfies_AG2.invoice_number, "Line #")).to have_content approved_inv_split_billing_not_satisfies_AG2.invoice_lines[0].line_num

    # Invoices(new/pending/approved) with partial(by left one segment as blank) billing with satisfying the account group AG2
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",draft_partial_blank_inv_header_satisfies_AG2.invoice_number, "Line #")).to have_content draft_partial_blank_inv_line_satisfies_AG2.line_num
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",pending_partial_blank_inv_satisfies_AG2.invoice_number, "Line #")).to have_content pending_partial_blank_inv_satisfies_AG2.invoice_lines[0].line_num
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",approved_partial_blank_inv_satisfies_AG2.invoice_number, "Line #")).to have_content approved_partial_blank_inv_satisfies_AG2.invoice_lines[0].line_num

    # Invoices(new/pending/approved) with partial(by left one segment as blank) billing without satisfying the account group AG2'
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",draft_partial_blank_inv_header_not_satisfies_AG2.invoice_number, "Line #")).to have_content draft_partial_blank_inv_line_not_satisfies_AG2.line_num
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",pending_partial_blank_inv_not_satisfies_AG2.invoice_number, "Line #")).to have_content pending_partial_blank_inv_not_satisfies_AG2.invoice_lines[0].line_num
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",approved_partial_blank_inv_not_satisfies_AG2.invoice_number, "Line #")).to have_content approved_partial_blank_inv_not_satisfies_AG2.invoice_lines[0].line_num

    # invoices(new/pending/approved) with partial(by inactivating the lookup value) billing with satisfying the account group AG2'
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",draft_partial_inv_header_satisfies_AG2.invoice_number, "Line #")).to have_content draft_partial_inv_line_satisfies_AG2.line_num
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",pending_partial_inv_satisfies_AG2.invoice_number, "Line #")).to have_content pending_partial_inv_satisfies_AG2.invoice_lines[0].line_num
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",approved_partial_inv_satisfies_AG2.invoice_number, "Line #")).to have_content approved_partial_inv_satisfies_AG2.invoice_lines[0].line_num

    # invoices(new/pending/approved) with partial(by inactivating the lookup value) billing without satisfying the account group AG2
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",draft_partial_inv_header_not_satisfies_AG2.invoice_number, "Line #")).to have_content draft_partial_inv_line_not_satisfies_AG2.line_num
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",pending_partial_inv_not_satisfies_AG2.invoice_number, "Line #")).to have_content pending_partial_inv_not_satisfies_AG2.invoice_lines[0].line_num
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",approved_partial_inv_not_satisfies_AG2.invoice_number, "Line #")).to have_content approved_partial_inv_not_satisfies_AG2.invoice_lines[0].line_num

    # Invoice with incomplete billing
    expect(get_data_from_column_by_comparing_rows(invoice_line, "Invoice #",draft_incomplete_billing_inv_header.invoice_number, "Line #")).to have_content draft_incomplete_billing_inv_header.invoice_lines[0].line_num
  end

  scenario 'Invoice doc(with complete/incomplete/partial billing) access based on account group restriction for the Colombia User' do
    login_as colombia_user.login
    lookup_value = LookupValue.find_by(name: red_lookup_values_details[3][:name])
    lookup_value.update(active: false)
    #### colombia User cannot see the invoices belongs to COA A ####
    invoice_index.load
    expect(invoice_index.data_table).to have_content "No rows."
    #### colombia User cannot see any invoice lines belongs to COA A ####
    invoice_line.load
    expect(invoice_line.data_table).to have_content "No rows."
  end

  def get_data_from_column(page, header_name)
    index = page.data_table.headers.map(&:text).index(header_name)
    page.data_table.lines.map{ |line| line.columns[index].text }
  end

  def get_data_from_column_by_comparing_rows(page, header_name1,invoice_num, header_name2)
    line_num = []
    index1 = invoice_line.data_table.headers.map(&:text).index(header_name1)
    invoice_numbers = invoice_line.data_table.lines.map{ |line| line.columns[index1].text }
    invoice_number_indexes = invoice_numbers.each_index.select{ |i| invoice_numbers[i] == invoice_num }
    index2 = invoice_line.data_table.headers.map(&:text).index(header_name2)
    invoice_number_indexes.each do |line_index|
      line_num << invoice_line.data_table.lines[line_index].columns[index2].text
    end
    line_num
  end
end
