require 'spec_helper'

feature '[App platform] Custom field on categories', type: :feature, js: true, custom_fields: true do
  include SessionHelper
  include LocalesHelper

  locales = YAML.load(File.open('spec/fixtures/locales/locales.yml')).keys

  let(:project_edit_page) { ProjectPage::Edit.new }

  given(:date) { Time.zone.now }
  given!(:project_money_cf) { FactoryGirl.create(:custom_field_attribute_money, model: 'project', col_name: 'custom_field_1', prompt: 'Money field') }
  given!(:project_number_cf) { FactoryGirl.create(:custom_field_attribute_numeric, model: 'project', col_name: 'custom_field_2', prompt: 'Number field') }
  given!(:project_date_cf) { FactoryGirl.create(:custom_field_attribute_datetime, model: "project", col_name: 'custom_field_3', prompt: "date field") }
  given!(:admin_user) { FactoryGirl.create(:admin) }
  given!(:project) { FactoryGirl.create(:project, created_by: admin_user, custom_field_1: Money.new(123456.89, Currency.first.code), custom_field_2: 1234567.89) }

  locales.each do |locale|
    scenario "Currency, Number, date, and money type system and custom fields value on #{locale}" do
      allow(Setup).to receive(:default_timezone).and_return('UTC')
      Time.zone = Setup.default_timezone
      freezed_time = Time.zone.local(2018, 01, 02, 00, 0, 0)
      Timecop.travel(freezed_time)
      I18n.locale = locale
      admin_user.update_attribute(:default_locale, locale)
      Setup.assign(:default_locale, locale)
      login_as admin_user.login
      project_edit_page.load(id: project.id)
      project_edit_page.start_date.set default_date_format(date, I18n.locale)
      project_edit_page.end_date.set default_date_format(date, I18n.locale)
      project_edit_page.money_custom_field_amount[0].set price_humanize(100000001.76, Currency.first.code)
      project_edit_page.money_custom_field_currency[0].select Currency.first.code
      project_edit_page.custom_fields[0].set default_date_format(date, I18n.locale)
      project_edit_page.custom_fields[1].set qty_humanize(1290876489,locale)
      project_edit_page.save.click
      project_edit_page.load(id: project.id)
      expect(project_edit_page.start_date.value).to eq default_date_format(date, I18n.locale)
      expect(project_edit_page.end_date.value).to eq default_date_format(date, I18n.locale)
      expect(project_edit_page.money_custom_field_amount[0].value.gsub(" 100","100").gsub("76 ", "76")).to eq price_humanize(100000001.76, Currency.first.code)
      expect(project_edit_page.custom_fields[0].value).to eq default_date_format(date, I18n.locale)
      expect(project_edit_page.custom_fields[1].value).to have_content qty_humanize(1290876489, I18n.locale)
    end
  end
end
