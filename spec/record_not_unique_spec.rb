# frozen_string_literal: true

require 'spec_helper'

describe RecordNotUnique, use_connection: true do
  it 'when unique contraint is voilated rescues ActiveRecord::RecordNotUnique exceptions as activerecord errors' do
    Company.create(name: 'test')
    dupe = Company.create(name: 'test')

    expect(dupe.save).to be false
    expect(dupe.errors.messages.keys).to contain_exactly(:name)
    expect(dupe.errors[:name].first).to match(/has already been taken/)
  end

  it 'when used with ! methods like save! raises error and stores error messages' do
    dupe = Company.new(name: 'test')
    expect do
      dupe.save!
    end.to raise_exception(ActiveRecord::RecordInvalid)
    expect(dupe.errors.messages.keys).to contain_exactly(:name)
    expect(dupe.errors[:name].first).to match(/has already been taken/)
  end

  it 'when unique contraint is voilated by a composite index' do
    company = Company.first
    User.create(name: 'foo', username: 'foo', company_id: company.id)
    dupe = User.create(name: 'bar', username: 'foo', company_id: company.id)

    expect(dupe.save).to be(false)
    expect(dupe.errors.messages.keys).to contain_exactly(:username)
    expect(dupe.errors.full_messages.to_sentence).to match(/#{company.name}/)
  end

  it 'when model has multiple indexes' do
    Company.first
    company2 = Company.create(name: 'test2')

    User.create(name: 'foo', username: 'foo', company_id: company2.id)
    dupe = User.create(name: 'foo', username: 'bar', company_id: company2.id)

    expect(dupe.save).to be(false)
    expect(dupe.errors.messages.keys).to contain_exactly(:name)
    expect(dupe.errors.full_messages.to_sentence).to match(/has already been taken/)
  end
end
