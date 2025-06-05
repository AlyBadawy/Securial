include Securial::Engine.routes.url_helpers

RSpec.shared_examples "unauthorized request" do |http_method, path_lambda, type, params_lambda = nil|
  let(:path) { instance_exec(&path_lambda) }
  let(:method) { http_method.to_sym }
  let(:params) { params_lambda ? instance_exec(&params_lambda) : {} }

  it "returns 401 Unauthorized with #{type.to_s.titleize}" do
    case type
    when :no_token
      headers = {}
    when :invalid_token
      headers = { "Authorization" => "Bearer INVALID" }
    when :regular_user
      headers = {
        'Authorization' => Securial::Auth::AuthEncoder.encode(create(:securial_session)),
        'Accept' => 'application/json',
        'Content-Type' => 'application/json', "User-Agent" => "Ruby/RSpec",
      }
    end

    case http_method.to_sym
    when :get
      get path, headers: headers, as: :json
    when :post
      post path, headers: headers, as: :json, params: params
    when :put
      put path, headers: headers, as: :json, params: params
    when :patch
      patch path, headers: headers, as: :json, params: params
    when :delete
      delete path, headers: headers, as: :json
    end

    expect(response).to have_http_status(:unauthorized)
  end
end
