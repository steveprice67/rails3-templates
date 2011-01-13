file 'app/helpers/layout_helper.rb', <<-EOF
module LayoutHelper
  def title(page_title, show_title = true)
    content_for(:title) { h(page_title.to_s) }
    @show_title = show_title
  end

  def show_title?
    @show_title
  end
end
EOF

remove_file 'app/views/layouts/application.html.erb'
file 'app/views/layouts/application.html.erb', <<-EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title><%= content_for?(:title) ? yield(:title) : '#{app_const_base}' %></title>
  <%= stylesheet_link_tag :all %>
  <%= javascript_include_tag :defaults %>
  <%= csrf_meta_tag %>
</head>
<body>
  <div id="header">
    {{header}}
  </div>
  <div id="navigation">
    {{navigation}}
  </div>
  <div id="content">
    <% flash.each do |name, msg| %>
      <%= content_tag :div, msg, :id => "flash_\#{name}" %>
    <% end %>
    <%= content_tag :h2, yield(:title) if show_title? %>
    <%= yield %>
  </div>
  <div id="footer">
    Copyright &copy;2011, #{app_const_base}. All rights reserved.
  </div>
</body>
</html>
EOF

file 'app/views/shared/_error_messages.html.erb', <<-EOF
<% if target.errors.any? %>
  <div id="error_explanation">
    <h2><%= pluralize(target.errors.count, "error") %> prohibited this <%=h target.class.to_s.underscore.downcase.gsub(/_/, ' ') %> from being saved:</h2>
    <ul>
    <% target.errors.full_messages.each do |msg| %>
      <li><%= msg %></li>
    <% end %>
    </ul>
  </div>
<% end %>
EOF

file 'public/stylesheets/application.css', <<-EOF
html, body {
  margin: 0;
  padding: 0;
  background-color: white;
  font-family: Verdana, Helvetica, Arial;
  font-size: 14px;
}
div#header {
  padding: 5px;
  background-color: #DDDDDD;
}
div#navigation {
  margin-left: 0.5%;
  margin-top: 0.5%; 
  padding: 0.5%;
  width: 15%;
  float: left;
}
div#content {
  margin: 0;
  margin-left: 16%;
  border-left: solid #DDDDDD 2px;
  padding: 1%;
}
div#footer {
  clear: both;
  padding: 5px;
  background-color: #DDDDDD;
  font-size: 10px;
  text-align: right;
}
div#navigation ul {
  list-style: none;
  margin: 0;
  padding: 2px;
}
#flash_notice, #flash_error, #flash_alert {
  padding: 5px 5px;
  margin: 5px 0;
}
#flash_notice {
  background-color: #CFC;
  border: solid 1px #6C6;
}
#flash_error, #flash_alert {
  background-color: #FCC;
  border: solid 1px #C66;
}
h1, h2 {
  margin: 0 0 5px 0;
  padding: 0;
}
EOF
