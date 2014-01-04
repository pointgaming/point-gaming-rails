module Admin
  class GroupsController < Admin::ApplicationController
    before_filter :ensure_group, except: [:index, :new, :create]
    before_filter :ensure_groups, only: [:index, :new, :edit]
    before_filter :ensure_permissions, only: [:new, :edit]
    authorize_resource

    respond_to :html, :json

    def sub_layout
      "admin_groups"
    end

    def index
      respond_with(@groups)
    end

    def new
      @group = Group.new
      respond_with(@group)
    end

    def edit
      @group_users = @group.users
      respond_with(@group)
    end

    def create
      @group = Group.new(params[:group])

      @group.save
      respond_with(@group, location: edit_admin_group_path(@group))
    end

    def update
      params[:group][:permissions] ||= []

      @group.update_attributes(params[:group])
      respond_with(@group, location: edit_admin_group_path(@group))
    end

    protected

    def ensure_group
      @group = Group.find(params[:id])
    end

    def ensure_groups
      @groups = Group.order_by(sort_order: "ASC").all
    end

    def ensure_permissions
      @permissions = Permission.where(default: nil)
    end
  end
end
