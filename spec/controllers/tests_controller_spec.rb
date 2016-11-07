require "rails_helper"

describe TestsController, type: :controller do

  let(:file1) { fixture_file_upload("files/1.jpg", "image/jpeg") }
  let(:file2) { fixture_file_upload("files/file.txt", "text/plain") }
  let(:user) { User.create }

  before(:each) { subject.class.croppable :users }

  it "should crop a valid image" do
    post :create, params: { user: { crop_avatar: { x: 0, y: 0, w: 100, h: 100, image: file1 } } }
    expect(response).to have_http_status(:ok)
  end

  it "should fail with an invalid crop target" do
    expect(user.avatar.to_s).to match(/default\-.*/)

    patch :update, params: { id: user.id, user: { crop_avatar: { x: 0, y: 0, w: 100, h: 100, image: file2 } } }

    expect(user.avatar.to_s).to match(/default\-.*/)
  end

  it "should raise if configured to raise_on_error" do
    Voltron.config.crop.raise_on_error = true

    expect { patch :update, params: { id: user.id, user: { crop_avatar: { x: 0, y: 0, w: 100, h: 100, image: file2 } } } }.to raise_error(MiniMagick::Error)
  end

end
