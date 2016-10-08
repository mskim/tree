module NodesHelper
  def nested_nodes(nodes)
    nodes.map do |node, sub_nodes|
      render(node) + content_tag(:div, nested_nodes(sub_nodes), :class => "nested_nodes")
    end.join.html_safe
  end
 
end
