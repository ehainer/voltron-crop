require "rails_helper"

class Template
  extend ActionView::Helpers::FormHelper
end

describe Voltron::Crop::Field do

  let(:user) { User.new }

  let(:builder) { ActionView::Helpers::FormBuilder.new(:user, user, Template, {}) }

  it "can generate crop input markup" do
    image = user.avatar.to_s

    expect(builder.crop_field(:avatar)).to eq("<input data-crop=\"#{image}\" type=\"file\" name=\"user[crop_avatar]\" id=\"user_crop_avatar\" />")
  end

end