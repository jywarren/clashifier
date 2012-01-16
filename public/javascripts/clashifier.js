var $C
// Color-sampling tool
Clash = {
	header_height: 50,
	pointer_x: 0,
	pointer_y: 0,
	color: "red",
	colors: {
		red: [255,0,0],
		green: [0,255,0],
		blue: [0,0,255],
		yellow: [255,255,0],
	},
	brush_size: 4,
	mousedown: false,
	samples: new Hash(),
	initialize: function() {
		this.element = $('clashifier')
		this.element.observe('mouseup',Clash.on_mouseup)
		this.element.observe('mousedown',Clash.on_mousedown)
		this.element.observe('mousemove',Clash.on_mousemove)
		this.canvas = this.element.getContext('2d');
		$C = this.canvas
		this.width = document.width
		this.height = document.height-100
		this.element.style.width = this.width+"px"
		this.element.style.height = this.height+"px"
		this.element.width = this.width
		this.element.height = this.height
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
                var y = Event.pointerY(e)-Clash.header_height
		Clash.pointer_x = x
                Clash.pointer_y = y
		if (Clash.mousedown) {
			for (var i = -Clash.brush_size/2;i<Clash.brush_size/2;i++) {
			for (var j = -Clash.brush_size/2;j<Clash.brush_size/2;j++) {
				var x1 = x+i, y1 = y+j
				// remember that we've recorded this pixel already (store in x,y hash?)
				if (!Clash.samples.get(x1+","+y1)) {
					bands = Clash.encode_bands(Clash.get_pixels(x1,y1))
					Clash.samples.set(x1+","+y1,bands)
					Clash.put_pixels(x1,y1)
				// data is sent on button press...
				}
			}
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
		pixels.data[0] = Clash.colors[Clash.color][0]
		pixels.data[1] = Clash.colors[Clash.color][1]
		pixels.data[2] = Clash.colors[Clash.color][2]
		$C.putImageData(pixels,x,y)
	},
	encode_bands: function(b) {
		return "{'red':"+b[0]+",'green':"+b[1]+",'blue':"+b[2]+"}"
	},
	upload: function(bands) {
		Clash.notify("saving...")
		new Ajax.Request("/classifier/train",{
			method: "post",
			parameters: { 
				author: $('author').value,
				classname: $(Clash.color).innerHTML, //hacky but gets the classname from the element
				image_url: image_url, //hacky but gets the classname from the element
				pixels: Object.toJSON(Clash.samples)
			 },
			onSuccess: function(response) {
				Clash.notify(response.responseText,3)
			}
		})
	},
	notify: function(message,timeout) {
		$('notification').innerHTML = message
		if (timeout) setTimeout(function(){$('notification').innerHTML = ""},timeout*3000)
	},
	// rename a class/color in the palette
	select_class: function(color,force) {
		if (force || $(color).innerHTML == 'click to name') {
			$(color).innerHTML = prompt("Enter a classname.")
		}
		Clash.color = color
	},
}
