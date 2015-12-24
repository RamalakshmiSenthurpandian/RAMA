require './spec/page_objects/sections/section6.rb'

module Coupa9
	class Choose < SitePrism::Page 
		section :choose, Coupa10::ChooseSection, ".ui-dialog-content.ui-widget-content"
	end
end

