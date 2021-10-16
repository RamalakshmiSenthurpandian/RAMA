require 'spec_helper'
RSpec.feature 'CD-251620: lookupvalues and account restrcition while creating documents', type: :feature, js: true, accounts: true, account_security: true do
  include SessionHelper
  include SharedHelper
  include ExpenseLiteHelper
  context '' do
    let(:expense_home) { ExpensesPage::Home.new }

    given!(:commodity_cf) { FactoryGirl.create(:custom_field_attribute_string, model: "commodity", type: "CustomFieldAttributeString", col_name: "custom_field_1", field_name: "account2", prompt: "Account2", position: 1, created_by_id: admin.id, updated_by_id: admin.id ) }
    given!(:commodity) { FactoryGirl.create(:commodity, custom_field_1: 200)}
    given!(:expense_category) { FactoryGirl.create(:expense_category) }

    given!(:field_type1) { FactoryGirl.create :account_field_type, name: 'Seg 1' }
    given!(:field_type2) { FactoryGirl.create :account_field_type, name: 'Seg 2' }
    given!(:field_type3) { FactoryGirl.create :account_field_type, name: 'Seg 3' }
    given!(:field_type4) { FactoryGirl.create :account_field_type, name: 'Seg 4' }
    given!(:field_type5) { FactoryGirl.create :account_field_type, name: 'Seg 5' }

    given!(:red_lookup) { FactoryGirl.create(:lookup, name: 'Red', active: true) }
    given!(:blue_lookup) { FactoryGirl.create(:lookup, name: 'Blue', active: true) }
    given!(:green_lookup) { FactoryGirl.create(:lookup, name: 'Green', active: true) }

    given!(:chennai_coa) { FactoryGirl.create(:account_type, name: "Chennai_COA", segment_1_field_type_id: field_type1.id, segment_1_lookup_id: red_lookup.id, segment_2_field_type_id: field_type2.id, segment_2_lookup_id: red_lookup.id, segment_3_field_type_id: field_type3.id, segment_3_lookup_id: red_lookup.id, segment_3_model: "commodity", segment_3_column: "custom_field_1", dynamic_flag: true) }
    given!(:pune_coa) { FactoryGirl.create(:account_type, name: "Pune_COA", segment_1_field_type_id: field_type1.id, segment_1_lookup_id: red_lookup.id, segment_2_field_type_id: field_type2.id, segment_2_lookup_id: red_lookup.id, segment_3_field_type_id: field_type3.id, segment_3_lookup_id: red_lookup.id, dynamic_flag: true) }
    given!(:delhi_coa) { FactoryGirl.create(:account_type, :with_locked_segments, segment_values_at: [3, 5], name: "Delhi_COA", segment_1_field_type_id: field_type1.id, segment_1_lookup_id: blue_lookup.id, segment_2_field_type_id: field_type2.id, segment_2_lookup_id: green_lookup.id, segment_3_field_type_id: field_type3.id, segment_3_lookup_id: blue_lookup.id, segment_3_required: true, segment_3_lookup_level: 1, segment_3_parent: 1, segment_3_model: "commodity", segment_3_column: "custom_field_1", segment_4_field_type_id: field_type4.id, segment_4_lookup_id: green_lookup.id, segment_4_lookup_level: 1, segment_4_parent: 2, segment_5_field_type_id: field_type5.id, segment_5_lookup_id: red_lookup.id, segment_5_required: true, dynamic_flag: true) }
    given!(:qatar_coa) { FactoryGirl.create(:account_type, :with_locked_segments, segment_values_at: [1,2,3,4,5], name: "Qatar_COA", segment_1_field_type_id: field_type1.id, segment_1_lookup_id: red_lookup.id, segment_2_field_type_id: field_type2.id, segment_2_required: true, segment_2_lookup_id: red_lookup.id, segment_3_field_type_id: field_type3.id, segment_3_lookup_id: red_lookup.id, segment_3_required: true, segment_3_model: "commodity", segment_3_column: "custom_field_1", segment_4_field_type_id: field_type4.id, segment_4_lookup_id: red_lookup.id, segment_4_required: true, segment_5_field_type_id: field_type5.id, segment_5_lookup_id: red_lookup.id, segment_5_required: true, dynamic_flag: true) }
    given!(:doha_coa) { FactoryGirl.create(:account_type, name: "Doha_COA", segment_1_field_type_id: field_type1.id, segment_1_lookup_id: blue_lookup.id, segment_2_field_type_id: field_type2.id, segment_2_lookup_id: green_lookup.id, segment_3_field_type_id: field_type3.id, segment_3_lookup_level: 1, segment_3_parent: 1, segment_3_model: "commodity", segment_3_column: "custom_field_1", segment_4_field_type_id: field_type4.id, segment_4_lookup_level: 1, segment_4_parent: 2, segment_5_field_type_id: field_type5.id, segment_5_lookup_id: red_lookup.id, dynamic_flag: true) }

    given!(:red_lookup_values_details) { [{name: "Red 100", external_ref_num: '100', account_type_id: nil}, {name: "Red 200", external_ref_num: '200', account_type_id: nil}, {name: "Red 300", external_ref_num: '300', account_type_id: chennai_coa.id}, {name: "Red 400", external_ref_num: '400', account_type_id: chennai_coa.id}, {name: "Red 500", external_ref_num: '500', account_type_id: delhi_coa.id}, {name: "Red 600", external_ref_num: '600', account_type_id: delhi_coa.id}, {name: "Red 700", external_ref_num: '700', account_type_id: qatar_coa.id}, {name: "Red 800", external_ref_num: '800', account_type_id: qatar_coa.id}, {name: "Red 900", external_ref_num: '900', account_type_id: doha_coa.id}, {name: "Red 1000", external_ref_num: '1000', account_type_id: doha_coa.id}] }
    given!(:red_lookup_values) do
      red_lookup_values_details.each_index do |i|
        FactoryGirl.create(:lookup_value, name: red_lookup_values_details[i][:name], lookup_id: red_lookup.id, external_ref_num:red_lookup_values_details[i][:external_ref_num], account_type_id: red_lookup_values_details[i][:account_type_id])
      end
    end

    # Lookup values single parent multiple_child hierarchy
    #all the users can see this Lookupvalue
    given!(:blue_200) { FactoryGirl.create(:lookup_value, name: "Blue 200", lookup_id: blue_lookup.id, external_ref_num: '200') }
    given!(:blue_200_child_details) { [{name: "Blue 201", external_ref_num: '201'}, {name: "Blue 202", external_ref_num: '202'}] }
    given!(:blue_200_child_values) do
      blue_200_child_details.each_index do |i|
        FactoryGirl.create(:lookup_value, name: blue_200_child_details[i][:name], lookup_id: blue_lookup.id, external_ref_num: blue_200_child_details[i][:external_ref_num], parent_id: blue_200.id)
      end
    end

    # Only the users who has the "chennai coa" access can see these Lookupvalues.
    given!(:blue_6000) { FactoryGirl.create(:lookup_value, name: "Blue 6000", lookup_id: blue_lookup.id, external_ref_num: '6000', account_type_id: chennai_coa.id) }
    given!(:blue_6001) { FactoryGirl.create(:lookup_value, name: "Blue 6001", lookup_id: blue_lookup.id, external_ref_num: '6001', parent_id: blue_6000.id) }

    # Only the users who has the "delhi coa" access can see these Lookupvalues.
    given!(:blue_7000) { FactoryGirl.create(:lookup_value, name: "Blue 7000", lookup_id: blue_lookup.id, external_ref_num: '7000', account_type_id: delhi_coa.id) }
    given!(:blue_7001) { FactoryGirl.create(:lookup_value, name: "Blue 7001", lookup_id: blue_lookup.id, external_ref_num: '7001', parent_id: blue_7000.id) }

    # Only the users who has the "doha coa" access can see these Lookupvalues.
    given!(:blue_8000) { FactoryGirl.create(:lookup_value, name: "Blue 8000", lookup_id: blue_lookup.id, external_ref_num: '8000', account_type_id: doha_coa.id) }
    given!(:blue_8001) { FactoryGirl.create(:lookup_value, name: "Blue 8001", lookup_id: blue_lookup.id, external_ref_num: '8001', parent_id: blue_8000.id) }

    # Only the users who has the "qatar coa" access can see these Lookupvalues.
    given!(:blue_8002) { FactoryGirl.create(:lookup_value, name: "Blue 8002", lookup_id: blue_lookup.id, external_ref_num: '8002', parent_id: blue_8000.id, account_type_id: qatar_coa.id) }
    given!(:blue_8003) { FactoryGirl.create(:lookup_value, name: "Blue 8003", lookup_id: blue_lookup.id, external_ref_num: '8003', parent_id: blue_8000.id, account_type_id: chennai_coa.id) }

    # Lookup values sequential parent child hierarchy.
    # All the users can see this Lookupvalue
    given!(:green_1981) { FactoryGirl.create(:lookup_value, name: "Green 1981", lookup_id: green_lookup.id, external_ref_num: '1981') }
    given!(:green_1982) { FactoryGirl.create(:lookup_value, name: "Green 1982", lookup_id: green_lookup.id, external_ref_num: '1982', parent_id: green_1981.id) }
    given!(:green_1983) { FactoryGirl.create(:lookup_value, name: "Green 1983", lookup_id: green_lookup.id, external_ref_num: '1983', parent_id: green_1982.id) }

    given!(:green_1994) { FactoryGirl.create(:lookup_value, name: "Green 1994", lookup_id: green_lookup.id, external_ref_num: '1994', account_type_id: chennai_coa.id) }
    given!(:green_1995) { FactoryGirl.create(:lookup_value, name: "Green 1995", lookup_id: green_lookup.id, external_ref_num: '1995', parent_id: green_1994.id) }
    given!(:green_1996) { FactoryGirl.create(:lookup_value, name: "Green 1996", lookup_id: green_lookup.id, external_ref_num: '1996', parent_id: green_1995.id) }

    given!(:green_2021) { FactoryGirl.create(:lookup_value, name: "Green 2021", lookup_id: green_lookup.id, external_ref_num: '2021', account_type_id: delhi_coa.id) }
    given!(:green_2022) { FactoryGirl.create(:lookup_value, name: "Green 2022", lookup_id: green_lookup.id, external_ref_num: '2022', parent_id: green_2021.id) }
    given!(:green_2023) { FactoryGirl.create(:lookup_value, name: "Green 2023", lookup_id: green_lookup.id, external_ref_num: '2023', parent_id: green_2022.id) }

    given!(:green_1945) { FactoryGirl.create(:lookup_value, name: "Green 1945", lookup_id: green_lookup.id, external_ref_num: '1945', account_type_id: doha_coa.id) }
    given!(:green_1946) { FactoryGirl.create(:lookup_value, name: "Green 1946", lookup_id: green_lookup.id, external_ref_num: '1946', parent_id: green_1945.id) }
    given!(:green_1947) { FactoryGirl.create(:lookup_value, name: "Green 1947", lookup_id: green_lookup.id, external_ref_num: '1947', parent_id: green_1946.id, account_type_id: qatar_coa.id) }

    #Accounts for Chennai COA:
    given!(:chennai_coa_account1) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[1][:name]}", account_type_id: chennai_coa.id, segment_1: red_lookup_values_details[0][:external_ref_num], segment_2: red_lookup_values_details[0][:external_ref_num], segment_3: red_lookup_values_details[1][:external_ref_num], code: "#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[1][:external_ref_num]}", active: true) }
    given!(:chennai_coa_account2) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[0][:name]}", account_type_id: chennai_coa.id, segment_1: red_lookup_values_details[0][:external_ref_num], segment_2: red_lookup_values_details[0][:external_ref_num], segment_3: red_lookup_values_details[0][:external_ref_num], code: "#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[0][:external_ref_num]}", active: true) }
    given!(:chennai_coa_account3) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[1][:name]}-#{red_lookup_values_details[0][:name]}", account_type_id: chennai_coa.id, segment_1: red_lookup_values_details[0][:external_ref_num], segment_2: red_lookup_values_details[1][:external_ref_num], segment_3: red_lookup_values_details[0][:external_ref_num], code: "#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[1][:external_ref_num]}-#{red_lookup_values_details[0][:external_ref_num]}", active: true) }
    given!(:chennai_coa_account4) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[2][:name]}-#{red_lookup_values_details[0][:name]}", account_type_id: chennai_coa.id, segment_1: red_lookup_values_details[0][:external_ref_num], segment_2: red_lookup_values_details[2][:external_ref_num], segment_3: red_lookup_values_details[0][:external_ref_num], code: "#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[2][:external_ref_num]}-#{red_lookup_values_details[0][:external_ref_num]}", active: true) }
    given!(:chennai_coa_account5) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[2][:name]}-#{red_lookup_values_details[3][:name]}", account_type_id: chennai_coa.id, segment_1: red_lookup_values_details[0][:external_ref_num], segment_2: red_lookup_values_details[2][:external_ref_num], segment_3: red_lookup_values_details[3][:external_ref_num], code: "#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[2][:external_ref_num]}-#{red_lookup_values_details[3][:external_ref_num]}", active: true) }
    given!(:chennai_coa_account6) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[1][:name]}-#{red_lookup_values_details[1][:name]}", account_type_id: chennai_coa.id, segment_1: red_lookup_values_details[0][:external_ref_num], segment_2: red_lookup_values_details[1][:external_ref_num], segment_3: red_lookup_values_details[1][:external_ref_num], code: "#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[1][:external_ref_num]}-#{red_lookup_values_details[1][:external_ref_num]}", active: true) }
    given!(:chennai_coa_account7) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[1][:name]}", account_type_id: chennai_coa.id, segment_1: red_lookup_values_details[0][:external_ref_num], segment_2: red_lookup_values_details[1][:external_ref_num], code: "#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[1][:external_ref_num]}", active: true) }
    given!(:chennai_coa_account8) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[1][:name]}-#{red_lookup_values_details[2][:name]}-#{red_lookup_values_details[0][:name]}", account_type_id: chennai_coa.id, segment_1: red_lookup_values_details[1][:external_ref_num], segment_2: red_lookup_values_details[2][:external_ref_num], segment_3: red_lookup_values_details[0][:external_ref_num], code: "#{red_lookup_values_details[1][:external_ref_num]}-#{red_lookup_values_details[2][:external_ref_num]}-#{red_lookup_values_details[0][:external_ref_num]}", active: true) }
    given!(:chennai_coa_account9) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[1][:name]}-#{red_lookup_values_details[3][:name]}", account_type_id: chennai_coa.id, segment_1: red_lookup_values_details[0][:external_ref_num], segment_2: red_lookup_values_details[1][:external_ref_num], segment_3: red_lookup_values_details[3][:external_ref_num], code: "#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[1][:external_ref_num]}-#{red_lookup_values_details[3][:external_ref_num]}", active: true) }
    given!(:chennai_coa_account10) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[2][:name]}-#{red_lookup_values_details[1][:name]}", account_type_id: chennai_coa.id, segment_1: red_lookup_values_details[0][:external_ref_num], segment_2: red_lookup_values_details[2][:external_ref_num], segment_3: red_lookup_values_details[1][:external_ref_num], code: "#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[2][:external_ref_num]}-#{red_lookup_values_details[1][:external_ref_num]}", active: true) }
    given!(:chennai_coa_account11) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[3][:name]}-#{red_lookup_values_details[1][:name]}", account_type_id: chennai_coa.id, segment_1: red_lookup_values_details[0][:external_ref_num], segment_2: red_lookup_values_details[3][:external_ref_num], segment_3: red_lookup_values_details[1][:external_ref_num], code: "#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[3][:external_ref_num]}-#{red_lookup_values_details[1][:external_ref_num]}", active: true) }

    #Accounts for Pune COA
    given!(:pune_coa_account1) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[0][:name]}", account_type_id: pune_coa.id, segment_1: red_lookup_values_details[0][:external_ref_num], segment_2: red_lookup_values_details[0][:external_ref_num], segment_3: red_lookup_values_details[0][:external_ref_num], code: "#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[0][:external_ref_num]}", active: true) }
    given!(:pune_coa_account2) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[1][:name]}-#{red_lookup_values_details[0][:name]}", account_type_id: pune_coa.id, segment_1: red_lookup_values_details[0][:external_ref_num], segment_2: red_lookup_values_details[1][:external_ref_num], segment_3: red_lookup_values_details[0][:external_ref_num], code: "#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[1][:external_ref_num]}-#{red_lookup_values_details[0][:external_ref_num]}", active: true) }
    given!(:pune_coa_account3) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[1][:name]}-#{red_lookup_values_details[1][:name]}", account_type_id: pune_coa.id, segment_1: red_lookup_values_details[0][:external_ref_num], segment_2: red_lookup_values_details[1][:external_ref_num], segment_3: red_lookup_values_details[1][:external_ref_num], code: "#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[1][:external_ref_num]}-#{red_lookup_values_details[1][:external_ref_num]}", active: true) }
    given!(:pune_coa_account4) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[1][:name]}", account_type_id: pune_coa.id, segment_1: red_lookup_values_details[0][:external_ref_num], segment_2: red_lookup_values_details[0][:external_ref_num], segment_3: red_lookup_values_details[1][:external_ref_num], code: "#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[1][:external_ref_num]}", active: true) }

    #Accounts for Delhi COA
    given!(:delhi_coa_account1) { FactoryGirl.create(:account, name: "#{blue_7000.name}-#{green_1981.name}-#{blue_7001.name}-#{green_1982.name}-#{red_lookup_values_details[1][:name]}", account_type_id: delhi_coa.id, segment_1: blue_7000.external_ref_num, segment_2: green_1981.external_ref_num, segment_3: blue_7001.external_ref_num, segment_4: green_1982.external_ref_num, segment_5: red_lookup_values_details[1][:external_ref_num], code: "#{blue_7000.external_ref_num}-#{green_1981.external_ref_num}-#{blue_7001.external_ref_num}-#{green_1982.external_ref_num}-#{red_lookup_values_details[1][:external_ref_num]}", active: true) }
    given!(:delhi_coa_account2) { FactoryGirl.create(:account, name: "#{blue_200.name}-#{green_1981.name}-#{blue_200_child_details[1][:name]}-#{green_1982.name}-#{red_lookup_values_details[1][:name]}", account_type_id: delhi_coa.id, segment_1: blue_200.external_ref_num, segment_2: green_1981.external_ref_num, segment_3: blue_200_child_details[1][:external_ref_num], segment_4: green_1982.external_ref_num, segment_5: red_lookup_values_details[1][:external_ref_num], code: "#{blue_200.external_ref_num}-#{green_1981.external_ref_num}-#{blue_200_child_details[1][:external_ref_num]}-#{green_1982.external_ref_num}-#{red_lookup_values_details[1][:external_ref_num]}", active: true) }
    given!(:delhi_coa_account3) { FactoryGirl.create(:account, name: "#{blue_200.name}-#{green_1981.name}-#{blue_200_child_details[0][:name]}-#{green_1982.name}-#{red_lookup_values_details[1][:name]}", account_type_id: delhi_coa.id, segment_1: blue_200.external_ref_num, segment_2: green_1981.external_ref_num, segment_3: blue_200_child_details[0][:external_ref_num], segment_4: green_1982.external_ref_num, segment_5: red_lookup_values_details[1][:external_ref_num], code: "#{blue_200.external_ref_num}-#{green_1981.external_ref_num}-#{blue_200_child_details[0][:external_ref_num]}-#{green_1982.external_ref_num}-#{red_lookup_values_details[1][:external_ref_num]}", active: true) }
    given!(:delhi_coa_account4) { FactoryGirl.create(:account, name: "#{blue_7000.name}-#{green_2021.name}-#{blue_7001.name}-#{green_2022.name}-#{red_lookup_values_details[4][:name]}", account_type_id: delhi_coa.id, segment_1: blue_7000.external_ref_num, segment_2: green_2021.external_ref_num, segment_3: blue_7001.external_ref_num, segment_4: green_2022.external_ref_num, segment_5: red_lookup_values_details[4][:external_ref_num], code: "#{blue_7000.external_ref_num}-#{green_2021.external_ref_num}-#{blue_7001.external_ref_num}-#{green_2022.external_ref_num}-#{red_lookup_values_details[4][:external_ref_num]}", active: true) }
    given!(:delhi_coa_account5) { FactoryGirl.create(:account, name: "#{blue_7000.name}-#{green_2021.name}-#{blue_7001.name}--#{red_lookup_values_details[0][:name]}", account_type_id: delhi_coa.id, segment_1: blue_7000.external_ref_num, segment_2: green_2021.external_ref_num, segment_3: blue_7001.external_ref_num, segment_4: nil, segment_5: red_lookup_values_details[0][:external_ref_num], code: "#{blue_7000.external_ref_num}-#{green_2021.external_ref_num}-#{blue_7001.external_ref_num}--#{red_lookup_values_details[0][:external_ref_num]}", active: true) }
    given!(:delhi_coa_account6) { FactoryGirl.create(:account, name: "#{blue_7000.name}-#{green_1981.name}-#{blue_7001.name}--#{red_lookup_values_details[0][:name]}", account_type_id: delhi_coa.id, segment_1: blue_7000.external_ref_num, segment_2: green_1981.external_ref_num, segment_3: blue_7001.external_ref_num, segment_4: nil, segment_5: red_lookup_values_details[0][:external_ref_num], code: "#{blue_7000.external_ref_num}-#{green_1981.external_ref_num}-#{blue_7001.external_ref_num}--#{red_lookup_values_details[0][:external_ref_num]}", active: true) }
    given!(:delhi_coa_account7) { FactoryGirl.create(:account, name: "#{blue_200.name}-#{green_2021.name}-#{blue_200_child_details[0][:name]}-#{green_2022.name}-#{red_lookup_values_details[1][:name]}", account_type_id: delhi_coa.id, segment_1: blue_200.external_ref_num, segment_2: green_2021.external_ref_num, segment_3: blue_200_child_details[0][:external_ref_num], segment_4: green_2022.external_ref_num, segment_5: red_lookup_values_details[1][:external_ref_num], code: "#{blue_200.external_ref_num}-#{green_2021.external_ref_num}-#{blue_200_child_details[0][:external_ref_num]}-#{green_2022.external_ref_num}-#{red_lookup_values_details[1][:external_ref_num]}", active: true) }
    given!(:delhi_coa_account8) { FactoryGirl.create(:account, name: "#{blue_200.name}-#{green_2021.name}-#{blue_200_child_details[0][:name]}--#{red_lookup_values_details[1][:name]}", account_type_id: delhi_coa.id, segment_1: blue_200.external_ref_num, segment_2: green_2021.external_ref_num, segment_3: blue_200_child_details[0][:external_ref_num], segment_4: nil, segment_5: red_lookup_values_details[1][:external_ref_num], code: "#{blue_200.external_ref_num}-#{green_2021.external_ref_num}-#{blue_200_child_details[0][:external_ref_num]}--#{red_lookup_values_details[1][:external_ref_num]}", active: true) }
    given!(:delhi_coa_account9) { FactoryGirl.create(:account, name: "#{blue_200.name}-#{green_1981.name}-#{blue_200_child_details[0][:name]}-#{green_1982.name}-#{red_lookup_values_details[0][:name]}", account_type_id: delhi_coa.id, segment_1: blue_200.external_ref_num, segment_2: green_1981.external_ref_num, segment_3: blue_200_child_details[0][:external_ref_num], segment_4: green_1982.external_ref_num, segment_5: red_lookup_values_details[0][:external_ref_num], code: "#{blue_200.external_ref_num}-#{green_1981.external_ref_num}-#{blue_200_child_details[0][:external_ref_num]}-#{green_1982.external_ref_num}-#{red_lookup_values_details[0][:external_ref_num]}", active: true) }
    given!(:delhi_coa_account10) { FactoryGirl.create(:account, name: "#{blue_200.name}-#{green_1981.name}-#{blue_200_child_details[0][:name]}-#{green_1982.name}-#{red_lookup_values_details[4][:name]}", account_type_id: delhi_coa.id, segment_1: blue_200.external_ref_num, segment_2: green_1981.external_ref_num, segment_3: blue_200_child_details[0][:external_ref_num], segment_4: green_1982.external_ref_num, segment_5: red_lookup_values_details[4][:external_ref_num], code: "#{blue_200.external_ref_num}-#{green_1981.external_ref_num}-#{blue_200_child_details[0][:external_ref_num]}-#{green_1982.external_ref_num}-#{red_lookup_values_details[4][:external_ref_num]}", active: true) }
    given!(:delhi_coa_account11) { FactoryGirl.create(:account, name: "#{blue_200.name}--#{blue_200_child_details[0][:name]}--#{red_lookup_values_details[1][:name]}", account_type_id: delhi_coa.id, segment_1: blue_200.external_ref_num, segment_2: nil, segment_3: blue_200_child_details[0][:external_ref_num], segment_4: nil, segment_5: red_lookup_values_details[1][:external_ref_num], code: "#{blue_200.external_ref_num}--#{blue_200_child_details[0][:external_ref_num]}--#{red_lookup_values_details[1][:external_ref_num]}", active: true) }
    given!(:delhi_coa_account12) { FactoryGirl.create(:account, name: "#{blue_7000.name}-#{green_2021.name}-#{blue_7001.name}-#{green_2022.name}-#{red_lookup_values_details[0][:name]}", account_type_id: delhi_coa.id, segment_1: blue_7000.external_ref_num, segment_2: green_2021.external_ref_num, segment_3: blue_7001.external_ref_num, segment_4: green_2022.external_ref_num, segment_5: red_lookup_values_details[0][:external_ref_num], code: "#{blue_7000.external_ref_num}-#{green_2021.external_ref_num}-#{blue_7001.external_ref_num}-#{green_2022.external_ref_num}-#{red_lookup_values_details[0][:external_ref_num]}", active: true) }

    #Account for Qatar COA
    given!(:qatar_coa_account1) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[6][:name]}-#{red_lookup_values_details[7][:name]}-#{red_lookup_values_details[6][:name]}-#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[0][:name]}", account_type_id: qatar_coa.id, segment_1: red_lookup_values_details[6][:external_ref_num], segment_2: red_lookup_values_details[7][:external_ref_num], segment_3: red_lookup_values_details[6][:external_ref_num], segment_4: red_lookup_values_details[0][:external_ref_num], segment_5: red_lookup_values_details[0][:external_ref_num], code: "#{red_lookup_values_details[6][:external_ref_num]}-#{red_lookup_values_details[7][:external_ref_num]}-#{red_lookup_values_details[6][:external_ref_num]}-#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[0][:external_ref_num]}", active: true) }
    given!(:qatar_coa_account2) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[6][:name]}-#{red_lookup_values_details[1][:name]}-#{red_lookup_values_details[1][:name]}-#{red_lookup_values_details[7][:name]}-#{red_lookup_values_details[0][:name]}", account_type_id: qatar_coa.id, segment_1: red_lookup_values_details[6][:external_ref_num], segment_2: red_lookup_values_details[1][:external_ref_num], segment_3: red_lookup_values_details[1][:external_ref_num], segment_4: red_lookup_values_details[7][:external_ref_num], segment_5: red_lookup_values_details[0][:external_ref_num], code: "#{red_lookup_values_details[6][:external_ref_num]}-#{red_lookup_values_details[1][:external_ref_num]}-#{red_lookup_values_details[1][:external_ref_num]}-#{red_lookup_values_details[7][:external_ref_num]}-#{red_lookup_values_details[0][:external_ref_num]}", active: true) }
    given!(:qatar_coa_account3) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[6][:name]}-#{red_lookup_values_details[6][:name]}-#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[7][:name]}-#{red_lookup_values_details[7][:name]}", account_type_id: qatar_coa.id, segment_1: red_lookup_values_details[6][:external_ref_num], segment_2: red_lookup_values_details[6][:external_ref_num], segment_3: red_lookup_values_details[0][:external_ref_num], segment_4: red_lookup_values_details[7][:external_ref_num], segment_5: red_lookup_values_details[7][:external_ref_num], code: "#{red_lookup_values_details[6][:external_ref_num]}-#{red_lookup_values_details[6][:external_ref_num]}-#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[7][:external_ref_num]}-#{red_lookup_values_details[7][:external_ref_num]}", active: true) }
    given!(:qatar_coa_account4) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[6][:name]}-#{red_lookup_values_details[6][:name]}-#{red_lookup_values_details[1][:name]}-#{red_lookup_values_details[7][:name]}-#{red_lookup_values_details[7][:name]}", account_type_id: qatar_coa.id, segment_1: red_lookup_values_details[6][:external_ref_num], segment_2: red_lookup_values_details[6][:external_ref_num], segment_3: red_lookup_values_details[1][:external_ref_num], segment_4: red_lookup_values_details[7][:external_ref_num], segment_5: red_lookup_values_details[7][:external_ref_num], code: "#{red_lookup_values_details[6][:external_ref_num]}-#{red_lookup_values_details[6][:external_ref_num]}-#{red_lookup_values_details[1][:external_ref_num]}-#{red_lookup_values_details[7][:external_ref_num]}-#{red_lookup_values_details[7][:external_ref_num]}", active: true) }
    given!(:qatar_coa_account5) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[1][:name]}-#{red_lookup_values_details[6][:name]}-#{red_lookup_values_details[7][:name]}-#{red_lookup_values_details[1][:name]}", account_type_id: qatar_coa.id, segment_1: red_lookup_values_details[0][:external_ref_num], segment_2: red_lookup_values_details[1][:external_ref_num], segment_3: red_lookup_values_details[6][:external_ref_num], segment_4: red_lookup_values_details[7][:external_ref_num], segment_5: red_lookup_values_details[1][:external_ref_num], code: "#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[1][:external_ref_num]}-#{red_lookup_values_details[6][:external_ref_num]}-#{red_lookup_values_details[7][:external_ref_num]}-#{red_lookup_values_details[1][:external_ref_num]}", active: true) }
    given!(:qatar_coa_account6) { FactoryGirl.create(:account, name: "#{red_lookup_values_details[0][:name]}-#{red_lookup_values_details[1][:name]}-#{red_lookup_values_details[6][:name]}-#{red_lookup_values_details[1][:name]}-#{red_lookup_values_details[1][:name]}", account_type_id: qatar_coa.id, segment_1: red_lookup_values_details[0][:external_ref_num], segment_2: red_lookup_values_details[1][:external_ref_num], segment_3: red_lookup_values_details[6][:external_ref_num], segment_4: red_lookup_values_details[1][:external_ref_num], segment_5: red_lookup_values_details[1][:external_ref_num], code: "#{red_lookup_values_details[0][:external_ref_num]}-#{red_lookup_values_details[1][:external_ref_num]}-#{red_lookup_values_details[6][:external_ref_num]}-#{red_lookup_values_details[7][:external_ref_num]}-#{red_lookup_values_details[1][:external_ref_num]}", active: true) }

    #Account for Doha COA
    given!(:doha_coa_account1) { FactoryGirl.create(:account, name: "#{blue_8000.name}-#{green_1945.name}-#{blue_8001.name}-#{green_1946.name}-#{red_lookup_values_details[8][:name]}", account_type_id: doha_coa.id, segment_1: blue_8000.external_ref_num, segment_2: green_1945.external_ref_num, segment_3: blue_8001.external_ref_num, segment_4: green_1946.external_ref_num, segment_5: red_lookup_values_details[8][:external_ref_num], code: "#{blue_8000.external_ref_num}-#{green_1946.external_ref_num}-#{blue_8001.external_ref_num}-#{green_1946.external_ref_num}-#{red_lookup_values_details[8][:external_ref_num]}", active: true) }
    given!(:doha_coa_account3) { FactoryGirl.create(:account, name: "#{blue_8000.name}-#{green_1981.name}-#{blue_8001.name}-#{green_1982.name}-#{red_lookup_values_details[1][:name]}", account_type_id: doha_coa.id, segment_1: blue_8000.external_ref_num, segment_2: green_1981.external_ref_num, segment_3: blue_8001.external_ref_num, segment_4: green_1982.external_ref_num, segment_5: red_lookup_values_details[1][:external_ref_num], code: "#{blue_8000.external_ref_num}-#{green_1981.external_ref_num}-#{blue_8001.external_ref_num}-#{green_1982.external_ref_num}-#{red_lookup_values_details[1][:external_ref_num]}", active: true) }
    given!(:doha_coa_account4) { FactoryGirl.create(:account, name: "#{blue_8000.name}-#{green_1981.name}-#{blue_8001.name}-#{green_1982.name}-#{red_lookup_values_details[0][:name]}", account_type_id: doha_coa.id, segment_1: blue_8000.external_ref_num, segment_2: green_1981.external_ref_num, segment_3: blue_8001.external_ref_num, segment_4: green_1982.external_ref_num, segment_5: red_lookup_values_details[0][:external_ref_num], code: "#{blue_8000.external_ref_num}-#{green_1981.external_ref_num}-#{blue_8001.external_ref_num}-#{green_1982.external_ref_num}-#{red_lookup_values_details[0][:external_ref_num]}", active: true) }

    given!(:admin) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Admin", login: "Document Creator", business_group_security_type: 0, account_security_type: 0) }

    #account group with segment rules
    let!(:chennai_coa_ag_by_seg) { FactoryGirl.create(:account_group, account_type_id: chennai_coa.id, name: "chennai_coa_ag_by_segments", created_by_id: admin.id, updated_by_id: admin.id, segment_1_col: "", segment_1_op: "", segment_1_val: "", segment_2_col: "", segment_2_op: "eq", segment_2_val: "300", segment_3_col: "", segment_3_op: "", segment_3_val: "") }
    let!(:pune_coa_ag_by_seg) { FactoryGirl.create(:account_group, account_type_id: pune_coa.id, name: "pune_coa_ag_by_segments", created_by_id: admin.id, updated_by_id: admin.id, segment_1_col: "", segment_1_op: "", segment_1_val: "", segment_2_col: "", segment_2_op: "eq", segment_2_val: "100", segment_3_col: "", segment_3_op: "", segment_3_val: "") }
    let!(:delhi_coa_ag_by_seg) { FactoryGirl.create(:account_group, account_type_id: delhi_coa.id, name: "delhi_coa_ag_by_segments", created_by_id: admin.id, updated_by_id: admin.id, segment_1_col: "", segment_1_op: "", segment_1_val: "", segment_2_col: "", segment_2_op: "eq", segment_2_val: "1981", segment_3_col: "", segment_3_op: "", segment_3_val: "", segment_4_col: "", segment_4_op: "", segment_4_val: "", segment_5_col: "", segment_5_op: "", segment_5_val: "") }
    let!(:qatar_coa_ag_by_seg) { FactoryGirl.create(:account_group, account_type_id: qatar_coa.id, name: "qatar_coa_ag_by_segments", created_by_id: admin.id, updated_by_id: admin.id, segment_1_col: "", segment_1_op: "", segment_1_val: "", segment_2_col: "", segment_2_op: "", segment_2_val: "", segment_3_col: "", segment_3_op: "", segment_3_val: "", segment_4_col: "", segment_4_op: "eq", segment_4_val: "200", segment_5_col: "", segment_5_op: "", segment_5_val: "") }
    let!(:doha_coa_ag_by_seg) { FactoryGirl.create(:account_group, account_type_id: doha_coa.id, name: "doha_coa_ag_by_segments", created_by_id: admin.id, updated_by_id: admin.id, segment_1_col: "", segment_1_op: "", segment_1_val: "", segment_2_col: "", segment_2_op: "", segment_2_val: "", segment_3_col: "", segment_3_op: "", segment_3_val: "", segment_4_col: "", segment_4_op: "", segment_4_val: "", segment_5_col: "", segment_5_op: "eq", segment_5_val: "200") }

    #List of Users with different account security restriction
    # user with no account restriction
    given!(:us_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User, Expense Processor", login: "US User", business_group_security_type: 0, account_security_type: 0, expense_user: true) }

    # Users restricted to default chart of account
    given!(:fiji_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "Fiji User", business_group_security_type: 0, account_security_type: 1, default_account_type_id: chennai_coa.id, default_account_id: chennai_coa_account2, expense_user: true) }
    given!(:colombia_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "Colombia User", business_group_security_type: 0, account_security_type: 1, default_account_type_id: delhi_coa.id, default_account_id: delhi_coa_account2, expense_user: true) }
    given!(:india_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "India User", business_group_security_type: 0, account_security_type: 1, default_account_type_id: qatar_coa.id, default_account_id: qatar_coa_account1, expense_user: true) }
    given!(:japan_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "Japan User", business_group_security_type: 0, account_security_type: 1, default_account_type_id: doha_coa.id, default_account_id: doha_coa_account1, expense_user: true) }

    # User restricted to specific account groups
    given!(:china_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "China User", business_group_security_type: 0, account_security_type: 2, account_groups: [chennai_coa_ag_by_seg], expense_user: true) }
    given!(:egypt_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "Egypt User", business_group_security_type: 0, account_security_type: 2, account_groups: [delhi_coa_ag_by_seg], expense_user: true) }
    given!(:paris_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "Paris User", business_group_security_type: 0, account_security_type: 2, account_groups: [qatar_coa_ag_by_seg], expense_user: true) }
    given!(:italy_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "Italy User", business_group_security_type: 0, account_security_type: 2, account_groups: [doha_coa_ag_by_seg], custom_field_1: 200, expense_user: true) }

    shared_examples 'lookup values display and account display for chennai_coa' do |user|
      scenario '' do
        login_as user
        create_expense
        expense_home.expense_lines.account_icon.click
        ##### Lookup value display#####
        if user != china_user.login
          expense_home.account_popup.choose_account_type.select chennai_coa.name if user == us_user.login
          wait_for_ajax
          expense_home.account_popup.choose_account_type.select chennai_coa.name if user == "Austria User"
          wait_for_ajax
          # The frist 4 lookup values from the Red lookup should be displayed
          expense_home.choose_an_account.segment[0].click
          expect(expense_home.segment_1_results).to have_content "Red 100 (100) Red 200 (200) Red 300 (300) Red 400 (400)"
          expect(find_all("#account_segment_1_lv_id_chosen_results li").count).to eq 4
          expense_home.choose_an_account.segment[0].click
          expense_home.choose_an_account.segment[1].click
          expect(expense_home.segment_2_results).to have_content "Red 100 (100) Red 200 (200) Red 300 (300) Red 400 (400)"
          expect(find_all("#account_segment_2_lv_id_chosen_results li").count).to eq 4
          expense_home.choose_an_account.segment[1].click
          expense_home.choose_an_account.segment[2].click
          expect(expense_home.segment_3_results).to have_content "Red 100 (100) Red 200 (200) Red 300 (300) Red 400 (400)"
          expect(find_all("#account_segment_3_lv_id_chosen_results li").count).to eq 4
        else
          expense_home.choose_an_account.segment[0].click
          expect(expense_home.segment_1_results).to have_content "Red 100 (100) Red 200 (200) Red 300 (300) Red 400 (400)"
          expense_home.select_lookupvalue_on_segment("Red 200 (200)")
          expense_home.choose_an_account.segment[1].click
          expect(expense_home.segment_2_results).to have_content "Red 100 (100) Red 200 (200) Red 300 (300) Red 400 (400)"
          expense_home.select_lookupvalue_on_segment("Red 200 (200)")
          expense_home.choose_an_account.segment[2].click
          expect(expense_home.segment_3_results).to have_content "Red 100 (100) Red 200 (200) Red 300 (300) Red 400 (400)"
          expense_home.select_lookupvalue_on_segment("Red 200 (200)")
          expense_home.choose_an_account.choose.click
          expect(expense_home.choose_an_account.errors[0]).to have_content "Your security settings prohibit access to this account."
          expense_home.choose_an_account.segment[1].click
          expect(expense_home.segment_2_results).to have_content "Red 100 (100) Red 200 (200) Red 300 (300) Red 400 (400)"
          find('#account_segment_2_lv_id_chosen_results_option_3').click
          expense_home.choose_an_account.choose.click
          expect(expense_home.expense_lines.account_details).to have_content "Chennai_COA, Red 200-Red 300-Red 200, 200-300-200"       
        end
      end
    end

    shared_examples 'lookup values display and account display for pune_coa' do |user|
      scenario'' do
        login_as user
        create_expense
        expense_home.expense_lines.account_icon.click
        ##### Lookup value display#####
        # For pune COA since it's doesn't have specific lookup values only the first 2 lookup vaules from Red lookup should display
        expense_home.account_popup.choose_account_type.select pune_coa.name
        wait_for_ajax
        expense_home.choose_an_account.segment[0].click
        expect(expense_home.segment_1_results).to have_content "Red 100 (100) Red 200 (200)"
        expect(find_all("#account_segment_1_lv_id_chosen_results li").count).to eq 2
        expense_home.choose_an_account.segment[0].click
        expense_home.choose_an_account.segment[1].click
        expect(expense_home.segment_2_results).to have_content "Red 100 (100) Red 200 (200)"
        expect(find_all("#account_segment_2_lv_id_chosen_results li").count).to eq 2
        expense_home.choose_an_account.segment[1].click
        expense_home.choose_an_account.segment[2].click
        expect(expense_home.segment_3_results).to have_content "Red 100 (100) Red 200 (200)"
        expect(find_all("#account_segment_3_lv_id_chosen_results li").count).to eq 2
      end
    end

    shared_examples 'lookup values display and account display for delhi_coa' do |user|
      scenario '' do
        login_as user
        create_expense
        expense_home.expense_lines.account_icon.click
        # For Delhi COA
        if user != egypt_user.login
          expense_home.account_popup.choose_account_type.select delhi_coa.name if user == us_user.login
          wait_for_ajax
          expense_home.account_popup.choose_account_type.select delhi_coa.name if user == "Austria User"
          wait_for_ajax
          # Segment 1: Should display only the blue 200 lookup value and blue 7000 lookup value
          expense_home.choose_an_account.segment[0].click
          expect(expense_home.segment_1_results).to have_content "Blue 200 (200) Blue 7000 (7000)"
          expense_home.select_lookupvalue_on_segment("Blue 7000 (7000)")
          expect(find_all("#account_segment_1_lv_id_chosen_results li").count).to eq 2
          # Segment 2: Should display only the green 1981 lookup value and green 2021 lookup value
          expense_home.choose_an_account.segment[1].click
          expect(expense_home.segment_2_results).to have_content "Green 1981 (1981) Green 2021 (2021)"
          expense_home.select_lookupvalue_on_segment("Green 1981 (1981)")
          expect(find_all("#account_segment_2_lv_id_chosen_results li").count).to eq 2
          # Segment 3: depends on seg1 it should display the child value of the lookup value selected in the 1st segment
          expense_home.choose_an_account.segment[2].click
          expect(expense_home.segment_3_results).to have_content "Blue 7001 (7001)"
          expect(find_all("#account_segment_3_lv_id_chosen_results li").count).to eq 1
          expense_home.choose_an_account.segment[2].click
          # Segment 4: depends on seg2 it should display the child value of the lookup value selected in the 2nd segment
          expense_home.choose_an_account.segment[3].click
          expect(expense_home.segment_4_results).to have_content "Green 1982 (1982)"
          expect(find_all("#account_segment_4_lv_id_chosen_results li").count).to eq 1
          expense_home.choose_an_account.segment[3].click
          # Segment 5: should display only the red lookup values(Red 100/Red 200/Red 500/Red 600)
          expense_home.choose_an_account.segment[4].click
          expect(expense_home.segment_5_results).to have_content "Red 100 (100) Red 200 (200) Red 500 (500) Red 600 (600)"
          expect(find_all("#account_segment_5_lv_id_chosen_results li").count).to eq 4
        elsif user == egypt_user.login
          expense_home.choose_an_account.segment[0].click
          expense_home.select_lookupvalue_on_segment("Blue 7000 (7000)")
          expense_home.choose_an_account.segment[1].click
          expense_home.select_lookupvalue_on_segment("Green 2021 (2021)")
          expense_home.choose_an_account.segment[2].click
          expense_home.select_lookupvalue_on_segment("Blue 7001 (7001)")
          expense_home.choose_an_account.segment[3].click
          expense_home.select_lookupvalue_on_segment("Green 2022 (2022)")
          expense_home.choose_an_account.segment[4].click
          expense_home.select_lookupvalue_on_segment("#{red_lookup_values_details[0][:name]} (#{red_lookup_values_details[0][:external_ref_num]})")
          expense_home.choose_an_account.choose.click
          expect(expense_home.choose_an_account.errors[1]).to have_content "You do not have access to that account"
          expense_home.choose_an_account.segment[1].click
          expense_home.select_lookupvalue_on_segment("Green 1981 (1981)")
          expense_home.choose_an_account.choose.click
          expect(expense_home.expense_lines.account_details).to have_content "Delhi_COA, Blue 7000-Green 1981-Blue 7001--Red 100, 7000-1981-7001--100"
        end
      end
    end

    shared_examples 'lookup values display and account display for qatar_coa' do |user|
      scenario '' do
        login_as user
        create_expense
        expense_home.expense_lines.account_icon.click
        # For Qatar COA
        if user != paris_user.login
          expense_home.account_popup.choose_account_type.select qatar_coa.name if user == us_user.login
          wait_for_ajax
          expense_home.account_popup.choose_account_type.select qatar_coa.name if user == "Austria User"
          wait_for_ajax
          # Segment 1: Should display only the red lookup values(Red 100/Red 200/Red 700/Red 800)
          expense_home.choose_an_account.segment[0].click
          expect(expense_home.segment_1_results).to have_content "Red 100 (100) Red 200 (200) Red 700 (700) Red 800 (800)"
          expect(find_all("#account_segment_1_lv_id_chosen_results li").count).to eq 4
          expense_home.choose_an_account.segment[0].click
          # Segment 2: Should display only the red lookup values(Red 100/Red 200/Red 700/Red 800)
          expense_home.choose_an_account.segment[1].click
          expect(expense_home.segment_2_results).to have_content "Red 100 (100) Red 200 (200) Red 700 (700) Red 800 (800)"
          expect(find_all("#account_segment_2_lv_id_chosen_results li").count).to eq 4
          expense_home.choose_an_account.segment[1].click
          # Segment 3: Should display only the red lookup values(Red 100/Red 200/Red 700/Red 800)
          expense_home.choose_an_account.segment[2].click
          expect(expense_home.segment_3_results).to have_content "Red 100 (100) Red 200 (200) Red 700 (700) Red 800 (800)"
          expect(find_all("#account_segment_3_lv_id_chosen_results li").count).to eq 4
          expense_home.choose_an_account.segment[2].click
          # Segment 4: Should display only the red lookup values(Red 100/Red 200/Red 700/Red 800)
          expense_home.choose_an_account.segment[3].click
          expect(expense_home.segment_4_results).to have_content "Red 100 (100) Red 200 (200) Red 700 (700) Red 800 (800)" 
          expect(find_all("#account_segment_4_lv_id_chosen_results li").count).to eq 4
          expense_home.choose_an_account.segment[3].click
          # Segment 5: Should display only the red lookup values(Red 100/Red 200/Red 700/Red 800)
          expense_home.choose_an_account.segment[4].click
          expect(expense_home.segment_5_results).to have_content "Red 100 (100) Red 200 (200) Red 700 (700) Red 800 (800)"
          expect(find_all("#account_segment_5_lv_id_chosen_results li").count).to eq 4
          expense_home.choose_an_account.segment[4].click
        elsif user == paris_user.login
          expense_home.choose_an_account.segment[0].click
          expense_home.select_lookupvalue_on_segment("Red 200 (200)")
          expense_home.choose_an_account.segment[1].click
          expense_home.select_lookupvalue_on_segment("Red 200 (200)")
          expense_home.choose_an_account.segment[2].click
          expense_home.select_lookupvalue_on_segment("Red 200 (200)")
          expense_home.choose_an_account.segment[3].click
          expense_home.select_lookupvalue_on_segment("Red 800 (800)")
          expense_home.choose_an_account.segment[4].click
          expense_home.select_lookupvalue_on_segment("Red 200 (200)")
          expense_home.choose_an_account.choose.click
          expect(expense_home.choose_an_account.errors[0]).to have_content "Your security settings prohibit access to this account."
          expense_home.choose_an_account.segment[3].click
          find('#account_segment_4_lv_id_chosen_results_option_2').click
          expense_home.choose_an_account.choose.click
          expect(expense_home.expense_lines.account_details).to have_content "Qatar_COA, Red 200-Red 200-Red 200-Red 200-Red 200, 200-200-200-200-200"
        end
      end
    end

    shared_examples 'lookup values display and account display for doha_coa' do |user|
      scenario '' do
        login_as user
        create_expense
        expense_home.expense_lines.account_icon.click
        # For Doha COA
        if user != italy_user.login
          expense_home.account_popup.choose_account_type.select doha_coa.name if user == us_user.login
          wait_for_ajax
          expense_home.account_popup.choose_account_type.select doha_coa.name if user == "Austria User"
          wait_for_ajax
          # Segment 1: Should display only the blue 200 lookup value and blue 8000 lookup value
          expense_home.choose_an_account.segment[0].click
          expect(expense_home.segment_1_results).to have_content "Blue 200 (200) Blue 8000 (8000)"
          expense_home.select_lookupvalue_on_segment("Blue 200 (200)")
          expect(find_all("#account_segment_1_lv_id_chosen_results li").count).to eq 2
          # Segment 2: Should display only the green 1981 lookup value and green 1945 lookup value
          expense_home.choose_an_account.segment[1].click
          expect(expense_home.segment_2_results).to have_content "Green 1945 (1945) Green 1981 (1981)"
          expense_home.select_lookupvalue_on_segment("Green 1945 (1945)")
          expect(find_all("#account_segment_2_lv_id_chosen_results li").count).to eq 2
          # Segment 3: depends on seg1 it should display the child value of the lookup value selected in the 1st segment
          expense_home.choose_an_account.segment[2].click
          expect(expense_home.segment_3_results).to have_content "Blue 201 (201) Blue 202 (202)"
          expense_home.choose_an_account.segment[2].click
          expect(find_all("#account_segment_3_lv_id_chosen_results li").count).to eq 2
          # Segment 4: depends on seg2 it should display the child value of the lookup value selected in the 2nd segment
          expense_home.choose_an_account.segment[3].click
          expect(expense_home.segment_4_results).to have_content "Green 1946 (1946)"
          expense_home.choose_an_account.segment[3].click
          expect(find_all("#account_segment_4_lv_id_chosen_results li").count).to eq 1
          # Segment 5: should display only the red lookup values(Red 100/Red 200/Red 500/Red 600)
          expense_home.choose_an_account.segment[4].click
          expect(expense_home.segment_5_results).to have_content "Red 100 (100) Red 1000 (1000) Red 200 (200) Red 900 (900)"
          expense_home.choose_an_account.segment[4].click
          expect(find_all("#account_segment_5_lv_id_chosen_results li").count).to eq 4
        elsif user == italy_user.login
          expense_home.choose_an_account.segment[0].click
          expense_home.select_lookupvalue_on_segment("Blue 200 (200)")
          expense_home.choose_an_account.segment[1].click
          expense_home.select_lookupvalue_on_segment("Green 1945 (1945)")
          expense_home.choose_an_account.segment[2].click
          expense_home.select_lookupvalue_on_segment("Blue 201 (201)")
          expense_home.choose_an_account.segment[3].click
          expense_home.select_lookupvalue_on_segment("Green 1946 (1946)")
          expense_home.choose_an_account.segment[4].click
          expense_home.select_lookupvalue_on_segment("Red 100 (100)")
          expense_home.choose_an_account.choose.click
          expect(expense_home.choose_an_account.errors[0]).to have_content "Your security settings prohibit access to this account."
          expense_home.choose_an_account.segment[4].click
          expense_home.select_lookupvalue_on_segment("Red 200 (200)")
          expense_home.choose_an_account.choose.click
          expect(expense_home.expense_lines.account_details).to have_content "Doha_COA, Blue 200-Green 1945-Blue 201-Green 1946-Red 200, 200-1945-201-1946-200"        
        end
      end
    end

    shared_examples "account display" do |user|
      scenario '' do
        login_as user
        create_expense
        ##### account display #####
        expense_home.expense_lines.account_with_autocomplete.click
        expense_home.expense_lines.account_autocomplete_field.set '200'
        if user == fiji_user.login
          expect(expense_home.account_code_autocomplete_list[0]).to have_content "Red 100-Red 100-Red 200: 100-100-200 (Chennai_COA)"
          expect(expense_home.account_code_autocomplete_list[1]).to have_content "Red 100-Red 200: 100-200 (Chennai_COA)"
          expect(expense_home.account_code_autocomplete_list[2]).to have_content "Red 100-Red 200-Red 100: 100-200-100 (Chennai_COA)"
          expect(expense_home.account_code_autocomplete_list[3]).to have_content "Red 100-Red 200-Red 200: 100-200-200 (Chennai_COA)"
          expect(expense_home.account_code_autocomplete_list[4]).to have_content "Red 100-Red 200-Red 400: 100-200-400 (Chennai_COA)"
          expect(expense_home.account_code_autocomplete_list[5]).to have_content "Red 100-Red 300-Red 200: 100-300-200 (Chennai_COA)"
          expect(expense_home.account_code_autocomplete_list[6]).to have_content "Red 100-Red 400-Red 200: 100-400-200 (Chennai_COA)"
          expect(expense_home.account_code_autocomplete_list[7]).to have_content "Red 200-Red 300-Red 100: 200-300-100 (Chennai_COA)"
        elsif user == colombia_user.login
          expect(expense_home.account_code_autocomplete_list[0]).to have_content "Blue 200--Blue 201--Red 200: 200--201--200 (Delhi_COA)"
          expect(expense_home.account_code_autocomplete_list[1]).to have_content "Blue 200-Green 1981-Blue 201-Green 1982-Red 100: 200-1981-201-1982-100 (Delhi_COA)"
          expect(expense_home.account_code_autocomplete_list[2]).to have_content "Blue 200-Green 1981-Blue 201-Green 1982-Red 200: 200-1981-201-1982-200 (Delhi_COA)"
          expect(expense_home.account_code_autocomplete_list[3]).to have_content "Blue 200-Green 1981-Blue 201-Green 1982-Red 500: 200-1981-201-1982-500 (Delhi_COA)"
          expect(expense_home.account_code_autocomplete_list[4]).to have_content "Blue 200-Green 1981-Blue 202-Green 1982-Red 200: 200-1981-202-1982-200 (Delhi_COA)"
          expect(expense_home.account_code_autocomplete_list[5]).to have_content "Blue 200-Green 2021-Blue 201--Red 200: 200-2021-201--200 (Delhi_COA)"
          expect(expense_home.account_code_autocomplete_list[6]).to have_content "Blue 200-Green 2021-Blue 201-Green 2022-Red 200: 200-2021-201-2022-200 (Delhi_COA)"
          expect(expense_home.account_code_autocomplete_list[7]).to have_content "Blue 7000-Green 1981-Blue 7001-Green 1982-Red 200: 7000-1981-7001-1982-200 (Delhi_COA)"
        elsif user == india_user.login
          expect(expense_home.account_code_autocomplete_list[0]).to have_content "Red 100-Red 200-Red 700-Red 200-Red 200: 100-200-700-200-200 (Qatar_COA)"
          expect(expense_home.account_code_autocomplete_list[1]).to have_content "Red 100-Red 200-Red 700-Red 800-Red 200: 100-200-700-800-200 (Qatar_COA)"
          expect(expense_home.account_code_autocomplete_list[2]).to have_content "Red 700-Red 200-Red 200-Red 800-Red 100: 700-200-200-800-100 (Qatar_COA)"
          expect(expense_home.account_code_autocomplete_list[3]).to have_content "Red 700-Red 700-Red 200-Red 800-Red 800: 700-700-200-800-800 (Qatar_COA)"
        elsif user == japan_user.login
          expect(expense_home.account_code_autocomplete_list[0]).to have_content "Blue 8000-Green 1981-Blue 8001-Green 1982-Red 200: 8000-1981-8001-1982-200 (Doha_COA)"
        elsif user == china_user.login
          # accounts which has 200 as segemnt value and satisfies the chennai_coa_ag_by_seg
          expect(expense_home.account_code_autocomplete_list[0]).to have_content "Red 100-Red 300-Red 200: 100-300-200 (Chennai_COA)"
          expect(expense_home.account_code_autocomplete_list[1]).to have_content "Red 200-Red 300-Red 100: 200-300-100 (Chennai_COA)"
        elsif user == egypt_user.login
          expect(expense_home.account_code_autocomplete_list[0]).to have_content "Blue 200-Green 1981-Blue 201-Green 1982-Red 100: 200-1981-201-1982-100 (Delhi_COA)"
          expect(expense_home.account_code_autocomplete_list[1]).to have_content "Blue 200-Green 1981-Blue 201-Green 1982-Red 200: 200-1981-201-1982-200 (Delhi_COA)"
          expect(expense_home.account_code_autocomplete_list[2]).to have_content "Blue 200-Green 1981-Blue 201-Green 1982-Red 500: 200-1981-201-1982-500 (Delhi_COA)"
          expect(expense_home.account_code_autocomplete_list[3]).to have_content "Blue 200-Green 1981-Blue 202-Green 1982-Red 200: 200-1981-202-1982-200 (Delhi_COA)"
          expect(expense_home.account_code_autocomplete_list[4]).to have_content "Blue 7000-Green 1981-Blue 7001-Green 1982-Red 200: 7000-1981-7001-1982-200 (Delhi_COA)"
        elsif user == paris_user.login
          expect(expense_home.account_code_autocomplete_list[0]).to have_content "Red 100-Red 200-Red 700-Red 200-Red 200: 100-200-700-200-200 (Qatar_COA)"
        elsif user == italy_user.login
          expect(expense_home.account_code_autocomplete_list[0]).to have_content "Blue 8000-Green 1981-Blue 8001-Green 1982-Red 200: 8000-1981-8001-1982-200 (Doha_COA)"
        else
          expect(expense_home.account_code_autocomplete_list[0]).to have_content "Blue 200--Blue 201--Red 200: 200--201--200 (Delhi_COA)"
          expect(expense_home.account_code_autocomplete_list[1]).to have_content "Blue 200-Green 1981-Blue 201-Green 1982-Red 100: 200-1981-201-1982-100 (Delhi_COA)"
          expect(expense_home.account_code_autocomplete_list[2]).to have_content "Blue 200-Green 1981-Blue 201-Green 1982-Red 200: 200-1981-201-1982-200 (Delhi_COA)"
          expect(expense_home.account_code_autocomplete_list[3]).to have_content "Blue 200-Green 1981-Blue 201-Green 1982-Red 500: 200-1981-201-1982-500 (Delhi_COA)"
          expect(expense_home.account_code_autocomplete_list[4]).to have_content "Blue 200-Green 1981-Blue 202-Green 1982-Red 200: 200-1981-202-1982-200 (Delhi_COA)"
          expect(expense_home.account_code_autocomplete_list[5]).to have_content "Blue 200-Green 2021-Blue 201--Red 200: 200-2021-201--200 (Delhi_COA)"
          expect(expense_home.account_code_autocomplete_list[6]).to have_content "Blue 200-Green 2021-Blue 201-Green 2022-Red 200: 200-2021-201-2022-200 (Delhi_COA)"
          expect(expense_home.account_code_autocomplete_list[7]).to have_content "Blue 7000-Green 1981-Blue 7001-Green 1982-Red 200: 7000-1981-7001-1982-200 (Delhi_COA)"
          expect(expense_home.account_code_autocomplete_list[8]).to have_content "Blue 8000-Green 1981-Blue 8001-Green 1982-Red 200: 8000-1981-8001-1982-200 (Doha_COA)"
          expect(expense_home.account_code_autocomplete_list[9]).to have_content "Red 100-Red 100-Red 200: 100-100-200 (Chennai_COA)"
          expect(expense_home.account_code_autocomplete_list[10]).to have_content "Red 100-Red 100-Red 200: 100-100-200 (Pune_COA)"
          expect(expense_home.account_code_autocomplete_list[11]).to have_content "Red 100-Red 200: 100-200 (Chennai_COA)"
          expect(expense_home.account_code_autocomplete_list[12]).to have_content "Red 100-Red 200-Red 100: 100-200-100 (Chennai_COA)"
          expect(expense_home.account_code_autocomplete_list[13]).to have_content "Red 100-Red 200-Red 100: 100-200-100 (Pune_COA)"
          expect(expense_home.account_code_autocomplete_list[14]).to have_content "Red 100-Red 200-Red 200: 100-200-200 (Chennai_COA)"
        end
      end
    end

    context 'feature off' do
      #user without any account restriction
      it_behaves_like "lookup values display and account display for chennai_coa", "US User"
      it_behaves_like "lookup values display and account display for pune_coa", "US User"
      it_behaves_like "lookup values display and account display for delhi_coa", "US User"
      it_behaves_like "lookup values display and account display for qatar_coa", "US User" 
      it_behaves_like "lookup values display and account display for doha_coa", "US User"

      # user restricted to default COA
      it_behaves_like "lookup values display and account display for chennai_coa", "Fiji User"
      it_behaves_like "lookup values display and account display for delhi_coa", "Colombia User"
      it_behaves_like "lookup values display and account display for qatar_coa", "India User"
      it_behaves_like "lookup values display and account display for doha_coa", "Japan User"

      # user restricted to specific account group
      it_behaves_like "lookup values display and account display for chennai_coa", "China User"
      it_behaves_like "lookup values display and account display for delhi_coa", "Egypt User"
      it_behaves_like "lookup values display and account display for qatar_coa", "Paris User"
      it_behaves_like "lookup values display and account display for doha_coa", "Italy User"

      # accounts display fcor different users
      it_behaves_like "account display", "US User"
      it_behaves_like "account display", "Fiji User"
      it_behaves_like "account display", "Colombia User"
      it_behaves_like "account display", "India User"
      it_behaves_like "account display", "Japan User"
      it_behaves_like "account display", "China User"
      it_behaves_like "account display", "Italy User"
      it_behaves_like "account display", "Egypt User"
      it_behaves_like "account display", "Paris User"
    end

    context 'feature ON' do
      before do
        Feature.enable!('enable_account_security_by_coa_only')
      end
      
      let!(:chennai_coa_ag_by_coa) { FactoryGirl.create(:account_group, :with_coa_only, account_type_id: chennai_coa.id, name: "chennai_coa_ag_by_coa", created_by_id: admin.id, updated_by_id: admin.id, ) }
      let!(:pune_coa_ag_by_coa) { FactoryGirl.create(:account_group, :with_coa_only, account_type_id: pune_coa.id, name: "pune_coa_ag_by_coa", created_by_id: admin.id, updated_by_id: admin.id) }
      let!(:delhi_coa_ag_by_coa) { FactoryGirl.create(:account_group, :with_coa_only, account_type_id: delhi_coa.id, name: "delhi_coa_ag_by_coa", created_by_id: admin.id, updated_by_id: admin.id) }
      let!(:qatar_coa_ag_by_coa) { FactoryGirl.create(:account_group, :with_coa_only, account_type_id: qatar_coa.id, name: "qatar_coa_ag_by_coa", created_by_id: admin.id, updated_by_id: admin.id) }
      let!(:doha_coa_ag_by_coa) { FactoryGirl.create(:account_group,:with_coa_only, account_type_id: doha_coa.id, name: "doha_coa_ag_by_coa", created_by_id: admin.id, updated_by_id: admin.id) }

      given!(:austria_user) { FactoryGirl.create(:user, :with_roles, roles: "User, Buyer, Accounts Payable, Expense User , Expense Processor", login: "Austria User", business_group_security_type: 0, account_security_type: 2, account_groups: [chennai_coa_ag_by_coa, delhi_coa_ag_by_coa, qatar_coa_ag_by_coa, doha_coa_ag_by_coa], expense_user: true) }

      #user without any account restriction
      it_behaves_like "lookup values display and account display for chennai_coa", "US User"
      it_behaves_like "lookup values display and account display for pune_coa", "US User"
      it_behaves_like "lookup values display and account display for delhi_coa", "US User"
      it_behaves_like "lookup values display and account display for qatar_coa", "US User"
      it_behaves_like "lookup values display and account display for doha_coa", "US User"

      it_behaves_like "lookup values display and account display for chennai_coa", "Austria User"
      it_behaves_like "lookup values display and account display for delhi_coa", "Austria User"
      it_behaves_like "lookup values display and account display for qatar_coa", "Austria User"
      it_behaves_like "lookup values display and account display for doha_coa", "Austria User"

      # user restricted to default COA
      it_behaves_like "lookup values display and account display for chennai_coa", "Fiji User"
      it_behaves_like "lookup values display and account display for delhi_coa", "Colombia User"
      it_behaves_like "lookup values display and account display for qatar_coa", "India User"
      it_behaves_like "lookup values display and account display for doha_coa", "Japan User"

      # user restricted to specific account group
      it_behaves_like "lookup values display and account display for chennai_coa", "China User"
      it_behaves_like "lookup values display and account display for delhi_coa", "Egypt User"
      it_behaves_like "lookup values display and account display for qatar_coa", "Paris User"
      it_behaves_like "lookup values display and account display for doha_coa", "Italy User"

      # accounts display fcor different users
      it_behaves_like "account display", "US User"
      it_behaves_like "account display", "Fiji User"
      it_behaves_like "account display", "Colombia User"
      it_behaves_like "account display", "India User"
      it_behaves_like "account display", "Japan User"
      it_behaves_like "account display", "China User"
      it_behaves_like "account display", "Italy User"
      it_behaves_like "account display", "Egypt User"
      it_behaves_like "account display", "Paris User"
    end
  end

  def create_expense
    expense_home.load
    wait_for_ajax
    expense_home.add_exp_report.click
    set_expense_lite_date 'today','expense_date'
    expense_home.expense_lines.total.click
    expense_home.expense_lines.total.set '100'
  end
end
