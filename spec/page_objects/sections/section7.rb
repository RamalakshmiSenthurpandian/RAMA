module Coupa11
	class DesSection <SitePrism::Section
		element :description, ".acitem"
		element :quantity, ".quantity_field_input"
		element :uom, ".uom_field"
		element :price, ".price_field"
		element :imagback, ".pick-billing-template"
		element :accenture, "div[data-account_id='1059']"
	end
end