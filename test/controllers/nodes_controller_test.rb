require "test_helper"

class NodesControllerTest < ActionController::TestCase
  def node
    @node ||= nodes :one
  end

  def test_index
    get :index
    assert_response :success
    assert_not_nil assigns(:nodes)
  end

  def test_new
    get :new
    assert_response :success
  end

  def test_create
    assert_difference("Node.count") do
      post :create, node: { ancestry: node.ancestry, book_id: node.book_id, kind: node.kind, name: node.name }
    end

    assert_redirected_to node_path(assigns(:node))
  end

  def test_show
    get :show, id: node
    assert_response :success
  end

  def test_edit
    get :edit, id: node
    assert_response :success
  end

  def test_update
    put :update, id: node, node: { ancestry: node.ancestry, book_id: node.book_id, kind: node.kind, name: node.name }
    assert_redirected_to node_path(assigns(:node))
  end

  def test_destroy
    assert_difference("Node.count", -1) do
      delete :destroy, id: node
    end

    assert_redirected_to nodes_path
  end
end
