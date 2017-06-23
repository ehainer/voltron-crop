require 'spec_helper'

class Template
  extend ActionView::Helpers::FormHelper
end

describe Voltron::Crop::Field do

  let(:user) { FactoryGirl.build(:user) }

  let(:builder) { ActionView::Helpers::FormBuilder.new(:user, user, Template, {}) }

  it 'can generate crop input markup' do
    expect(builder.crop_field(:avatar)).to eq("<input data-crop-image=\"#{user.avatar.to_s}\" type=\"file\" name=\"user[avatar]\" id=\"user_avatar\" />")
  end

end