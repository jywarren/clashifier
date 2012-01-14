var $C
// Color-sampling tool
Clash = {
	pointer_x: 0,
	pointer_y: 0,
	mousedown: false,
	samples: new Hash,
	initialize: function() {
		this.element = $('clashifier')
		this.element.observe('mouseup',Clash.on_mouseup)
		this.element.observe('mousedown',Clash.on_mousedown)
		this.element.observe('mousemove',Clash.on_mousemove)
		this.canvas = this.element.getContext('2d');
		$C = this.canvas
		this.element.style.width = document.width+"px"
		this.element.style.height = document.height+"px"
		this.element.width = document.width
		this.element.height = document.height
		this.width = document.width
		this.height = document.height
	},
	on_mousedown: function() {
		Clash.mousedown = true
	},
	on_mouseup: function() {
		Clash.mousedown = false
		Clash.upload()
	},
	// save samples every frame and send them as a batch
	on_mousemove: function(e) {
		var x = Event.pointerX(e)
                var y = Event.pointerY(e)
		Clash.pointer_x = x
                Clash.pointer_y = y
		if (Clash.mousedown) {
			// remember that we've recorded this pixel already (store in x,y hash?)
			if (!Clash.samples.get(x+","+y)) {
				bands = Clash.encode_bands(Clash.get_pixels(x,y))
				Clash.samples.set(x+","+y,bands)
				Clash.put_pixels(x,y)
			// data is sent on button press...
			}
		}
	},
	get_pixels: function(x,y) {
		pixels = $C.getImageData(x,y,1,1).data
		r = pixels[0]
		g = pixels[1]
		b = pixels[2]
		return [r,g,b]
	},
	put_pixels: function(x,y) {
		pixels = $C.getImageData(x,y,1,1)
		pixels.data[0] = 255
		pixels.data[1] = 0
		pixels.data[2] = 0
		$C.putImageData(pixels,x,y)
	},
	encode_bands: function(b) {
		return "{'red':"+b[0]+",'green':"+b[1]+",'blue':"+b[2]+"}"
	},
	upload_batch: function() {
		new Ajax.Request("/classifier/train",{
			method: "post",
			parameters: { 
				author: $('author').value,
				classname: $('classname').value,
				pixels: Clash.samples.toJSON()
			 },
			onSuccess: function(response) {
				$('notification').innerHTML = response.responseText
			}
		})
	},
	upload: function(bands) {
		new Ajax.Request("/classifier/train_pixel",{
			method: "get",
			parameters: { 
				author: $('author').value,
				classname: $('classname').value,
				bands: bands
			 },
			onSuccess: function(response) {
				$('notification').innerHTML = response.responseText
			}
		})
	}
}
