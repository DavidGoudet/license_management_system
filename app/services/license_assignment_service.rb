class LicenseAssignmentService
  class AssignmentError < StandardError; end

    def initialize(account)
      @account = account
    end

    # Assign multiple products to multiple users
    # Returns: { success: true/false, assignments: [], errors: [] }
    def bulk_assign(product_ids:, user_ids:)
      product_ids = Array(product_ids).reject(&:blank?).map(&:to_i)
      user_ids = Array(user_ids).reject(&:blank?).map(&:to_i)

      return error_result("Please select at least one product") if product_ids.empty?
      return error_result("Please select at least one user") if user_ids.empty?

      products = @account.products.where(id: product_ids)
      users = @account.users.where(id: user_ids)

      return error_result("Invalid products selected") if products.count != product_ids.count
      return error_result("Invalid users selected") if users.count != user_ids.count

      validation_result = validate_licenses_available(products, users)
      return validation_result unless validation_result[:success]

      assignments = []

      ActiveRecord::Base.transaction do
        products.each do |product|
          users.each do |user|
            next if user.has_license_for?(product)

            assignment = LicenseAssignment.create!(
              account: @account,
              user: user,
              product: product
            )
            assignments << assignment
          end
        end
      end

      if assignments.empty?
        return {
          success: true,
          assignments: [],
          errors: [],
          message: "No licenses were assigned - all selected users already have the selected products"
        }
      end

      {
        success: true,
        assignments: assignments,
        errors: [],
        message: "Successfully assigned #{assignments.count} license(s)"
      }

    rescue ActiveRecord::RecordInvalid => e
      error_result(e.record.errors.full_messages.join(", "))
    rescue AssignmentError => e
      error_result(e.message)
    rescue StandardError => e
      error_result("An unexpected error occurred: #{e.message}")
    end

    # Unassign multiple licenses
    def bulk_unassign(assignment_ids:)
      assignment_ids = Array(assignment_ids).reject(&:blank?).map(&:to_i)

      return error_result("Please select at least one assignment") if assignment_ids.empty?

      assignments = @account.license_assignments.where(id: assignment_ids)
      count = assignments.count

      ActiveRecord::Base.transaction do
        assignments.destroy_all
      end

      {
        success: true,
        assignments: [],
        errors: [],
        message: "Successfully removed #{count} license(s)"
      }

    rescue StandardError => e
      error_result("Failed to remove licenses: #{e.message}")
    end

    private

      def validate_licenses_available(products, users)
        errors = []

        products.each do |product|
          # Get total available licenses for this product
          total_licenses = Subscription.total_licenses_for(@account.id, product.id)

          # Count currently used licenses
          used_licenses = LicenseAssignment.where(
            account_id: @account.id,
            product_id: product.id
          ).count

          # Count how many new assignments we're trying to make
          new_assignments_count = users.count do |user|
            !user.has_license_for?(product)
          end

          available = total_licenses - used_licenses

          if new_assignments_count > available
            errors << "#{product.name}: Only #{available} license(s) available, " \
                      "but trying to assign #{new_assignments_count}"
          end
        end

        if errors.any?
          error_result(errors.join("; "))
        else
          { success: true, errors: [] }
        end
      end

    def error_result(message)
      {
        success: false,
        assignments: [],
        errors: [ message ],
        message: message
      }
    end
end
