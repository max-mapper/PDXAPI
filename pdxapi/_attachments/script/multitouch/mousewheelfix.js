/* Copyright (c) 2006-2008 MetaCarta, Inc., published under the Clear BSD
* license.  See http://svn.openlayers.org/trunk/openlayers/license.txt for the
* full text of the license. */

/* Fix for vertical-only mouse delta in capable browsers
* by Nathan Vander Wilt, 2010 April 13. */


// patch to support vertical-only scrolling (applies to 2.9.1)
OpenLayers.Handler.MouseWheel.prototype.onWheelEvent = function(e) {
		// make sure we have a map and check keyboard modifiers
		if (!this.map || !this.checkModifiers(e)) {
				return;
		}
		
		// Ride up the element's DOM hierarchy to determine if it or any of 
		//  its ancestors was: 
		//   * specifically marked as scrollable
		//   * one of our layer divs
		//   * the map div
		//
		var overScrollableDiv = false;
		var overLayerDiv = false;
		var overMapDiv = false;
		
		var elem = OpenLayers.Event.element(e);
		while((elem != null) && !overMapDiv && !overScrollableDiv) {

				if (!overScrollableDiv) {
						try {
								if (elem.currentStyle) {
										overflow = elem.currentStyle["overflow"];
								} else {
										var style = 
												document.defaultView.getComputedStyle(elem, null);
										var overflow = style.getPropertyValue("overflow");
								}
								overScrollableDiv = ( overflow && 
										(overflow == "auto") || (overflow == "scroll") );
						} catch(err) {
								//sometimes when scrolling in a popup, this causes 
								// obscure browser error
						}
				}

				if (!overLayerDiv) {
						for(var i=0, len=this.map.layers.length; i<len; i++) {
								// Are we in the layer div? Note that we have two cases
								// here: one is to catch EventPane layers, which have a 
								// pane above the layer (layer.pane)
								if (elem == this.map.layers[i].div 
										|| elem == this.map.layers[i].pane) { 
										overLayerDiv = true;
										break;
								}
						}
				}
				overMapDiv = (elem == this.map.div);

				elem = elem.parentNode;
		}
		
		// Logic below is the following:
		//
		// If we are over a scrollable div or not over the map div:
		//  * do nothing (let the browser handle scrolling)
		//
		//    otherwise 
		// 
		//    If we are over the layer div: 
		//     * zoom/in out
		//     then
		//     * kill event (so as not to also scroll the page after zooming)
		//
		//       otherwise
		//
		//       Kill the event (dont scroll the page if we wheel over the 
		//        layerswitcher or the pan/zoom control)
		//
		if (!overScrollableDiv && overMapDiv) {
				if (overLayerDiv) {
						var delta = 0;
						if (!e) {
								e = window.event;
						}
						if (e.wheelDeltaY !== undefined) {
							// WebKit provides full 2-axis wheel info
							delta = e.wheelDeltaY / 120;
						} else if (e.axis !== undefined) {
							// Gecko provides info per axis, since FF3.5
							if (e.axis == e.VERTICAL_AXIS) {
								delta = -e.detail / 3;
							}
						} else if (e.wheelDelta) {
								delta = e.wheelDelta/120; 
								if (window.opera && window.opera.version() < 9.2) {
										delta = -delta;
								}
						} else if (e.detail) {
								delta = -e.detail / 3;
						}
						this.delta = this.delta + delta;

						if(this.interval) {
								window.clearTimeout(this._timeoutId);
								this._timeoutId = window.setTimeout(
										OpenLayers.Function.bind(function(){
												this.wheelZoom(e);
										}, this),
										this.interval
								);
						} else {
								this.wheelZoom(e);
						}
				}
				OpenLayers.Event.stop(e);
		}
};

// also need to fix wheelChange for fractional zoom support (applies to 2.9.1)
OpenLayers.Control.Navigation.prototype.wheelChange = function(evt, deltaZ) {
        var currentZoom = this.map.getZoom();
				var zoomAdjust = (map.fractionalZoom) ? deltaZ : Math.round(deltaZ);
        var newZoom = this.map.getZoom() + zoomAdjust;
        newZoom = Math.max(newZoom, 0);
        newZoom = Math.min(newZoom, this.map.getNumZoomLevels());
        if (newZoom === currentZoom) {
            return;
        }
        var size    = this.map.getSize();
        var deltaX  = size.w/2 - evt.xy.x;
        var deltaY  = evt.xy.y - size.h/2;
        var newRes  = this.map.baseLayer.getResolutionForZoom(newZoom);
        var zoomPoint = this.map.getLonLatFromPixel(evt.xy);
        var newCenter = new OpenLayers.LonLat(
                            zoomPoint.lon + deltaX * newRes,
                            zoomPoint.lat + deltaY * newRes );
        this.map.setCenter( newCenter, newZoom );
    }