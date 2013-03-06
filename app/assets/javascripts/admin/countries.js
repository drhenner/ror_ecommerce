jQuery(document).ready(function ($) {
  var selected = 1;
  $countries_select = $('#countries_select');
  $countries_select.on('change', function(){
    selected = $countries_select.val();
    var $link = $('#activate-link');
    var url = $link.attr('href').replace(/(\/+[0-9]{1,9})$/, "/"+selected);
    $link.attr('href', url).click();
  })
});