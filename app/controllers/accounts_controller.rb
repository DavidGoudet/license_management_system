class AccountsController < ApplicationController
  before_action :set_account, only: [ :show, :edit, :update, :destroy ]

    def index
      @accounts = Account.all.order(:name)
    end

    def show
      @users_count = @account.users.count
      @subscriptions_count = @account.subscriptions.count
      @assignments_count = @account.license_assignments.count
    end

    def new
      @account = Account.new
    end

    def create
      @account = Account.new(account_params)

      if @account.save
        redirect_to @account, notice: "Account was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @account.update(account_params)
        redirect_to @account, notice: "Account was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @account.destroy
      redirect_to accounts_url, notice: "Account was successfully destroyed."
    end

    private

      def set_account
        @account = Account.find(params[:id])
      end

    def account_params
      params.require(:account).permit(:name)
    end
end
