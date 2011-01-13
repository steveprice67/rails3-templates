gem 'cancan'
run 'bundle install'

user = ask 'What do you want to name the user model? [user]'
user = 'user' if user.blank?
User = user.capitalize
users = user.pluralize

join_table = ['roles', users].sort.join('_')

num = next_migration_number
file "db/migrate/#{num}_create_#{users}.rb", <<-EOF
class Create#{users.capitalize} < ActiveRecord::Migration
  def self.up
    create_table :#{users} do |t|
      t.string :username, :null => false
      t.string :password_digest, :limit => 128, :default => '',
        :null => false
      t.string :password_salt, :default => '', :null => false
      t.timestamps
    end
    add_index :#{users}, :username, :unique => true
  end
  def self.down
    drop_table :#{users}
  end
end
EOF

num = next_migration_number
file "db/migrate/#{num}_create_roles.rb", <<-EOF
class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name
      t.timestamps
    end
    add_index :roles, :name
  end
  def self.down
    drop_table :roles
  end
end
EOF

num = next_migration_number
file "db/migrate/#{num}_create_#{join_table}.rb", <<-EOF
class Create#{join_table.camelize} < ActiveRecord::Migration
  def self.up
    create_table :#{join_table}, :id => false do |t|
      t.references :role
      t.references :#{user}
    end
    add_index :#{join_table}, :role_id
    add_index :#{join_table}, :#{user}_id
  end
  def self.down
    drop_table :#{join_table}
  end
end
EOF

compat = (user == 'user') ? "" : <<-EOF
  alias :current_user :current_#{user}
  helper_method :current_user

EOF
file 'app/controllers/application_controller.rb', <<-EOF
class ApplicationController < ActionController::Base
  protect_from_forgery
  rescue_from CanCan::AccessDenied, :with => :permission_denied

  helper_method :current_#{user}, :signed_in?

  def current_#{user}
    return @current_#{user} if defined? @current_#{user}
    @current_#{user} = #{User}.find(session[:#{user}_id]) if session[:#{user}_id]
    @current_#{user} ||= #{User}.new
  end
#{compat}
  def signed_in?
     !session[:#{user}_id].blank?
  end

  protected

  def authenticate
    unless current_#{user}.persisted?
      session[:return_to] = request.fullpath
      redirect_to login_path,
        :notice => 'You must be logged in to access this page.'
    end
  end

  private

  def permission_denied(exception)
    flash[:alert] = exception.message
    redirect_to root_path
  end
end
EOF

file 'app/controllers/roles_controller.rb', <<-EOF
class RolesController < ApplicationController
  before_filter :authenticate
  load_and_authorize_resource

  def index
  end

  def show
    redirect_to roles_url
  end

  def new
  end

  def edit
  end

  def create
    if @role.save
      redirect_to roles_path, :notice => 'Role created.'
    else
      render :action => "new"
    end
  end

  def update
    if @role.update_attributes(params[:role])
      redirect_to roles_path, :notice => 'Role updated.'
    else
      render :action => "edit"
    end
  end

  def destroy
    @role.destroy
    redirect_to roles_path
  end
end
EOF

file "app/controllers/#{user}_sessions_controller.rb", <<-EOF
class UserSessionsController < ApplicationController
  def new
    @#{user} = #{User}.new
  end

  def create
    if #{user} = #{User}.authenticate!(params[:#{user}])
      return_to = session[:return_to]
      reset_session
      session[:#{user}_id] = #{user}.id
      redirect_to return_to || root_path, :notice => "Welcome \#{#{user}.username}."
    else
      params[:#{user}].delete(:password)
      @#{user} = #{User}.new(params[:#{user}])
      flash[:error] = 'Authentication failed.'
      render :action => 'new'
    end
  end

  def destroy
    #{user}_id = session[:saved_#{user}_id]
    reset_session
    if #{user}_id && #{user} = #{User}.find(#{user}_id)
      session[:#{user}_id] = #{user}_id
      flash[:notice] = "Welcome back \#{#{user}.username}."
    else
      flash[:notice] = "Successfully logged out."
    end
    redirect_to root_path
  end
end
EOF

file "app/controllers/#{users}_controller.rb", <<-EOF
class #{users.capitalize}Controller < ApplicationController
  before_filter :authenticate
  before_filter :clean_params, :only => [:update]
  load_and_authorize_resource

  def index
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    if @#{user}.save
      redirect_to @#{user}, :notice => '#{User} created.'
    else
      render :action => "new"
    end
  end

  def update
    if @#{user}.update_attributes(params[:#{user}])
      redirect_to @#{user}, :notice => '#{User} updated.'
    else
      render :action => "edit"
    end
  end

  def destroy
    @#{user}.destroy
    redirect_to #{users}_path
  end

  def become
    session[:saved_#{user}_id] = current_#{user}.id
    session[:#{user}_id] = @#{user}.id
    redirect_to root_path
  end

  private

  def clean_params
    params[:#{user}].delete(:password) if params[:#{user}][:password].blank?
    params[:#{user}].delete(:password_confirmation) if params[:#{user}][:password_confirmation].blank?

    if current_#{user}.admin?
      params[:#{user}][:role_ids] ||= []
    else
      params[:#{user}][:role_ids].delete(:role_ids)
    end
  end
end
EOF

file 'app/models/ability.rb', <<-EOF
class Ability
  include CanCan::Ability

  def initialize(#{user})
    alias_action :update, :destroy, :to => :modify

    if #{user}.admin?
      can :manage, :all
      can :become, #{User}
    else
      can :manage, #{User}, :id => #{user}.id
    end

    cannot :modify, Role, :id => 1
    cannot :destroy, #{User}, :id => 1
  end
end
EOF

file 'app/models/role.rb', <<-EOF
class Role < ActiveRecord::Base
  before_validation :normalize_name

  attr_accessible :name

  validates_presence_of :name
  validates_length_of :name, :within => 3..32
  validates_uniqueness_of :name

  has_and_belongs_to_many :#{users}

  def to_sym
    name.to_sym
  end

  private

  def normalize_name
    self.name = self.name.strip.downcase.gsub(/\s+/, '_')
  end
end
EOF

file "app/models/#{user}.rb", <<-EOF
require 'digest/sha1'

class #{User} < ActiveRecord::Base
  before_save :encrypt_password
  before_save :preserve_admin

  attr_accessor :password, :password_confirmation
  attr_accessible :username, :password, :password_confirmation, :role_ids

  validates :username, :presence => true, :uniqueness => true,
    :length => {:minimum => 3}
  validates :password, :presence => true, :confirmation => true,
    :length => {:minimum => 8}, :if => :password_required?

  has_and_belongs_to_many :roles

  def self.authenticate!(params)
    #{user} = find_by_username(params[:username])
    #{user} && #{user}.authenticates?(params[:password]) ? #{user} : nil
  end

  def admin?
    is? :admin
  end

  def is?(role)
    roles.map(&:to_sym).include? role
  end

  protected

  def authenticates?(password)
    password_digest == _encrypt(password)
  end

  def encrypt_password
    return if password.blank?
    self.password_salt = Digest::SHA1.hexdigest([Time.now, rand].join)
    self.password_digest = _encrypt(password)
  end

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  def preserve_admin
    role_ids << 1 if id == 1 && !role_ids.include?(1)
  end

  private

  def _encrypt(password)
    Digest::SHA1.hexdigest([password_salt, password].join)
  end
end
EOF

file 'app/views/roles/_form.html.erb', <<-EOF
<%= form_for(@role) do |f| %>
  <%= render 'shared/error_messages', :target => @role %>
  <div class="field">
    <%= f.label :name %><br />
    <%= f.text_field :name %>
  </div>
  <div class="actions">
    <%= f.submit %>
  </div>
<% end %>
EOF

file 'app/views/roles/edit.html.erb', <<-EOF
<% title 'Editing role' -%>
<%= render 'form' %>
<%= link_to 'Back', roles_path %>
EOF

file 'app/views/roles/index.html.erb', <<-EOF
<% title 'Listing roles' -%>
<table>
  <tr>
    <th>Name</th>
    <th></th>
  </tr>
<% @roles.each do |role| %>
  <tr>
    <td><%= role.name %></td>
    <td>
      <% if can? :modify, role %><%= link_to 'edit', edit_role_path(role) %><% end %>
      <% if can? :destroy, role %><%= link_to 'destroy', role, :confirm => 'Are you sure?', :method => :delete %><% end %>
    </td>
  </tr>
<% end %>
</table>
<br />
<% if can? :new, Role %><%= link_to 'New Role', new_role_path %><% end %>
EOF

file 'app/views/roles/new.html.erb', <<-EOF
<% title 'New Role' -%>
<%= render 'form' %>
<%= link_to 'Back', roles_path %>
EOF

file "app/views/#{user}_sessions/new.html.erb", <<-EOF
<% title 'Login' -%>
<%= form_for(@#{user}, :url => #{user}_sessions_path) do |f| %>
  <p>
    <%= f.label :username %><br />
    <%= f.text_field :username %>
  </p>
  <p>
    <%= f.label :password %><br />
    <%= f.password_field :password %>
  </p>
  <p><%= f.submit 'login' %></p>
<% end -%>
EOF

file "app/views/#{users}/_form.html.erb", <<-EOF
<%= form_for(@#{user}) do |f| %>
  <%= render 'shared/error_messages', :target => @#{user} %>
  <div class="field">
    <%= f.label :username %><br />
    <%= f.text_field :username %>
  </div>
  <div class="field">
    <%= f.label :password %><br />
    <%= f.password_field :password %>
  </div>
  <div class="field">
    <%= f.label :password_confirmation %><br />
    <%= f.password_field :password_confirmation %>
  </div>
<% if current_#{user}.admin? -%>
  <div class="field">
    <ul>
      <%= habtm_checkboxes(@#{user}, :role_ids, Role.all, :name) %>
    </ul>
  </div>
<% end -%>
  <div class="actions">
    <%= f.submit %>
  </div>
<% end %>
EOF

file "app/views/#{users}/edit.html.erb", <<-EOF
<h1>Editing #{user}</h1>
<%= render 'form' %>
<%= link_to 'Show', @#{user} %> |
<%= link_to 'Back', #{users}_path %>
EOF

file "app/views/#{users}/index.html.erb", <<-EOF
<% title 'Listing #{users}' -%>
<table>
  <tr>
    <th>Username</th>
    <th></th>
  </tr>
<% @#{users}.each do |#{user}| %>
  <tr>
    <td><%= #{user}.username %></td>
    <td>
      <% if can? :read, #{user} %><%= link_to 'show', #{user} %><% end %>
      <% if can? :modify, #{user} %><%= link_to 'edit', edit_#{user}_path(#{user}) %><% end %>
      <% if can? :destroy, #{user} %><%= link_to 'destroy', #{user}, :confirm => 'Are you sure?', :method => :delete %><% end %>
      <% if current_#{user}.id != #{user}.id && can?(:become, #{user}) %><%= link_to 'become', become_#{user}_path(#{user}) %><% end %>
    </td>
  </tr>
<% end %>
</table>
<br />
<%= link_to 'New #{User}', new_#{user}_path %>
EOF

file "app/views/#{users}/new.html.erb", <<-EOF
<% title 'New #{User}' -%>
<%= render 'form' %>
<%= link_to 'Back', #{users}_path %>
EOF

file "app/views/#{users}/show.html.erb", <<-EOF
<p>
  <b>Username:</b>
  <%= @#{user}.username %>
</p>
<%= link_to 'Edit', edit_#{user}_path(@#{user}) %> |
<%= link_to 'Back', #{users}_path %>
EOF

gsub_file 'app/views/layouts/application.html.erb', /^\s+{{header}}\s*$/i, <<-EOF
<% if signed_in? -%>
    Logged in as: <%= h current_#{user}.username %>
<% else -%>
    &nbsp;
<% end -%>
EOF

gsub_file 'app/views/layouts/application.html.erb', /^\s+{{navigation}}\s*$/i, <<-EOF
    <ul>
      <li><%= link_to 'Home', root_path %></li>
<% if signed_in? -%>
  <% if current_#{user}.admin? -%>
      <li><%= link_to 'Roles', roles_path %></li>
      <li><%= link_to '#{users.capitalize}', #{users}_path %></li>
  <% end -%>
      <li><%= link_to('Profile', current_#{user}) %></li>
      <li><%= link_to('Logout', logout_path) %></li>
<% else -%>
      <li><%= link_to('Login', login_path)  %></li>
<% end -%>
    </ul>
EOF

route <<-EOF
resources :roles
  resources :#{users} do
    get :become, :on => :member
  end
  resources :#{user}_sessions, :only => [:new, :create, :destroy]

  match '/login'  => 'user_sessions#new'
  match '/logout' => 'user_sessions#destroy'
EOF

application "  config.filter_parameters += [:password_confirmation]"

password = 'password' #xxx ask for this

append_file 'db/seeds.rb', <<-EOF
role = Role.create(:name => 'admin')
#{user} = #{User}.new(:username => 'admin', :password => '#{password}')
#{user}.password_confirmation = #{user}.password
#{user}.roles << role
#{user}.save
EOF

rake 'db:migrate'
rake 'db:setup'
