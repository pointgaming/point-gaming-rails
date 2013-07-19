(function(window){
  "use strict";

  window.PointGaming.views.home_about = window.PointGaming.views.base.extend({

    initialize: function(){

      //Wistia embed
      var wistiaEmbed = Wistia.embed("eb49updl7z", {
        version: "v1",
        videoWidth: 855,
        videoHeight: 481,
        videoFoam: true,
        volumeControl: true,
        controlsVisibleOnLoad: false,
        autoPlay: true
      });
      
      //Display video on click of thumbnail
      $('.video-thumbnail').click(function(){
        $(".index, .screen").slideUp(200);
        $(".close_video, .wistia_embed_script, .wistia_embed").delay(200).fadeIn(800);
      });
      
      //Close Video button
      $('.close_video').click(function(){
        $(".wistia_embed_script, .wistia_embed, .close_video").slideUp(400);
        $(".index, .screen").delay(400).slideDown(400);
        wistiaEmbed.pause();
      });
      
      //Sign Up -- Slide up video and display form and checkboxes
      //Pause video if currently playing
      $('.signup').click(function(){
        $(".screen, .wistia_embed_script, .wistia_embed, .close_video").slideUp(200);
        $(".signup, .signup_complete").fadeOut(200);
        $(".signup_form,.index").delay(200).slideDown(200); 
        wistiaEmbed.pause();
      }); 
      
      //Cancel
      $('.cancel').click(function(){
        $(".signup_form").slideUp(400);
        $(".screen").delay(200).slideDown(400);
        $(".signup").delay(400).slideDown(400);
      });
      
      //when video ends: close player and show index text and sign up form
      wistiaEmbed.bind("end", function () {
        $(".signup, .wistia_embed_script, .wistia_embed, .close_video").delay(200).slideUp(400);
        $(".index, .signup_form").delay(600).slideDown(400);
      });

      //Animated jquery scroller
      $(".nav_link, .top").click(function(event){   
        event.preventDefault();
        $('html,body').animate({scrollTop: 0}, 500);
      });
      
      //Display FB like buttons
      $('.fb-button').click(function(){
        $(".fb-like").toggleClass("fb-like-display", 200);
        $(".fb-like-extras").slideToggle(200);
      });

      (function(d, s, id) {
        var js, fjs = d.getElementsByTagName(s)[0];
        if (d.getElementById(id)) return;
        js = d.createElement(s); js.id = id;
        js.src = "//connect.facebook.net/en_US/all.js#xfbml=1";
        fjs.parentNode.insertBefore(js, fjs);
      }(document, 'script', 'facebook-jssdk'));

    },
    
    bindEvents: function() {
    }

  });

})(window);
