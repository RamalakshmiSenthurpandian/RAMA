describe "retreiving Commodity translation using API filters" do
    let(:user) { FactoryGirl.create(:admin) }
    let(:scopes) { OpenidConnect::OidcScope.where(name: ['core.common.read']) }

    let(:client) do
      OpenidConnect::OidcClient.create(name: 'test client', grant_type: 'authorization_code', system: false, oidc_scopes: scopes)
    end

    let(:token) do
      OpenidConnect::OidcAccessToken.create(oidc_client: client, user: user, oidc_scopes: client.oidc_scopes)
    end

    let!(:user2) { FactoryGirl.create(:user) }

    let(:json_header) { { 'Authorization' => "Bearer #{token.unhashed_token}", 'Accept' => 'application/json' } }

    let!(:text_cf) { FactoryGirl.create(:custom_field_attribute_string, col_name: "custom_field_1", field_name: 'text_cf', prompt: 'text_cf', model: "commodity", editable: true, active: true, api_global_namespace: false) }

    let(:api_filter_with_all_fields) do
      [
        :id,
        :created_at,
        :updated_at,
        :locale,
        :name,
        {
          :"commodity" => [
            :id,
            :created_at,
            :updated_at,
            :active,
            :name,
            :translated_name,
            :deductibility,
            :category,
            :subcategory,
            { :"parent" => [ :id, :created_at, :updated_at, :active, :name, :translated_name, :deductibility, :category, :subcategory, { :custom_fields => {} }, { :created_by => [:id, :login, :email, :employee_number, :firstname, :lastname] }, { :updated_by => [:id, :login, :email, :employee_number, :firstname, :lastname] }] },
            { :custom_fields => {} },
            { :created_by => [:id, :login, :email, :employee_number, :firstname, :lastname] },
            { :updated_by => [:id, :login, :email, :employee_number, :firstname, :lastname] }
          ]
        }
      ]
    end

    let!(:api_filter_with_primary_fields) do
      [
        :id,      
        :created_at,
        :updated_at,
        :locale,
        :name
      ]
    end

    let!(:api_filter_with_primary_and_nested_fields) do
      [
        :id,
        :created_at,
        :updated_at,
        :locale,
        :name,
        { 
          :"commodity" => [
            :id,
            :active,
            :name,
            { :"parent" => [ :id, :active, :name ] }
          ]
        }
      ]
    end

    let!(:parent_commodity) { FactoryGirl.create(:commodity, name: "Parent commodity" , category:'goods', deductibility:'fully_deductible', subcategory:'investment_goods', custom_field_1: "Parent_text", custom_field_2: user2.id, created_by: user, updated_by: user2) }
    let!(:child_commodity) { FactoryGirl.create(:commodity, name: "Child commodity", category:'goods', deductibility:'fully_deductible', subcategory:'investment_goods', custom_field_1: "child_text", custom_field_2: user.id, parent_id: parent_commodity.id, created_by: user, updated_by: user2) }
    let!(:es_commodity_translation) { FactoryGirl.create(:commodity_translation, commodity: child_commodity, locale: 'es', name: "erteyrte") }

    context 'with default filter added' do
      let(:params) { {"filter" => "default_commodity_translations_filter"} }

      it 'should give the API response with the fields added in the API filter' do
        ApiFilter.find_by(name: "default_commodity_translations_filter").update(is_default: true)
        # get "/api/commodity_translations/#{es_commodity_translation.id}", params: params, :headers => {:accept => "application/json", "x-coupa-api-key" => api_key}
        get "/api/commodity_translations/#{es_commodity_translation.id}", params: {}, headers: json_header
        expect(response).to be_success
        response_data = JSON.parse(response.body)
      end
    end

    context 'All fields' do
      let!(:filter_with_all_fields) { FactoryGirl.create(:api_filter, name: 'api_filter_with_all_fields' ,controller_name: 'commodity_translations', controller_action: nil, is_default: true, filter: api_filter_with_all_fields) }
      let(:params) { {"filter" => filter_with_all_fields.name} }

      it 'should give the API response with the fields added in the API filter' do
        get "/api/commodity_translations/#{es_commodity_translation.id}", params: params, headers: json_header
        expect(response).to be_success
        response_data = JSON.parse(response.body)
        binding.pry
      end
    end

    context 'primary fields' do
      let!(:filter_with_primary_fields) { FactoryGirl.create(:api_filter, name: 'api_filter_with_primary_fields' ,controller_name: 'commodity_translations', controller_action: nil, is_default: true, filter: api_filter_with_primary_fields) }
      let(:params) { {"filter" => filter_with_primary_fields.name} }

      it 'should give the API response with the fields added in the API filter' do
        get "/api/commodity_translations/#{es_commodity_translation.id}", params: params, headers: json_header
        expect(response).to be_success
        response_data = JSON.parse(response.body)
        binding.pry
      end
    end

    context 'primary and nested fields' do
      let!(:filter_with_primary_and_nested_fields) { FactoryGirl.create(:api_filter, name: 'api_filter_with_primary_and_nested_fields' ,controller_name: 'commodity_translations', controller_action: nil, is_default: true, filter: api_filter_with_primary_and_nested_fields) }
      let(:params) { {"filter" => filter_with_primary_and_nested_fields.name} }

      it 'should give the API response with the fields added in the API filter' do
        get "/api/commodity_translations/#{es_commodity_translation.id}", params: params, headers: json_header
        expect(response).to be_success
        response_data = JSON.parse(response.body)
        binding.pry
      end
    end
  end
