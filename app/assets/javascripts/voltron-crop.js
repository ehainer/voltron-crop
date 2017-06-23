//= require voltron
//= require cropit
//= require simple-slider

Voltron.addModule('Crop', function(){

  var Crop = function(options, config){

    var _positioned = false;

    var configDefaults = {
      preview: $('<div />', { class: 'cropit-preview' }),
      input: $('<input />', { type: 'file', class: 'cropit-input' }),
      zoom: $('<input />', { type: 'text', class: 'cropit-zoom' }),
      fileInput: null,
      container: null,
      image: null
    };

    var cropDefaults = {
      imageBackground: true,
      imageBackgroundBorderWidth: 100,
      width: 300,
      height: 300,
      onImageLoading: function(){
        var el = this.$fileInput,
            crop = el.data('crop');

        // If the crop class exists on the element, store the current zoom value so
        // we can pick it up later in onImageLoaded callback
        if(crop){
          Voltron.dispatch('crop:loading', { crop: crop, element: el.get(0) });
          el.data('last_zoom', parseFloat(crop.getZoom().val()));
        }
      },
      onImageLoaded: function(){
        // Reset the zoom value to what it was before,
        // then trigger a change event on the input so the image is properly resized
        var el = this.$fileInput,
            crop = el.data('crop'),
            zoom = el.data('last_zoom');

        if(crop && zoom){
          Voltron.dispatch('crop:loaded', { crop: crop, element: el.get(0), data: { zoom: zoom } });
          crop.getZoom().simpleSlider('setRatio', zoom);
          crop.getZoom().data('sliderObject').input.val(zoom).trigger('change');
          crop.setPosition();
        }
      }
    };

    config = $.extend(configDefaults, config);
    options = $.extend(cropDefaults, options);

    return {
      initialize: function(){
        // When the form is submitted, gather the x, y, width, height, zoom inputs
        this.getFileInput().closest('form').on('submit', $.proxy(this.update, this))
        // Add the crop html
        this.getFileInput().before(this.getCropContainer());
        // Initiate the zoom slider
        this.getZoom().simpleSlider();

        // If a cached file is present (form was submitted, but page re-rendered, possibly due to failed validation), include the input
        if(this.getFileInput().data('crop-cache')){
          this.getCropContainer().prepend($('<input />', { type: 'hidden', name: this.getName('cache'), value: this.getFileInput().data('crop-cache') }));
        }

        // If a zoom level was passed, set the slider to the specified zoom level
        if(this.getFileInput().data('crop-zoom')){
          this.getZoom().data('sliderObject').input.val(this.getFileInput().data('crop-zoom')).trigger('change');
        }

        // Include self on the file input element's data
        this.getFileInput().data('crop', this);
      },

      update: function(){
        var dimensions = this.getDimensions(),
            zoom = parseFloat(this.getZoom().val());

        this.getCropContainer().find('.' + this.getFieldName() + '-crop-dimension-x').val(dimensions.x);
        this.getCropContainer().find('.' + this.getFieldName() + '-crop-dimension-y').val(dimensions.y);
        this.getCropContainer().find('.' + this.getFieldName() + '-crop-dimension-w').val(dimensions.w);
        this.getCropContainer().find('.' + this.getFieldName() + '-crop-dimension-h').val(dimensions.h);
        this.getCropContainer().find('.' + this.getFieldName() + '-crop-zoom').val(zoom);
      },

      getDimensions: function(){
        var imageBg = this.getCropObject().$bg,
            borderWidth = this.getCropObject().bgBorderWidthArray,
            cropImage = this.getCropContainer().cropit('imageSize'),
            cropWindow = this.getCropContainer().cropit('previewSize'),
            zoom = this.getCropContainer().cropit('zoom'),
            cropPosition = imageBg.position(),
            cropPercentX = Math.abs(cropPosition.left-borderWidth[3])/(cropImage.width*zoom),
            cropPercentY = Math.abs(cropPosition.top-borderWidth[0])/(cropImage.height*zoom),
            cropPercentW = cropWindow.width/(cropImage.width*zoom),
            cropPercentH = cropWindow.height/(cropImage.height*zoom),
            positionX = Math.abs(cropPosition.left-borderWidth[3]),
            positionY = Math.abs(cropPosition.top-borderWidth[0]),
            cropX = cropImage.width*cropPercentX,
            cropY = cropImage.height*cropPercentY,
            cropW = cropImage.width*cropPercentW,
            cropH = cropImage.height*cropPercentH;

        return { x: cropX, y: cropY, w: cropW, h: cropH };
      },

      setPosition: function(){
        // Only set the position of the image once, after the initial image is loaded
        // For additionl uploads the default positioning should be used
        if(!_positioned){
          var cropImage = this.getCropContainer().cropit('imageSize'),
              x = this.getFileInput().data('crop-x'),
              y = this.getFileInput().data('crop-y'),
              zoom = this.getCropContainer().cropit('zoom');

          x = ((cropImage.width*zoom)*x)/cropImage.width;
          y = ((cropImage.height*zoom)*y)/cropImage.height;

          if(!isNaN(parseFloat(x)) && !isNaN(parseFloat(y))){
            this.getCropContainer().cropit('offset', { x: -x, y: -y });
          }
          _positioned = true;
        }
      },

      getName: function(field){
        return $(config.fileInput).attr('name').replace(/([a-z0-9_]+)\]$/i, '$1_' + field + ']');
      },

      getFieldName: function(){
        return $(config.fileInput).attr('name').replace(/.*\[([a-z0-9_]+)\]$/i, '$1');
      },

      getImage: function(){
        return this.getCropContainer().cropit('imageSrc');
      },

      setImage: function(path){
        this.getCropContainer().cropit('imageSrc', Voltron.getBaseUrl() + path);
      },

      getZoom: function(){
        return $(config.zoom);
      },

      getFileInput: function(){
        return $(config.fileInput);
      },

      getPreview: function(){
        return $(config.preview);
      },

      getDimensionInput: function(){
        var content = $('<div />');
        content.append($('<input />', { type: 'hidden', name: this.getName('x'), class: this.getFieldName() + '-crop-dimension-x' }));
        content.append($('<input />', { type: 'hidden', name: this.getName('y'), class: this.getFieldName() + '-crop-dimension-y' }));
        content.append($('<input />', { type: 'hidden', name: this.getName('w'), class: this.getFieldName() + '-crop-dimension-w' }));
        content.append($('<input />', { type: 'hidden', name: this.getName('h'), class: this.getFieldName() + '-crop-dimension-h' }));
        content.append($('<input />', { type: 'hidden', name: this.getName('zoom'), class: this.getFieldName() + '-crop-zoom' }));
        return content.html();
      },

      getConfig: function(){
        return $.extend(options, {
          imageState: { src: config.image },
          minZoom: 0,
          maxZoom: 2,
          freeMove: false,
          $preview: this.getPreview(),
          $fileInput: this.getFileInput(),
          $zoomSlider: this.getZoom()
        });
      },

      getCropContainer: function(){
        if(config.container === null){
          config.container = $('<div />', { class: 'cropit-container' });
          config.container.append(this.getDimensionInput());
          config.container.append(this.getPreview());
          config.container.append($('<div />', { class: 'zoom-container' }).append(this.getZoom()));

          config.container.cropit(this.getConfig());

          var borderWidth = config.container.data('cropit').bgBorderWidthArray;

          this.getPreview().css({
            marginTop: borderWidth[0],
            marginRight: borderWidth[1],
            marginBottom: borderWidth[2],
            marginLeft: borderWidth[3]
          });
        }
        return config.container;
      },

      getCropObject: function(){
        return this.getCropContainer().data('cropit');
      }
    };
  };

  return {
    initialize: function(){
      $('input[data-crop-image]').each(function(){
        var crop = Voltron('Crop/new', $(this).data('crop-options'), $.extend({ fileInput: this, image: $(this).data('crop-image') }, $(this).data('crop-config')));
        crop.initialize();
      });
    },

    new: function(options, config){
      return new Crop(options, config);
    },

    // START: Compatibility with Voltron Upload module
    // Ensures the crop container is created before the Upload dropzone is instantiated.
    onBeforeModuleInitializeUpload: function(o){
      this.initialize();
    },

    // Updates the crop image when an upload is completed
    onUploadComplete: function(o){
      var crop = $(o.element).data('crop');
      if(o.data.uploads && crop){
        crop.setImage(o.data.uploads.first().url);
      }
    }
    // END: Compatibility with Voltron Upload module
  };
}, true);
