/* Written 2010 April 22 by Nathan Vander Wilt */


// monkey-patch known browser events so we get the callbacks we need
OpenLayers.Events.prototype.BROWSER_EVENTS.push("touchstart", "touchmove", "touchend",
												"gesturestart", "gesturechange", "gestureend");


// mimics Handler.Drag for compatibility with Control.DragPan subclass

OpenLayers.Handler.Multitouch = OpenLayers.Class(OpenLayers.Handler, {
	// callbacks: [down move done](e.xy), [zoom](e, dZ)
	
	lastScale: 1,
	
	// OpenLayers.Pixel of previous XY
	last: null,
	
	dragging: false,
	
	touchstart: function(e) {
		if (this.last) {
			// if new finger being added, finish current move sequence first
			this.touchend(e);
		}
		
		this.dragging = false;
		e.xy = this.touchesCenter(e);
		this.callback("down", [e.xy]);
		this.last = e.xy;
		this.lastScale = e.scale;
	},
	
	touchmove: function(e) {
		if (!this.last) {
			// if finger was lifted, start new move sequence instead
			return this.touchstart(e);
		}
		
		this.dragging = true;
		OpenLayers.Event.stop(e);
		
		e.xy = this.touchesCenter(e);
		if (!e.xy.equals(this.last)) {
			this.callback("move", [e.xy]);
		}
		if (e.scale != this.lastScale) {
			var dScale = e.scale - this.lastScale;
			this.callback("zoom", [e, dScale]);
		}
		
		this.last = e.xy;
		this.lastScale = e.scale;
	},
	
	touchend: function(e) {
		e.xy = this.last;
		this.callback("done", [e.xy]);
		this.last = null;
	},
	
	touchcancel: function(e) {
		return this.touchend(e);
	},
	
	touchesCenter: function(e) {
		var touches = e.touches;
		var sumX = 0;
		var sumY = 0;
		for (var i = 0; i < touches.length; ++i) {
			var touch = touches[i];
			sumX += touch.clientX;
			sumY += touch.clientY;
		}
		var fakeEvt = {
			"clientX": sumX / touches.length,
			"clientY": sumY / touches.length
		};
		return this.map.events.getMousePosition(fakeEvt);
	},
	
	CLASS_NAME: "OpenLayers.Handler.Multitouch"
});