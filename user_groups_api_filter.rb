describe 'User groups using API filters' do
    let(:user) { FactoryGirl.create(:user, :with_roles, roles: ['Buyer, User']) }
    let(:scopes) { OpenidConnect::OidcScope.where(name: ['core.user_group.read']) }

    let(:client) do
      OpenidConnect::OidcClient.create(name: 'test client', grant_type: 'authorization_code', system: false, oidc_scopes: scopes)
    end

    let(:token) do
      OpenidConnect::OidcAccessToken.create(oidc_client: client, user: user, oidc_scopes: client.oidc_scopes)
    end

    let!(:user2) {  FactoryGirl.create(:user, :with_roles, roles: ['Buyer, User']) }

    let(:json_header) { { 'Authorization' => "Bearer #{token.unhashed_token}", 'Accept' => 'application/json' } }

    let!(:text_cf) { FactoryGirl.create(:custom_field_attribute_string, col_name: "custom_field_1", field_name: 'text_cf', prompt: 'text_cf', model: "user_group", editable: true, active: true, api_global_namespace: false) }

    let!(:group1) { FactoryGirl.create(:user_group, name: "group1", open: true, description: "group1 description", created_by_id: user.id, updated_by_id: user.id, custom_field_1: "group1 text", users: [user]) }
    let!(:group2) { FactoryGirl.create(:user_group, name: "group2", open: true, description: "group2 description", created_by_id: user2.id, updated_by_id: user2.id, custom_field_1: "group2 text", users: [user2], owner: group1) }

    let(:api_filter_with_all_fields) do
      [
        :id,
        :created_at,
        :updated_at,
        :name,
        :active,
        :open,
        :can_approve,
        :description,
        :mention_name,
        :type,
        :avatar_thumb_url,
        { :"owner" => [ :id, :created_at, :updated_at, :name, :active, :open, :type, :can_approve, :description, :mention_name, :avatar_thumb_url, { :"users" => [ :id, :login, :email, :employee_number, :firstname, :lastname] }, { :"content_groups" => [ :id, :created_at, :updated_at, :name, :description, { :updated_by => [:id, :login, :email, :employee_number, :firstname, :lastname] } ] }, { :custom_fields => {} }, { :created_by => [:id, :login, :email, :employee_number, :firstname, :lastname] }, { :updated_by => [:id, :login, :email, :employee_number, :firstname, :lastname] } ] },
        { :"users" => [ :id, :login, :email, :employee_number, :firstname, :lastname] },
        { :"content_groups" => [ :id, :created_at, :updated_at, :name, :description, { :updated_by => [:id, :login, :email, :employee_number, :firstname, :lastname] } ] },
        { :custom_fields => {} },
        { :created_by => [:id, :login, :email, :employee_number, :firstname, :lastname] },
        { :updated_by => [:id, :login, :email, :employee_number, :firstname, :lastname] }
      ]
    end

    context 'with default filter added' do
      let(:params) { {"filter" => "default_user_groups_filter"} }

      it 'should give the API response with the fields added in the API filter' do
        ApiFilter.find_by(name: "default_user_groups_filter").update(is_default: true)
        get "/api/user_groups/#{group1.id}", params: params, headers: json_header
        expect(response).to be_success
        response_data = JSON.parse(response.body)
      end
    end

    context 'All fields' do
      let!(:filter_with_all_fields) { FactoryGirl.create(:api_filter, name: 'api_filter_with_all_fields' ,controller_name: 'user_groups', controller_action: nil, is_default: true, filter: api_filter_with_all_fields) }
      let(:params) { {"filter" => filter_with_all_fields.name} }
      it 'should give the API response with the fields added in the API filter' do
        get "/api/user_groups/#{group2.id}", params: params, headers: json_header
        expect(response).to be_success
        response_data = JSON.parse(response.body)
      end
    end
  end
