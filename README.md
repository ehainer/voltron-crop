[![Coverage Status](https://coveralls.io/repos/github/ehainer/voltron-crop/badge.svg?branch=master)](https://coveralls.io/github/ehainer/voltron-crop?branch=master)
[![Build Status](https://travis-ci.org/ehainer/voltron-crop.svg?branch=master)](https://travis-ci.org/ehainer/voltron-crop)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)

# Voltron::Crop

Trying to bring a little sanity to the process of cropping images in ruby utilizing Scott Cheng's [cropit](http://scottcheng.github.io/cropit/) plugin and the [CarrierWave](https://github.com/carrierwaveuploader/carrierwave) file uploader.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'voltron-crop', '~> 0.1.3'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install voltron-crop

Then run the following to create the voltron.rb initializer (if not existing already) and add the upload config:

    $ rails g voltron:crop:install

Then, include the necessary js and css by adding the following to your application.js and application.css respectively

```javascript
//= require voltron-crop
```

```css
/*
 *= require voltron-crop
 */
```

If you want to customize the out-of-the-box functionality or styles, you can copy the assets (javascript/css) to your app assets directory by running:

    $ rails g voltron:crop:install:assets

## Usage

Voltron Crop exposes a new form builder method, `crop_field`, that is essentially just an extension of FormBuilder's [file_field](https://apidock.com/rails/ActionView/Helpers/FormBuilder/file_field) method, but automatically handles the creation of necessary data-* attributes on the generated input field that are utilitzed by the crop js module to generate the crop interface.

Given a user model with the following (using [CarrierWave's](https://github.com/carrierwaveuploader/carrierwave) `mount_uploader` method)

```ruby
class User < ActiveRecord::Base
  mount_uploader :avatar, AvatarUploader
end
```

```ruby
<%= form_for @user do |f| %>
  <%= f.crop_field :avatar %>
<% end %>
```

Optionally, any cropit option listed on the [cropit site](http://scottcheng.github.io/cropit/) can be passed as a part of the `data-crop-options` attribute (you would need to modify the js module to change options whose value is a callback function, see Installation above for instructions on extracting the assets for modification):

```ruby
<%= form_for @user do |f| %>
  <%= f.crop_field :avatar, data: { crop_options: { width: 300, height: 300 } } %>
<% end %>
```

## Configuration

After running the installer (see: Installation), configuration options should appear within `config/initializers/voltron.rb`

| Option     | Default      | Comment                                                                                                                                                                                                                                                                                        |
|------------|--------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| min_width  | 300 (pixels) | The minimum width of the cropped image. This does not affect the preview crop size, it only makes a difference when the image itself is cropped. If the cropped image width is less than this value, the image is automatically scaled up proportionally to match this minimum width.    |
| min_height | 300 (pixels) | The minimum height of the cropped image. This does not affect the preview crop size, it only makes a difference when the image itself is cropped. If the cropped image height is less than this value, the image is automatically scaled up proportionally to match this minimum height. |

## Integration

Voltron Crop is designed to work seamlessly with [Voltron Upload](https://github.com/ehainer/voltron-upload), to the point that no changes are necessary to use both together. If Voltron Upload is installed it will still have an effect on file upload fields, even those generated via the `crop_field` method. The built in event observer methods found in the Crop js module (`onBeforeModuleInitializeUpload`, `onUploadComplete`) handles tying the upload module to the crop interface. There is also a built-in upload preview template in the Upload gem that is designed to work well with the crop interface, the `progress` template. If using the Crop and Upload gem together, the following is at the very least a good start for a simple user interface, as the upload container will take the form of a one-off file upload progress bar that changes the crop image when uploaded:

```ruby
<%= form_for @user do |f| %>
  <%= f.crop_field :avatar, preview: :progress %>
<% end %>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ehainer/voltron-crop. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [GNU General Public License](https://www.gnu.org/licenses/gpl-3.0.en.html).

