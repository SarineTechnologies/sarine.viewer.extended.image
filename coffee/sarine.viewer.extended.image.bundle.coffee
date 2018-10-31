###!
sarine.viewer - v0.3.6 -  Sunday, April 22nd, 2018, 10:29:11 AM 
 The source code, name, and look and feel of the software are Copyright © 2015 Sarine Technologies Ltd. All Rights Reserved. You may not duplicate, copy, reuse, sell or otherwise exploit any portion of the code, content or visual design elements without express written permission from Sarine Technologies Ltd. The terms and conditions of the sarine.com website (http://sarine.com/terms-and-conditions/) apply to the access and use of this software.
###
class Viewer
  rm = ResourceManager.getInstance();
  constructor: (options) ->
    console.log("")
    @first_init_defer = $.Deferred()
    @full_init_defer = $.Deferred()
    {@src, @element,@autoPlay,@callbackPic} = options
    @id = @element[0].id;
    @element = @convertElement()
    Object.getOwnPropertyNames(Viewer.prototype).forEach((k)-> 
      if @[k].name == "Error" 
          console.error @id, k, "Must be implement" , @
    ,
      @)
    @element.data "class", @
    @element.on "play", (e)-> $(e.target).data("class").play.apply($(e.target).data("class"),[true])
    @element.on "stop", (e)-> $(e.target).data("class").stop.apply($(e.target).data("class"),[true])
    @element.on "cancel", (e)-> $(e.target).data("class").cancel().apply($(e.target).data("class"),[true])
  error = () ->
    console.error(@id,"must be implement" )
  first_init: Error
  full_init: Error
  play: Error
  stop: Error
  convertElement : Error
  cancel : ()-> rm.cancel(@)
  loadImage : (src)-> rm.loadImage.apply(@,[src])
  loadAssets : (resources, onScriptLoadEnd) ->
    # resources item should contain 2 properties: element (script/css) and src.
    if (resources isnt null and resources.length > 0)
      scripts = []
      for resource in resources
          if(resource.element == 'script')
            scripts.push(resource.src + cacheVersion)
          else
            element = document.createElement(resource.element)
            element.href = resource.src + cacheVersion
            element.rel= "stylesheet"
            element.type= "text/css"
            $(document.head).prepend(element)
      
      scriptsLoaded = 0;
      scripts.forEach((script) ->
          $.getScript(script,  () ->
              if(++scriptsLoaded == scripts.length) 
                onScriptLoadEnd();
          )
        )

    return      
  setTimeout : (delay,callback)-> rm.setTimeout.apply(@,[@delay,callback]) 

  # is http/2 supported
  isHTTP2: ()->
    ie = false;
    win7 = false;
    return true;
    try 
      ie = navigator.userAgent.match( /(MSIE |Trident.*rv[ :])([0-9]+)/ )[ 2 ];
      win7 = navigator.userAgent.match( /Windows NT 6.1/ )[0];
    catch e 

    return location.protocol == "https:" && !(win7 && ie)

@Viewer = Viewer 

class SarineExtendedImage extends Viewer
	
	constructor: (options) -> 			
		super(options)		
		{@imagesArr, @borderRadius,@tableInscriptionImageName,@atomSize} = options

	convertElement : () ->				
		@element		

	first_init : ()->
		defer = $.Deferred() 

		if !@tableInscriptionImageName
			@failed()
			defer.resolve(@)
		else 
			defer.notify(@id + " : start load first image1")

		_t = @
		configArray = window.configuration.experiences.filter((i)-> return i.atom == 'tableInscrtiption')
		imgConfig = null
		if (configArray.length != 0)
			imgConfig = configArray[0]


		@fullSrc =  window.stones[0].viewers.resources[@tableInscriptionImageName]
		@loadImage(@fullSrc).then((img)->
			canvas = $("<canvas>")
			ctx = canvas[0].getContext('2d')
			if(img.src.indexOf('data:image') != -1)
				imgName = 'no_stone'
			else
				if(img.src.indexOf('?') != -1)
					className = img.src.substr(0, img.src.indexOf('?'))
					imgName = className.substr((className.lastIndexOf("/") + 1), className.lastIndexOf("/")).slice(0,-4)
				else
					imgName = img.src.substr((img.src.lastIndexOf("/") + 1), img.src.lastIndexOf("/")).slice(0,-4)

    div = $("<div>")
    div.attr({width : _t.atomSize.width, height :  _t.atomSize.height })
    canvas.attr({width : img.width, height :  img.height ,class : imgName})
		canvas.on 'click', (e) => _t.initPopup(_t.fullSrc )
			if _t.borderRadius then canvas.css({'border-radius' : _t.borderRadius})
		  ctx.drawImage(img, 0, 0, img.width, img.height)
      div.appendChild(canvas)
		  _t.element.append(div)
			defer.resolve(_t)
			)
		defer
	failed : () ->
		_t = @ 
		_t.loadImage(_t.callbackPic).then (img)->
			canvas = $("<canvas >")
			canvas.attr({"class": "no_stone" ,"width": img.width, "height": img.height}) 
			canvas[0].getContext("2d").drawImage(img, 0, 0, img.width, img.height)
			_t.element.append(canvas)	
	full_init : ()-> 
		defer = $.Deferred()
		defer.resolve(@)		
		defer
	initPopup : (src)=>
		_t = @
		if($(".storyline").length > 0)then sliderWrap = $(".slider-wrap")
		else
			sliderWrap = $("body").find('div.dashboard')
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
			if _t.inIframe() then gemPrintContainer.addClass('iframe-inscription-container-hide')
			if($('.slider-wrap').length==0) then sliderHeight = sliderWrap.last().height() else sliderHeight = $('.slider-wrap').last().height()
			inscriptionContainer.height(sliderHeight)
			iframeElement = $('<img id="iframe-inscription"  ></img>')
			closeButton = $('<a id="closeInscription">&times;</a>')
			if @addCss
				closeButton.css 'font-size', '35px'
				closeButton.css 'position', 'absolute'
				closeButton.css 	'right', '15px'

			inscriptionContainer.append closeButton
			divContainer.append iframeElement
			inscriptionContainer.append divContainer
			sliderWrap.before inscriptionContainer

		iframeElement.attr 'src', src
		window.scrollTo(0,0)

		sliderWrap.css 'display','none'
		inscriptionContainer.css 'display', 'block'
		closeButton.on 'click', (=>
			sliderWrap.css 'display', 'block'
			inscriptionContainer.css 'display', 'none'
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
		


