// THIS CODE WILL HAVE A LINK OPEN IN A NEW POPUP
$(document).on('click','a[data-popup]', function(e) {
  window.open($(this)[0].href);
     e.preventDefault();
  });

//THIS CODE WILL DISABLE ANY AUTOCOMPLETE for CSS class == disableAutoComplete
if (document.getElementsByTagName) {
  var inputElements = document.getElementsByTagName("input");
  for (i=0; inputElements[i]; i++) {
    if (inputElements[i].className && (inputElements[i].className.indexOf("disableAutoComplete") != -1)) {
      inputElements[i].setAttribute("autocomplete","off");
    }//if current input element has the disableAutoComplete class set.
  }//loop thru input elements
}//basic DOM-happiness-check

// This allows forms to have unobtrusive JS nested forms.
$(function() {
  $('form a.add_child').click(function() {
    var assoc   = $(this).attr('data-association');
    var content = $('#' + assoc + '_fields_template').html();
    var regexp  = new RegExp('new_' + assoc, 'g');
    var new_id  = new Date().getTime();

    $(this).parent().before(content.replace(regexp, new_id));
    return false;
  });

  $('form').on('click', 'a.remove_child', function() {
    var hidden_field = $(this).prev('input[type=hidden]')[0];
    if(hidden_field) {
      hidden_field.value = '1';
    }
    $(this).parents('.new_fields').remove();
    $(this).parents('.fields').hide();
    return false;
  });
});
