shared_context 'authentication', authentication: true do
  let(:sign_in?) {true}

  before {sign_in current_user if sign_in?}

  context 'unauthenticated' do
    let(:sign_in?) {false}

    response do
      it {should have_http_status(:redirect)}
      it {should redirect_to(new_user_session_path)}
    end

    describe 'flash' do
      it {should set_flash[:alert].to('You need to sign in or sign up before continuing.')}
    end
  end
end
