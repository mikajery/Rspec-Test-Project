$(document).on('click', '.ScrollTo', function() {
  var go_to = $(this).attr('href') || $(this).data('href');
  if($(go_to).length > 0) {
    $('html, body').animate({scrollTop:$(go_to).position().top}, 500);
  }
  return false;
});

$(function() {
  var wow = new WOW({
    boxClass:     'wow',      // animated element css class (default is wow)
    animateClass: 'animated', // animation css class (default is animated)
    offset:       0,          // distance to the element when triggering the animation (default is 0)
    mobile:       true,       // trigger animations on mobile devices (default is true)
    live:         true        // act on asynchronously loaded content (default is true)
  });
  wow.init();
});

window.onload = function () {
  // Need to test it in production
  var i = 0,
      max = 0,
      o = null,

      // list of stuff to preload
      preload = [
          window.applicationJsUrl,
          window.applicationCssUrl
      ],
      isIE = navigator.appName.indexOf('Microsoft') === 0;

  for (i = 0, max = preload.length; i < max; i += 1) {
    if (isIE) {
        new Image().src = preload[i];
        continue;
    }
    o = document.createElement('object');
    o.data = preload[i];

    // IE stuff, otherwise 0x0 is OK
    //o.width = 1;
    //o.height = 1;
    //o.style.visibility = "hidden";
    //o.type = "text/plain"; // IE
    o.width  = 0;
    o.height = 0;

    // only FF appends to the head
    // all others require body
    document.body.appendChild(o);
  }
};
