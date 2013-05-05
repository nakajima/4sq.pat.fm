@Template = 
  render: (name, context) ->
    content = $("#_template_#{name}").html()
    Mustache.render(content, context)