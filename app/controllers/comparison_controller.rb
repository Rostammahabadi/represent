class ComparisonController < ApplicationController

  def index
    bill_id = params[:bill]
    selected_subject = params[:topic]
    congress_id = params[:id]
    @rep = HouseMember.where(congress_id: congress_id).first || Senator.where(congress_id: congress_id).first
    if bill_id
      @bill = Bill.where(bill_id: bill_id).first
      if @bill.nil?
        flash[:alert] = "This bill does not exist"
        redirect_to "/bills?name=#{@rep.full_name}&congress_id=#{congress_id}"
      end
    end
    bill = Bill.where(bill_id: bill_id).first
    all_bills = Bill.where(primary_subject: selected_subject)

    if bill && @rep.class == HouseMember && bill.house_bill_vote
      @bill = bill
    elsif bill && @rep.class == Senator && bill.senate_bill_vote
      @bill = bill
    elsif bill
      flash[:failure] = "This bill was not voted on by #{@rep.full_name}"
      redirect_to "/bills?name=#{@rep.full_name}&congress_id=#{congress_id}"
    elsif all_bills && @rep.class == HouseMember
      @bills = all_bills.find_all do |bill|
        bill.house_bill_vote
      end
    elsif all_bills
      @bills = all_bills.find_all do |bill|
        bill.senate_bill_vote
      end
    end
  end

  private

  def comparison_params
    params.permit(:bill, :topic, :id)
  end
end
