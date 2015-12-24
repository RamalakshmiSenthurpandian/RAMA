require './spec/page_objects/sections/section5.rb'
module Coupa8
class Accounting<SitePrism::Page
		section :type1, Coupa7::Fill1,".right_top"
	end
end