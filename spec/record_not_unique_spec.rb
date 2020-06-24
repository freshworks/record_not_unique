# frozen_string_literal: true

require 'spec_helper'

describe RecordNotUnique, use_connection: true do

  it "rescues ActiveRecord::RecordNotUnique exceptions as activerecord errors" do
    company = Company.create(name: 'test')
    dupe = Company.create(name: 'test')
    
    expect(dupe.save).to eql false
    expect(dupe.errors.messages.keys).to contain_exactly(:name)
    expect(dupe.errors[:name].first).to match /has already been taken/
  end

  it "raises when used with ! methods like save!" do
    expect { 
      Company.create!(name: 'test') 
    }.to raise_exception(ActiveRecord::RecordNotUnique)
  end

  it "When unique contraint is voilated by a composite index" do
    company = Company.first
    user = User.create(name: 'foo', username: 'foo', company_id: company.id)
    dupe = User.create(name: 'bar', username: 'foo', company_id: company.id)
    
    expect(dupe.save).to eql(false)
    expect(dupe.errors.messages.keys).to contain_exactly(:username)
    expect(dupe.errors.full_messages.to_sentence).to match /#{company.name}/
  end

  it "Works for multiple indexes" do
    company1 = Company.first
    company2 = Company.create(name: 'test2')
    
    user = User.create(name: 'foo', username: 'foo', company_id: company2.id)
    dupe = User.create(name: 'foo', username: 'bar', company_id: company2.id)
    
    expect(dupe.save).to eql(false)
    expect(dupe.errors.messages.keys).to contain_exactly(:name)
    expect(dupe.errors.full_messages.to_sentence).to match /has already been taken/
  end
end