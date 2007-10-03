class CardnameController < ApplicationController
  helper :wagn, :card 
  cache_sweeper :card_sweeper
  before_filter :load_card, :edit_ok    
  
  def update
    @old_card = @card.clone
    if @card.update_attributes params[:card]
      render :action=>'view'
    elsif @card.errors.on(:confirmation_required)
      @confirm = true   
      @card.confirm_rename=true
      @card.update_link_ins = true
      render :action=>'edit', :status=>422
    else 
      @request_type='html'
      render_card_errors(@card)
    end
  end

=begin
  def confirm
    @action = 'confirm'
    if params[:card] and name=params[:card][:name]
      @card.name = name
    end
    render :action=>'edit'
  end
=end

end
