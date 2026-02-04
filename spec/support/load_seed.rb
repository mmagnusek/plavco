module LoadSeed
  def admin
    @admin ||= User.find_by(email_address: 'john@plavci.cz')
  end

  def user
    @user ||= User.find_by(email_address: 'jane@plavci.cz')
  end

  def trainer
    @trainer ||= Trainer.find_by(name: 'Plavco')
  end
end
