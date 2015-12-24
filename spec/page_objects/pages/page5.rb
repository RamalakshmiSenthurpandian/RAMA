require './spec/page_objects/sections/section2.rb'
#require './spec/page_objects/sections/section3.rb'
module With1
	class Id < SitePrism::Page
		set_url "http://e-test.me/idsite/pages/tables.html"
		section :tab, With2::Id2Section,"#page-wrapper"
		#section :next, With3::Id3Section,".dataTables_paginate.paging_simple_numbers"
                                      
	end
end
