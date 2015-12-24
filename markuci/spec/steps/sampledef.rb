require 'spec_helper'
 module Server
step 'I am on homepage' do
	#visit 'http:/localhost:3000/users'
	obj=Sample::Index.new
	obj.load
	obj.new_user.click
	
	sleep 5
end
step 'I will enter the details' do
	obj1=Page2::Create.new
	obj1.user_name.set "Ram"
	obj1.user_emp_no.set "55"
	obj1.user_dept.set "Automation"
	obj1.user_address.set "main road,vadapalani"
	obj1.commit.click
	sleep 5
	obj1.back.click
	sleep 10
end
step 'I will edit and update the users' do 
	obj=Sample::Index.new
	obj.link_to "Edit",5.click
	sleep 3
end
end
RSpec.configure{|c| c.include Server}
