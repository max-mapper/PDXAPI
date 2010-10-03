OpenLayers.Control.MultitouchNavigation = OpenLayers.Class(OpenLayers.Control.DragPan, {
	draw: function() {
		this.handler = new OpenLayers.Handler.Multitouch(this, {
			"move": this.panMap,
			"done": this.panMapDone,
			"zoom": this.wheelChange
		});
    this.activate();
	},
	
  // NOTE: MouseWheelMonkeyPatches must be loaded for fractionalZoom support!
  wheelChange: function() {
    OpenLayers.Control.Navigation.prototype.wheelChange.apply(this, arguments);
  },
  
	CLASS_NAME: "OpenLayers.Control.MultitouchNavigation"
});
