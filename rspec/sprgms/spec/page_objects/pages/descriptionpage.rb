require './spec/page_objects/sections/section7.rb'
module Coupa12
	class Description < SitePrism::Page
		section :descrip, Coupa11::DesSection, "#inv_body"
	end
end
