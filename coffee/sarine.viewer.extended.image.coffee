
class SarineExtendedImage extends Viewer
	
	constructor: (options) ->
		super(options)		
		{@imagesArr, @borderRadius,@tableInscriptionImageName,@atomSize} = options

	convertElement : () ->				
		@element		

	first_init : ()->
		defer = $.Deferred() 

		if !@tableInscriptionImageName || !window.stones[0].viewers.resources[@tableInscriptionImageName]
			@failed(->
        return defer.resolve(@)
      )

		else 
			defer.notify(@id + " : start load first image1")

  _t = @
  configArray = window.configuration.experiences.filter((i)-> return i.atom == 'tableInscrtiption')
  imgConfig = null
  if (configArray.length != 0)
    imgConfig = configArray[0]
  _t.fullSrc = window.stones[0].viewers.resources[@tableInscriptionImageName]
  if !_t.fullSrc
    @failed()
    return defer.resolve(@)

		@loadImage(_t.fullSrc).then((img)->
			canvas = $("<canvas>")
			ctx = canvas[0].getContext('2d')
			if(img.src.indexOf('data:image') != -1)
        @failed()
        return defer.resolve(@)
			else
				if(img.src.indexOf('?') != -1)
					className = img.src.substr(0, img.src.indexOf('?'))
					imgName = className.substr((className.lastIndexOf("/") + 1), className.lastIndexOf("/")).slice(0,-4)
				else
					imgName = img.src.substr((img.src.lastIndexOf("/") + 1), img.src.lastIndexOf("/")).slice(0,-4)


    canvas.attr({width : img.width, height :  img.height ,class : imgName})
    canvas.css({width:'100%',height:'100%',cursor: 'pointer'})
    canvas.on 'click', (e) => _t.initPopup(_t.fullSrc )
    if _t.borderRadius then canvas.css({'border-radius' : _t.borderRadius})
    ctx.drawImage(img, 0, 0, img.width, img.height)
    div = $("<div>")
    div.css({width : _t.atomSize.width, height :  _t.atomSize.height,margin:'0 auto'})
    div.append(canvas)
    _t.element.append(div)

			defer.resolve(_t)
			)
		defer
	failed : (callback) ->
    _t = undefined
    _t = this
    _t.loadImage(_t.callbackPic).then(img) ->
      canvas = undefined
      canvas = $('<canvas>')
      canvas.attr
        'class': 'no_stone'
        'width': img.width
        'height': img.height
      canvas[0].getContext('2d').drawImage img, 0, 0, img.width, img.height
      _t.element.append canvas
      callback()
	full_init : ()-> 
		defer = $.Deferred()
		defer.resolve(@)		
		defer
	initPopup : (src)=>
		_t = @
		if($(".storyline").length > 0)then sliderWrap = $(".slider-wrap")
		else
			sliderWrap = $("body").find('.slide--tableInscription')
			@addCss = true
		inscriptionContainer = $('#iframe-inscription-container')
		divContainer = $('<div id="image-container" class="table-img-container">')
		if @addCss
			divContainer.css 'padding-top', '50px'
			divContainer.css 'text-align', 'center'

		iframeElement = $('#iframe-inscription')

		closeButton = $('#closeIframe')
		if (inscriptionContainer.length == 0)
        inscriptionContainer = $('<div id="iframe-inscription-container" class="slider-wrap">')
        if Device.isMobileOrTablet() then inscriptionContainer.addClass('mobile')
        if _t.inIframe() then inscriptionContainer.addClass('iframe-inscription-container-hide')
        if($('.slider-wrap').length==0) then sliderHeight = sliderWrap.last().height() else sliderHeight = $('.slider-wrap').last().height()
        inscriptionContainer.height(sliderHeight)

        iframeElement = $('<img id="iframe-inscription" style="width:100%;height:100%"></img>')
        closeButton = $('<a id="closeInscription">&times;</a>')
        if @addCss
          closeButton.css 'font-size', '35px'
          closeButton.css 'position', 'absolute'
          closeButton.css 	'right', '15px'

        inscriptionContainer.append closeButton
        divContainer.append iframeElement
        inscriptionContainer.append divContainer

     if @addCss then sliderWrap.find('.content').before inscriptionContainer else sliderWrap.prepend inscriptionContainer
     if @addCss then inscriptionContainer.parent().find('.content').css 'display','none'


   iframeElement.attr 'src', src

	 inscriptionContainer.css 'display', 'block'

	 closeButton.on 'click', (=>
       inscriptionContainer.css 'display', 'none'
       inscriptionContainer.parent().find('.content').css 'display','block'
			    return
		)

	inIframe :()->
		try
			return window.self != window.top
		catch e
			return true
		return

	play : () -> return		
	stop : () -> return

@SarineExtendedImage = SarineExtendedImage
		
