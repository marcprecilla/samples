class OffersController < ApplicationController
  http_basic_authenticate_with name: 'admin', password: 'titssp4a'

  skip_before_filter :authenticate, :accept_terms, :complete_onboarding, :verify_subscription

  def index
    @offers = Offer.all
  end

  def show
    @offer = Offer.find_by_uuid(params[:id])
  end

  def new
    @offer = Offer.new
    @stripe_plans = Stripe::Plan.all.sort {|x,y| x.name <=> y.name}
  end

  def create
    @offer = Offer.create(params[:offer])
    @offer.save

    redirect_to offers_path
  end

  def edit
    @offer = Offer.find_by_uuid(params[:id])
    @stripe_plans = Stripe::Plan.all.sort {|x,y| x.name <=> y.name}
  end

  def update
    @offer = Offer.find_by_uuid(params[:id])
    @offer.update_attributes(params[:offer])

    redirect_to offers_path
  end

  def destroy
    @offer = Offer.find_by_uuid(params[:id])
    @offer.destroy

    redirect_to offers_path
  end
end
