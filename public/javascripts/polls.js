// poll javascript

// add an option field
  
function add_option(container_id){
  var container = $(container_id);
  var template = new Template('<p class="option" id="option_#{id}"><input type="text" name="poll[option_attributes][][title]" size="30" /> <a href="#" onclick="Element.remove(\'option_#{id}\')">Cancel</a></p>');
  new Insertion.Bottom(container, template.evaluate({id: new Date().getTime()}));
}


// delete an option 

function delete_option(id, container_id){  
  if(confirm("Really delete this option?")){
    var container = $(container_id);

    // mark option for deletion
    $("option_"+id).down('.should_destroy').value = 1

    // hide the field
    Element.hide("option_"+id);

    // don't redisplay the deletion notice if its already there
    if(typeof $('options').previous("#options-deleted") == 'undefined')
    {
      new Insertion.After('options-title', '<p class="option" id="options-deleted">Removed options will be deleted when you Save this poll.</p>');
    }
    new Effect.Highlight('options-deleted');
  }
}
