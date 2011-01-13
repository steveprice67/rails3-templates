route 'root :to => "pages#index"'

file 'app/controllers/pages_controller.rb', <<-EOF
class PagesController < ApplicationController
  def index
  end
end
EOF

file 'app/views/pages/index.html.erb', <<-EOF
<% title 'pages#index' -%>
<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed a purus eu mauris convallis tempor. Pellentesque feugiat porttitor facilisis. Morbi nec leo sem, ac facilisis nisi. Donec porttitor, neque elementum bibendum commodo, risus magna varius velit, vel vestibulum risus ligula a ante. Nullam viverra molestie dapibus. Suspendisse potenti. Morbi et enim eget lectus placerat malesuada et ut odio. In hac habitasse platea dictumst. Suspendisse ipsum lacus, dignissim eu sagittis eu, viverra sit amet libero. Maecenas ac justo ut dui commodo cursus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Morbi nec augue sit amet nisl vehicula imperdiet. Mauris justo purus, volutpat vitae facilisis sed, sagittis a lectus. Donec vel sem mi.</p>
<p>Praesent rutrum augue quis est malesuada tempor. Aliquam dui eros, ultrices at adipiscing ullamcorper, pellentesque quis arcu. Ut convallis, risus a lobortis varius, augue nisi ullamcorper augue, at tincidunt eros quam non magna. Mauris sodales ornare aliquet. Phasellus at neque justo, et interdum urna. Pellentesque laoreet porta felis eget blandit. Quisque dictum sollicitudin nibh at hendrerit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse scelerisque lectus vel lectus condimentum sollicitudin. Pellentesque fringilla sapien eget quam pretium aliquam. Mauris porta malesuada nisl ac ultrices. Curabitur feugiat nisl non sapien pellentesque congue. Nullam neque arcu, suscipit tincidunt posuere non, fringilla eu lectus. Nullam tincidunt adipiscing magna, eu bibendum est placerat vitae. Cras gravida ultrices tortor eget ullamcorper. Morbi fermentum, ante eu porta venenatis, nibh eros aliquet erat, eu consectetur orci tortor ac neque. Aliquam augue lorem, imperdiet vel aliquet non, dapibus vitae elit. Donec sed nulla tellus. In hac habitasse platea dictumst. In hac habitasse platea dictumst.</p>
<p>Sed quis tortor elit, in congue lacus. Cras magna turpis, posuere nec tincidunt vitae, sodales sit amet enim. Suspendisse potenti. Curabitur commodo ligula leo. Suspendisse arcu nulla, interdum at porta ut, dapibus in enim. Aliquam lacus sem, condimentum eget bibendum ut, sollicitudin sed arcu. Pellentesque venenatis cursus tortor ut molestie. Pellentesque at lacus ante, in interdum urna. Sed auctor urna id erat suscipit auctor. Duis volutpat dui a lacus blandit et gravida nulla facilisis. Mauris pellentesque viverra arcu, sed cursus tellus feugiat quis. Mauris a dui vitae mi eleifend porttitor non vel libero. Etiam in lacus velit, nec pulvinar tortor.</p>
EOF
