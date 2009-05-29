// poll javascript

// add an option field
  
function add_option(container_id){
  var container = $(container_id);
  var template = new Template('<p class="option" id="option_#{id}"><input type="text" name="poll[option_attributes][][title]" size="30" /> <a href="#" onclick="Element.remove(\'option_#{id}\')">Cancel</a></p>');
  new Insertion.Bottom(container, template.evaluate({id: new Date().getTime()}));
  $(container).childElements().last().childElements()[0].activate();
}


// delete an option 

function delete_option(id, container_id){  
  if(confirm("Really delete this option?")){
    var container = $(container_id);

    // mark option for deletion
    ($("option_"+id).down('.should_destroy') || $("option_"+id).next('.error-with-field').next('.should_destroy')).value = 1

    // hide the field
    var elem = Element.hide("option_"+id);
    var next_elem = elem.nextSiblings()[0];
    if (next_elem.hasClassName('error-with-field')) {
      next_elem.hide();
    }

    // don't redisplay the deletion notice if its already there
    if(typeof $('options').previous('.title').down('#options-deleted') == 'undefined')
    {
      new Insertion.After('options-title', '<p class="option" id="options-deleted">Removed options will be deleted when you Save this poll.</p>');
    }
    new Effect.Highlight('options-deleted');
  }
}


// rearrange the page contents (works around problems with error messages)

function initialize_page_view() {
  $('options').descendants().findAll(function(obj) {
    return obj.hasClassName('delete');
  }).each(function(obj) {
    obj.nextSiblings()[0].insert({ after:obj.remove() });
  });
}
