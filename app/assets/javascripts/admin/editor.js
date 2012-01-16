jQuery(document).ready(function($) {

  var TradeShow = window.TradeShow || { };

  TradeShow.Blog = {
    initialize : function(){
      /*-----------------------------------------------------------
                WMD
      -----------------------------------------------------------*/

      if( $("#wmd-container textarea").length ) {

          $("#wmd-container textarea").elastic();

          if($("#wmd-container textarea").focus()) {
            $("#wmd-container textarea").TextAreaResizer();
          }
      }
      /*-----------------------------------------------------------
                POST CREATE AND DRAFT EDIT
      -----------------------------------------------------------*/

      editPost = function() {
        var title = $("#title-container input").val();

        $(".post h2 a").text(title);
//alert('yuio');
        //1st: Removes all non alphanumeric characters from the string.
        //2nd: No more than one of the separator in a row.
        //3rd: Remove leading/trailing separator.
        var url = "/1234-" + title.replace(/[^a-zA-Z0-9]+/g, "-").replace(/-{2,}/g, "-").replace(/^-|-$/g, "").toLowerCase();

        $("#title-container p").text(url);
      }

      $("#title-container").live("keyup paste focus", function() {
        //alert('live');
        editPost();
      });

      //Only need to load the title in the url preview for the edit draft page
      if($(".draft-title-container").length) {
        editPost();
      }

      /*-----------------------------------------------------------
                HIGHLIGHT.JS
      -----------------------------------------------------------*/

      hljs.tabReplace = '    ';
      hljs.initHighlightingOnLoad();

      //Turn on code highlight for post and draft previews
      $("#wmd-preview").live('click', function() {
        $("pre code").each(function(i, e) {hljs.highlightBlock(e, '    ')});
      });
    }
  }
TradeShow.Blog.initialize();
});