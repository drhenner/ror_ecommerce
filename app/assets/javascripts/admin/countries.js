jQuery(document).ready(function ($) {
  var selected = 1;
  $countries_select = $('#countries_select');
  $countries_select.on('change', function(element){
    var selected = $(element.target).val();
    var $link = $('#activate-link');
    if (selected) {
      url = $link.attr('href', "/admin/config/countries/" + selected + '/activate').click();
    }
  })
});
