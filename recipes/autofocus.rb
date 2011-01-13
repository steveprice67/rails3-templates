append_file 'public/javascripts/application.js', <<-EOF
$(document).read(function() {
  // Autofocus q field on search forms if browser doesn't support autofocus
  // attribute on an element.
  if (!("autofocus" in document.createElement("input"))) {
    document.getElementById("q").focus();
  }
});
EOF
