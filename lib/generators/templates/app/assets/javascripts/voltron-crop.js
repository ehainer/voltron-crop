//= require voltron
//= require cropit
//= require simple-slider

Voltron.addModule('Crop', function(){

  var _crops = {};

  var Crop = function(options){

    var _preview = $('<div />', { class: 'cropit-preview' }),
        _input = $('<input />', { type: 'file', class: 'cropit-input' }),
        _zoom = $('<input />', { type: 'text', class: 'cropit-zoom' }),
        _cropper = null,
        _name = 'file',
        _image = null,
        _id = $.now();

    var defaults = {
      imageBackground: true,
      imageBackgroundBorderWidth: 100,
      width: 300,
      height: 300,
      onImageLoading: function(){
        var el = this.$preview.closest('[data-crop]');
        // If the crop class exists on the element, store the current zoom value so
        // we can pick it up later in onImageLoaded callback
        if(el.data('crop')){
          el.data('last_zoom', parseFloat(el.data('crop').getZoom().val()));
        }
      },
      onImageLoaded: function(){
        // Reset the zoom value to what it was before,
        // then trigger a change event on the input so the image is properly resized
        var el = this.$preview.closest('[data-crop]');
        var zoom = el.data('last_zoom');
        el.data('crop').getZoom().simpleSlider('setRatio', zoom);
        el.data('crop').getZoom().data('sliderObject').input.val(zoom).trigger('change');
      }
    };

    options = $.extend(defaults, options);

    return {
      update: function(){
        var dimensions = this.getDimensions();
        this.getCropper().find('.crop-dimension-x').val(dimensions.x);
        this.getCropper().find('.crop-dimension-y').val(dimensions.y);
        this.getCropper().find('.crop-dimension-w').val(dimensions.width);
        this.getCropper().find('.crop-dimension-h').val(dimensions.height);
      },

      getId: function(){
        return _id;
      },

      getDimensions: function(){
        var imageBg = this.getCropObject().$bg;
        var borderWidth = this.getCropObject().bgBorderWidthArray;
        var cropImage = this.getCropper().cropit('imageSize'),
          cropWindow = this.getCropper().cropit('previewSize'),
          zoom = this.getCropper().cropit('zoom'),
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

        return { x: cropX, y: cropY, width: cropW, height: cropH }
      },

      setName: function(name){
        _name = name;
        return this;
      },

      getName: function(field){
        return _name.replace(/([a-z0-9_]+)\]$/i, "$1_" + field + "]");
      },

      setImage: function(image){
        _image = image;
        return this;
      },

      getImage: function(){
        return _image;
      },

      setZoom: function(html){
        _zoom = html;
        return this;
      },

      getZoom: function(){
        return $(_zoom);
      },

      setFileInput: function(html){
        _input = html;
        return this;
      },

      getFileInput: function(){
        return $(_input);
      },

      setPreview: function(html){
        _preview = html;
        return this;
      },

      getPreview: function(){
        return $(_preview);
      },

      getDimensionInput: function(){
        var content = $('<div />');
        content.append($('<input />', { type: 'hidden', name: this.getName('x'), class: 'crop-dimension-x' }));
        content.append($('<input />', { type: 'hidden', name: this.getName('y'), class: 'crop-dimension-y' }));
        content.append($('<input />', { type: 'hidden', name: this.getName('w'), class: 'crop-dimension-w' }));
        content.append($('<input />', { type: 'hidden', name: this.getName('h'), class: 'crop-dimension-h' }));
        return content.html();
      },

      getConfig: function(){
        return $.extend(options, {
          imageState: { src: this.getImage() },
          minZoom: 0,
          maxZoom: 2,
          freeMove: false,
          $preview: this.getPreview(),
          $fileInput: this.getFileInput(),
          $zoomSlider: this.getZoom()
        });
      },

      getCropper: function(){
        if(_cropper === null){
          _cropper = $('<div />', { 'data-crop': this.getId(), class: 'cropit-container' });
          _cropper.data('crop', this);
          _cropper.append(this.getDimensionInput());
          _cropper.append(this.getPreview());
          _cropper.append($('<div />', { class: 'zoom-container' }).append(this.getZoom()));

          _cropper.cropit(this.getConfig());

          var borderWidth = _cropper.data('cropit').bgBorderWidthArray;

          this.getPreview().css({
            marginTop: borderWidth[0],
            marginRight: borderWidth[1],
            marginBottom: borderWidth[2],
            marginLeft: borderWidth[3]
          });

          this.getFileInput().addClass('cropper').data('cropper', _cropper);
        }
        return _cropper;
      },

      getCropObject: function(){
        return this.getCropper().data('cropit');
      }
    };
  };

  return {
    initialize: function(){
      $('input[data-crop]:not(.cropper):visible').each(this.addCrop);
    },

    addCrop: function(){
      var crop = Voltron('Crop/new', this, $(this).data('options'));
      $(this).closest('form').on('submit', $.proxy(crop.update, crop));
      $(this).before(crop.getCropper());
      crop.getZoom().simpleSlider();
    },

    getCrops: function(){
      return _crops;
    },

    getCrop: function(id){
      if(_crops[id]){
        return _crops[id];
      }
      return false;
    },

    new: function(input, options){
      var crop = new Crop(options);
      crop.setFileInput($(input));
      crop.setName($(input).attr('name'));
      crop.setImage($(input).data('crop'));
      _crops[crop.getId()] = crop;
      return crop;
    }
  };
}, true);
