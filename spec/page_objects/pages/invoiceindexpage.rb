require './spec/page_objects/sections/section4.rb'
module Coupa3
class Credit <SitePrism::Page
		section :type, Coupa4::InvoiceSection,"#page-container"
	end
end