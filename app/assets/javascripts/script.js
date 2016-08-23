$(document).ready(function() {

  $.ajaxSetup({
    headers: {
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    }
  });
  
  $("#start_crunching").unbind('click').on("click", function(){
    var hashtag = $("#hashtag").val();
    if(verify_hashtag(hashtag)){
      $.ajax({
        url: "/crunch_tweets/tag",
        type: "post",
        dataType: 'json',
        data: { hashtag: hashtag},
        success:function(data) {
          if(data["success"]==true){
            $("#crunch_tweets").hide('slow');
            $("#stats").show();
            console.log(data);
            update_stats(hashtag);
          }
          else{
           display_error(data["message"]);
          }
        },
        error: function(error){
          console.log(error);
        }
      });
    }
    else{
      display_error("Invalid hashta!<br/>Valid Params Length between 1 and 140 and does not include . or space");
    }
  });

  function update_stats(hashtag){
    $.ajax({
      url: "/crunch_tweets/update_stats",
      type: "get",
      data: { hashtag: hashtag},
      success:function(data) {
        if(data["success"]==true){
          $("#stats").html("Crunched #" + data["hashtag"] + "with " + data["total_tweets"] + " tweets and " + data["total_users"] + "<br/>Most tweets by user " + data["user_with_most_tweets"]);
        }
        else{
          display_error( (data["message"] || "An expected errror occured") );
        }
        setTimeout(function(){
          update_stats(hashtag);
        }, 5000);
      },
      error: function(error){
        console.log(error);
      }
    });
  }

  function verify_hashtag(hashtag){
    if(hashtag.length==0 || hashtag.length>140 || hashtag.includes(" ") || hashtag.includes(".")){
      return false;
    }
    else{
      return true;
    }
  }

  function display_error(message){
    $("#error").html("An error occured with message: " + message);
    $("#error").show();
    setTimeout( function(){
      $("#error").hide('slow');
      $("#error").html();
    }, 5000);
  }

});  