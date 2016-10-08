require "test_helper"

class NodeTest < ActiveSupport::TestCase
  def node
    @node ||= Node.new
  end

  def test_valid
    assert node.valid?
  end
end
