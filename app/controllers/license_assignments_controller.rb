# app/controllers/license_assignments_controller.rb

class LicenseAssignmentsController < ApplicationController
  before_action :set_account
  before_action :load_assignment_data, only: [ :index ]

  def index
    # Just render
  end

  def create
    service = LicenseAssignmentService.new(@account)
    result = service.bulk_assign(
      product_ids: params[:product_ids],
      user_ids: params[:user_ids]
    )

    respond_to do |format|
      if result[:success]
        format.html {
          redirect_to account_license_assignments_path(@account),
                      notice: result[:message]
        }
        format.turbo_stream {
          flash.now[:notice] = result[:message]
          load_assignment_data
          render turbo_stream: [
            turbo_stream.replace("flash-messages", partial: "license_assignments/flash"),
            turbo_stream.replace("product-licenses-list", partial: "license_assignments/product_list", locals: { products_with_licenses: @products_with_licenses }),
            turbo_stream.replace("current-assignments-table", partial: "license_assignments/assignments_table", locals: { current_assignments: @current_assignments })
          ]
        }
      else
        format.html {
          flash.now[:alert] = result[:message]
          load_assignment_data
          render :index, status: :unprocessable_entity
        }
        format.turbo_stream {
          flash.now[:alert] = result[:message]
          load_assignment_data
          render turbo_stream: [
            turbo_stream.replace("flash-messages", partial: "license_assignments/flash"),
            turbo_stream.replace("product-licenses-list", partial: "license_assignments/product_list", locals: { products_with_licenses: @products_with_licenses }),
            turbo_stream.replace("current-assignments-table", partial: "license_assignments/assignments_table", locals: { current_assignments: @current_assignments })
          ]
        }
      end
    end
  end

  def bulk_destroy
    service = LicenseAssignmentService.new(@account)
    result = service.bulk_unassign(assignment_ids: params[:assignment_ids])

    respond_to do |format|
      if result[:success]
        format.html {
          redirect_to account_license_assignments_path(@account),
                      notice: result[:message]
        }
        format.turbo_stream {
          flash.now[:notice] = result[:message]
          load_assignment_data
          render turbo_stream: [
            turbo_stream.replace("flash-messages", partial: "license_assignments/flash"),
            turbo_stream.replace("product-licenses-list", partial: "license_assignments/product_list", locals: { products_with_licenses: @products_with_licenses }),
            turbo_stream.replace("current-assignments-table", partial: "license_assignments/assignments_table", locals: { current_assignments: @current_assignments })
          ]
        }
      else
        format.html {
          redirect_to account_license_assignments_path(@account),
                      alert: result[:message]
        }
        format.turbo_stream {
          flash.now[:alert] = result[:message]
          load_assignment_data
          render turbo_stream: [
            turbo_stream.replace("flash-messages", partial: "license_assignments/flash"),
            turbo_stream.replace("product-licenses-list", partial: "license_assignments/product_list", locals: { products_with_licenses: @products_with_licenses }),
            turbo_stream.replace("current-assignments-table", partial: "license_assignments/assignments_table", locals: { current_assignments: @current_assignments })
          ]
        }
      end
    end
  end

  private

    def set_account
      @account = Account.find(params[:account_id])
    end

  def load_assignment_data
    @products_with_licenses = @account.products
                                      .joins(:subscriptions)
                                      .where("subscriptions.expires_at > ?", Time.current)
                                      .distinct
                                      .order(:name)
                                      .map do |product|
      total_licenses = Subscription.total_licenses_for(@account.id, product.id)
      used_licenses = LicenseAssignment.where(
        account_id: @account.id,
        product_id: product.id
      ).count

      {
        product: product,
        total_licenses: total_licenses,
        used_licenses: used_licenses,
        remaining_licenses: total_licenses - used_licenses
      }
    end

    @users = @account.users.order(:name)
    @current_assignments = @account.license_assignments
                                   .includes(:user, :product)
                                   .order("products.name, users.name")
  end
end
