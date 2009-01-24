// poll javascript

// add an answer field
  
function add_answer(container_id){
  var container = $(container_id);
  var template = new Template('<p class="answer" id="answer_#{id}"><input type="text" name="poll[answer_attributes][][title]" /> <a href="#" onclick="Element.remove(\'answer_#{id}\')">Cancel</a></p>');
  new Insertion.Bottom(container, template.evaluate({id: Math.round(Math.random() * 100000)}));
}


// delete an answer 

function delete_answer(id, container_id){  
  if(confirm("Really delete this answer?")){
    var container = $(container_id);

    // mark answer for deletion
    $("answer_"+id).down('.should_destroy').value = 1

    // hide the field
    Element.hide("answer_"+id);

    // don't redisplay the deletion notice if its already there
    if(typeof $('answers').previous("#answers-deleted") == 'undefined')
    {
      new Insertion.After('answers-title', '<p class="answer" id="answers-deleted">Removed answers will be deleted when you Save this poll.</p>');
    }
    new Effect.Highlight('answers-deleted');
  }
}
