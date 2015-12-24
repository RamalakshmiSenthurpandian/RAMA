require 'spec_helper'
module With 
	step 'I am on the etest page and click the button testing withid' do
		obj=Service::Etest.new
		obj.load
		#obj.test_withid.click
    end
    step 'I click tables' do
    	@obj1=With1::Id.new
    	@obj1.load
    end
    step 'I click the element engine in section tab' do
        @obj1.tab.engine.click
        sleep 2
    end
    step 'I click the element in nextbutton in section tab' do
        @obj1.tab.nextbutton.click
        sleep 10
    end
        

end
RSpec.configure{|c| c.include With}	 
  