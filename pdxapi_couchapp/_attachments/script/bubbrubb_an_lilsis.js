(function() {
  function addBubbRubb() {
    var bubb = document.createElement("script");
    bubb.setAttribute('type', 'text/javascript');
    bubb.src = "http://github.com/maxogden/bubbrubb/raw/master/bubbrubb.js"
    bubb.onload = function() {
      $("#bubbrubb").bubbRubb({feeds: feeds});
    }
    document.body.appendChild(bubb);
  }

  // In case the user doesn't have jQuery, we'll go fetch it all nice like. they up cookin breakfast or something anyway
  if(!window.jQuery) {
    var jquery = document.createElement("script");
    jquery.setAttribute('type', 'text/javascript');
    jquery.src = "http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js";
    jquery.onload = function() {
      addBubbRubb();
    }
    document.body.appendChild(jquery);
  } else {
    addBubbRubb();
  }
})();
